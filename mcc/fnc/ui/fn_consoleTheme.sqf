disableSerialization;
params [["_i", nil]];
private _themes = call MCCMK_fnc_consoleThemes;	// one shared list (MCC_fnc_consoleAlpha paints from it too)
if (isNil {profileNamespace getVariable "MCC_consoleThemeV2"}) then {
	private _old = profileNamespace getVariable ["MCC_consoleTheme", 0];
	profileNamespace setVariable ["MCC_consoleTheme", if (_old < 4) then {_old} else {if (_old == 4) then {0} else {_old - 1}}];
	profileNamespace setVariable ["MCC_consoleThemeV2", true];
};
if (isNil "_i") then {_i = profileNamespace getVariable ["MCC_consoleTheme", 0]};
_i = (_i max 0) min (count _themes - 1);
profileNamespace setVariable ["MCC_consoleTheme", _i];

private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (!isNull _d) then {
	{
		private _c = _d displayCtrl (9150 + _forEachIndex);
		_c ctrlSetTextColor ((_x select 1) + [1]);
		_c ctrlSetActiveColor ((((_x select 1) vectorMultiply 1.3) apply {_x min 1}) + [1]);
		_c ctrlSetTooltip format ["Console colour: %1", _x select 0];
	} forEach _themes;
	private _frame = _d displayCtrl 9160;
	private _p = ctrlPosition (_d displayCtrl (9150 + _i));
	_frame ctrlSetPosition [(_p select 0) - 0.002, (_p select 1) - 0.0025, (_p select 2) + 0.004, (_p select 3) + 0.005];
	_frame ctrlCommit 0;
	[] call MCC_fnc_consoleAlpha;
};
_themes select _i
