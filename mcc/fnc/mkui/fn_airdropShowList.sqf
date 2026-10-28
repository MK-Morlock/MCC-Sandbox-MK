disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
if (isNil "MCC_airDropArray") then {MCC_airDropArray = []};
private _c = _d displayCtrl 1033;
lbClear _c;
{_c lbAdd getText (configFile >> "CfgVehicles" >> _x >> "displayName")} forEach MCC_airDropArray;
_c lbSetCurSel ((count MCC_airDropArray) - 1);
