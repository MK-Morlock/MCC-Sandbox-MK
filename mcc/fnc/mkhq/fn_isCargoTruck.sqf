/*
	MCCMK_fnc_isCargoTruck - a truck built to carry cargo (cargo, covered cargo or flatbed - modded ones too): a truck
	with no more than 2 passenger seats in the back, that isn't a fuel, ammo, repair or medical truck. Troop transports
	(benches in the back) aren't. Cached per type. [vehicle] -> boolean
*/
params [["_v", objNull, [objNull]]];
if (isNull _v) exitWith {false};
private _t = typeOf _v;
private _cache = uiNamespace getVariable "MCCMK_cargoTruckCache";
if (isNil "_cache") then {_cache = createHashMap; uiNamespace setVariable ["MCCMK_cargoTruckCache", _cache]};
private _r = _cache get _t;
if (!isNil "_r") exitWith {_r};
_r = call {
	if !(_v isKindOf "Truck_F") exitWith {false};
	private _c = configFile >> "CfgVehicles" >> _t;
	if ((getNumber (_c >> "transportFuel")) > 0 || {(getNumber (_c >> "transportAmmo")) > 0} || {(getNumber (_c >> "transportRepair")) > 0} || {(getNumber (_c >> "attendant")) > 0}) exitWith {false};
	(getNumber (_c >> "transportSoldier")) <= 2
};
_cache set [_t, _r];
_r
