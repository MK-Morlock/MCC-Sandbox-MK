/*
 ANC_fnc_doMoor
 - [boat] call ANC_fnc_doMoor; for mission makers (see ANC_fnc_doOrder).
*/
params [["_boat", objNull, [objNull]]];
[_boat, "moor"] call ANC_fnc_doOrder;
