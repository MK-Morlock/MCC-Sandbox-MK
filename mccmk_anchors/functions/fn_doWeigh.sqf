/*
 ANC_fnc_doWeigh
 - [boat] call ANC_fnc_doWeigh; for mission makers (see ANC_fnc_doOrder).
*/
params [["_boat", objNull, [objNull]]];
[_boat, "weigh"] call ANC_fnc_doOrder;
