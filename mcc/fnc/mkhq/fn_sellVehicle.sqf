params [["_v", objNull, [objNull]], ["_u", objNull, [objNull]], ["_toCredits", false, [true]]];
if (!isServer) exitWith {};
([_v, _u] call MCCMK_fnc_sellCheck) params ["_cat", "_rec", "_who"];
if (_cat == "") exitWith {["This vehicle can't be sold here."] remoteExec ["MCCMK_fnc_hint", _u]};
private _name = getText (configOf _v >> "displayName");
private _side = side group _u;
private _cr = switch (true) do {
	case (_cat == "seized"): {_toCredits || {_who != "cmd"}};
	default {(_rec select 0) == "cr"};
};
private _val = [_v, _cat, _rec, _cr] call MCCMK_fnc_sellValue;
deleteVehicle _v;
if ((_val select 0) == "res") then {
	private _var = format ["MCC_res%1", _side];
	private _r = +(missionNamespace getVariable [_var, [0, 0, 0, 0, 0]]);
	{_r set [_forEachIndex, (_r select _forEachIndex) + _x]} forEach (_val select 1);
	missionNamespace setVariable [_var, _r];
	publicVariable _var;
	[format ["Sold %1: +%2 Ammo, +%3 Supply, +%4 Fuel for the side.", _name, (_val select 1) select 0, (_val select 1) select 1, (_val select 1) select 2]] remoteExec ["MCCMK_fnc_hint", _u];
} else {
	private _uid = if (_cat == "bought") then {_rec param [2, getPlayerUID _u]} else {getPlayerUID _u};
	private _who2 = if (_cat == "bought") then {_rec param [4, name _u]} else {name _u};
	[_uid, _who2, _val select 1, format ["You received %1 credits from the sale of %2.", _val select 1, _name]] call MCCMK_fnc_creditAdd;
	if (_uid != getPlayerUID _u) then {[format ["Sold %1: %2 credits refunded to %3.", _name, _val select 1, _who2]] remoteExec ["MCCMK_fnc_hint", _u]};
};
["INFO", "selling", "%1 sold %2 (%3) for %4", [name _u, _name, _cat, _val]] call MCC_fnc_log;
