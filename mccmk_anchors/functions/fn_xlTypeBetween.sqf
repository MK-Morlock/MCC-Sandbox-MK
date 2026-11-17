/*
    ANC_fnc_xlTypeBetween  (server)
    What type of extra line already joins two vehicles: "tow", "tether", or "" (none). One TYPE of line between any two
    vehicles: several tow lines (one per point - useful for pulling a stuck vehicle off a beach) or several tethers are
    fine, but towing and tethering the same pair isn't - let go of one type first. [vehicle, vehicle]  ->  kind
*/
params [["_a", objNull, [objNull]], ["_b", objNull, [objNull]]];
if (isNil "ANC_xLines") exitWith {""};
private _kind = "";
{
    if ((((_y get "a") isEqualTo _a) && {(_y get "b") isEqualTo _b}) || {((_y get "a") isEqualTo _b) && {(_y get "b") isEqualTo _a}}) exitWith {_kind = _y get "kind"};
} forEach ANC_xLines;
_kind
