params [["_comp", "", ["", []]]];
private _key = str _comp;
private _cache = missionNamespace getVariable ["MCC_compFootprints", createHashMap];
if (_key in _cache) exitWith {_cache get _key};
private _r = 0;
if (_comp isEqualType "") then {
	if (_comp == "") exitWith {};
	private _objs = call (compile (preprocessFileLineNumbers format ["%1mcc\general_scripts\docobject\%2.sqf", MCC_path, _comp]));
	if (_objs isEqualType []) then {
		{
			if (_x isEqualType [] && {count _x > 1} && {(_x select 1) isEqualType []} && {count (_x select 1) > 1}) then {
				_r = _r max (vectorMagnitude [(_x select 1) select 0, (_x select 1) select 1, 0]);
			};
		} forEach _objs;
	};
} else {
	private _cfg = configFile >> "CfgGroups" >> "Empty";
	{_cfg = _cfg >> _x} forEach _comp;
	{
		private _p = getArray (_x >> "position");
		if (count _p > 1) then {_r = _r max (vectorMagnitude [_p select 0, _p select 1, 0])};
	} forEach ("isClass _x" configClasses _cfg);
};
_r = ((_r + 4) max 12) min 60;
_cache set [_key, _r];
missionNamespace setVariable ["MCC_compFootprints", _cache];
if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_compositionFootprint", "%1: footprint radius %2 m", [_comp, round _r]] call MCC_fnc_log};
_r
