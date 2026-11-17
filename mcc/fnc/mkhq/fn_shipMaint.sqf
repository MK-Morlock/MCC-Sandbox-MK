params [["_ship", objNull, [objNull]], ["_act", "", [""]], ["_u", objNull, [objNull]], ["_free", false, [true]]];
if (!isServer || {isNull _ship} || {isNull _u}) exitWith {};
private _side = _ship getVariable ["MCC_side", sideUnknown];
private _name = _ship getVariable ["MCC_LHDDisplayName", "Ship"];
if (_free && {!([_u] call MCCMK_fnc_isMissionMaker)}) then {_free = false};
private _say = {params ["_m"]; [_m] remoteExec ["MCCMK_fnc_shipStatusMsg", _u]};
if (!_free && {!([_u, _side] call MCCMK_fnc_shipCanCommand)}) exitWith {["Only the commander can order maintenance."] call _say};
([_ship] call MCCMK_fnc_shipMaintCost) params ["_rep", "_ammo", "_rSup", "_rAmmo", "_nDam", "_nEmpty", "_nDest", "_hull"];
private _need = switch (_act) do {
	case "repair": {[0, _rep, 0]};
	case "rearm": {[_ammo, 0, 0]};
	case "replace": {[_rAmmo, _rSup, 0]};
	case "hull": {[0, _hull, 0]};
	default {[0, 0, 0]};
};
if (_need isEqualTo [0, 0, 0] && {_act != "radar"}) exitWith {["Nothing to do."] call _say};
// Hull: a partial repair if there isn't enough Supply for a full one - whatever Supply is in stock is spent, and the
// hull is repaired by that much.
private _partial = -1;
if (_act == "hull" && {!_free} && {!(call MCCMK_fnc_resFree)}) then {
	private _have = (missionNamespace getVariable [format ["MCC_res%1", _side], [0, 0, 0, 0, 0]]) select 1;
	if (_have < (_need select 1) && {_have >= 1}) then {_partial = floor _have; _need = [0, _partial, 0]};
};
if (_act == "hull" && {(serverTime - (_ship getVariable ["MCCMK_hullLastHit", -1e6])) < 120}) exitWith {["The hull can't be repaired while the ship is under attack."] call _say};
if (_act == "replace" && {(_ship getVariable ["MCCMK_replacingUntil", 0]) > serverTime}) exitWith {["Weapons are already being replaced."] call _say};
if (!_free) then {
	private _var = format ["MCC_res%1", _side];
	private _r = +(missionNamespace getVariable [_var, [0, 0, 0, 0, 0]]);
	if ((_r select 0) < (_need select 0) || {(_r select 1) < (_need select 1)}) exitWith {_free = -1};
	_r set [0, (_r select 0) - (_need select 0)];
	_r set [1, (_r select 1) - (_need select 1)];
	missionNamespace setVariable [_var, _r];
	publicVariable _var;
};
if (_free isEqualTo -1) exitWith {["Not enough resources."] call _say};
switch (_act) do {
	case "repair": {{if (!isNull _x && {alive _x}) then {_x setDamage 0}} forEach (_ship getVariable ["MCCMK_weapons", []]); [format ["%1: weapons repaired.", _name]] call _say};
	case "rearm": {{if (!isNull _x && {alive _x}) then {[_x, 1] remoteExec ["setVehicleAmmo", _x]}} forEach (_ship getVariable ["MCCMK_weapons", []]); [format ["%1: weapons rearmed.", _name]] call _say};
	case "hull": {
		private _full = [1000, 2000, 600, 1500] param [_ship getVariable ["MCC_ShipType", 0], 1000];
		private _hull = if (_partial >= 0) then {((_ship getVariable ["MCCMK_hull", 1]) + (_partial / _full)) min 1} else {1};
		_ship setVariable ["MCCMK_hull", _hull, true];
		if (_hull >= 0.25) then {_ship setVariable ["MCCMK_crippled", false, true]};
		if (_hull > 0) then {_ship setVariable ["MCCMK_disabled", false, true]};
		if (_hull >= 0.5) then {{deleteVehicle _x} forEach (_ship getVariable ["MCCMK_smoke", []]); _ship setVariable ["MCCMK_smoke", []]};
		[if (_partial >= 0) then {format ["%1: hull repaired to %2%3 - not enough Supply for a full repair.", _name, round (_hull * 100), "%"]} else {format ["%1: hull repaired.", _name]}] call _say;
	};
	case "replace": {
		_ship setVariable ["MCCMK_replacingUntil", serverTime + 120, true];
		[format ["%1: replacing %2 weapon(s), about 2 minutes.", _name, _nDest]] call _say;
		[_ship, _side, _name] spawn {
			params ["_ship", "_side", "_name"];
			private _specs = _ship getVariable ["MCCMK_weaponSpecs", []];
			private _ws = _ship getVariable ["MCCMK_weapons", []];
			private _todo = [];
			{
				private _w = _ws param [_forEachIndex, objNull];
				if (isNull _w || {!alive _w}) then {_todo pushBack _forEachIndex; if (!isNull _w) then {{deleteVehicle _x} forEach crew _w; deleteVehicle _w}};
			} forEach _specs;
			sleep 120;
			{[_ship, _side, _specs select _x, _x] call MCCMK_fnc_shipWeaponSpawn} forEach _todo;
			_ship setVariable ["MCCMK_replacingUntil", 0, true];
			[format ["%1: %2 weapon(s) back in service.", _name, count _todo]] remoteExec ["systemChat", _side];
		};
	};
};
["INFO", "ships", "%1 ordered %2 on %3 (%4 Ammo, %5 Supply%6)", [name _u, _act, _name, _need select 0, _need select 1, ["", ", free"] select _free]] call MCC_fnc_log;
