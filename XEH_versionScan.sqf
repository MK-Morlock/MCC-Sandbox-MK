/*======================================================== XEH_versionScan.sqf ===========================================================
	Diagnostic: find which mod owns the text "[1.0.0] 23.09.2014".

	With the full mod list, Arma writes at the main menu:
		Error in expression <[1.0.0] 23.09.2014>
		Error Missing ]
	Some mod is running `compile`/`call compile` on a version string. Arma does not say which mod, so this
	searches for that text (or any "[x.y.z] dd.mm.yyyy"-style string) and writes where it lives to the RPT:

	MCC [WARN] versionScan | ...   one line per match, with the config path / variable name and the source mod
	MCC [INFO] versionScan | ...   start, finish and "no match" lines

	<IN>	0: STRING "config" - scans the game config (run once at game start, from Extended_PreStart_EventHandlers)
			   STRING "menu"   - scans variables, CBA settings and main-menu controls (from Extended_DisplayLoad >> RscDisplayMain)
			1: DISPLAY (only for "menu")
==========================================================================================================================================*/
params [["_mode", "config", [""]], ["_display", displayNull, [displayNull]]];
if !(missionNamespace getVariable ["MCC_debug", false]) exitWith {};

private _fnc_log = {
	params ["_level", "_msg"];
	diag_log text format ["MCC [%1] versionScan | %2", _level, _msg];
};

// true for the exact text, or for anything shaped like "[1.0.0] 23.09.2014"
private _fnc_match = {
	params ["_t"];
	if ((_t find "23.09.2014") >= 0) exitWith {true};
	if ((_t select [0, 1]) != "[") exitWith {false};
	private _close = _t find "]";
	_close >= 6
	&& {count ((_t select [1, _close - 1]) splitString ".") >= 3}
	&& {count ((_t select [_close + 1]) splitString ".") >= 3}
};

private _hits = 0;
private _start = diag_tickTime;

if (_mode == "config") exitWith {
	if (!isNil {uiNamespace getVariable "MCC_versionScan_configDone"}) exitWith {};
	uiNamespace setVariable ["MCC_versionScan_configDone", true];
	["INFO", "scanning game config for the text behind 'Error Missing ]' ([1.0.0] 23.09.2014)"] call _fnc_log;

	private _classes = 0;
	private _fnc_checkClass = {
		params ["_cfg"];
		_classes = _classes + 1;
		{
			private _t = getText _x;
			if ([_t] call _fnc_match) then {
				_hits = _hits + 1;
				["WARN", format ["FOUND config text %1 = %2 | mod: %3 | addons that define this class: %4",
					_x, str _t, configSourceMod _cfg, configSourceAddonList _cfg]] call _fnc_log;
			};
		} forEach configProperties [_cfg, "isText _x", false];
	};

	[configFile] call _fnc_checkClass;
	{
		private _top = _x;
		[_top] call _fnc_checkClass;
		private _children = "true" configClasses _top;
		// very large classes (CfgVehicles, CfgWeapons...) are scanned one level down only, to keep start-up fast
		private _deep = count _children <= 3000;
		{
			[_x] call _fnc_checkClass;
			if (_deep) then {
				{[_x] call _fnc_checkClass} forEach ("true" configClasses _x);
			};
		} forEach _children;
	} forEach ("true" configClasses configFile);

	if (_hits == 0) then {
		["INFO", format ["config: no match in %1 classes (%2 s) - the text is not stored in config; see the main-menu scan", _classes, (diag_tickTime - _start) toFixed 1]] call _fnc_log;
	} else {
		["INFO", format ["config: %1 match(es) in %2 classes (%3 s)", _hits, _classes, (diag_tickTime - _start) toFixed 1]] call _fnc_log;
	};
};

// ---- "menu": runs a few seconds after the main menu opens -------------------------------------------------------------------------
if (!isNil {uiNamespace getVariable "MCC_versionScan_menuDone"}) exitWith {};
uiNamespace setVariable ["MCC_versionScan_menuDone", true];
uiSleep 3;
["INFO", "scanning variables, CBA settings and main-menu controls"] call _fnc_log;

// Variables (strings, or strings one level inside arrays). The variable name usually starts with the mod's tag.
{
	private _ns = _x;
	private _nsName = ["uiNamespace", "missionNamespace", "profileNamespace", "parsingNamespace"] select _forEachIndex;
	{
		private _name = _x;
		private _v = _ns getVariable _name;
		if (!isNil "_v") then {
			private _found = switch (true) do {
				case (_v isEqualType ""): {[_v] call _fnc_match};
				case (_v isEqualType []): {(_v findIf {_x isEqualType "" && {[_x] call _fnc_match}}) >= 0};
				default {false};
			};
			if (_found) then {
				_hits = _hits + 1;
				["WARN", format ["FOUND variable %1 getVariable %2 = %3", _nsName, str _name, str _v select [0, 300]]] call _fnc_log;
			};
		};
	} forEach allVariables _ns;
} forEach [uiNamespace, missionNamespace, profileNamespace, parsingNamespace];

// CBA settings (a mod that keeps its version in a text setting and compiles it)
if (!isNil "cba_settings_allSettings" && {!isNil "CBA_settings_fnc_get"} && {cba_settings_allSettings isEqualType []}) then {
	{
		private _setting = _x;
		private _v = [_setting] call CBA_settings_fnc_get;
		if (!isNil "_v" && {_v isEqualType ""} && {[_v] call _fnc_match}) then {
			_hits = _hits + 1;
			["WARN", format ["FOUND CBA setting %1 = %2", _setting, str _v]] call _fnc_log;
		};
	} forEach cba_settings_allSettings;
};

// Main-menu controls (a mod showing its version on the menu)
if (!isNull _display) then {
	{
		private _t = ctrlText _x;
		if ([_t] call _fnc_match) then {
			_hits = _hits + 1;
			["WARN", format ["FOUND main-menu control %1 (idc %2) text %3", ctrlClassName _x, ctrlIDC _x, str _t]] call _fnc_log;
		};
	} forEach allControls _display;
};

if (_hits == 0) then {
	["INFO", "menu: no match - the text only existed briefly inside another mod's script; compare mod lists instead"] call _fnc_log;
} else {
	["INFO", format ["menu: %1 match(es)", _hits]] call _fnc_log;
};
