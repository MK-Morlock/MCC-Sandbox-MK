params [["_v", objNull, [objNull]], ["_u", objNull, [objNull]]];
private _no = ["", [], ""];
if (isNull _v || {isNull _u} || {!alive _v}) exitWith {_no};
if !(_v isKindOf "LandVehicle" || {_v isKindOf "Air"} || {_v isKindOf "Ship"}) exitWith {_no};
if (_v isKindOf "StaticWeapon" || {_v getVariable ["MCC_isLHD", false]}) exitWith {_no};
if (((crew _v) select {alive _x}) isNotEqualTo []) exitWith {_no};
private _side = side group _u;
private _rec = _v getVariable ["MCCMK_bought", []];
private _cat = "";
if (_rec isNotEqualTo []) then {
	if ((_rec param [0, ""]) in ["res", "cr"] && {(_rec param [3, sideUnknown]) isEqualTo _side}) then {_cat = "bought"};
} else {
	private _cs = getNumber (configOf _v >> "side");
	private _vs = [east, west, independent, civilian] param [_cs, civilian];
	if (_cs in [0, 1, 2] && {[_side, _vs] call BIS_fnc_sideIsEnemy}) then {_cat = "seized"};
};
if (_cat == "") exitWith {_no};
private _r = missionNamespace getVariable ["MCCMK_sellRadius", 30];
private _bases = ([_side] call MCCMK_fnc_spawnPoints) select {!(_x getVariable ["MCC_isLHD", false])};
private _at = (_bases findIf {(_x distance2D _v) < _r}) >= 0;
if (!_at) then {_at = ((missionNamespace getVariable ["MCCMK_vehicleShops", []]) findIf {!isNull _x && {(_x distance2D _v) < _r}}) >= 0};
if (!_at && {_cat == "bought"}) then {
	_at = ((missionNamespace getVariable ["MCC_staticShips", []]) findIf {
		!isNull _x && {(_x getVariable ["MCC_side", sideUnknown]) isEqualTo _side} && {(_x distance2D _v) < ((([_x getVariable ["MCC_ShipType", 0]] call MCCMK_fnc_shipCfg) select 3) select 1) + _r}
	}) >= 0;
};
if (!_at) exitWith {_no};
private _isCmd = ((missionNamespace getVariable ["MCC_server", objNull]) getVariable [format ["CP_commander%1", _side], ""]) == getPlayerUID _u;
private _who = switch (true) do {
	case (_cat == "seized"): {["seller", "cmd"] select _isCmd};
	case ((_rec select 0) == "res"): {["", "cmd"] select _isCmd};
	default {["", "buyer"] select (_isCmd || {(_rec param [2, ""]) == getPlayerUID _u})};
};
if (_who == "") exitWith {_no};
[_cat, _rec, _who]
