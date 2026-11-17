/*
	MCCMK_fnc_heliStateText - an aircraft's state in one line, for the logs: [aircraft] -> text. Engine, can move, overall
	damage, every engine / rotor part's damage, fuel, height above the sea, its pilot and crew, and the pilot's order.
*/
params [["_h", objNull]];
if (isNull _h) exitWith {"(gone)"};
private _parts = [];
(getAllHitPointsDamage _h) params [["_names", []], ["_sels", []], ["_dmg", []]];
{
	private _n = toLower _x;
	if ((_n find "engine") >= 0 || {(_n find "rotor") >= 0} || {(_n find "transmission") >= 0} || {(_n find "fuel") >= 0}) then {_parts pushBack format ["%1 %2", _x, (_dmg param [_forEachIndex, 0]) toFixed 2]};
} forEach _names;
private _d = driver _h;
private _pb = _h call BIS_fnc_getPitchBank;
format ["engine %1, can move %2, damage %3 | parts: %4 | fuel %5, centre %6 m above the sea, nose %12 deg (+ up), lean %13 deg | pilot %7, crew %8 | pilot's order '%9', done %10 | boat in the bay: %11",
	isEngineOn _h, canMove _h, (damage _h) toFixed 2, _parts joinString ", ", (fuel _h) toFixed 2, ((getPosASL _h) select 2) toFixed 1,
	if (isNull _d) then {"none"} else {format ["%1 (%2)", name _d, ["dead", "alive"] select (alive _d)]}, count (crew _h),
	if (isNull _d) then {"-"} else {currentCommand _d}, if (isNull _d) then {"-"} else {unitReady _d},
	if (isNil "MCCMK_fltAttached") then {"?"} else {private _b = [_h] call MCCMK_fltAttached; if (isNull _b) then {"no"} else {typeOf _b}},
	(_pb select 0) toFixed 1, (_pb select 1) toFixed 1]
