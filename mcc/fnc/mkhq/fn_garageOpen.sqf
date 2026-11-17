/*
	MCCMK_fnc_garageOpen - (client, spawned) the Virtual Garage for ONE class, from the MCC console's Spawn or Evac panel:
	[class]. Arma's own garage, opened
	on that vehicle, with only its own tab shown and its list trimmed to that one vehicle - Random, Load, Import and the crew
	tabs hidden (kept hidden while it is open) - so only its paint and parts can be changed, never the vehicle. The MCC
	console is closed while it is open and opened again after (it reopens on the panel that was open).
	What it is left with is kept in the profile for that class (MCCMK_garage - between missions) and sent to the server
	(MCCMK_fnc_garageSync): every time that class is spawned from these panels it has that paint and those parts
	(MCCMK_fnc_garageApply).
*/
params [["_cls", "", [""]], ["_panel", -1], ["_from", ""]];
// (MK) nothing to change: no paint choice and no parts - not opened at all
private _cfgV = configFile >> "CfgVehicles" >> _cls;
private _nTex = count ("true" configClasses (_cfgV >> "TextureSources"));
private _nAnim = count ("getText (_x >> 'source') == 'user' && {getText (_x >> 'displayName') != ''}" configClasses (_cfgV >> "AnimationSources"));
if (_nTex < 2 && {_nAnim == 0}) exitWith {[format ["%1 is not customisable in the garage", getText (_cfgV >> "displayName")]] call MCCMK_fnc_hint};
if (_cls == "" || {!isClass (configFile >> "CfgVehicles" >> _cls)} || {!(_cls isKindOf "AllVehicles")} || {_cls isKindOf "CAManBase"}) exitWith {["Garage: no vehicle chosen"] call MCCMK_fnc_hint};
if (!isNil "MCCMK_garageBusy") exitWith {};
MCCMK_garageBusy = true;
private _name = getText (configFile >> "CfgVehicles" >> _cls >> "displayName");
// the console closed (reopened after)
private _hadConsole = !isNull (uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]);
while {dialog} do {closeDialog 0};
uiSleep 0.2;
// (MK) where the garage stands its vehicle (local to this machine only); the view distance 150 m while it is open, put back after
private _vdOld = [viewDistance, getObjectViewDistance select 0];
setViewDistance 150;
setObjectViewDistance 150;
// (the garage puts its vehicle on the surface under its spot, whatever height is given, so: flat open LAND as far as
// possible from every unit, found as it opens; local to this machine - nobody else
// sees it)
private _units = allUnits select {alive _x};
private _best = []; private _bd = -1;
for "_k" from 1 to 40 do {
	if (_bd > 1000) exitWith {};	// (good enough: over 1 km from every unit - no need to try all 40)
	private _q = [random worldSize, random worldSize, 0];
	if (!surfaceIsWater _q) then {
		private _f = [_q, 0, 300, 20, 0, 0.1, 0] call BIS_fnc_findSafePos;	// (gradient 0.1 - fairly flat, not on a hill)
		if ((count _f) >= 2 && {!surfaceIsWater _f} && {((ATLToASL [_f select 0, _f select 1, 0]) isFlatEmpty [-1, -1, 0.15, 12, 0, false]) isNotEqualTo []}) then {
			private _d = if (_units isEqualTo []) then {1e9} else {selectMin (_units apply {_x distance2D _f})};
			if (_d > _bd) then {_bd = _d; _best = _f};
		};
	};
};
if (_best isEqualTo []) then {_best = [getPos player, 0, 1500, 15, 0, 0.3, 0] call BIS_fnc_findSafePos};
private _c = "Land_HelipadEmpty_F" createVehicleLocal [_best select 0, _best select 1, 0];
BIS_fnc_garage_center = _c;
uiNamespace setVariable ["bis_fnc_garage_defaultClass", _cls];
private _ehOpen = [missionNamespace, "garageOpened", {
	params [["_d", displayNull]];
	if (isNull _d) then {_d = uiNamespace getVariable ["BIS_fnc_arsenal_display", displayNull]};
	if (isNull _d) exitWith {};
	{private _b = _x; for "_t" from 0 to 29 do {private _cc = _d displayCtrl (_b + _t); if (!isNull _cc) then {_cc ctrlSetFade 1; _cc ctrlCommit 0}}} forEach [800, 860, 900, 910, 930, 960];
	{if ((ctrlClassName _x) in ["ButtonRandom", "ButtonLoad", "ButtonImport"]) then {_x ctrlShow false}} forEach (allControls _d);
}] call BIS_fnc_addScriptedEventHandler;
["Open", true] call BIS_fnc_garage;
private _t = diag_tickTime + 8;
waitUntil {uiSleep 0.1; !isNull (uiNamespace getVariable ["BIS_fnc_arsenal_display", displayNull]) || {diag_tickTime > _t}};
private _out = [];
if (isNull (uiNamespace getVariable ["BIS_fnc_arsenal_display", displayNull])) then {
	[missionNamespace, "garageOpened", _ehOpen] call BIS_fnc_removeScriptedEventHandler;
	["Garage: it did not open"] call MCCMK_fnc_hint;
} else {
	uiSleep 0.6;
	private _gd = uiNamespace getVariable ["BIS_fnc_arsenal_display", displayNull];
	private _dn = toLower getText (configFile >> "CfgVehicles" >> _cls >> "displayName");
	private _fnModel = {params ["_m"]; _m = toLower _m; if ((_m select [0, 1]) == "\") then {_m = _m select [1]}; if ((count _m) > 4 && {(_m select [(count _m) - 4]) == ".p3d"}) then {_m = _m select [0, (count _m) - 4]}; _m};
	private _myModel = [getText (configFile >> "CfgVehicles" >> _cls >> "model")] call _fnModel;
	private _fnRow = {
		params ["_l"];
		private _r = -1;
		if (!isNull _l) then {
			// by class first - the armed and unarmed Huron share a model, so a model or a name match could be either
			for "_i" from 0 to ((lbSize _l) - 1) do {if ((toLower (_l lbData _i)) == (toLower _cls)) exitWith {_r = _i}};
			if (_r < 0) then {for "_i" from 0 to ((lbSize _l) - 1) do {if (([_l lbData _i] call _fnModel) == _myModel || {(toLower (_l lbText _i)) == _dn}) exitWith {_r = _i}}};
		};
		_r
	};
	// its own tab (the list it is in, else its kind)
	private _tab = -1;
	for "_tt" from 0 to 9 do {if (([_gd displayCtrl (960 + _tt)] call _fnRow) >= 0) exitWith {_tab = _tt}};
	if (_tab < 0) then {
		_tab = switch (true) do {
			case (_cls isKindOf "Plane"): {3};
			case (_cls isKindOf "Helicopter"): {2};
			case (_cls isKindOf "Ship"): {4};
			case (_cls isKindOf "Tank" || {_cls isKindOf "Wheeled_APC_F"}): {1};
			case (_cls isKindOf "StaticWeapon"): {5};
			default {0};
		};
	};
	["TabSelectLeft", [_gd, _tab]] call BIS_fnc_garage;
	uiSleep 0.3;
	// that tab's list trimmed to this ONE vehicle - the row of its class (else the first row of its model or name: never
	// two rows, so another class sharing its model can't be chosen)
	private _l = _gd displayCtrl (960 + _tab);
	if (!isNull _l) then {
		private _keepRow = [_l] call _fnRow;
		if (_keepRow >= 0) then {for "_i" from ((lbSize _l) - 1) to 0 step -1 do {if (_i != _keepRow) then {_l lbDelete _i}}};
	};
	// the crew / passenger tabs (only shown in the garage, never taken) and everything that could change the vehicle: hidden
	private _crewWords = ["crew", "cargo", "passenger", "commander", "driver", "gunner", "pilot"];
	private _fnIsCrewCtrl = {params ["_cc"]; private _s = toLower ((ctrlText _cc) + " " + (ctrlTooltip _cc) + " " + (ctrlClassName _cc)); (_crewWords findIf {(_s find _x) >= 0}) >= 0};
	private _crewTabs = [];
	for "_tt" from 0 to 29 do {if (({private _cc = _gd displayCtrl (_x + _tt); !isNull _cc && {[_cc] call _fnIsCrewCtrl}} count [900, 910, 930]) > 0) then {_crewTabs pushBack _tt}};
	_crewTabs = _crewTabs - [_tab];
	private _crewOther = (allControls _gd) select {private _i = ctrlIDC _x; !((_i >= 800 && {_i < 1000})) && {[_x] call _fnIsCrewCtrl}};
	private _fnLock = {
		for "_tt" from 0 to 29 do {
			if ((_tt <= 5 && {_tt != _tab}) || {_tt in _crewTabs}) then {{private _x2 = _gd displayCtrl (_x + _tt); if (!isNull _x2 && {ctrlShown _x2}) then {_x2 ctrlShow false}} forEach [800, 860, 900, 910, 930, 960]};
		};
		{if ((ctrlClassName _x) in ["ButtonRandom", "ButtonLoad", "ButtonImport"] && {ctrlShown _x}) then {_x ctrlShow false}} forEach (allControls _gd);
		{if (ctrlShown _x) then {_x ctrlShow false}} forEach _crewOther;
	};
	call _fnLock;
	{private _b = _x; for "_tt" from 0 to 29 do {private _cc = _gd displayCtrl (_b + _tt); if (!isNull _cc) then {_cc ctrlSetFade 0; _cc ctrlCommit 0.15}}} forEach [800, 860, 900, 910, 930, 960];
	[missionNamespace, "garageOpened", _ehOpen] call BIS_fnc_removeScriptedEventHandler;
	private _row = [_l] call _fnRow;
	if (_row >= 0) then {_l lbSetCurSel -1; _l lbSetCurSel _row};
	// (MK) the right-hand side opened on what it has: its paint tab, else its parts tab - found by their words (their
	// numbers are the garage's own)
	uiSleep 0.4;
	private _rt = [];
	for "_tt" from 6 to 29 do {
		private _cc = _gd displayCtrl (930 + _tt);
		if (!isNull _cc) then {
			private _s = toLower ((ctrlText _cc) + " " + (ctrlTooltip _cc) + " " + (ctrlClassName _cc));
			private _kind = switch (true) do {
				case ((["texture", "skin", "paint", "camo"] findIf {(_s find _x) >= 0}) >= 0): {"paint"};
				case ((["animation", "component", "part"] findIf {(_s find _x) >= 0}) >= 0): {"parts"};
				default {""};
			};
			_rt pushBack [_tt, _kind, ctrlShown _cc, ctrlEnabled _cc, lbSize (_gd displayCtrl (960 + _tt))];
		};
	};
	private _pick = (_rt select {(_x select 1) == "paint" && {(_x select 4) > 0}}) param [0, []];
	if (_pick isEqualTo []) then {_pick = (_rt select {(_x select 1) == "parts" && {(_x select 4) > 0}}) param [0, []]};
	if (_pick isNotEqualTo []) then {["TabSelectRight", [_gd, _pick select 0]] call BIS_fnc_garage};
	// (where it was put - debug)
	private _g = missionNamespace getVariable ["BIS_fnc_garage_center", objNull];
	if (!isNull _g && {missionNamespace getVariable ["MCC_debug", false]}) then {["INFO", "garage", "spot: %1 at %2, %3 m from the nearest unit, %4 m above the sea", [typeOf _g, mapGridPosition _g, round _bd, round ((getPosASL _g) select 2)]] call MCC_fnc_log};
	waitUntil {uiSleep 0.2; if (!isNull _gd) then {call _fnLock}; isNull (uiNamespace getVariable ["BIS_fnc_arsenal_display", displayNull])};
	// what it was left with - only if it is still this vehicle
	private _g = missionNamespace getVariable ["BIS_fnc_garage_center", objNull];
	if (!isNull _g && {_g isKindOf "AllVehicles"} && {!(_g isKindOf "CAManBase")}) then {
		if ((toLower (typeOf _g)) == (toLower _cls)) then {
			private _cz = [_g] call BIS_fnc_getVehicleCustomization;
			_out = [_cz select 0, _cz select 1];
		};
	};
	if (!isNull _g && {_g != _c} && {!(_g isKindOf "CAManBase")}) then {{deleteVehicle _x} forEach (crew _g); deleteVehicle _g};
};
if (!isNull _c) then {deleteVehicle _c};
setViewDistance (_vdOld select 0);
setObjectViewDistance (_vdOld select 1);
BIS_fnc_garage_center = nil;
uiNamespace setVariable ["bis_fnc_garage_defaultClass", nil];
// kept (profile, between missions) and sent to the server
if (_out isNotEqualTo []) then {
	private _store = profileNamespace getVariable ["MCCMK_garage", createHashMap];
	if !(_store isEqualType createHashMap) then {_store = createHashMap};
	_store set [toLower _cls, _out];
	profileNamespace setVariable ["MCCMK_garage", _store];
	saveProfileNamespace;
	[[[toLower _cls, _out]]] remoteExec ["MCCMK_fnc_garageSync", 2];
	["INFO", "garage", "%1: paint and parts kept - %2", [_cls, _out]] call MCC_fnc_log;
	[format ["Garage: %1 will be spawned with this paint and these parts", _name]] call MCCMK_fnc_hint;
};
MCCMK_garageBusy = nil;
if (_hadConsole) then {
	uiSleep 0.2;
	createDialog (["mcc_groupGen", "mcc_groupGenButtons"] select (profileNamespace getVariable ["MCC_consoleButtons", false]));
	// (MK) back to the panel it was opened from, with the class chosen again in it
	if (_panel >= 0) then {
		waitUntil {uiSleep 0.1; !isNull (uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull])};
		uiSleep 0.3;
		[_panel, true] execVM ((missionNamespace getVariable ["MCC_path", "\mcc_sandbox_mod\"]) + "mcc\general_scripts\groupGen\controlsHandle.sqf");
		uiSleep 0.6;
		[_from, _cls] call MCCMK_fnc_garageReselect;
	};
};
