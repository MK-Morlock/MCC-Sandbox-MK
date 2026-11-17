/*
	MCCMK_fnc_supportAir - (server) a SUPPORT AIRCRAFT set up as the CBA options say ("Support aircraft", MCCMK Commander
	Console): [aircraft, the side it works for, what it is ("Rescue helicopter")]. The rescue helicopter (or boat), rope
	extraction, pickup and Boat pickup helicopters, fast-rope helicopters, the airdrop plane and paradrop aircraft.
	  - "Support aircraft: invulnerable" (off): on - neither it nor its crew can be damaged;
	  - "Support aircraft: targeted by the enemy" (off): off - its crew captive, the enemy ignores it (MCC's blue icon still
	    shows it as yours - MCCMK_fnc_airIcons); on - a normal target (its crew put on the side it works for if they were
	    made civilian).
	And when it is destroyed, its side is told ("Rescue helicopter destroyed"); with debug on, what hit it is logged.
*/
params [["_v", objNull], ["_side", civilian], ["_what", "Support aircraft"]];
if (!isServer || {isNull _v}) exitWith {};
// the side it works for: as its group is already flagged (MCC_dropFor), if it was given as civilian (the airdrop plane is
// created civilian); and its group flagged with it - MCC's blue map icon (MCCMK_fnc_airIcons) and the consoles show only
// flagged aircraft, and a captive crew has no icon of Arma's own 
private _dg = group (driver _v);
if (isNull _dg) then {_dg = group ((crew _v) param [0, objNull])};
if (!(_side in [west, east, resistance]) && {!isNull _dg}) then {_side = _dg getVariable ["MCC_dropFor", _side]};
if (!isNull _dg && {_side in [west, east, resistance]}) then {_dg setVariable ["MCC_dropFor", _side, true]};
private _inv = missionNamespace getVariable ["MCCMK_supportInvuln", false];
private _tgt = missionNamespace getVariable ["MCCMK_supportTargeted", false];
if (_inv) then {_v allowDamage false; {_x allowDamage false} forEach (crew _v)};
if (_tgt) then {
	private _d = driver _v;
	if (!isNull _d && {(side group _d) isEqualTo civilian} && {!(_side isEqualTo civilian)}) then {
		private _g0 = group _d;
		private _g = createGroup [_side, true];
		(crew _v) joinSilent _g;
		_g setBehaviour "CARELESS"; _g setCombatMode "BLUE";
		{_g setVariable [_x, _g0 getVariable _x, true]} forEach ((allVariables _g0) select {(_x find "mcc") == 0});
	};
	_v setCaptive false; {_x setCaptive false} forEach (crew _v);
} else {
	_v setCaptive true; {_x setCaptive true} forEach (crew _v);
};
_v setVariable ["MCCMK_supportWhat", [_what, _side]];
if (_v getVariable ["MCCMK_supportEH", false]) exitWith {};
_v setVariable ["MCCMK_supportEH", true];
_v addEventHandler ["Killed", {
	params ["_v", "_k", "_i"];
	(_v getVariable ["MCCMK_supportWhat", ["Support aircraft", civilian]]) params ["_what", "_side"];
	["MCCNotificationBad", ["Support", format ["%1 destroyed", _what], ""]] remoteExec ["bis_fnc_showNotification", [0, _side] select (_side in [west, east, independent])];
	["INFO", "support", "%1 (%2) destroyed at %3 | by %4 (%5)", [_what, typeOf _v, mapGridPosition _v, if (isNull _k) then {"nothing"} else {typeOf _k}, if (isNull _i) then {"-"} else {name _i}]] call MCC_fnc_log;
}];
