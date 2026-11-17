params [["_mode", "alone", [""]], ["_incl", true, [true]], ["_ship", objNull, [objNull]], ["_boats", [], [[]]]];
call MCCMK_fnc_boatChoiceClear;
// A numbered menu, opened straight away (Arma closes the scroll menu after any choice, so choices added to it would
// need a second scroll): press the boat's number, or click it.
MCCMK_boatMenuData = [_mode, _incl, _boats select [0, 9]];
MCCMK_boatMenu = [[["Board which boat?", "Send to which boat?"] select !_incl, false]];
{
	MCCMK_boatMenu pushBack [[_x, _ship] call MCCMK_fnc_boatLabel, [_forEachIndex + 2], "", -5,
		[["expression", format ["MCCMK_boatMenuData params ['_m', '_i', '_b']; [_m, _b select %1, _i] call MCCMK_fnc_boardBoat;", _forEachIndex]]], "1", "1"];
} forEach (MCCMK_boatMenuData select 2);
[{commandingMenu isEqualTo ""}, {showCommandingMenu "#USER:MCCMK_boatMenu"}, [], 1, {showCommandingMenu "#USER:MCCMK_boatMenu"}] call CBA_fnc_waitUntilAndExecute;
