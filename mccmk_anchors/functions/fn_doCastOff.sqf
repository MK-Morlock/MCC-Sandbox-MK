/*
 ANC_fnc_doCastOff
 - [boat] call ANC_fnc_doCastOff; for mission makers (see ANC_fnc_doOrder).
*/
params [["_boat", objNull, [objNull]]];
[_boat, "castoff"] call ANC_fnc_doOrder;
