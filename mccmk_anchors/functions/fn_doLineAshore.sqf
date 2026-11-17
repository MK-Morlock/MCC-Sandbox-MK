/*
 ANC_fnc_doLineAshore
 - [boat] call ANC_fnc_doLineAshore; for mission makers (see ANC_fnc_doOrder).
*/
params [["_boat", objNull, [objNull]]];
[_boat, "lineAshore"] call ANC_fnc_doOrder;
