params [["_faction", "", [""]]];
if (_faction == "") exitWith {[]};
private _key = "MCC_factionSiblings_" + toLower _faction;
private _cached = uiNamespace getVariable _key;
if (!isNil "_cached") exitWith {+_cached};

private _cfgF = configFile >> "CfgFactionClasses";
private _mod = toLower configSourceMod (_cfgF >> _faction);
private _side = [_faction] call MCC_fnc_factionSide;
private _result = [];
{
	private _f = configName _x;
	if (toLower _f != toLower _faction && {isNumber (_x >> "side")} && {getNumber (_x >> "side") in [0, 1, 2, 3]} && {toLower configSourceMod _x == _mod} && {([_f] call MCC_fnc_factionSide) isEqualTo _side}) then {
		_result pushBack _f;
	};
} forEach ("true" configClasses _cfgF);
uiNamespace setVariable [_key, _result];
+_result
