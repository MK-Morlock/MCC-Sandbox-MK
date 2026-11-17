/*
 ANC_fnc_shorePost
*/
params ["_unit"];
private _objs = (nearestTerrainObjects [_unit, ["TREE", "SMALL TREE", "ROCK", "ROCKS", "FENCE", "WALL", "HIDE", "BUSH", "POWER LINES", "BUILDING", "HOUSE"], 3, true])
    + ((nearestObjects [_unit, ["Static"], 3]) select {!(_x isKindOf "Land_HelipadEmpty_F")});
if (count _objs == 0) exitWith {objNull};
private _best = objNull;
private _bd = 1e9;
{if ((_unit distance _x) < _bd) then {_bd = _unit distance _x; _best = _x}} forEach _objs;
_best
