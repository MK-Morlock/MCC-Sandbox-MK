disableSerialization;
params [["_i", nil]];
private _themes = [
	["Black",    [0.12,0.12,0.12], [0,0,0]],
	["Gunmetal", [0.19,0.21,0.24], [0.10,0.11,0.13]],
	["Olive",    [0.19,0.23,0.15], [0.10,0.12,0.08]],
	["Navy",     [0.00,0.17,0.34], [0.00,0.09,0.17]],
	["Burgundy", [0.47,0.00,0.00], [0.23,0.00,0.00]],
	["Teal",     [0.00,0.25,0.25], [0.00,0.13,0.13]]
];
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
