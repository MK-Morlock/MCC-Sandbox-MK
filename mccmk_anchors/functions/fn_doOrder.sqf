/*
    ANC_fnc_doOrder  (any computer)
    Script interface for mission makers - usable in waypoint "On Activation", triggers and scripts: (each is [boat,
    "<order>"] call ANC_fnc_doOrder). Runs on the server.
*/
params [["_boat", objNull, [objNull]], ["_order", "", [""]]];
if (isNull _boat) exitWith {};
[[_boat, _order, objNull], "aiOrder", 2] call ANC_fnc_remote;
