disableSerialization;
params [["_v", nil], ["_m", nil]];
if (isNil "_v") then {_v = profileNamespace getVariable ["MCC_consoleAlpha", 0.5]};
if (isNil "_m") then {_m = profileNamespace getVariable ["MCC_consoleMapAlpha", 1]};
_v = (_v max 0) min 1;
_m = (_m max 0) min 1;
profileNamespace setVariable ["MCC_consoleAlpha", _v];
profileNamespace setVariable ["MCC_consoleMapAlpha", _m];

private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};

private _theme = [["Black", [0.11,0.12,0.13], [0,0,0]], ["Gunmetal", [0.19,0.21,0.24], [0.10,0.11,0.13]], ["Olive", [0.20,0.22,0.15], [0.11,0.12,0.08]], ["Navy", [0.10,0.14,0.22], [0.05,0.07,0.12]], ["Coyote", [0.29,0.25,0.19], [0.16,0.13,0.10]], ["Burgundy", [0.25,0.09,0.11], [0.13,0.04,0.05]], ["Teal", [0.11,0.20,0.21], [0.05,0.11,0.12]]] param [profileNamespace getVariable ["MCC_consoleTheme", 0], ["Black", [0.11,0.12,0.13], [0,0,0]]];
_theme params ["", "_rgb", "_dark"];
private _panel = if (_v <= 0.5) then {_rgb + [0.96 * (_v / 0.5)]} else {
	private _f = (_v - 0.5) / 0.5;
	((_rgb vectorMultiply (1 - _f)) vectorAdd (_dark vectorMultiply _f)) + [0.96 + 0.04 * _f]
};
{(_d displayCtrl _x) ctrlSetTextColor _panel; (_d displayCtrl _x) ctrlCommit 0} forEach [9002, 9006, 9110, 9111, 9112];
{(_d displayCtrl _x) ctrlSetBackgroundColor _panel; (_d displayCtrl _x) ctrlCommit 0} forEach [9004, 9005];

private _map = _d displayCtrl 9000;
private _layer = 1 - ((1 - _m) ^ 0.25);
_map ctrlSetFade (1 - _layer);
(_d displayCtrl 9121) ctrlSetTooltip format ["Map: %1 %2 visible (right = solid, left = hidden)", round (_m * 100), "%"];
_map ctrlCommit 0;
(_d displayCtrl 9010) ctrlSetFade (1 - _m);
(_d displayCtrl 9010) ctrlCommit 0;
uiNamespace setVariable ["MCC_consoleMapBgAlpha", _m];
(_d displayCtrl 9001) ctrlSetBackgroundColor ((if (uiNamespace getVariable ["MCC_consoleMapContour", false]) then {[0.969, 0.957, 0.949]} else {[0.17, 0.18, 0.20]}) + [_m]);
