#define MCC_BRIEFING_TEXT 3055
disableSerialization;
private "_dlg";
private _string = controlNull;
["Diary updated"] call MCCMK_fnc_hint;

params ["_type"];

_dlg = (uiNamespace getVariable "MCC_groupGen_Dialog");
_string = ctrlText (_dlg displayCtrl MCC_BRIEFING_TEXT);

[_string, _type] remoteExec ["MCC_fnc_makeBriefing", 2, false];