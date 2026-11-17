// (server) Sells a ship: the commander (or mission maker); nobody on its deck; parked vehicles moved off first, or sold
// with it (each at its own sell value). The ship's value goes to the side's resources, and the ship is removed.
// [ship, caller, sell vehicles too]
params [["_ship", objNull, [objNull]], ["_u", objNull, [objNull]], ["_withVeh", false, [true]]];
if (!isServer || {isNull _ship} || {isNull _u}) exitWith {};
private _say = {params ["_m"]; [_m] remoteExec ["MCCMK_fnc_hint", _u]};
private _side = _ship getVariable ["MCC_side", side group _u];
if !(([_u] call MCCMK_fnc_isMissionMaker) || {[_u, _side] call MCCMK_fnc_shipCanCommand}) exitWith {["Only the commander can sell ships."] call _say};
if (_ship getVariable ["MCCMK_sinking", false]) exitWith {["The ship is sinking - it can't be sold."] call _say};
([_ship] call MCCMK_fnc_shipAboard) params ["_men", "_veh"];
if (count _men > 0) exitWith {[format ["%1 soldier(s) are still on its deck - everyone must leave the ship first.", count _men]] call _say};
if (count _veh > 0 && {!_withVeh}) exitWith {[format ["%1 vehicle(s) are parked on it - move them off first, or sell them with the ship.", count _veh]] call _say};
if (_withVeh && {(_veh findIf {((crew _x) findIf {alive _x && {isPlayer _x}}) >= 0}) >= 0}) exitWith {["Someone is in a vehicle on the ship - everyone must get out first."] call _say};
private _name = _ship getVariable ["MCC_LHDDisplayName", "Ship"];
([_ship] call MCCMK_fnc_shipSellValue) params ["_a", "_s", "_f", "_bought"];
if (_withVeh) then {
	{
		private _c = ([_x, _u] call MCCMK_fnc_sellCheck) select 0;
		if (_c != "") then {[_x, _u] call MCCMK_fnc_sellVehicle} else {{deleteVehicle _x} forEach (crew _x); deleteVehicle _x};
	} forEach _veh;
};
private _var = format ["MCC_res%1", _side];
private _r = +(missionNamespace getVariable [_var, [0, 0, 0, 0, 0]]);
_r set [0, (_r select 0) + _a];
_r set [1, (_r select 1) + _s];
_r set [2, (_r select 2) + _f];
missionNamespace setVariable [_var, _r];
publicVariable _var;
[_ship, format ["%1 sold: +%2 Supply, +%3 Ammo, +%4 Fuel.", _name, _s, _a, _f]] call MCCMK_fnc_shipRemove;
[format ["Sold the %1: +%2 Supply, +%3 Ammo, +%4 Fuel for the side.", _name, _s, _a, _f]] call _say;
["INFO", "ships", "%1 sold %2 (%3) for %4 Supply, %5 Ammo, %6 Fuel%7", [name _u, _name, ["placed", "bought"] select _bought, _s, _a, _f, ["", format [" with %1 vehicle(s)", count _veh]] select _withVeh]] call MCC_fnc_log;
