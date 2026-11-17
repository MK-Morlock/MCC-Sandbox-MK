/*
	MCCMK_fnc_fastRopeInsert - (server) the Commander Console's Fast-rope waypoint: the groups go in by helicopter, fly
	round the mission areas (MCCMK_fnc_safeRoute) and fast-rope at the point (MCCMK_fnc_fastRopeRun). Flying: helicopters
	start 4.5 km out (no player within 1.5 km) with the men aboard - the side's helicopter with the fewest seats that
	takes them (else the largest, as many as needed, up to 3). Pickup (MCCMK_fnc_pickupGo): the helicopters that picked
	them up, with whoever boarded. Several helicopters rope 35 m apart.
	The approach follows the line drawn: the helicopters come in from behind the rope point along it (round the mission
	areas to a lead-in 1.5 km back, then 400 m back), hover side by side across it and leave along it. Each one's green
	dot goes once its men are down. [groups, rope point, [[helicopter, the men], ...] (Pickup) or [], heading, drop id]
*/
params [["_grps", []], ["_pt", [0, 0, 0]], ["_preset", []], ["_hd", -1], ["_dd", []]];
if (!isServer) exitWith {};
_pt = [_pt select 0, _pt select 1, 0];
private _loads = +_preset;
if (_loads isEqualTo []) then {
	_grps = _grps select {!isNull _x};
	if (_grps isEqualTo []) exitWith {};
	private _men = [];
	{_men append ((units _x) select {alive _x && {vehicle _x == _x}})} forEach _grps;
	if (_men isEqualTo []) exitWith {};
	private _side = side (_grps select 0);
	private _sideN = [east, west, independent, civilian] find _side;
	private _best = ""; private _bs = 1e9; private _fb = ""; private _fs = -1;
	{
		private _c = configName _x;
		private _s = [_c, "allCargo"] call MCC_fnc_crewCount;
		if (_s > 0 && {getNumber (_x >> "isUav") == 0}) then {
			if (_s >= count _men && {_s < _bs}) then {_bs = _s; _best = _c};
			if (_s > _fs) then {_fs = _s; _fb = _c};
		};
	} forEach (format ["getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'side') == %1} && {(configName _x) isKindOf 'Helicopter'}", _sideN] configClasses (configFile >> "CfgVehicles"));
	private _cls = [_fb, _best] select (_best != "");
	if (_cls == "") exitWith {["WARN", "MCCMK_fnc_fastRopeInsert", "no transport helicopter for the side", []] call MCC_fnc_log};
	private _seats = ([_cls, "allCargo"] call MCC_fnc_crewCount) max 1;
	private _n = ((ceil ((count _men) / _seats)) max 1) min 3;
	private _from = if (_hd >= 0) then {_hd + 180 + (random 60) - 30} else {random 360};	// from behind the approach
	private _sp = _pt getPos [4500, _from];
	for "_k" from 1 to 11 do {
		if (((allPlayers findIf {(_x distance2D _sp) < 1500}) < 0)) exitWith {};
		_sp = _pt getPos [4500, _from + 30 * _k];
	};
	for "_i" from 0 to (_n - 1) do {
		private _h = [_cls, (_sp getPos [40 * _i, (_sp getDir _pt) + 90]) vectorAdd [0, 0, 100], _pt, 100, true, civilian] call MCC_fnc_createPlane;
		[_h, faction leader (_grps select 0)] call MCCMK_fnc_factionCrew;
		[_h, _side, "Fast-rope helicopter"] call MCCMK_fnc_supportAir;	//(MK) the "Support aircraft" options
		(group _h) setVariable ["MCC_dropFor", _side, true];	// (the map's blue icon - MCCMK_fnc_airIcons)
		_h lockDriver true;
		private _load = _men select [_i * _seats, _seats];
		{if (local _x) then {_x moveInCargo _h} else {[_x, _h] remoteExec ["moveInCargo", _x]}} forEach _load;
		_loads pushBack [_h, _load];
	};
};
if (_loads isEqualTo []) exitWith {};
private _nL = count _loads;
if (_hd < 0) then {_hd = ((_loads select 0) select 0) getDir _pt};
// side by side across the approach; a green dot on each (replacing the line's one)
private _spots = [];
for "_i" from 0 to (_nL - 1) do {
	private _s = _pt getPos [35 * (_i - (_nL - 1) / 2), _hd + 90];
	_spots pushBack [_s select 0, _s select 1, 0];
};
if (count _dd == 2) then {["set", _dd select 0, _spots] remoteExec ["MCCMK_fnc_dropDots", _dd select 1]};
{
	_x params ["_h", "_load"];
	private _spot = _spots select _forEachIndex;
	private _away = _spot getPos [4500, _hd];	// leaving along the line
	// round the mission areas to a lead-in 1.5 km behind the spot on the line, then 400 m behind it: in along the line
	private _leadIn = _spot getPos [1500, _hd + 180];
	private _align = _spot getPos [400, _hd + 180];
	private _route = ([getPosATL _h, [_leadIn select 0, _leadIn select 1, 0]] call MCCMK_fnc_safeRoute) + [[_align select 0, _align select 1, 0]];
	// its dot: gone once its men are down (or dead, or it's lost)
	if (count _dd == 2) then {
		[_h, _load, _dd, _forEachIndex] spawn {
			params ["_h", "_load", "_dd", "_i"];
			private _t = time + 900;
			sleep 5;
			waitUntil {sleep 3; time > _t || {!alive _h && {(_load findIf {alive _x && {vehicle _x == _h}}) >= 0}} || {(_load findIf {alive _x && {(vehicle _x != _x) || {((getPosATL _x) select 2) > 2}}}) < 0}};
			[_dd, _i] call MCCMK_fnc_dropDone;
		};
	};
	[_h, _spot, _load, _away, _route] spawn {
		params ["_h", "_spot", "_load", "_away", "_route"];
		private _g = group (driver _h);
		_h land "NONE";
		for "_w" from (count waypoints _g) - 1 to 0 step -1 do {deleteWaypoint [_g, _w]};
		_h flyInHeight 50;
		//(MK) down to its hover height on the way in (MCCMK_fnc_heliGlide), not after it has stopped
		[_h, _spot, 50, ((missionNamespace getVariable ["MCCMK_wpHover", 20]) max 5) min 50] spawn MCCMK_fnc_heliGlide;
		{private _w = _g addWaypoint [_x, 0]; _w setWaypointType "MOVE"; _w setWaypointBehaviour "CARELESS"; _w setWaypointCombatMode "BLUE"; _w setWaypointSpeed "FULL"; _w setWaypointCompletionRadius 200} forEach _route;
		// the Evac's way: the last waypoint ON the rope point (10 m), full speed; the rope sequence once it has arrived
		_h setVariable ["wp_complete", false];
		private _wl = _g addWaypoint [_spot, 0];
		_wl setWaypointType "MOVE";
		_wl setWaypointBehaviour "CARELESS";
		_wl setWaypointCombatMode "BLUE";
		_wl setWaypointSpeed "FULL";
		_wl setWaypointCompletionRadius 10;
		_wl setWaypointStatements ["true", "(vehicle this) setVariable ['wp_complete', true];"];
		//(MK) Fast Rope Pos makes its OWN final approach (a waypoint 90 m past the spot -
		// MCCMK_fnc_heliRopePos): handed over 350 m out, still flying in along the line
		private _t = time + 600;
		waitUntil {sleep 1; !alive _h || {!alive (driver _h)} || {time > _t} || {_h getVariable ["wp_complete", false]} || {(_h distance2D _spot) < 350}};
		if (!alive _h || {!alive (driver _h)}) exitWith {};
		[_h, _spot, _load, _away] call MCCMK_fnc_fastRopeRun;
	};
} forEach _loads;
["INFO", "MCCMK_fnc_fastRopeInsert", "fast-rope at %1: %2 helicopter(s) (%3), %4", [mapGridPosition _pt, _nL, typeOf ((_loads select 0) select 0), ["flying in", "from the pickup"] select (_preset isNotEqualTo [])]] call MCC_fnc_log;
