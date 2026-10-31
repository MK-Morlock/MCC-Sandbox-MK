params [["_cls", "", [""]]];
private _cfg = configFile >> "CfgVehicles" >> _cls;
if (!isClass _cfg) exitWith {false};
if ((getNumber (_cfg >> "transportFuel")) > 0 || {(getNumber (_cfg >> "transportAmmo")) > 0} || {(getNumber (_cfg >> "transportRepair")) > 0}) exitWith {false};
if (([_cls, true] call BIS_fnc_crewCount) > 1) exitWith {false};
private _real = {
	params ["_list"];
	(_list findIf {private _l = toLower _x; ((_l find "horn") < 0) && {(_l find "smokelauncher") < 0} && {(_l find "flare") < 0}}) >= 0
};
if ([getArray (_cfg >> "weapons")] call _real) exitWith {false};
(([_cls, true] call BIS_fnc_allTurrets) findIf {[getArray (([_cfg, _x] call BIS_fnc_turretConfig) >> "weapons")] call _real}) < 0
