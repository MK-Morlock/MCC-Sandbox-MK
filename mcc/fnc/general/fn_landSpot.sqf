params [["_c", [], [[]]], ["_r", 100, [0]], ["_tries", 30, [0]], ["_clear", 15, [0]]];
if (count _c < 2) exitWith {[]};
private _covered = {
	params ["_p"];
	private _top = (AGLToASL [_p select 0, _p select 1, 0]) vectorAdd [0, 0, 60];
	private _bottom = (AGLToASL [_p select 0, _p select 1, 0]) vectorAdd [0, 0, -1];
	private _hits = lineIntersectsSurfaces [_top, _bottom, objNull, objNull, true, 3, "GEOM", "NONE"];
	private _soft = nearestTerrainObjects [_p, ["TREE", "SMALL TREE", "BUSH"], 20, false, true];
	(_hits findIf {!isNull (_x select 2) && {!((_x select 2) in _soft)} && {!((_x select 2) isKindOf "CAManBase")}}) >= 0
};
private _ok = {
	params ["_p"];
	!(surfaceIsWater _p)
	&& {((surfaceNormal _p) select 2) > 0.85}
	&& {([0, 45, 90, 135, 180, 225, 270, 315] findIf {surfaceIsWater (_p getPos [_clear, _x])}) < 0}
	&& {((nearestTerrainObjects [_p, ["ROCK", "ROCKS"], _clear + 25, false, true]) findIf {((_x distance2D _p) - (((boundingBoxReal _x) select 2) * 0.5)) < 3}) < 0}
	&& {!([_p] call MCC_fnc_posOnBuilding)}
	&& {!([_p] call _covered)}
};
private _res = [];
for "_t" from 1 to (_tries max 1) do {
	private _p = _c getPos [_r * sqrt (random 1), random 360];
	_p = [_p select 0, _p select 1, 0];
	if ([_p] call _ok) exitWith {_res = _p};
};
_res
