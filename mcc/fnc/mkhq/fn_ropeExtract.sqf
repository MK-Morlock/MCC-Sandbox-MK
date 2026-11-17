/*
	MCCMK_fnc_ropeExtract - (server) the Commander Console's "Rope extraction" for squads: [groups]. For each, a helicopter
	of its faction with the fewest passenger seats that fit it comes from out of sight (about 4.5 km, routed round the
	mission areas), hovers 25 m over its leader, and they're winched up (MCCMK_fnc_ropeSquadUp - players use "Request
	pickup rope"); then it lands them at the side's nearest HQ or F.O.B. (MCCMK_fnc_sarHome) and flies off the map.
*/
params [["_grps", []]];
if (!isServer) exitWith {};
{
	[_x] spawn {
		params ["_g"];
		private _us = (units _g) select {alive _x && {vehicle _x == _x}};
		if (_us isEqualTo []) exitWith {};
		private _side = side _g;
		private _fac = faction (leader _g);
		private _list = [_fac, "transportheli"] call MCCMK_fnc_factionAssets;
		if (_list isEqualTo [] && {missionNamespace getVariable ["MCCMK_vanillaFallback", true]}) then {_list = [["O_Heli_Light_02_unarmed_F"], ["B_Heli_Transport_01_F"], ["I_Heli_Transport_02_F"]] select ([east, west, independent] find _side max 0)};
		if (_list isEqualTo []) exitWith {};
		private _fit = (_list apply {[[_x] call MCCMK_seatsOf, _x]}) select {(_x select 0) >= count _us};
		private _cls = if (_fit isNotEqualTo []) then {_fit sort true; (_fit select 0) select 1} else {private _a = _list apply {[[_x] call MCCMK_seatsOf, _x]}; _a sort false; (_a select 0) select 1};
		private _lp = getPos (leader _g);
		private _p = [_lp, 4500, false] call MCCMK_fnc_sarSpawnPos;
		if (_p isEqualTo []) then {_p = _lp getPos [4500, random 360]};
		private _h = createVehicle [_cls, [_p select 0, _p select 1, 80], [], 0, "FLY"];
		_h setPosASL [_p select 0, _p select 1, ((getTerrainHeightASL _p) max 0) + 80];
		private _crew = createVehicleCrew _h;
		[_h, _fac] call MCCMK_fnc_factionCrew;
		_crew setBehaviour "CARELESS";
		_crew setCombatMode "BLUE";
		[_h, _side, "Rope extraction helicopter"] call MCCMK_fnc_supportAir;	//(MK) the "Support aircraft" options
		_h flyInHeight 50;
		[_h, _lp, 50, ((missionNamespace getVariable ["MCCMK_wpHover", 20]) max 5) min 50] spawn MCCMK_fnc_heliGlide;
		["INFO", "ropeExtract", "%1: %2 for %3 men from %4 m", [groupId _g, _cls, count _us, round (_p distance2D _lp)]] call MCC_fnc_log;
		{_h doMove _x; waitUntil {sleep 2; !alive _h || {(_h distance2D _x) < 300}}} forEach ([_p, _lp] call MCCMK_fnc_safeRoute);
		private _ta = time + 480;
		waitUntil {sleep 2; _h doMove (getPos (leader _g)); !alive _h || {(_h distance2D (leader _g)) < 120} || {time > _ta}};
		if (!alive _h) exitWith {};
		private _hov = ((missionNamespace getVariable ["MCCMK_wpHover", 20]) max 5) min 50;
		private _lp2 = getPos (leader _g);
		[_h, [_lp2 select 0, _lp2 select 1, 0], _hov, {alive _h}] call MCCMK_fnc_heliHoverAtMove;	//(MK) the pilot ordered at the spot
		[_h, true] call MCCMK_fnc_heliDoorsAll;	//(MK) doors and ramp: open while they're lifted, shut as it leaves
		[_us, _h] call MCCMK_fnc_ropeSquadUp;
		[_h, false] call MCCMK_fnc_heliDoorsAll;
		[_h] remoteExec ["MCCMK_fnc_heliHold", _h];
		private _aboard = (crew _h) select {_x in (units _g)};
		_h flyInHeight 50;
		if (_aboard isNotEqualTo []) then {
			private _lz = [_side, getPos _h, false] call MCCMK_fnc_sarHome;
			private _pad = createVehicle ["Land_HelipadEmpty_F", _lz, [], 0, "CAN_COLLIDE"];
			{_h doMove _x; waitUntil {sleep 2; !alive _h || {(_h distance2D _x) < 300}}} forEach ([getPos _h, _lz] call MCCMK_fnc_safeRoute);
			_h doMove _lz;
			private _tl = time + 300;
			waitUntil {sleep 2; !alive _h || {(_h distance2D _lz) < 150} || {time > _tl}};
			// landed and waiting: nobody put out - ordered out (F keys) by a player leader, or by their own AI leader
			[_h, 180] spawn MCCMK_fnc_heliDoorWatch;	//(MK) doors and ramp open as it touches down, shut as it takes off
			_h land "GET OUT";	// (down and staying down, engine running - "GET IN" is a low hover; it climbed away)
			private _tg = time + 60;
			waitUntil {sleep 1; !alive _h || {isTouchingGround _h} || {((getPosATL _h) select 2) < 1.5} || {time > _tg}};
			_h flyInHeight 0;
			{if (!isPlayer (leader group _x) || {((leader group _x) distance _h) > 100}) then {unassignVehicle _x; [_x] orderGetIn false; doGetOut _x}} forEach _aboard;
			waitUntil {sleep 2; !alive _h || {((crew _h) findIf {alive _x && {_x in _aboard}}) < 0}};
			deleteVehicle _pad;
			sleep 5;
		};
		[_h] call MCCMK_fnc_heliLeave;
		{deleteVehicle _x} forEach ((units _crew) + [_h]);
		deleteGroup _crew;
	};
} forEach _grps;
