/*
 ANC_fnc_isSubmersible
 - submarines and SDVs (vehicles using Arma's submarine simulation).
*/
params [["_boat", objNull, [objNull]]];
!isNull _boat && {(toLower getText (configOf _boat >> "simulation")) isEqualTo "submarinex"}
