/*
	MCCMK_fnc_factionAssets - a faction's vehicles or soldiers of one kind, from its pools (MCCMK_fnc_pools - MCC MK's
	single faction filter): its own content, then official DLC, then all, then a sibling faction's; never vanilla (callers
	have their own fallback). Kinds: air (armed planes and helicopters), boat (armed boats), smallboat (boats seating 3+),
	transportheli (helicopters seating 4+), anyair, lightarmed (armed cars, not trucks or APCs), men (riflemen and the like -
	no pilots, crews, snipers, officers, UAV operators). Not submarines (SDVs). [faction, kind] -> [classes]
*/
params [["_faction", "", [""]], ["_kind", "air", [""]]];
if (isNil "MCCMK_assetCache") then {MCCMK_assetCache = createHashMap};
private _key = _faction + "|" + _kind;
if (_key in MCCMK_assetCache) exitWith {+(MCCMK_assetCache get _key)};
private _own = {params ["_k"]; [_faction, _k] call MCCMK_fnc_poolOwn};
private _seats = {params ["_c"]; getNumber (configFile >> "CfgVehicles" >> _c >> "transportSoldier")};
private _out = switch (_kind) do {
	case "air": {(["PlaneCAS"] call _own) + (["HeliArmed"] call _own)};
	case "boat": {(["ShipArmed"] call _own) select {!(_x isKindOf "SDV_01_base_F")}};
	case "smallboat": {(["Ship"] call _own) select {!(_x isKindOf "SDV_01_base_F") && {([_x] call _seats) >= 3}}};
	case "transportheli": {(["Heli"] call _own) select {([_x] call _seats) >= 4}};
	case "anyair": {(["Plane"] call _own) + (["Heli"] call _own)};
	case "lightarmed": {(["CarTurret"] call _own) select {!(_x isKindOf "Truck_F")}};
	case "men": {(["Inf"] call _own) select {private _l = toLower _x; (["pilot", "crew", "diver", "survivor", "unarmed", "story", "_vr_", "sniper", "spotter", "officer", "uav"] findIf {(_l find _x) >= 0}) < 0}};
	default {[]};
};
_out = _out arrayIntersect _out;
MCCMK_assetCache set [_key, _out];
+_out
