/*
	MCCMK_fnc_airPatrol - server: Air Patrol from the Commander Console's CAS list. A jet or a helicopter flies in from the
	map edge along the line the commander drew (a helicopter at full speed) and patrols the area round its end on a chain of random waypoints (like
	GAIA's aircraft), renewed as it finishes them: a jet within 4 km at 800 m, a helicopter within 1.5 km at about 90 m.
	(MK) The aircraft chosen in the console (or, given none, one of the faction's), loaded as chosen: Air - air-to-air
	missiles on every pylon that takes them; Ground - ground weapons only; Mixed - one air-to-air pair for self-defence,
	ground weapons on the rest. Guns are always kept. Radar and data link are on, and Arma's AI does the rest - it engages
	what it finds. Its time on station (jets 8 min, helicopters 6 min) starts when it reaches the patrol area; then, or
	once it's out of missiles, it flies back off the map edge and is removed.
	[side, target position, entry position (map edge), CAS type, aircraft class, crew faction, loadout]
*/
if (!isServer) exitWith {_this remoteExec ["MCCMK_fnc_airPatrol", 2]};
params ["_side", "_target", "_entry", ["_kind", ""], ["_class", ""], ["_crewFaction", "", [""]], ["_loadout", "", [""]]];
private _chosen = _class != "" && {isClass (configFile >> "CfgVehicles" >> _class)};
private _heli = if (_chosen) then {_class isKindOf "Helicopter"} else {((toLower _kind) find "heli") >= 0};
// the loadout: named in the entry (one added from the MCC console); else as chosen in the panel; from an old-style
// entry its role; else Mixed
private _named = switch (true) do {
	case (((toLower _kind) find "(air)") >= 0): {"Air"};
	case (((toLower _kind) find "(ground)") >= 0): {"Ground"};
	case (((toLower _kind) find "(mixed)") >= 0): {"Mixed"};
	default {""};
};
if (_named != "") then {_loadout = _named};
if !(_loadout in ["Air", "Ground", "Mixed"]) then {
	private _k = toLower _kind;
	_loadout = switch (true) do {
		case ((_k find "(air)") >= 0 || {(_k find "air-to-air") >= 0}): {"Air"};
		case ((_k find "(ground)") >= 0 || {(_k find "air-to-ground") >= 0}): {"Ground"};
		default {"Mixed"};
	};
};
private _sideKey = [["EAST", "GUER"] select (_side isEqualTo resistance), "WEST"] select (_side isEqualTo west);
if (_class == "" || {!isClass (configFile >> "CfgVehicles" >> _class)}) then {
	_class = if (_heli) then {
		createHashMapFromArray [["WEST", "B_Heli_Attack_01_dynamicLoadout_F"], ["EAST", "O_Heli_Attack_02_dynamicLoadout_F"], ["GUER", "I_Heli_light_03_dynamicLoadout_F"]] get _sideKey
	} else {
		createHashMapFromArray [["WEST", "B_Plane_Fighter_01_F"], ["EAST", "O_Plane_Fighter_02_F"], ["GUER", "I_Plane_Fighter_04_F"]] get _sideKey
	};
};
//(MK) the faction's own aircraft first (MCCMK_fnc_poolOwn - its pools, or a sibling's): an armed helicopter, or a jet that
// carries air-to-air missiles (in its weapons or its pylons' standard load); the configured aircraft when it has none
if (_crewFaction != "" && {!_chosen}) then {	// an aircraft chosen in the console is never swapped
	private _aaCap = {
		params ["_c"];
		private _cf = configFile >> "CfgVehicles" >> _c;
		private _mags = getArray (_cf >> "magazines");
		{_mags append getArray (_x >> "magazines")} forEach ("true" configClasses (_cf >> "Turrets"));
		{_mags pushBack getText (_x >> "attachment")} forEach ("true" configClasses (_cf >> "Components" >> "TransportPylonsComponent" >> "pylons"));
		(_mags findIf {getNumber (configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _x >> "ammo") >> "airLock") >= 2}) >= 0
	};
	private _own = if (_heli) then {[_crewFaction, "HeliArmed"] call MCCMK_fnc_poolOwn} else {([_crewFaction, "Plane"] call MCCMK_fnc_poolOwn) select {[_x] call _aaCap}};
	if (_own isNotEqualTo []) then {_class = selectRandom _own};
};
private _alt = [800, 90] select _heli;
private _radius = [4000, 1500] select _heli;
private _onStation = [480, 360] select _heli;
//(MK) The helicopter starts 4.5 km beyond the patrol area's edge, in the direction clicked - out of sight, like the QRF
// helicopters (at the map edge it could be 20+ km away). Another direction if a player is within 1.5 km of that point.
if (_heli) then {
	private _pl = (allPlayers - (entities "HeadlessClient_F")) select {alive _x};
	private _d0 = _target getDir _entry;
	private _dist = _radius + 4500;
	private _best = _d0;
	private _bestFar = -1;
	{
		private _d = _d0 + _x;
		private _p = _target getPos [_dist, _d];
		private _near = 1e9;
		{_near = _near min (_x distance2D _p)} forEach _pl;
		if (_near >= 1500) exitWith {_best = _d; _bestFar = _near};
		if (_near > _bestFar) then {_bestFar = _near; _best = _d};
	} forEach [0, 30, -30, 60, -60, 90, -90, 120, -120, 150, -150, 180];
	_entry = _target getPos [_dist, _best];
};
// in the air from the start: height above the sea when over water (above the ground would be above the seabed)
private _spawnASL = [_entry select 0, _entry select 1, ((getTerrainHeightASL _entry) max 0) + _alt];
private _veh = createVehicle [_class, ASLToAGL _spawnASL, [], 0, "FLY"];
[_veh, "Air Patrol"] call MCCMK_fnc_airTrack;	//(MK) debug
_veh setDir (_entry getDir _target);
_veh setPosASL _spawnASL;
_veh setVelocityModelSpace [0, [150, 50] select _heli, 0];
_veh engineOn true;
private _grp = createGroup [_side, true];
(units (createVehicleCrew _veh)) joinSilent _grp;
[_veh, [_side, _crewFaction] select (_crewFaction != "")] call MCCMK_fnc_crewFix;	// the caller's faction flies it
// the jet: air-to-air missiles only (every pylon that can take them; the rest are emptied). The helicopter: air-to-ground
// only - each pylon its best ground-attack weapon (missiles first, then rockets), no air-to-air missiles. Both keep guns.
private _isAA = {
	params ["_mag"];
	private _ammo = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
	(getNumber (_ammo >> "airLock")) >= 2 || {((getNumber (_ammo >> "aiAmmoUsageFlags")) mod 512) >= 256}
};
private _agRank = {	// 0 missile, 1 rocket, 2 bomb or other ground weapon, -1 not air-to-ground
	params ["_mag"];
	if ([_mag] call _isAA) exitWith {-1};
	private _sim = toLower getText (configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _mag >> "ammo") >> "simulation");
	switch (true) do {
		case (_sim == "shotmissile"): {0};
		case (_sim == "shotrocket"): {1};
		case (_sim in ["shotsubmunitions", "shotbullet", "shotshell"]): {2};
		default {-1};
	};
};
//(MK) 0 IR-guided missile (fire and forget), 1 unguided rocket, 2 other guided missile (laser...), 3 other ground weapon
private _agKind = {
	params ["_mag"];
	if ([_mag] call _isAA) exitWith {-1};
	private _a = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
	private _sim = toLower getText (_a >> "simulation");
	private _ir = (getNumber (_a >> "irLock")) > 0;
	private _laser = (getNumber (_a >> "laserLock")) > 0;
	switch (true) do {
		case (_sim == "shotmissile" && {_ir} && {!_laser}): {0};
		case (_sim == "shotrocket"): {1};
		case (_sim == "shotmissile"): {2};
		case (_sim in ["shotsubmunitions", "shotbullet", "shotshell"]): {3};
		default {-1};
	}
};
private _hasGunner = (count (allTurrets [_veh, false])) > 0;
private _nPyl = count (getPylonMagazines _veh);
private _pc = "true" configClasses (configOf _veh >> "Components" >> "TransportPylonsComponent" >> "pylons");
private _aaOK = {params ["_i"]; ((_veh getCompatiblePylonMagazines _i) findIf {[_x] call _isAA}) >= 0};
//(MK) Mixed: one air-to-air pair for self-defence - the first pylon that takes an air-to-air missile and its mirror
// (the aircraft's config says which); with no mirror given, the last other pylon that takes one
private _aaPylons = [];
if (_loadout == "Mixed") then {
	{
		private _i = _forEachIndex + 1;
		if (_aaPylons isEqualTo [] && {[_i] call _aaOK}) then {
			_aaPylons = [_i];
			private _mi = getNumber (_x >> "mirroredMissilePos");
			if (_mi > 0 && {_mi != _i} && {[_mi] call _aaOK}) then {_aaPylons pushBack _mi};
		};
	} forEach _pc;
	if (count _aaPylons == 1) then {
		for "_j" from _nPyl to 1 step -1 do {
			if (count _aaPylons < 2 && {!(_j in _aaPylons)} && {[_j] call _aaOK}) then {_aaPylons pushBack _j};
		};
	};
};
//(MK) a helicopter's ground missile pair: the first other pylon that can take a missile, and its mirror; with no mirror
// given, the next pylon that can take a missile
private _missilePylons = [];
if (_heli && {_loadout != "Air"}) then {
	private _canMissile = {
		params ["_i"];
		!(_i in _aaPylons) && {((_veh getCompatiblePylonMagazines _i) findIf {([_x] call _agKind) in [0, 2]}) >= 0}
	};
	{
		private _i = _forEachIndex + 1;
		if (_missilePylons isEqualTo [] && {[_i] call _canMissile}) then {
			_missilePylons = [_i];
			private _mi = getNumber (_x >> "mirroredMissilePos");
			if (_mi > 0 && {_mi != _i} && {[_mi] call _canMissile}) then {_missilePylons pushBack _mi};
		};
	} forEach _pc;
	if (count _missilePylons == 1) then {
		for "_j" from 1 to _nPyl do {
			if (count _missilePylons < 2 && {!(_j in _missilePylons)} && {[_j] call _canMissile}) then {_missilePylons pushBack _j};
		};
	};
};
private _aaMags = [];
{
	private _pyl = _forEachIndex + 1;
	private _compat = _veh getCompatiblePylonMagazines _pyl;
	private _pick = "";
	private _turret = [-1];
	private _kinds = _compat apply {[[_x] call _agKind, _x]};
	switch (true) do {
		// air-to-air: every pylon (Air), or the self-defence pair (Mixed); a pylon that can't take one stays empty
		case (_loadout == "Air" || {_pyl in _aaPylons}): {
			private _ok = _compat select {[_x] call _isAA};
			if (_ok isNotEqualTo []) then {_pick = _ok select 0};
		};
		case (_heli): {
			//(MK) Mostly rockets, a few missiles: ONE left/right pair of pylons carries missiles (IR fire-and-forget if they
			// fit, else laser-guided - usable when someone lases the target), on 2-missile racks if there are any, else
			// single missiles; every other pylon a rocket pod. Missiles for the GUNNER (he fires them himself), rockets
			// for the PILOT (he lines up the rocket runs). A pylon that can't take its kind gets the other.
			private _missile = {
				params ["_kinds"];
				private _got = "";
				{
					private _k = _x;
					if (_got == "") then {
						private _c = (_kinds select {(_x select 0) == _k}) apply {[getNumber (configFile >> "CfgMagazines" >> (_x select 1) >> "count"), _x select 1]};
						private _pref = (_c select {(_x select 0) == 2}) + (_c select {(_x select 0) == 1}) + (_c select {!((_x select 0) in [1, 2])});
						if (_pref isNotEqualTo []) then {_got = (_pref select 0) select 1};
					};
				} forEach [0, 2];
				_got
			};
			private _rocket = {
				params ["_kinds"];
				private _r = _kinds select {(_x select 0) == 1};
				if (_r isEqualTo []) then {""} else {(_r select 0) select 1}
			};
			if (_pyl in _missilePylons) then {
				_pick = [_kinds] call _missile;
				if (_pick != "") then {_turret = [[-1], [0]] select _hasGunner} else {_pick = [_kinds] call _rocket};
			} else {
				_pick = [_kinds] call _rocket;
				if (_pick == "") then {_pick = [_kinds] call _missile; if (_pick != "") then {_turret = [[-1], [0]] select _hasGunner}};
			};
			if (_pick == "") then {
				private _o = _kinds select {(_x select 0) == 3};
				if (_o isNotEqualTo []) then {_pick = (_o select 0) select 1};
			};
		};
		default {
			// a jet's ground weapons: guided missiles and bombs first, then IR missiles, rockets, anything else
			{
				private _k = _x;
				if (_pick == "") then {
					private _m = _kinds select {(_x select 0) == _k};
					if (_m isNotEqualTo []) then {_pick = (_m select 0) select 1};
				};
			} forEach [2, 0, 1, 3];
		};
	};
	_veh setPylonLoadout [_pyl, _pick, true, _turret];
	if (_pick != "") then {_aaMags pushBackUnique _pick};
} forEach (getPylonMagazines _veh);
// radar and data link on; Arma's AI finds and engages targets itself
_veh setVehicleRadar 1;
_veh setVehicleReceiveRemoteTargets true;
_veh setVehicleReportRemoteTargets true;
_grp setCombatMode "RED";
_grp setBehaviour "AWARE";
_veh flyInHeight _alt;
private _wp = _grp addWaypoint [_target, 0];
_wp setWaypointType "MOVE";
// a helicopter flies in at full speed, back to normal once it's in the patrol area. (MK) In "aware" with open fire, Arma's
// helicopter AI slowed down to hunt for targets on the way, whatever its speed mode: it flies in careless, holding fire,
// held at its top speed, and only starts hunting once it's on station.
if (_heli) then {
	_grp setSpeedMode "FULL"; _wp setWaypointSpeed "FULL";
	_grp setBehaviour "CARELESS";
	_grp setCombatMode "BLUE";
	_veh forceSpeed ((getNumber (configFile >> "CfgVehicles" >> _class >> "maxSpeed")) / 3.6);
};
[format ["Air Patrol (%1) inbound.", getText (configFile >> "CfgVehicles" >> _class >> "displayName")]] remoteExec ["systemChat", _side];
["INFO", "MCCMK_fnc_airPatrol", "%1 for %2 at %3, from %4 | loadout %5, %6 min on station | pylons: %7", [_class, _side, mapGridPosition _target, mapGridPosition _entry, _loadout, _onStation / 60, _aaMags]] call MCC_fnc_log;
[_veh, _grp, _side, _target, _entry, _radius, _onStation, _aaMags, _alt, _heli] spawn {
	params ["_veh", "_grp", "_side", "_target", "_entry", "_radius", "_onStation", "_aaMags", "_alt", "_heli"];
	// a chain of random waypoints across the patrol area (like GAIA's aircraft), renewed when it's done
	private _chain = {
		{deleteWaypoint _x} forEachReversed (waypoints _grp);
		for "_i" from 1 to (6 + floor random 4) do {
			private _p = _target getPos [(_radius * 0.3) + random (_radius * 0.7), random 360];
			private _w = _grp addWaypoint [_p, 0];
			_w setWaypointType "MOVE";
			_w setWaypointCompletionRadius ([300, 100] select (_alt < 200));
		};
	};
	private _t0 = -1;
	private _why = "time on station over";
	while {alive _veh && {canMove _veh} && {({alive _x} count crew _veh) > 0}} do {
		if (_t0 < 0 && {(_veh distance2D _target) < _radius}) then {
			_t0 = time;
			_grp setSpeedMode "NORMAL";
			if (_heli) then {_veh forceSpeed -1; _grp setBehaviour "AWARE"; _grp setCombatMode "RED"};	//(MK) on station: hunting
			call _chain;
			["Air Patrol on station."] remoteExec ["systemChat", _side];
		};
		if (_t0 >= 0) then {
			if (time > _t0 + _onStation) exitWith {};
			if (_aaMags isNotEqualTo [] && {({((_x select 0) in _aaMags) && {(_x select 2) > 0}} count (magazinesAllTurrets _veh)) == 0}) exitWith {_why = (["out of missiles", "out of ammunition"] select _heli)};
			if ((currentWaypoint _grp) >= (count (waypoints _grp))) then {call _chain};
			_veh flyInHeight _alt;
		};
		if (_t0 >= 0 && {time > _t0 + _onStation || {_why != "time on station over"}}) exitWith {};
		sleep 3;
	};
	if (!alive _veh || {!canMove _veh}) exitWith {["Air Patrol lost."] remoteExec ["systemChat", _side]};
	[format ["Air Patrol leaving (%1).", _why]] remoteExec ["systemChat", _side];
	{deleteWaypoint _x} forEachReversed (waypoints _grp);
	_grp setCombatMode "BLUE";
	_grp setBehaviour "CARELESS";
	//(MK) out past the EDGE of the map the way it came, at its top speed; removed once beyond it (12 minutes at most)
	private _out = [getPosATL _veh, _target getDir _veh] call MCCMK_fnc_mapEdgeExit;
	private _w = _grp addWaypoint [_out, 0];
	_w setWaypointType "MOVE";
	if (_heli) then {_grp setSpeedMode "FULL"; _w setWaypointSpeed "FULL"; _veh forceSpeed ((getNumber (configOf _veh >> "maxSpeed")) / 3.6)};
	private _t1 = time;
	waitUntil {sleep 2; !alive _veh || {((((getPosATL _veh) select 0) < 0) || {((getPosATL _veh) select 1) < 0} || {((getPosATL _veh) select 0) > worldSize} || {((getPosATL _veh) select 1) > worldSize})} || {time > _t1 + 720}};
	{_veh deleteVehicleCrew _x} forEach crew _veh;
	deleteVehicle _veh;
	deleteGroup _grp;
};
