/*
    ANC_fnc_hullPoint
    The top of the stem (bow) or transom (stern), just outside the hull - where a bow roller, bow eye or stern cleat
    would be.

    How: looking back at the boat from in front (or behind), it scans upwards
    from the waterline in 10 cm steps. While the scan keeps hitting the hull close to the first hit, it's still on the
    stem / transom; as soon as it misses, or hits something set well back (a cabin, console, gun mount or mast), it
    has passed the top of the hull. The point is just below that top.

    [boat, true] = stern. Returned in the boat's own coordinates; remembered
    once the boat floats. Adjusted points (ANC_fnc_pointFor) take priority.
*/
params [["_boat", objNull, [objNull]], ["_stern", false, [false]]];
private _key = ["ANC_stemPoint2", "ANC_transomPoint2"] select _stern;
private _cached = _boat getVariable [_key, []];
if (count _cached == 3) exitWith {_cached};

(_boat call ANC_fnc_boatGeometry) params ["_cx", "_sternY", "_bowY", "_halfW", "_bottomZ", "_topZ", "_length", "_zWater"];
private _endY = [_bowY, _sternY] select _stern;
private _sign = [1, -1] select _stern;
private _first = [];
private _top = [];
private _z = _zWater + 0.05;
private _zMax = (_zWater + 3.5) min _topZ;
while {_z <= _zMax} do {
    private _from = _boat modelToWorldWorld [_cx, _endY + (_sign * 3), _z];
    private _to = _boat modelToWorldWorld [_cx, _endY - (_sign * _length * 0.5), _z];
    private _hits = (lineIntersectsSurfaces [_from, _to, objNull, objNull, true, -1, "GEOM", "FIRE"]) select {(_x select 2) isEqualTo _boat || {(_x select 3) isEqualTo _boat}};
    if (count _hits == 0) then {
        if (count _first > 0) exitWith {_z = _zMax + 1}; // above the top of the hull
    } else {
        private _p = _boat worldToModel (ASLToAGL ((_hits select 0) select 0));
        if (count _first == 0) then {_first = _p};
        // Something set well back from the stem / transom: superstructure - stop.
        if (abs ((_p select 1) - (_first select 1)) > 0.8) exitWith {_z = _zMax + 1};
        _top = _p;
    };
    _z = _z + 0.1;
};

private _found = if (count _top == 3) then {
    [_top select 0, (_top select 1) + (_sign * 0.1), (_top select 2) - 0.05]
} else {
    // Nothing hit at all: the end of the outline, just above the waterline.
    [_cx, _endY, _zWater + 0.3]
};
if (surfaceIsWater getPosASL _boat) then {_boat setVariable [_key, _found]};
_found
