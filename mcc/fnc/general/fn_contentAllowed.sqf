params [["_cls", "", ["", configNull]], ["_faction", "", [""]], ["_mode", 2, [0]]];
if (_mode >= 2) exitWith {true};
private _cfg = if (_cls isEqualType "") then {configFile >> "CfgVehicles" >> _cls} else {_cls};
if (!isClass _cfg) exitWith {true};
private _groups = uiNamespace getVariable "MCC_modSourceGroups";
if (isNil "_groups") then {
	_groups = createHashMap;
	{_groups set [toLower (_x select 1), [_x select 2, _x select 3]]} forEach getLoadedModsInfo;
	uiNamespace setVariable ["MCC_modSourceGroups", _groups];
	if (missionNamespace getVariable ["MCC_debug", false]) then {
		["DEBUG", "contentFilter", "content sources: %1", [(keys _groups) apply {[_x, _groups get _x]}]] call MCC_fnc_log;
	};
};
private _groupOf = {
	params ["_src"];
	if (_src == "") exitWith {0};
	private _i = _groups getOrDefault [toLower _src, [false, false]];
	if (_i select 0) exitWith {0};
	if (_i select 1) exitWith {1};
	2
};
private _c = [configSourceMod _cfg] call _groupOf;
private _f = [configSourceMod (configFile >> "CfgFactionClasses" >> _faction)] call _groupOf;
if (_c == _f) exitWith {true};
(_mode == 1) && {_c == 1}
