/*================================================================== MCC_fnc_assetsCandidates ==================================================================
	Classes offered for an asset slot on the Assets page.
	Vehicles and units: the selected factions (enemy and player faction, with the other factions of their mods); with
	Show all mods: every public class of that kind from every loaded mod.
	Objects: vanilla plus the mods of the selected factions; with Show all mods: every mod.
	Kept for the game session. Run scheduled (the first full scan can take a few seconds).
	<IN>	0: STRING role, 1: BOOL show all mods, 2: ARRAY selected factions
	<OUT>	ARRAY of [display text, class], sorted by text
==============================================================================================================================================================*/
params [["_role", "", [""]], ["_showAll", false, [false]], ["_factions", [], [[]]]];
private _isObject = toLower _role in ["cache", "radio", "radar", "fuel", "intel"];
private _key = format ["MCC_assetCand_%1_%2_%3", toLower _role, _showAll, (_factions apply {toLower _x}) joinString ","];
private _cached = uiNamespace getVariable _key;
if (!isNil "_cached") exitWith {+_cached};

private _modOf = {
	private _m = configSourceMod _this;
	if (_m == "") then {"Arma 3"} else {_m}
};
private _classes = [];
if (_isObject) then {
	private _pool = uiNamespace getVariable "MCC_assetObjectPool";
	if (isNil "_pool") then {
		_pool = "getNumber (_x >> 'scope') == 2 && {!(configName _x isKindOf 'AllVehicles')} && {getText (_x >> 'model') != ''}" configClasses (configFile >> "CfgVehicles");
		uiNamespace setVariable ["MCC_assetObjectPool", _pool];
	};
	private _mods = [""];
	{_mods pushBackUnique toLower configSourceMod (configFile >> "CfgFactionClasses" >> _x)} forEach _factions;
	_classes = _pool select {(_showAll || {toLower configSourceMod _x in _mods}) && {[_x, _role] call MCC_fnc_assetRoleMatch}};
} else {
	if (_showAll) then {
		private _pool = uiNamespace getVariable "MCC_assetVehiclePool";
		if (isNil "_pool") then {
			_pool = "getNumber (_x >> 'scope') == 2 && {configName _x isKindOf 'AllVehicles'}" configClasses (configFile >> "CfgVehicles");
			uiNamespace setVariable ["MCC_assetVehiclePool", _pool];
		};
		_classes = _pool select {[_x, _role] call MCC_fnc_assetRoleMatch};
	} else {
		private _fs = [];
		{_fs pushBackUnique _x; {_fs pushBackUnique _x} forEach ([_x] call MCC_fnc_factionSiblings)} forEach _factions;
		{
			_classes append (([_x] call MCC_fnc_factionClasses) select {[_x, _role] call MCC_fnc_assetRoleMatch});
		} forEach _fs;
	};
};

private _result = [];
private _seen = [];
{
	private _c = configName _x;
	if !(toLower _c in _seen) then {
		_seen pushBack toLower _c;
		private _who = if (_isObject) then {_x call _modOf} else {
			private _f = getText (_x >> "faction");
			getText (configFile >> "CfgFactionClasses" >> _f >> "displayName") + " / " + (_x call _modOf)
		};
		_result pushBack [format ["%1 (%2) - %3", getText (_x >> "displayName"), _c, _who], _c];
	};
} forEach _classes;
_result sort true;
uiNamespace setVariable [_key, _result];
+_result
