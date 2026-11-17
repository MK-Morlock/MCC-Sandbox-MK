/*
    ANC_fnc_isAground
    True if the boat is touching the bottom: at the bow, amidships and the stern, the keel (the bottom of the boat's
    outline) is checked against the sea bed / ground right under it. Within 15 cm at any of them = aground. Beached
    and grounded boats aren't drifted by the wind.
*/
params [["_boat", objNull, [objNull]]];
if (isNull _boat) exitWith {false};
(_boat call ANC_fnc_boatGeometry) params ["_cx", "_sternY", "_bowY", "", "_bottomZ", "", "_length"];
private _ys = [_sternY + (_length * 0.15), (_sternY + _bowY) / 2, _bowY - (_length * 0.15)];
(_ys findIf {
    private _keel = _boat modelToWorldWorld [_cx, _x, _bottomZ];
    ((_keel select 2) - (getTerrainHeightASL _keel)) < 0.15
}) != -1
