/*
    ANC_fnc_xlFree  (server)
    Is this attachment point on this vehicle free of extra lines (tow lines and tethers)? Points within 0.5 m count as
    the same point. [vehicle, point]  ->  true / false
*/
params [["_v", objNull, [objNull]], ["_pt", [], [[]]]];
if (isNil "ANC_xLines" || {count _pt != 3}) exitWith {true};
private _free = true;
{
    if (((_y get "a") isEqualTo _v && {((_y get "aPt") distance _pt) < 0.5}) || {(_y get "b") isEqualTo _v && {((_y get "bPt") distance _pt) < 0.5}}) exitWith {_free = false};
} forEach ANC_xLines;
_free
