/*
    ANC_fnc_hullSidePoint
    The top of the boat's side (gunwale / rail) at a given distance along it, just outside the hull - where a cleat
    would be. Same method as the stem
    point: scans upwards from the waterline, looking in at the side, and stops
    when it misses or hits something set well in from the side (a cabin).
    [boat, y, side (1 = starboard, -1 = port)]
*/
params [["_boat", objNull, [objNull]], ["_y", 0, [0]], ["_side", 1, [0]], ["_unused", 0]];
(_boat call ANC_fnc_boatGeometry) params ["_cx", "", "", "_halfW", "_bottomZ", "_topZ", "_length", "_zWater"];
private _first = [];
private _top = [];
private _z = _zWater + 0.05;
private _zMax = (_zWater + 3.5) min _topZ;
while {_z <= _zMax} do {
    private _from = _boat modelToWorldWorld [_cx + (_side * (_halfW + 2)), _y, _z];
    private _to = _boat modelToWorldWorld [_cx, _y, _z];
    private _hits = (lineIntersectsSurfaces [_from, _to, objNull, objNull, true, -1, "GEOM", "FIRE"]) select {(_x select 2) isEqualTo _boat || {(_x select 3) isEqualTo _boat}};
    if (count _hits == 0) then {
        if (count _first > 0) exitWith {_z = _zMax + 1};
    } else {
        private _p = _boat worldToModel (ASLToAGL ((_hits select 0) select 0));
        if (count _first == 0) then {_first = _p};
        if (abs ((_p select 0) - (_first select 0)) > 0.5) exitWith {_z = _zMax + 1};
        _top = _p;
    };
    _z = _z + 0.1;
};
if (count _top == 3) then {
    [(_top select 0) + (_side * 0.1), _top select 1, (_top select 2) - 0.05]
} else {
    [_cx + (_side * (_halfW + 0.1)), _y, _zWater + 0.3]
}
