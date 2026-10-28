disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
private _list = missionNamespace getVariable [format ["MCC_evacVehicles_%1", call MCC_fnc_evacSide], []];
private _c = _d displayCtrl 42;
private _sel = missionNamespace getVariable ["MCC_evacSelectedObj", objNull];
lbClear _c;
{
	_c lbAdd (if (alive _x) then {format ["%1, %2%3", _x, getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName"), ["", " (no driver)"] select !(alive (driver _x))]} else {"N/A"});
} forEach _list;
private _i = _list find _sel;
if (_i < 0 && {count _list > 0}) then {_i = (count _list) - 1};
missionNamespace setVariable ["MCC_evacSelectedObj", _list param [_i, objNull]];
missionNamespace setVariable ["MCC_evacVehicles_index", _i max 0];
_c lbSetCurSel _i;
