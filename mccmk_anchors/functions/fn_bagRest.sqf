/*
    ANC_fnc_bagRest
    Puts a loose line end down properly: on the ground straight beneath it (or in the water, just below the surface),
    the bag sitting flat on its underside and tilted to the slope - not hanging in the air where it happened to stop.
    In water it starts at the surface and then sinks under its own weight. Only for a loose end (after a throw, or
    when the line is let go); it doesn't touch a held line. [the line's end object, the bag]
*/
params ["_pad", "_bag"];
if (isNull _pad) exitWith {};
private _p = getPosASL _pad;
private _water = surfaceIsWater _p;
// In water: at the surface - from there it sinks under its own weight (ANC_fnc_shoreWatch).
private _z = if (_water) then {(getTerrainHeightASL _p) max -0.08} else {getTerrainHeightASL _p};
_pad setPosASL [_p select 0, _p select 1, _z];
private _up = if (_water) then {[0, 0, 1]} else {surfaceNormal _p};
private _dir = vectorDir _pad;
_dir = vectorNormalized (_dir vectorDiff (_up vectorMultiply (_dir vectorDotProduct _up)));
if (vectorMagnitude _dir < 0.1) then {_dir = [0, 1, 0]};
_pad setVectorDirAndUp [_dir, _up];
if (!isNull _bag) then {
    // The bag's underside on the ground: lift it by the depth of its own bottom half.
    private _bottom = ((boundingBoxReal _bag) select 0) select 2;
    _bag attachTo [_pad, [0, 0, (-_bottom) max 0.05]];
    _bag setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];
    _bag setVariable ["ANC_attOff", [0, 0, (-_bottom) max 0.05]]; // kept for ANC_fnc_bagMove
    _bag setVariable ["ANC_attVD", [[0, 1, 0], [0, 0, 1]]];
};
