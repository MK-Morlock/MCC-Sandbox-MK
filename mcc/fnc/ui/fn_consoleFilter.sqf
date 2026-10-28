disableSerialization;
params [["_mode", "init", [""]], ["_arg", ""]];
private _allKeys = [west, east, resistance, civilian, "players"];

if (_mode == "shows") exitWith {
	private _u = _arg;
	private _st = missionNamespace getVariable ["MCC_groupGenGroupStatus", _allKeys];
	private _s = if (getNumber (configFile >> "CfgVehicles" >> typeOf _u >> "side") == 3 && {_u isKindOf "CAManBase"}) then {civilian} else {side _u};
	if (isPlayer _u) then {
		("players" in _st) || {(side group _u) in _st}
	} else {
		(_s in _st) || {((group _u) getVariable ["MCC_dropFor", sideUnknown]) in _st}
	}
};

private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
private _st = +(missionNamespace getVariable ["MCC_groupGenGroupStatus", _allKeys]);
if (_mode == "init" && {isNil "MCC_consoleFilterReady"}) then {
	MCC_consoleFilterReady = true;
	_st = +_allKeys;
	missionNamespace setVariable ["MCC_groupGenGroupStatus", _st];
};
if (_mode == "toggle") then {
	if (_arg isEqualTo "all") then {
		_st = if (({_x in _st} count _allKeys) == count _allKeys) then {[]} else {+_allKeys};
	} else {
		private _k = switch (_arg) do {case "west": {west}; case "east": {east}; case "ind": {resistance}; case "civ": {civilian}; default {"players"}};
		if (_k in _st) then {_st = _st - [_k]} else {_st pushBack _k};
	};
	missionNamespace setVariable ["MCC_groupGenGroupStatus", _st];
	MCC_UMListSig = [];
	_st execVM (MCC_path + "mcc\general_scripts\groupGen\group_manage.sqf");
};
if (isNull _d) exitWith {};
private _allOn = ({_x in _st} count _allKeys) == count _allKeys;
{
	_x params ["_k", "_bg", "_lb", "_col"];
	private _on = if (_k isEqualTo "all") then {_allOn} else {_k in _st};
	(_d displayCtrl _bg) ctrlSetText ([((["\mcc_sandbox_mod\data\", "\mcc_sandbox_mod\data\classic\"] select (uiNamespace getVariable ["MCC_console3D", false])) + "btn_round_d_ca.paa"), ((["\mcc_sandbox_mod\data\", "\mcc_sandbox_mod\data\classic\"] select (uiNamespace getVariable ["MCC_console3D", false])) + "btn_round_n_ca.paa")] select _on);
	(_d displayCtrl _lb) ctrlSetTextColor (if (_on) then {_col} else {[0.30, 0.31, 0.33, 1]});
} forEach [
	["all", 9201, 9211, [0.88, 0.89, 0.90, 1]],
	["players", 9202, 9212, [0.88, 0.89, 0.90, 1]],
	[west, 9203, 9213, [0.44, 0.63, 0.85, 1]],
	[east, 9204, 9214, [0.82, 0.42, 0.37, 1]],
	[resistance, 9205, 9215, [0.56, 0.75, 0.42, 1]],
	[civilian, 9206, 9216, [0.66, 0.55, 0.82, 1]]
];
