/*
	MCCMK_fnc_taruPickup - (server) Pickup for a squad's Taru pod drop (the Commander Console's Pod drop / Winch drop):
	enough Tarus with pods for the squad come from 4.5-5 km out - round the mission areas - and land at the LZ, side by side
	60 m apart. Nobody boards by himself: the leader orders his men into the pods (an AI soldier ordered into a full pod is
	sent to the next one with room). The leader's "Take off" (aboard), "Send helicopters" (within 50 m of the LZ, staying
	behind) or "Cancel pickup" (MCCMK_fnc_pickupGo) decides; then every loaded Taru flies round the mission areas to the
	line-up point and makes the drop (MCC_fnc_realParadrop), the empty ones fly away. The LZ is marked for the side (and
	smoked, if the setting is on).
	Also a paradrop's Pickup (_mode "para"): the helicopter or VTOL chosen (or one with enough seats) lands, the men board
	it, and it makes the paradrop.
	[group, [line start, line end], method (0 parachute, 1 winch), pod type ("bench" / "covered"), LZ (or [] - automatic),
	 mode ("taru" / "para"), the paradrop aircraft ("" - automatic), the paradrop's chute opening [manual?, AI height]]
*/
params [["_grp", grpNull], ["_line", []], ["_method", 0], ["_podType", "bench"], ["_lzWant", []], ["_mode", "taru"], ["_acCls", ""], ["_paraH", [0, 120]], ["_dd", []]];
private _para = _mode in ["para", "rope", "boat"];	// a paradrop or a fast-rope: the men board a helicopter (or VTOL) itself
//(MK) Boat pickup ("boat"): a boat carrier lands on the water by the squad's boat and waits until the boat is in its bay (or
// they're aboard); Take off flies it to the point and lands it on the water there to let the boat out (MCCMK_fnc_pickupGo)
private _boat = _mode == "boat";
if (!isServer || {isNull _grp} || {count _line < 2}) exitWith {};
private _leader = leader _grp;
private _side = side _grp;
private _men = (units _grp) select {alive _x};
private _seats = [8, 16] select (_podType == "covered");
// a paradrop: the helicopter or VTOL chosen, else the side's one with the fewest seats that still takes the squad
private _isLander = {params ["_c"]; isClass (configFile >> "CfgVehicles" >> _c) && {(_c isKindOf "Helicopter") || {getNumber (configFile >> "CfgVehicles" >> _c >> "vtol") > 0}}};
if (_para) then {
	if (_boat) then {
		// a boat carrier that can sit on the water (MCCMK_fnc_canFloat): the fewest seats that take the squad
		private _need = count ((units _grp) select {alive _x});
		private _best = ""; private _bs = 1e9; private _fb = ""; private _fs = -1;
		private _fac = faction (leader _grp);
		private _cands = ([_fac, "HeliTransport"] call MCCMK_fnc_pool) + ([_fac, "Heli"] call MCCMK_fnc_pool) + ([_fac, "Plane"] call MCCMK_fnc_pool);
		if (missionNamespace getVariable ["MCCMK_vanillaFallback", true]) then {
			_cands append ([["O_Heli_Transport_04_covered_F", "O_T_VTOL_02_infantry_dynamicLoadout_F"], ["B_Heli_Transport_03_F", "B_T_VTOL_01_infantry_F"], ["I_Heli_Transport_02_F"], []] select (([east, west, independent, civilian] find (side _grp)) max 0));
		};
		_cands = (_cands arrayIntersect _cands) select {isClass (configFile >> "CfgVehicles" >> _x) && {[_x] call MCCMK_fnc_boatCarrier} && {(getNumber (configFile >> "CfgVehicles" >> _x >> "maxFordingDepth")) >= 3}};
		{
			private _c = _x;
			if ([_c] call MCCMK_fnc_canFloat) then {
				private _s = [_c, "allCargo"] call MCC_fnc_crewCount;
				if (_s >= _need && {_s < _bs}) then {_bs = _s; _best = _c};
				if (_s > _fs) then {_fs = _s; _fb = _c};
			};
		} forEach _cands;
		["INFO", "MCCMK_fnc_taruPickup", "Boat pickup for %1 (%2): %3 carrier class(es) to choose from, chose %4", [groupId _grp, _fac, count _cands, [_fb, _best] select (_best != "")]] call MCC_fnc_log;
		_acCls = [_fb, _best] select (_best != "");
	};
	if (!_boat && {!([_acCls] call _isLander)}) then {
		private _sideN = [east, west, independent, civilian] find (side _grp);
		private _need = count ((units _grp) select {alive _x});
		private _best = ""; private _bs = 1e9; private _fb = ""; private _fs = -1;
		{
			private _c = configName _x;
			private _s = [_c, "allCargo"] call MCC_fnc_crewCount;
			if (_s > 0 && {getNumber (_x >> "isUav") == 0}) then {
				if (_s >= _need && {_s < _bs}) then {_bs = _s; _best = _c};
				if (_s > _fs) then {_fs = _s; _fb = _c};
			};
		} forEach (format ["getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'side') == %1} && {(configName _x) isKindOf 'Helicopter'}", _sideN] configClasses (configFile >> "CfgVehicles"));
		_acCls = [_fb, _best] select (_best != "");
	};
	_seats = ([_acCls, "allCargo"] call MCC_fnc_crewCount) max 1;
};
if (_para && {_acCls == ""}) exitWith {
	["WARN", "MCCMK_fnc_taruPickup", "no helicopter for a %1 pickup", [_mode]] call MCC_fnc_log;
	if (_boat) then {["Boat pickup: your side has no helicopter that can carry a boat"] remoteExec ["MCCMK_fnc_hint", leader _grp]};
};
private _n = (ceil ((count _men) / _seats)) max 1 min 3;
// the LZ: aimed at the leader (or the clicked spot) and chosen the way Arma's own landing chooses - that spot if it's flat
// and clear enough for the aircraft, else the nearest that is; the others 35 m apart; an invisible helipad on each, so
// the pilot can't go to a base or shop helipad instead
private _base = if (_lzWant isEqualType [] && {count _lzWant >= 2}) then {_lzWant} else {getPosATL _leader};
private _lzAim = [_base select 0, _base select 1, 0];
private _id = format ["pk%1", round (diag_tickTime * 10)];
private _acRad = if (_para) then {[10, 15] select (getNumber (configFile >> "CfgVehicles" >> _acCls >> "vtol") > 0)} else {11};	// clearance: a helicopter's rotor, a VTOL's wings; the Taru's rotor
// the Taru (as the pod drops pick it) and its pod
private _podFaction = faction _leader;
private _podCarriers = [_podFaction, "podCarrier"] call MCC_fnc_factionVehicles;
private _sideL = ["O", "B", "I", "B"] select (([east, west, independent, civilian] find _side) max 0);
private _black = (missionNamespace getVariable [format ["MCC_taruLivery%1", _sideL], 0]) == 1;
private _cls = if (_para) then {_acCls} else {call {
	private _m = _podCarriers select {(((toUpper _x) find "BLACK") >= 0) isEqualTo _black};
	if (count _m > 0) exitWith {selectRandom _m};
	if (count _podCarriers > 0) exitWith {selectRandom _podCarriers};
	private _own = format ["MCC_%1_Heli_Transport_04%2_F", _sideL, ["", "_black"] select _black];
	if (isClass (configFile >> "CfgVehicles" >> _own)) exitWith {_own};
	["O_Heli_Transport_04_F", "O_Heli_Transport_04_black_F"] select _black
}};
private _spots = if (_boat) then {
	// on the water, 40 m ahead of the boat (60 m apart if more than one)
	private _bv = vehicle _leader;
	if !(_bv isKindOf "Ship") then {private _i = (units _grp) findIf {(vehicle _x) isKindOf "Ship"}; if (_i >= 0) then {_bv = vehicle ((units _grp) select _i)}};
	private _a = _bv getPos [40, getDir _bv];
	(_n call {private _r = []; for "_k" from 0 to (_this - 1) do {private _q = _a getPos [60 * _k, (getDir _bv) + 90]; _r pushBack [_q select 0, _q select 1, 0]}; _r})
} else {[_lzAim, _n, _acRad, 35] call MCCMK_fnc_lzSpots};
private _lz = _spots select 0;
// where they come from: 4.5 km out, away from the drop, with no player within 1.5 km
private _from = (_lz getDir (_line select 0)) + 180;
private _spawn = _lz getPos [4500, _from];
for "_k" from 1 to 11 do {
	if (((allPlayers findIf {(_x distance2D _spawn) < 1500}) < 0)) exitWith {};
	_spawn = _lz getPos [4500, _from + 30 * _k];
};
_spawn = [_spawn select 0, _spawn select 1, 120];
private _inRoute = [_spawn, _lz] call MCCMK_fnc_safeRoute;
private _tarus = [];
for "_i" from 0 to (_n - 1) do {
	private _slot = _spots select _i;
	private _pad = createVehicle ["Land_HelipadEmpty_F", _slot, [], 0, "CAN_COLLIDE"];
	private _t = [_cls, _spawn getPos [40 * _i, _from + 90], _slot, 120, true, civilian] call MCC_fnc_createPlane;
	[_t, _podFaction] call MCCMK_fnc_factionCrew;
	[_t, _side, ["Pickup helicopter", "Boat pickup helicopter"] select _boat] call MCCMK_fnc_supportAir;	//(MK) the "Support aircraft" options
	private _pod = _t;	// a paradrop: the men board the aircraft itself
	if (_para) then {
		_t lockDriver true;
		{_t lockTurret [_x, true]} forEach (allTurrets [_t, false]);
	} else {
		if (_side != east) then {_t execVM "\a3\Air_F_Heli\Heli_Transport_04\Scripts\Heli_Transport_04_basic_black.sqf"};
		_pod = (([["MCC_podBench", "MCC_podBench_black"], ["MCC_podCovered", "MCC_podCovered_black"]] select (_podType == "covered")) select (((toUpper _cls) find "BLACK") >= 0)) createVehicle [0, 0, 0];
		_pod setPosASL ((getPosASL _t) vectorAdd [0, 0, -6]);
		_pod attachTo [_t, [0, 0, -1.2]];
		[_pod, _t] remoteExecCall ["disableCollisionWith", 0, _pod];
		_t setVariable ["MCC_attachedPod", _pod, true];
		_t lock true;
	};
	(group _t) setVariable ["MCC_dropFor", _side, true];
	_t flyInHeight 80;
	private _g = group _t;
	{private _w = _g addWaypoint [_x, 0]; _w setWaypointType "MOVE"; _w setWaypointBehaviour "CARELESS"; _w setWaypointCombatMode "BLUE"; _w setWaypointSpeed "FULL"; _w setWaypointCompletionRadius 150} forEach (_inRoute select [0, (count _inRoute) - 1]);
	if (_boat) then {
		//(MK) Boat pickup: down to the water on the way in, and settled onto it at the LZ (MCCMK_fnc_heliWaterLand)
		[_t, _slot] spawn {
			params ["_t", "_slot"];
			waitUntil {sleep 1; !alive _t || {(_t distance2D _slot) < 900}};
			if (!alive _t) exitWith {};
			private _g = group (driver _t);
			for "_w" from ((count (waypoints _g)) - 1) to 0 step -1 do {deleteWaypoint [_g, _w]};
			_t doMove _slot;
			[_t, _slot, {alive (_this select 0)}] call MCCMK_fnc_heliWaterDescent;
			if (alive _t) then {[_t, _slot, {true}, 10, true] call MCCMK_fnc_heliWaterLand};
		};
	} else {
	private _w = _g addWaypoint [_slot, 0];
	_w setWaypointType "MOVE";
	_w setWaypointBehaviour "CARELESS";
	_w setWaypointCombatMode "BLUE";
	_w setWaypointStatements ["true", "(vehicle this) land 'GET IN'"];
	[_t, 900] spawn MCCMK_fnc_heliDoorWatch;	//(MK) doors, ramp (and the pod's) open as it lands at the LZ, shut as it takes off
	};
	_tarus pushBack [_t, _pod, _pad];
};
private _st = createHashMapFromArray [["state", "wait"], ["tarus", _tarus], ["grp", _grp], ["line", _line], ["method", _method], ["podType", _podType], ["lz", _lz], ["aim", _lz], ["spawn", _spawn], ["mode", _mode], ["cls", _cls], ["paraH", _paraH], ["leaderObj", _leader], ["dd", _dd]];
missionNamespace setVariable [format ["MCCMK_pickup_%1", _id], _st];
private _what = switch (true) do {case (_boat): {"Boat pickup"}; case (_mode == "rope"): {"Fast-rope"}; case (_para): {"Paradrop"}; default {["Paradrop", "Winch drop"] select (_method == 1)}};
_st set ["what", _what];
// the LZ marked for the side, and the leader's actions
["start", _id, _lz, _what, owner _leader, _tarus apply {_x select 1}] remoteExec ["MCCMK_fnc_pickupClient", _side];
["INFO", "MCCMK_fnc_taruPickup", "%1 for %2: %3 x %4%5, LZ %6 (%7 m from where it was aimed), from %8 (%9 detours round mission areas)", [_what, groupId _grp, _n, _cls, if (_para) then {format [" (%1 seats)", _seats]} else {format [" with %1 pods", _podType]}, mapGridPosition _lz, round (_lz distance2D _lzAim), mapGridPosition _spawn, (count _inRoute) - 1]] call MCC_fnc_log;
// waiting at the LZ: smoke (if on) when the first is near; an AI man ordered into a full pod sent to one with room
[_id, _st] spawn {
	params ["_id", "_st"];
	private _smoked = false;
	private _landed = false;
	private _idle = -1;	// since when nobody has been aboard (from the landing)
	while {(_st get "state") == "wait"} do {
		private _tarus = (_st get "tarus") select {alive (_x select 0)};
		// the squad's leader changed (died, respawned, left, handed over): the actions go to the new one
		private _ld = leader (_st get "grp");
		if !(_ld isEqualTo (_st getOrDefault ["leaderObj", objNull])) then {
			_st set ["leaderObj", _ld];
			["unlead", _id] remoteExec ["MCCMK_fnc_pickupClient", side (_st get "grp")];
			if (isPlayer _ld) then {
				["lead", _id, _st get "lz", _st get "what", owner _ld, (_st get "tarus") apply {_x select 1}] remoteExec ["MCCMK_fnc_pickupClient", _ld];
				if (_landed) then {["move", _id, _st get "lz"] remoteExec ["MCCMK_fnc_pickupClient", _ld]};
			};
		};
		// 10 minutes on the ground with nobody aboard: they leave by themselves
		if (_landed) then {
			private _any = (_tarus findIf {private _e = _x; (((crew (_e select 1)) + (if (isNil "MCCMK_fltAttached") then {[]} else {crew ([_e select 0] call MCCMK_fltAttached)})) findIf {alive _x && {group _x != group (driver (_e select 0))}}) >= 0}) >= 0;	//(MK) a boat in its bay counts
			if (_any || {_idle < 0}) then {_idle = time};
			if (time - _idle > 600) exitWith {["cancel", _id] call MCCMK_fnc_pickupGo; ["INFO", "MCCMK_fnc_taruPickup", "pickup %1: nobody aboard for 10 minutes - they leave", [_id]] call MCC_fnc_log};
		};
		// the first Taru down: the LZ is where it landed (the marker, "Send helicopters", the smoke)
		if (!_landed) then {
			private _dn = _tarus findIf {(isTouchingGround (_x select 0) || {((_x select 0) getVariable ["MCCMK_waterState", ""]) == "afloat"}) && {((_x select 0) distance2D (_st get "lz")) < 400}};	//(MK) afloat counts
			if (_dn >= 0) then {
				_landed = true;
				private _p = getPosATL ((_tarus select _dn) select 0);
				_st set ["lz", [_p select 0, _p select 1, 0]];
				["move", _id, _st get "lz"] remoteExec ["MCCMK_fnc_pickupClient", side (_st get "grp")];
				["INFO", "MCCMK_fnc_taruPickup", "pickup %1: landed at %2 (%3 m from where it was aimed)", [_id, mapGridPosition _p, round (_p distance2D (_st get "aim"))]] call MCC_fnc_log;
			};
		};
		if (_tarus isEqualTo []) exitWith {["cancel", _id] call MCCMK_fnc_pickupGo};
		//(MK) Boat pickup for an AI-led squad: once a carrier is down, their boat is sent in and loads itself (MCCMK_fnc_aiBoatLoad);
		// once it's in the bay with the squad in it, they go - no Take off from a player
		if (_landed && {(_st getOrDefault ["mode", ""]) == "boat"} && {!isPlayer (leader (_st get "grp"))}) then {
			private _g = _st get "grp";
			private _bi = (units _g) findIf {(vehicle _x) isKindOf "Ship"};
			private _bt = if (_bi < 0) then {objNull} else {vehicle ((units _g) select _bi)};
			private _c = (_tarus select 0) select 0;
			if (!isNull _bt && {isNull (attachedTo _bt)} && {!(_st getOrDefault ["aiLoading", false])}) then {
				_st set ["aiLoading", true];
				[_bt, _c, _st] spawn {params ["_bt", "_c", "_st"]; [_bt, _c] call MCCMK_fnc_aiBoatLoad; _st set ["aiLoading", false]};
			};
			if (!isNull _bt && {(attachedTo _bt) isEqualTo _c} && {((units _g) findIf {alive _x && {!((vehicle _x) isEqualTo _bt)}}) < 0}) exitWith {["go", _id] call MCCMK_fnc_pickupGo};
		};
		if (!_smoked && {missionNamespace getVariable ["MCCMK_pickupSmoke", false]} && {(_tarus findIf {((_x select 0) distance2D (_st get "lz")) < 600}) >= 0}) then {
			_smoked = true;
			"SmokeShellPurple" createVehicle (_st get "lz");
		};
		private _pods = _tarus apply {_x select 1};
		{
			private _u = _x;
			private _av = assignedVehicle _u;
			if (!isPlayer _u && {_av in _pods} && {vehicle _u == _u} && {(_av emptyPositions "cargo") == 0} && {group _u != group (driver _av)}) then {
				private _o = _pods findIf {(_x emptyPositions "cargo") > 0};
				if (_o >= 0) then {
					unassignVehicle _u;
					_u assignAsCargo (_pods select _o);
					[_u] orderGetIn true;
				};
			};
		} forEach ((units (_st get "grp")) select {alive _x});
		sleep 2;
	};
};
