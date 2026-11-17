params [["_rule", "all", [""]], ["_groups", [], [[]]]];
if (_rule == "all") exitWith {true};
(_groups findIf {
	private _us = (units _x) select {alive _x};
	private _vs = [];
	{if (vehicle _x != _x) then {_vs pushBackUnique (vehicle _x)}} forEach _us;
	!(switch (_rule) do {
		case "foot": {(_us findIf {vehicle _x == _x}) >= 0};
		case "veh": {count _vs > 0};
		case "cargo": {(_vs findIf {getNumber (configOf _x >> "transportSoldier") > 0}) >= 0};
		case "pass": {(_vs findIf {count (fullCrew [_x, "cargo"]) > 0}) >= 0};
		case "support": {(_vs findIf {private _c = configOf _x; (getNumber (_c >> "transportRepair") > 0) || {getNumber (_c >> "transportFuel") > 0} || {getNumber (_c >> "transportAmmo") > 0} || {getNumber (_c >> "attendant") > 0}}) >= 0};
		case "heli": {(_vs findIf {_x isKindOf "Helicopter" || {_x isKindOf "VTOL_Base_F"}}) >= 0};
		case "air": {(_vs findIf {_x isKindOf "Air"}) >= 0};
		case "arty": {(_vs findIf {getNumber (configOf _x >> "artilleryScanner") == 1}) >= 0};
		case "taru": {(_vs findIf {((toLower typeOf _x) find "heli_transport_04") >= 0}) >= 0};
		case "boat": {(_vs findIf {_x isKindOf "Ship"}) >= 0};
		case "carrier": {(_vs findIf {[_x] call MCCMK_fnc_boatCarrier && {!(_x isKindOf "Plane")}}) >= 0};
		case "carrierboat": {(_vs findIf {[_x] call MCCMK_fnc_boatCarrier && {!isNull ([_x] call MCCMK_fltAttached)}}) >= 0};
		default {true};
	})
}) < 0
