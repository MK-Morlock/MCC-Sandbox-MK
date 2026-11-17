/*
    ANC_fnc_boatGeometry
    Size of a boat in its own coordinates, worked out once and remembered:
    [centreX, sternY, bowY, halfWidth, bottomZ, topZ, length, waterlineZ]
*/
params [["_boat", objNull, [objNull]]];
private _cached = _boat getVariable ["ANC_geometry", []];
if (count _cached == 8) exitWith {_cached};

(boundingBoxReal _boat) params ["_bbMin", "_bbMax"];
private _cx = ((_bbMin select 0) + (_bbMax select 0)) / 2;
private _halfW = ((_bbMax select 0) - (_bbMin select 0)) / 2;
private _length = (_bbMax select 1) - (_bbMin select 1);

private _mid = _boat modelToWorldWorld [_cx, 0, 0];
private _zWater = (_boat worldToModel (ASLToAGL [_mid select 0, _mid select 1, 0])) select 2;
_zWater = (_zWater max (_bbMin select 2)) min (_bbMax select 2);

private _geo = [_cx, _bbMin select 1, _bbMax select 1, _halfW, _bbMin select 2, _bbMax select 2, _length, _zWater];
// Remember it once floating. Not for submarines / SDVs: their waterline changes when they dive.
if ((surfaceIsWater getPosASL _boat) && {!(_boat call ANC_fnc_isSubmersible)}) then {_boat setVariable ["ANC_geometry", _geo]};
_geo
