params [["_def", "", [""]], ["_fac", "", [""]], ["_noLift", false, [false]]];
if (_def == "" || {_fac == ""} || {!isClass (configFile >> "CfgVehicles" >> _def)}) exitWith {_def};
if ((toUpper (getText (configFile >> "CfgVehicles" >> _def >> "faction"))) == toUpper _fac) exitWith {_def};
private _key = format ["MCCMK_facVehMatch_%1_%2", toUpper _fac, _def];
if (!isNil _key) exitWith {missionNamespace getVariable _key};
private _pool = [_fac] call MCCMK_fnc_factionVehicles;
private _m = if (count _pool == 0) then {""} else {[_def, _pool, _noLift] call MCCMK_fnc_matchVehicle};
if (_m isEqualType "" && {_m != ""}) then {
	["INFO", "factionVehicle", "%1 for %2: %3 (in place of %4)", [_fac, getText (configFile >> "CfgVehicles" >> _def >> "displayName"), _m, _def]] call MCC_fnc_log;
} else {_m = _def};
missionNamespace setVariable [_key, _m];
_m
