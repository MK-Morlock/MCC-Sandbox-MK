disableSerialization;
params [["_mode", "init", [""]], ["_v", -1, [0]]];
if (_mode == "toggle") then {profileNamespace setVariable ["MCCMK_consoleInfo", _v == 1]};
private _on = profileNamespace getVariable ["MCCMK_consoleInfo", false];
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
if (_mode == "init") then {(_d displayCtrl 9173) cbSetChecked _on};
{(_d displayCtrl _x) ctrlShow _on} forEach [9307, 9308, 9309, 1020, 1021, 1022];
