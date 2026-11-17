/*
	MCCMK_fnc_isArmedBoat - does a boat class carry a real weapon (a turret's, or the driver's)? Horns, smoke launchers,
	flares, searchlights and laser designators don't count. Cached per class. [class] -> boolean
	(MCCMK_fnc_armedBoatFallback: the side's vanilla armed speedboat, for a faction with no armed boats.)
*/
params [["_cls", "", [""]]];
private _cache = uiNamespace getVariable "MCCMK_armedBoatCache";
if (isNil "_cache") then {_cache = createHashMap; uiNamespace setVariable ["MCCMK_armedBoatCache", _cache]};
private _r = _cache get _cls;
if (!isNil "_r") exitWith {_r};
private _real = {
	params ["_ws"];
	(_ws findIf {
		private _l = toLower _x;
		((_l find "horn") < 0) && {(_l find "smoke") < 0} && {(_l find "flare") < 0} && {(_l find "laserdesignator") < 0} && {(_l find "searchlight") < 0}
	}) >= 0
};
_r = isClass (configFile >> "CfgVehicles" >> _cls) && {
	([getArray (configFile >> "CfgVehicles" >> _cls >> "weapons")] call _real)
	|| {(([_cls, false] call BIS_fnc_allTurrets) findIf {[getArray (([_cls, _x] call BIS_fnc_turretConfig) >> "weapons")] call _real}) >= 0}
};
_cache set [_cls, _r];
_r
