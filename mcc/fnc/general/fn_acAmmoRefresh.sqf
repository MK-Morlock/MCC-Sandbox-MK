disableSerialization;
private _d = findDisplay 5010;
private _uav = missionNamespace getVariable ["MCC_ACConsoleUp", objNull];
if (isNull _d || {!alive _uav} || {typeOf _uav != "B_T_VTOL_01_armed_F"}) exitWith {};
private _t = [_uav] call MCC_fnc_acAmmoType;
(_d displayCtrl 5019) ctrlSetText format ["40mm %1: %2", _t select 1, _t select 2];
private _b = _d displayCtrl 9185;
_b ctrlSetText (_t select 1);
_b ctrlShow ((missionNamespace getVariable ["MCC_ConsoleACweaponSelected", 0]) == 1);
