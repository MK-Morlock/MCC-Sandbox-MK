/*
	MCCMK_fnc_boatDmgGuard - (every computer - the damage handler fires where the aircraft is local, which can change) a boat
	carrier SITTING ON THE WATER takes no damage from boats (as Helocast does for its helicopters): a boat that misses the ramp
	bumps it but doesn't wreck it. Any other damage counts as normal. [aircraft]
*/
params [["_v", objNull]];
if (isNull _v || {_v getVariable ["MCCMK_boatDmgEH", false]}) exitWith {};
_v setVariable ["MCCMK_boatDmgEH", true];
if (missionNamespace getVariable ["MCC_debug", false]) then {["INFO", "boatDmgGuard", "%1: set up on this computer (local here: %2)", [typeOf _v, local _v]] call MCC_fnc_log};
_v addEventHandler ["HandleDamage", {
	params ["_v", "_sel", "_dmg", "_src", "_proj", "_idx"];
	// (MK) from a boat - or COLLISION damage (no weapon) with a boat near it or in its bay: Arma often credits a
	// collision to the helicopter's own pilot
	// (MK) "near": within 5 m EDGE TO EDGE (half of each one's size off the distance between them) - by centres, a big boat
	// can touch a Huron while its centre is over 20 m away
	private _near = {
		private _r = (sizeOf (typeOf _v)) / 2;
		((nearestObjects [_v, ["Ship"], 60]) findIf {((_v distance _x) - _r - ((sizeOf (typeOf _x)) / 2)) < 5}) >= 0
	};
	private _boatHit = (!isNull _src && {_src isKindOf "Ship"}) || {(_proj isEqualTo "" || {_proj isEqualType objNull && {isNull _proj}}) && {(((attachedObjects _v) findIf {_x isKindOf "Ship"}) >= 0) || {call _near}}};
	if (_boatHit && {!isNil "MCCMK_fltAfloat"} && {[_v] call MCCMK_fltAfloat}) exitWith {
		if ((missionNamespace getVariable ["MCC_debug", false]) && {time > (_v getVariable ["MCCMK_guardLogT", 0])}) then {
			_v setVariable ["MCCMK_guardLogT", time + 2];
			["INFO", "boatDmgGuard", "%1: boat damage cancelled (%2, %3)", [typeOf _v, if (_sel == "") then {"overall"} else {_sel}, _dmg toFixed 2]] call MCC_fnc_log;
		};
		if (_sel == "") then {damage _v} else {_v getHitIndex _idx}
	};
	if ((missionNamespace getVariable ["MCC_debug", false]) && {_sel == ""} && {_dmg > ((damage _v) + 0.01)} && {(_v getVariable ["MCCMK_waterLanding", false]) || {!isNil {_v getVariable "MCCMK_waterState"}}} && {time > (_v getVariable ["MCCMK_guardLogT2", 0])}) then {
		_v setVariable ["MCCMK_guardLogT2", time + 1];
		["INFO", "boatDmgGuard", "%1: damage NOT cancelled - overall to %2 (was %3), from %4, projectile '%5', boat hit %6, afloat %7, %8 m above the sea", [typeOf _v, _dmg toFixed 2, (damage _v) toFixed 2, if (isNull _src) then {"nothing"} else {typeOf _src}, _proj, _boatHit, if (isNil "MCCMK_fltAfloat") then {"?"} else {[_v] call MCCMK_fltAfloat}, ((getPosASL _v) select 2) toFixed 1]] call MCC_fnc_log;
	};
	nil
}];
