params [["_object", objNull, [objNull]]];
if (isNull _object) exitWith {""};

private _model = toLower ((getModelInfo _object) param [0, ""]);
private _class = toLower (typeOf _object);
private _key = _model + "|" + _class;
if (_key == "|") then {_key = toLower str _object};

private _cache = missionNamespace getVariable "MCC_survivalObjectTypeCache";
if (isNil "_cache") then {_cache = createHashMap; missionNamespace setVariable ["MCC_survivalObjectTypeCache", _cache]};
private _cached = _cache get _key;
if (!isNil "_cached") exitWith {_cached};

private _text = _model + " " + _class + " " + toLower str _object;
private _result = "";
{
	private _category = _x;
	if ((missionNamespace getVariable [_category, []]) findIf {_text find (toLower _x) >= 0} >= 0) exitWith {_result = _category};
} forEach ([false] call MCC_fnc_getSurvivalPlaceHolders);

_cache set [_key, _result];
_result
