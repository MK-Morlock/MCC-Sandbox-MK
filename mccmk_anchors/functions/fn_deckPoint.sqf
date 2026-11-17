/*
    ANC_fnc_deckPoint
    A mooring cleat position: on the deck, just inside the rail / gunwale on the given side, at a given distance along
    the boat - somewhere the crew could walk to and make a line fast, as on a real boat.

    How: finds the top of the side there (ANC_fnc_hullSidePoint), steps 0.35 m
    inboard of it, then looks straight down for the deck - ignoring anything more than 0.25 m above the rail (a cabin
    roof or gun mount).
    [boat, y, side (1 = starboard, -1 = port)]
*/
params [["_boat", objNull, [objNull]], ["_y", 0, [0]], ["_side", 1, [0]]];
(_boat call ANC_fnc_boatGeometry) params ["_cx", "", "", "_halfW", "_bottomZ", "_topZ", "_length", "_zWater"];
private _rail = [_boat, _y, _side] call ANC_fnc_hullSidePoint;
private _edgeX = (_rail select 0) - (_side * 0.1); // the hull's side itself
private _railZ = (_rail select 2) + 0.05;
private _inX = _edgeX - (_side * 0.35); // just inboard of the rail
if ((_inX - _cx) * _side < 0) then {_inX = _cx}; // narrow bow: stay on the centreline side

private _from = _boat modelToWorldWorld [_inX, _y, _railZ + 1.5];
private _to = _boat modelToWorldWorld [_inX, _y, _zWater - 0.5];
private _hits = (lineIntersectsSurfaces [_from, _to, objNull, objNull, true, -1, "GEOM", "FIRE"]) select {(_x select 2) isEqualTo _boat || {(_x select 3) isEqualTo _boat}};
private _deckZ = _railZ;
{
    private _p = _boat worldToModel (ASLToAGL (_x select 0));
    if ((_p select 2) <= _railZ + 0.25) exitWith {_deckZ = _p select 2};
} forEach _hits;
[_inX, _y, _deckZ + 0.05]
