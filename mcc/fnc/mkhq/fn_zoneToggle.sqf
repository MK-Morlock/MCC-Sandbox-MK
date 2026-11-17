disableSerialization;
params [["_mode", "init", [""]]];
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
if (_mode == "init" && {isNull (_d displayCtrl 9306)}) then {
	(ctrlPosition (_d displayCtrl 9000)) params ["_x", "_y", "_w", "_h"];
	private _c = _d ctrlCreate ["RscCheckbox", 9306];
	_c ctrlSetPosition [_x + 0.001975 * safezoneW, _y + _h - 0.0188333 * safezoneH, 0.0090625 * safezoneW, 0.0168333 * safezoneH];
	_c cbSetChecked (profileNamespace getVariable ["MCCMK_zoneControls", true]);
	_c ctrlSetBackgroundColor [0, 0.5, 0, 1];
	_c ctrlCommit 0;
	_c ctrlAddEventHandler ["CheckedChanged", {
		params ["_c", "_st"];
		profileNamespace setVariable ["MCCMK_zoneControls", _st == 1];
		["apply"] call MCCMK_fnc_zoneToggle;
	}];
};
private _on = profileNamespace getVariable ["MCCMK_zoneControls", true];
{(_d displayCtrl _x) ctrlShow _on} forEach [9303, 9304, 9305];
