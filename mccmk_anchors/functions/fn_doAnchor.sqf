/*
 ANC_fnc_doAnchor
 - [boat] call ANC_fnc_doAnchor; for mission makers (see ANC_fnc_doOrder).
*/
params [["_boat", objNull, [objNull]]];
[_boat, "anchor"] call ANC_fnc_doOrder;
