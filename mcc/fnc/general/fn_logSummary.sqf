if !(missionNamespace getVariable ["MCC_debug", false]) exitWith {};
if !(missionNamespace getVariable ["MCC_debug", false]) exitWith {};
private _counts = missionNamespace getVariable ["MCC_logCounts", createHashMap];
private _parts = [];
{
	_parts pushBack format ["%1=%2", _x, _counts getOrDefault [_x, 0]];
} forEach ["STAGE", "INFO", "WARN", "ERROR", "DEBUG"];

diag_log text "MCC [SUMMARY] ================================================================";
diag_log text format ["MCC [SUMMARY] MCC log counts this session: %1", _parts joinString ", "];
diag_log text "MCC [SUMMARY] Engine script errors (Error in expression / Undefined variable) are not counted here -";
diag_log text "MCC [SUMMARY] run the RPT through tools\rpt_error_summary.html to group and count them.";
diag_log text "MCC [SUMMARY] ================================================================";
