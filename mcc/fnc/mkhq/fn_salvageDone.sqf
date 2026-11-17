/*
	MCCMK_fnc_salvageDone  (server) - a wreck salvaged: removed, and paid for only when it was an ENEMY vehicle the
	salvager's side never bought or crewed (about 10% of its price, split Ammo / Supply / Fuel), Salvage rewards on and
	costs not Free. The first to finish is paid; anyone finishing at the same moment gets nothing. [wreck, salvager]
*/
params [["_v", objNull, [objNull]], ["_u", objNull, [objNull]]];
//(MK) a downed drone too; and a disabled, empty enemy vehicle (MCCMK_fnc_wcVehicle) - worth 1.5x its wreck
private _disabled = alive _v && {_v getVariable ["MCCMK_disabledSalvage", false]} && {!canMove _v} && {((crew _v) findIf {alive _x}) < 0};
if (!isServer || {isNull _v} || {isNull _u} || {alive _v && {!(_v getVariable ["MCCMK_downedDrone", false])} && {!_disabled}} || {_v getVariable ["MCCMK_salvaged", false]}) exitWith {};
_v setVariable ["MCCMK_salvaged", true];
private _side = side group _u;
private _pay = [0, 0, 0];
if ((missionNamespace getVariable ["MCCMK_salvageRewards", true]) && {!(call MCCMK_fnc_resFree)}) then {
	private _cs = getNumber (configOf _v >> "side");
	private _vs = [east, west, independent, civilian] param [_cs, civilian];
	private _rec = _v getVariable ["MCCMK_bought", []];
	private _ours = ((_rec param [3, sideUnknown]) isEqualTo _side) || {_side in (_v getVariable ["MCCMK_usedBy", []])};
	if (_cs in [0, 1, 2] && {[_side, _vs] call BIS_fnc_sideIsEnemy} && {!_ours}) then {
		private _c = [_v] call MCCMK_fnc_salvageCost;
		private _k = [1, 1.5] select _disabled;
		_pay = [floor (_c * 0.2 * 0.3 * 0.1 * _k), floor (_c * 0.2 * 0.5 * 0.1 * _k), floor (_c * 0.2 * 0.2 * 0.1 * _k)];
	};
	//(MK) your own side's wreck it BOUGHT with resources: 10% of what was paid back (the same as salvaging an enemy's wreck
	// of it pays; selling it intact gives 60%). Free vehicles (the console's, a mission's, given at the start) pay nothing.
	if (!alive _v && {(_rec param [0, ""]) == "res"} && {(_rec param [3, sideUnknown]) isEqualTo _side}) then {
		(_rec param [1, [0, 0, 0]]) params [["_ra", 0], ["_rs", 0], ["_rf", 0]];
		_pay = [floor (_ra * 0.1), floor (_rs * 0.1), floor (_rf * 0.1)];
	};
};
//(MK) a Taru pod the salvager's side paid for: part of what it cost back (the Sell vehicle rate for bought ones). A free
// one (the MCC console's, or ordered while resources were Free) gives nothing back.
private _podPaid = _v getVariable ["MCCMK_podPaid", []];
private _podBack = [];
if (count _podPaid == 2 && {(_podPaid select 1) isEqualTo _side} && {!(call MCCMK_fnc_resFree)}) then {
	private _pct = (missionNamespace getVariable ["MCCMK_sellBought", 60]) / 100;
	(_podPaid select 0) params [["_ca", 0], ["_cs", 0], ["_cf", 0], ["_cm", 0]];
	_podBack = [floor (_ca * _pct), floor (_cs * _pct), floor (_cf * _pct), floor (_cm * _pct)];
};
private _name = getText (configOf _v >> "displayName");
{deleteVehicle _x} forEach (crew _v);
deleteVehicle _v;
if (count _podBack == 4 && {((_podBack select 0) + (_podBack select 1) + (_podBack select 2) + (_podBack select 3)) > 0}) exitWith {
	private _var = format ["MCC_res%1", _side];
	private _r = +(missionNamespace getVariable [_var, [0, 0, 0, 0, 0]]);
	_r set [0, (_r select 0) + (_podBack select 0)];
	_r set [1, (_r select 1) + (_podBack select 1)];
	_r set [2, (_r select 2) + (_podBack select 2)];
	_r set [4, (_r select 4) + (_podBack select 3)];
	missionNamespace setVariable [_var, _r];
	publicVariable _var;
	[format ["Pod salvaged: +%1 Supply, +%2 Ammo, +%3 Fuel, +%4 Meds.", _podBack select 1, _podBack select 0, _podBack select 2, _podBack select 3]] remoteExec ["MCCMK_fnc_hint", _u];
	["INFO", "salvage", "%1 salvaged a %2 wreck | refunded %3 (ammo, supply, fuel, meds)", [name _u, _name, _podBack]] call MCC_fnc_log;
};
if ((_pay select 0) + (_pay select 1) + (_pay select 2) > 0) then {
	private _var = format ["MCC_res%1", _side];
	private _r = +(missionNamespace getVariable [_var, [0, 0, 0, 0, 0]]);
	{_r set [_forEachIndex, (_r select _forEachIndex) + _x]} forEach _pay;
	missionNamespace setVariable [_var, _r];
	publicVariable _var;
	[format ["Wreck salvaged: +%1 Supply, +%2 Ammo, +%3 Fuel.", _pay select 1, _pay select 0, _pay select 2]] remoteExec ["MCCMK_fnc_hint", _u];
} else {
	["Wreck cleared."] remoteExec ["MCCMK_fnc_hint", _u];
};
["INFO", "salvage", "%1 salvaged a %2 wreck | paid %3 (ammo, supply, fuel)", [name _u, _name, _pay]] call MCC_fnc_log;
