disableSerialization;
params [["_mode", "init", [""]], ["_arg", ""]];
private _allKeys = [west, east, resistance, civilian, "players"];

if (_mode == "shows") exitWith {
	private _u = _arg;
	private _st = missionNamespace getVariable ["MCC_groupGenGroupStatus", _allKeys];
	//(MK) a civilian by its class, its faction or its group (civilian-looking units of a class filed under another side
	// slipped through the Civ filter)
	private _s = if (_u isKindOf "CAManBase" && {getNumber (configFile >> "CfgVehicles" >> typeOf _u >> "side") == 3 || {getNumber (configFile >> "CfgFactionClasses" >> (faction _u) >> "side") == 3} || {(side (group _u)) isEqualTo civilian}}) then {civilian} else {side group _u};	//(MK) the group's side - a soldier of another side in a group is on the group's side
	if (!(civilian in _st) && {_s != civilian} && {_u isKindOf "CAManBase"} && {!isPlayer _u} && {(toLower (typeOf _u)) find "_civ" >= 0 || {(toLower (faction _u)) find "civ" >= 0}}) then {
		if (isNil {_u getVariable "MCCMK_civFilterLogged"}) then {
			_u setVariable ["MCCMK_civFilterLogged", true];
			["DEBUG", "consoleFilter", "shown with Civ off: %1 | faction %2 | group side %3 | config side %4", [typeOf _u, faction _u, side (group _u), getNumber (configFile >> "CfgVehicles" >> typeOf _u >> "side")]] call MCC_fnc_log;
		};
	};
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
//(MK) IEDs: IED and ambush markers on the console map shown or hidden (MCCMK_showIEDs; suicide bombers and armed civilians
// follow Civ). The 3D editor's IED markers (ambush symbols) follow it too. Separate from All, which is about sides.
//(MK) Orders: every group's waypoint markers and the lines to them shown or hidden (MCCMK_showOrders); the orders stand.
if (_mode == "toggle" && {_arg isEqualTo "orders"}) then {
	MCCMK_showOrders = !(missionNamespace getVariable ["MCCMK_showOrders", true]);
	_mode = "refresh";
};
if (_mode == "toggle" && {_arg isEqualTo "ieds"}) then {
	MCCMK_showIEDs = !(missionNamespace getVariable ["MCCMK_showIEDs", true]);
	{if ((markerType _x) == "mil_ambush") then {_x setMarkerAlphaLocal ([0, 1] select MCCMK_showIEDs)}} forEach allMapMarkers;
	_mode = "refresh";
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
	private _on = switch (true) do {
		case (_k isEqualTo "all"): {_allOn};
		case (_k isEqualTo "ieds"): {missionNamespace getVariable ["MCCMK_showIEDs", true]};
		case (_k isEqualTo "orders"): {missionNamespace getVariable ["MCCMK_showOrders", true]};
		default {_k in _st};
	};
	(_d displayCtrl _bg) ctrlSetText ([((["\mcc_sandbox_mod\data\", "\mcc_sandbox_mod\data\classic\"] select (uiNamespace getVariable ["MCC_console3D", false])) + "btn_round_d_ca.paa"), ((["\mcc_sandbox_mod\data\", "\mcc_sandbox_mod\data\classic\"] select (uiNamespace getVariable ["MCC_console3D", false])) + "btn_round_n_ca.paa")] select _on);
	(_d displayCtrl _lb) ctrlSetTextColor (if (_on) then {_col} else {[0.30, 0.31, 0.33, 1]});
} forEach [
	["all", 9201, 9211, [0.88, 0.89, 0.90, 1]],
	["players", 9202, 9212, [0.88, 0.89, 0.90, 1]],
	[west, 9203, 9213, [0.44, 0.63, 0.85, 1]],
	[east, 9204, 9214, [0.82, 0.42, 0.37, 1]],
	[resistance, 9205, 9215, [0.56, 0.75, 0.42, 1]],
	[civilian, 9206, 9216, [0.66, 0.55, 0.82, 1]],
	["orders", 9286, 9287, [0.47, 0.53, 0.88, 1]],
	["ieds", 9283, 9284, [0.76, 0.30, 0.36, 1]]
];
