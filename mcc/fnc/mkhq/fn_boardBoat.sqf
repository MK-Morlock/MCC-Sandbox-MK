params [["_mode", "alone", [""]], ["_boat", objNull, [objNull]], ["_incl", true, [true]]];
([player] call MCCMK_fnc_boardState) params ["_st", "_ship"];
private _what = ["Send to boat", "Board boat"] select _incl;
if (_st != "deck") exitWith {[format ["%1: you need to be on the ship's deck.", _what]] call MCCMK_fnc_hint};
if (isNull _boat) then {
	private _boats = [_ship] call MCCMK_fnc_boatsAlongside;
	if (_boats isEqualTo []) exitWith {[format ["%1: no boat with free seats alongside the ship.", _what]] call MCCMK_fnc_hint};
	if (count _boats == 1) exitWith {_boat = _boats select 0};
	[_mode, _incl, _ship, _boats] call MCCMK_fnc_boatChoice;
};
if (isNull _boat || {!alive _boat}) exitWith {};
private _who = [_mode, "deck", _incl] call MCCMK_fnc_boardUnits;
if (_who isEqualTo []) exitWith {[format ["%1: nobody to send.", _what]] call MCCMK_fnc_hint};
private _left = 0;
{
	private _u = _x;
	private _seats = (fullCrew [_boat, "", true]) select {isNull (_x select 0)};
	if (_seats isEqualTo []) then {_left = _left + 1} else {
		if (_u == player) then {
			if (isNull driver _boat) then {_u moveInDriver _boat} else {_u moveInAny _boat};
		} else {
			private _tur = (fullCrew [_boat, "turret", true]) select {isNull (_x select 0)};
			if (count _tur > 0) then {_u moveInTurret [_boat, (_tur select 0) select 3]} else {_u moveInAny _boat};
			[_u] orderGetIn true;
		};
	};
} forEach _who;
if (_left > 0) then {[format ["%1: %2 stayed on deck - not enough seats.", _what, _left]] call MCCMK_fnc_hint};
["INFO", "boarding", "%1: %2 into %3 from %4 (%5)%6", [name player, _what, typeOf _boat, _ship getVariable ["MCC_LHDDisplayName", "ship"], _mode, if (_left > 0) then {format [", %1 stayed", _left]} else {""}]] call MCC_fnc_log;
