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
// Where a class comes from: the mod of the addon that first DEFINED it. configSourceMod gives whichever mod last
// changed the class, so a vanilla vehicle that a DLC or mod adjusts would count as that DLC's or mod's content.
private _srcOf = {
	params ["_c"];
	private _adds = configSourceAddonList _c;
	if (_adds isEqualTo []) then {configSourceMod _c} else {configSourceMod (configFile >> "CfgPatches" >> (_adds select 0))}
};
private _c = [[_cfg] call _srcOf] call _groupOf;
private _f = [[configFile >> "CfgFactionClasses" >> _faction] call _srcOf] call _groupOf;
if (_c == _f) exitWith {true};
(_mode == 1) && {_c == 1}
