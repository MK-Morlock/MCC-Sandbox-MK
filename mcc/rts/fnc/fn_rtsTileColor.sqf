params [["_name", "", [""]], ["_alpha", 1, [0]]];
private _c = switch (toLower _name) do {
	case "mcc_rts_scanresourcesbasic": {[0.70, 0.92, 0.98]};
	case "mcc_rts_scanresourcesadvanced": {[0.20, 0.62, 0.85]};
	default {[1, 1, 1]};
};
private _cfg = configNull;
{
	if (isClass (missionConfigFile >> _x >> _name)) exitWith {_cfg = missionConfigFile >> _x >> _name};
	if (isClass (configFile >> _x >> _name)) exitWith {_cfg = configFile >> _x >> _name};
} forEach ["cfgRtsBuildings"];
if (!isNull _cfg) then {
	_c = switch (toLower getText (_cfg >> "constType")) do {
		case "hq": {[0.22, 0.78, 0.91]};
		case "barracks": {[0.93, 0.60, 0.55]};
		case "house": {[0.62, 0.72, 0.86]};
		case "workshop": {[0.31, 0.64, 1]};
		case "triage": {[0.42, 0.82, 0.66]};
		case "tradepost": {[0.95, 0.71, 0.27]};
		case "storage": {[0.90, 0.84, 0.70]};
		case "elecpower": {[0.98, 0.88, 0.45]};
		default {[1, 1, 1]};
	};
};
if (_alpha < 1) then {(_c apply {_x * 0.45}) + [1]} else {_c + [_alpha]}
