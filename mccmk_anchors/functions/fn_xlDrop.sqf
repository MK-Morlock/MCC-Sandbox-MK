/*
    ANC_fnc_xlDrop  (server)
    Every extra line on a vehicle is let go - it was destroyed or deleted. [vehicle]
*/
params [["_v", objNull, [objNull]]];
if (isNil "ANC_xLines") exitWith {};
private _ids = [];
{if (((_y get "a") isEqualTo _v) || {(_y get "b") isEqualTo _v}) then {_ids pushBack _x}} forEach ANC_xLines;
{[_x, "A line was lost."] call ANC_fnc_xlRelease} forEach _ids;
