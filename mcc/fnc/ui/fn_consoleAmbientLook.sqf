disableSerialization;
params [["_d", uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull], [displayNull]]];
if (isNull _d) exitWith {};
private _on = missionNamespace getVariable ["MCC_GAIA_AC", false];
(_d displayCtrl 1016) ctrlSetText ([((["\mcc_sandbox_mod\data\", "\mcc_sandbox_mod\data\classic\"] select (uiNamespace getVariable ["MCC_console3D", false])) + "btn_round_wide_n_ca.paa"), ((["\mcc_sandbox_mod\data\", "\mcc_sandbox_mod\data\classic\"] select (uiNamespace getVariable ["MCC_console3D", false])) + "btn_round_wide_d_ca.paa")] select _on);
(_d displayCtrl 1017) ctrlSetTextColor ([[0.88, 0.89, 0.90, 1], [0.56, 0.75, 0.42, 1]] select _on);
