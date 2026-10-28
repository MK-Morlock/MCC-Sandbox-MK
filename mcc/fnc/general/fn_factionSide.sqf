params [["_faction", "", [""]], ["_strict", false, [false]]];
if (_faction == "") exitWith {[0,-1] select _strict};

private _cfgSide = configFile >> "CfgFactionClasses" >> _faction >> "side";
if (isNumber _cfgSide && {getNumber _cfgSide in [0,1,2,3]}) exitWith {getNumber _cfgSide};

private _map = missionNamespace getVariable "MCC_factionSideCache";
if (isNil "_map") then {
	_map = createHashMap;
	{
		private _f = getText (_x >> "faction");
		private _s = getNumber (_x >> "side");
		if (_f != "" && {_s in [0,1,2,3]} && {!(_f in _map)} && {configName _x isKindOf "CAManBase" || {configName _x isKindOf "AllVehicles"}}) then {
			_map set [_f, _s];
		};
	} forEach ("getNumber (_x >> 'scope') >= 2" configClasses (configFile >> "CfgVehicles"));
	missionNamespace setVariable ["MCC_factionSideCache", _map];
};

private _side = _map getOrDefault [_faction, -1];
if (_side < 0) exitWith {
	if (!_strict) then {["WARN", "MCC_fnc_factionSide", "faction %1 has no side in CfgFactionClasses and no units - treated as EAST", [_faction]] call MCC_fnc_log};
	[0,-1] select _strict
};
if !(missionNamespace getVariable [format ["MCC_factionSideLogged_%1", _faction], false]) then {
	missionNamespace setVariable [format ["MCC_factionSideLogged_%1", _faction], true];
	["INFO", "MCC_fnc_factionSide", "faction %1 has no side in CfgFactionClasses - using its units' side %2", [_faction, _side]] call MCC_fnc_log;
};
_side
