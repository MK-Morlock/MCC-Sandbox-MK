params [["_faction", "", [""]]];
private _key = "MCC_factionClasses_" + toLower _faction;
private _cached = uiNamespace getVariable _key;
if (!isNil "_cached") exitWith {_cached};

private _cond = if (toLower _faction == "all") then {"getNumber (_x >> 'scope') == 2"} else {
	format ["getNumber (_x >> 'scope') == 2 && {toLower getText (_x >> 'faction') == '%1'}", toLower _faction]
};
private _t0 = diag_tickTime;
private _classes = _cond configClasses (configFile >> "CfgVehicles");
uiNamespace setVariable [_key, _classes];
if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC [PERF] factionClasses | %1: %2 classes in %3 s (kept for this game session)", _faction, count _classes, (diag_tickTime - _t0) toFixed 2]};
_classes
