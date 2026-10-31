params [
	["_budget", 0, [0]],
	["_zoneNumber", 0, [0, ""]],
	["_arrayGroup", [], [[]]],
	["_arrayUnits", [], [[]]],
	["_side", sideUnknown, [sideUnknown]],
	["_center", [], [[]]],
	["_radius", 0, [0]]
];
if ((count _arrayUnits == 0 && {count _arrayGroup == 0}) || {count _center < 2}) exitWith {0};
if ((missionNamespace getVariable ["MCC_MWBoats", 0]) == 1) exitWith {0};
private _c = [_center select 0, _center select 1, 0];
private _R = _radius + 1000;
private _step = 20 max (_R / 90);
private _dirs = [0, 45, 90, 135, 180, 225, 270, 315];
private _cellsUsed = createHashMap;
private _pts = [];
for "_dx" from -_R to _R step _step do {
	for "_dy" from -_R to _R step _step do {
		private _p = [(_c select 0) + _dx, (_c select 1) + _dy, 0];
		if ((_p distance2D _c) > _R) then {continue};
		if ((_p select 0) < 0 || {(_p select 1) < 0} || {(_p select 0) > worldSize} || {(_p select 1) > worldSize}) then {continue};
		if !(surfaceIsWater _p) then {continue};
		if ((getTerrainHeightASL _p) > -2) then {continue};
		if ((_dirs findIf {!(surfaceIsWater (_p getPos [15, _x]))}) >= 0) then {continue};
		private _key = format ["%1_%2", floor ((_p select 0) / 100), floor ((_p select 1) / 100)];
		if (_key in _cellsUsed) then {continue};
		if !((nearestTerrainObjects [_p, ["ROCK", "ROCKS"], 15, false, true]) isEqualTo []) then {continue};
		if ((_dirs findIf {private _d = _x; ([250, 500, 750, 1000] findIf {!(surfaceIsWater (_p getPos [_x, _d]))}) >= 0}) < 0) then {continue};
		if ((_pts findIf {(_x distance2D _p) < 100}) >= 0) then {continue};
		_cellsUsed set [_key, true];
		_pts pushBack _p;
	};
};
if (missionNamespace getVariable ["MCC_debug", false]) then {
	["DEBUG", "MCC_fnc_MWSpawnBoats", "%1 boat water points within %2 m of %3", [count _pts, round _R, mapGridPosition _c]] call MCC_fnc_log;
};
if (count _pts < 3) exitWith {0};

private _legOK = {
	params ["_a", "_b"];
	private _n = ceil ((_a distance2D _b) / 15);
	private _ok = true;
	for "_i" from 1 to _n do {
		private _q = _a vectorAdd ((_b vectorDiff _a) vectorMultiply (_i / _n));
		if (!(surfaceIsWater _q) || {(getTerrainHeightASL _q) > -2} || {([0, 45, 90, 135, 180, 225, 270, 315] findIf {!(surfaceIsWater (_q getPos [10, _x]))}) >= 0}) exitWith {_ok = false};
	};
	_ok
};

private _placed = 0;
private _used = [];
private _tries = 0;
while {_placed < _budget && {_tries < 12}} do {
	_tries = _tries + 1;
	private _free = _pts select {private _p = _x; (_used findIf {(_x distance2D _p) < 150}) < 0};
	if (_free isEqualTo []) exitWith {};
	private _start = selectRandom _free;
	_used pushBack _start;
	private _grp = grpNull;
	if (random 1 < 0.5 && {count _arrayGroup > 0}) then {
		private _g = selectRandom _arrayGroup;
		if ((15 * (_g select 1)) <= _budget) then {
			_grp = [_start, _side, call compile (_g select 2)] call BIS_fnc_spawnGroup;
			_placed = _placed + (15 * (_g select 1));
		};
	};
	if (isNull _grp && {count _arrayUnits > 0}) then {
		_grp = ([_start, random 360, (selectRandom _arrayUnits) select 1, _side] call BIS_fnc_spawnVehicle) select 2;
		_placed = _placed + 15;
	};
	if (isNull _grp) then {continue};

	private _things = units _grp;
	{_things pushBackUnique (vehicle _x)} forEach (units _grp);
	{_x allowDamage false} forEach _things;
	_things spawn {sleep 8; {if (!isNull _x) then {_x allowDamage true}} forEach _this};

	for "_i" from ((count waypoints _grp) - 1) to 0 step -1 do {deleteWaypoint [_grp, _i]};
	private _route = [_start];
	private _cur = _start;
	for "_k" from 1 to 4 do {
		private _pool = (_pts select {private _q = _x; ((_q distance2D _cur) <= 600) && {(_route findIf {(_x distance2D _q) < 200}) < 0}}) call BIS_fnc_arrayShuffle;
		private _i = _pool findIf {[_cur, _x] call _legOK};
		if (_i < 0) exitWith {};
		_cur = _pool select _i;
		_route pushBack _cur;
	};
	while {count _route > 1 && {!([_route select ((count _route) - 1), _route select 0] call _legOK)}} do {_route deleteAt ((count _route) - 1)};
	if (count _route > 1) then {
		{
			private _wp = _grp addWaypoint [_x, 0];
			_wp setWaypointType "MOVE";
			if (_forEachIndex == 0) then {_wp setWaypointBehaviour "SAFE"; _wp setWaypointSpeed "LIMITED"};
		} forEach ((_route select [1]) + [_route select 0]);
		private _cycle = _grp addWaypoint [_route select 1, 0];
		_cycle setWaypointType "CYCLE";
	};
	if (missionNamespace getVariable ["MCC_debug", false]) then {
		["DEBUG", "MCC_fnc_MWSpawnBoats", "boat group %1 (%2) at %3 - coastal patrol of %4 points", [groupId _grp, typeOf (vehicle leader _grp), mapGridPosition _start, count _route]] call MCC_fnc_log;
	};
};
_placed
