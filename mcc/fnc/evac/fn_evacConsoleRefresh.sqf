disableSerialization;
private _d = findDisplay 2993;
if (isNull _d) exitWith {};
private _list = missionNamespace getVariable [format ["MCC_evacVehicles_%1", playerSide], []];
private _c = _d displayCtrl 9103;
private _sel = missionNamespace getVariable ["MCC_evacConsoleObj", objNull];
lbClear _c;
{
	_c lbAdd (if (alive _x) then {format ["%1, %2%3", _x, getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName"), ["", " (no driver)"] select !(alive (driver _x))]} else {"N/A"});
} forEach _list;
private _i = _list find _sel;
if (_i < 0) then {
	_i = (count _list) - 1;
	missionNamespace setVariable ["MCC_evacVehicles_index", -2];
} else {
	missionNamespace setVariable ["MCC_evacVehicles_index", _i];
};
missionNamespace setVariable ["MCC_evacConsoleObj", _list param [_i, objNull]];
_c lbSetCurSel _i;
