params [["_pos", [0, 0], [[]]], ["_dir", 0, [0]], ["_t", 0, [0]], ["_side", sideUnknown, [sideUnknown]], ["_ignore", objNull, [objNull]]];
([_t] call MCCMK_fnc_shipCfg) params ["", "", "_minD", "_half"];
private _depth = round (-(getTerrainHeightASL _pos));
if !(surfaceIsWater _pos) exitWith {[false, "not at sea", _depth]};
private _least = 1e9;
{
	private _w = [(_pos select 0) + (_x select 0) * (cos _dir) + (_x select 1) * (sin _dir), (_pos select 1) - (_x select 0) * (sin _dir) + (_x select 1) * (cos _dir)];
	_least = _least min (-(getTerrainHeightASL _w));
} forEach [[0, 0], [0, (_half select 1) * 0.9], [0, -(_half select 1) * 0.9], [(_half select 0) * 0.8, 0], [-(_half select 0) * 0.8, 0]];
if (_least < _minD) exitWith {[false, format ["too shallow: %1 m, needs %2 m", round _least, _minD], _depth]};
private _gap = missionNamespace getVariable ["MCCMK_shipGap", 10];
private _boxOf = {
	params ["_c", "_d", "_tt"];
	private _h = ((([_tt] call MCCMK_fnc_shipCfg) select 3) apply {_x + _gap / 2});
	[[[1, 1], [1, -1], [-1, -1], [-1, 1]] apply {[(_c select 0) + (_x select 0) * (_h select 0) * (cos _d) + (_x select 1) * (_h select 1) * (sin _d), (_c select 1) - (_x select 0) * (_h select 0) * (sin _d) + (_x select 1) * (_h select 1) * (cos _d)]}, [[sin _d, cos _d], [cos _d, -(sin _d)]]]
};
private _overlap = {
	params ["_a", "_b"];
	private _sep = false;
	{
		private _ax = _x;
		private _pa = (_a select 0) apply {(_x select 0) * (_ax select 0) + (_x select 1) * (_ax select 1)};
		private _pb = (_b select 0) apply {(_x select 0) * (_ax select 0) + (_x select 1) * (_ax select 1)};
		if ((selectMax _pa) < (selectMin _pb) || {(selectMax _pb) < (selectMin _pa)}) exitWith {_sep = true};
	} forEach ((_a select 1) + (_b select 1));
	!_sep
};
private _mine = [_pos, _dir, _t] call _boxOf;
private _others = ((missionNamespace getVariable ["MCC_staticShips", []]) select {!isNull _x && {_x != _ignore}}) apply {
	private _tt = _x getVariable ["MCC_ShipType", 0];
	[getPos _x, (getDir _x) + ([0, 0, 0, 180] select ((_tt max 0) min 3)), _tt]
};
_others append (((missionNamespace getVariable ["MCCMK_shipInbound", []]) select {count _x >= 4}) apply {[_x select 0, _x select 3, _x select 2]});
if ((_others findIf {[_mine, _x call _boxOf] call _overlap}) >= 0) exitWith {[false, format ["closer than %1 m to another ship", _gap], _depth]};
private _enemy = (_pos nearEntities [["Man", "LandVehicle", "Air", "Ship"], 1000]) findIf {alive _x && {(side group _x) != civilian} && {[_side, side group _x] call BIS_fnc_sideIsEnemy}};
if (_enemy >= 0) exitWith {[false, "enemy within 1 km", _depth]};
private _range = missionNamespace getVariable ["MCCMK_shipRange", 3000];
private _near = true;
if (_range > 0) then {
	private _bases = (([_side] call MCCMK_fnc_spawnPoints) select {!(_x getVariable ["MCC_isLHD", false])}) apply {getPos _x};
	private _hq = missionNamespace getVariable [format ["MCC_START_%1", _side], []];
	if (_hq isEqualType [] && {count _hq > 1} && {!(_hq isEqualTo [0, 0, 0])}) then {_bases pushBack _hq};
	_near = (_bases findIf {(_x distance2D _pos) < _range}) >= 0;
};
if (!_near) exitWith {[false, format ["more than %1 km from your HQ or an F.O.B.", (round (_range / 100)) / 10], _depth]};
[true, "", _depth]
