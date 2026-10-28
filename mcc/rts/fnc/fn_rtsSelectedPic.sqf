disableSerialization;
params [["_obj", objNull], ["_cfgName", "", [""]], ["_constType", "", [""]]];
private _disp = uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", displayNull];
if (isNull _disp) exitWith {};
private _pic = "";
private _col = [1, 1, 1, 1];
private _isBuilding = false;
if (_cfgName != "" && {_constType != ""}) then {
	private _cfg = (if (isClass (missionConfigFile >> _cfgName)) then {missionConfigFile} else {configFile}) >> _cfgName >> _constType;
	if (toLower _cfgName == "cfgrtsbuildings") then {
		_pic = getText (_cfg >> "picture");
		_isBuilding = _pic != "";
		_col = [_constType, 1] call MCC_fnc_rtsTileColor;
	};
};
if (_pic == "" && {_obj isEqualType objNull} && {!isNull _obj} && {!isNull group _obj}) then {
	_pic = getText (configFile >> "CfgMarkers" >> (([group _obj] call MCC_fnc_getGroupIconData) select 2) >> "icon");
	_col = (side group _obj) call BIS_fnc_sideColor;
	_col set [3, 1];
};
private _show = _pic != "";
(_disp displayCtrl 9140) ctrlShow (_show && _isBuilding);
(_disp displayCtrl 9141) ctrlShow _show;
if (_show) then {
	(_disp displayCtrl 9141) ctrlSetText _pic;
	(_disp displayCtrl 9141) ctrlSetTextColor _col;
};
