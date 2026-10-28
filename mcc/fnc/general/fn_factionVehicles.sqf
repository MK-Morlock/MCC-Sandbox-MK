params [["_faction", "", [""]], ["_role", "", [""]], ["_noSiblings", false, [false]]];
if (_faction == "") exitWith {[]};
private _key = format ["MCC_factionVehicles_%1_%2_%3", toLower _faction, toLower _role, _noSiblings];
private _cached = uiNamespace getVariable _key;
if (!isNil "_cached") exitWith {+_cached};

private _classes = [_faction] call MCC_fnc_factionClasses;
private _result = [];
switch (toLower _role) do {
	case "tank": {
		private _tracked = _classes select {[_x, "tank"] call MCC_fnc_assetRoleMatch};
		private _mbt = _tracked select {toLower getText (_x >> "editorSubcategory") == "edsubcat_tanks"};
		_result = [_tracked, _mbt] select (count _mbt > 0);
	};
	case "cargoheli": {
		_result = _classes select {[_x, "cargoheli"] call MCC_fnc_assetRoleMatch};
		_result = [_result, [], {getNumber (_x >> "slingLoadMaxCargoMass")}, "DESCEND"] call BIS_fnc_sortBy;
	};
	case "officer": {
		_result = _classes select {[_x, "officer"] call MCC_fnc_assetRoleMatch};
		if (count _result == 0) then {
			_result = _classes select {(configName _x isKindOf "CAManBase") && {toLower (configName _x + " " + getText (_x >> "displayName")) find "leader" >= 0}};
		};
	};
	default {
		_result = _classes select {[_x, _role] call MCC_fnc_assetRoleMatch};
	};
};
_result = _result apply {configName _x};

if (count _result == 0 && {!_noSiblings}) then {
	{
		_result append ([_x, _role, true] call MCC_fnc_factionVehicles);
	} forEach ([_faction] call MCC_fnc_factionSiblings);
};
uiNamespace setVariable [_key, _result];
+_result
