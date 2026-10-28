params [["_src", "", ["", []]], ["_size", -1, [0]], ["_type", "", [""]]];
if (_size < 1) then {_size = 4 + floor random 5};
private _classes = [];
private _fac = "";
if (_src isEqualType "") then {
	_fac = _src;
	_classes = ([[_fac, "soldier", "men"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry) apply {_x select 0};
	if (count _classes == 0) then {_classes = ([[_fac, "soldier", ""] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry) apply {_x select 0}};
} else {
	_classes = (_src apply {if (_x isEqualType "") then {_x} else {_x param [0, ""]}}) select {_x != ""};
	_classes = _classes arrayIntersect _classes;
	private _facs = _classes apply {getText (configFile >> "CfgVehicles" >> _x >> "faction")};
	private _best = 0;
	{private _n = {_x == _y} count _facs; if (_n > _best) then {_best = _n; _fac = _x}} forEach (_facs arrayIntersect _facs);
};
if (count _classes == 0) exitWith {[]};
if (_type == "") then {_type = switch (true) do {case (_size <= 2): {"Sentry"}; case (_size <= 5): {"Fire Team"}; default {"Squad"}}};

private _related = switch (_type) do {
	case "Sentry": {["Sentry", "Patrol", "Fire Team"]};
	case "Fire Team": {["Fire Team", "Patrol", "Infantry"]};
	case "Squad": {["Squad", "Infantry", "Weapons Squad"]};
	case "Patrol": {["Patrol", "Fire Team", "Sentry"]};
	default {[_type]};
};
if (_fac != "") then {
	private _groups = [_fac] call MCCMK_fnc_factionGroups;
	private _pick = [];
	{
		private _t = _x;
		private _cands = _groups select {(_x select 0) == _t && {abs ((count (_x select 1)) - _size) <= 2}};
		if (count _cands > 0) exitWith {
			private _d = selectMin (_cands apply {abs ((count (_x select 1)) - _size)});
			_pick = selectRandom (_cands select {abs ((count (_x select 1)) - _size) == _d});
		};
	} forEach _related;
	if (count _pick > 0) exitWith {_classes = +(_pick select 1); _type = "#predefined"};
};
if (_type == "#predefined") exitWith {_classes};

private _recipe = switch (toLower _type) do {
	case "squad": {["Team Leader", "Grenadier", "Rifleman", "AT", "Medic", "Rifleman", "Grenadier", "Rifleman"]};
	case "weapons squad": {["Team Leader", "Rifleman", "Rifleman", "AT", "AT", "Rifleman"]};
	case "at team": {["Team Leader", "AT", "AT", "Rifleman"]};
	case "aa team": {["Team Leader", "AA", "AA"]};
	case "recon team": {["Team Leader", "Sniper", "Medic", "Rifleman"]};
	case "sniper team": {["Sniper", "Sniper"]};
	case "sentry": {["Rifleman", "Rifleman"]};
	case "patrol": {["Team Leader", "Rifleman", "Grenadier", "Rifleman"]};
	default {["Team Leader", "Grenadier", "Rifleman", "AT"]};
};
private _extra = ["Rifleman", "Autorifleman", "Rifleman", "Grenadier"];
private _i = 0;
while {count _recipe < _size} do {_recipe pushBack (_extra select (_i mod 4)); _i = _i + 1};
if (count _recipe > _size) then {_recipe resize _size};
private _jobKey = {
	switch (_this) do {
		case "Team Leader": {"TeamLeader"};
		case "AT": {"RiflemanAT"};
		case "AA": {"AASpecialist"};
		default {_this splitString " " joinString ""};
	}
};
private _byJob = createHashMap;
{
	private _j = [_x] call MCCMK_fnc_unitJob;
	if !(_j in ["HeliPilot", "HeliCrew", "Pilot", "Crewman", "Driver", "Diver", "Unarmed"]) then {
		(_byJob getOrDefault [_j, [], true]) pushBack _x;
	};
} forEach _classes;
if (count _byJob == 0) exitWith {
	private _o = [];
	for "_k" from 1 to _size do {_o pushBack selectRandom _classes};
	_o
};
private _out = [];
{
	private _chain = [_x call _jobKey, "chain"] call MCCMK_fnc_jobInfo;
	private _c = "";
	{
		private _l = _byJob getOrDefault [_x, []];
		if (count _l > 0) exitWith {_c = selectRandom _l};
	} forEach _chain;
	if (_c == "") then {_c = selectRandom (flatten (values _byJob))};
	_out pushBack _c;
} forEach _recipe;
_out
