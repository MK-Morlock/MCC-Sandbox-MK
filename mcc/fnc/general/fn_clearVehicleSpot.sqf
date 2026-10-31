params [["_pos", [], [[]]], ["_class", "", [""]], ["_maxDist", 56, [0]]];
if (count _pos < 2 || {_class == ""}) exitWith {[]};
private _size = sizeOf _class;
if (_size <= 0) then {_size = 8};
private _ok = {
	params ["_p"];
	!(surfaceIsWater _p)
	&& {
		private _h = getTerrainHeightASL _p;
		private _r = (_size * 0.5) max 2;
		([0, 45, 90, 135, 180, 225, 270, 315] findIf {private _q = _p getPos [_r, _x]; (surfaceIsWater _q) || {(abs ((getTerrainHeightASL _q) - _h)) > (_r * 0.36)}}) < 0
	}
	&& {((surfaceNormal _p) select 2) > 0.94}
	&& {!([_p] call MCC_fnc_posOnBuilding)}
	&& {((_p nearEntities [["LandVehicle", "Air", "Ship", "StaticWeapon"], (_size * 0.6) + 4]) select {alive _x}) isEqualTo []}
	&& {(((nearestTerrainObjects [_p, ["BUILDING", "HOUSE", "WALL", "FENCE", "BUNKER", "FORTRESS", "CHURCH", "CHAPEL", "TOWER", "ROCK", "ROCKS", "TREE", "SMALL TREE"], (_size * 0.5) + 30, false, true]) + (nearestObjects [_p, ["Static"], (_size * 0.5) + 30])) findIf {
		((_x distance2D _p) - (((boundingBoxReal _x) select 2) * 0.5)) < ((_size * 0.5) + 1)
	}) < 0}
};
private _cands = [[_pos select 0, _pos select 1, 0]];
{
	private _d = _x;
	if (_d <= _maxDist) then {
		for "_a" from 0 to 315 step 45 do {_cands pushBack (_pos getPos [_d, _a + random 20])};
	};
} forEach [8, 16, 24, 32, 44, 56];
private _res = [];
{
	private _e = _x findEmptyPosition [0, 6, _class];
	if (count _e > 0 && {[_e] call _ok}) exitWith {_res = _e};
} forEach _cands;
_res
