/*
    ANC_fnc_towMenu  (client)
    Tow line key with several vehicles in reach: a numbered list - "1 - Combat Boat (HMG) 8 m, port side". Picking one
    opens the usual tow line menu for it.
    [boat, [[vehicle, gap, where], ...]]
*/
params [["_boat", objNull, [objNull]], ["_cands", [], [[]]]];
if (!hasInterface || {isNull _boat} || {count _cands == 0}) exitWith {};
ANC_menuBoat = _boat;
ANC_towMenuCands = _cands;
ANC_towMenuDef = [["Tow line - which vehicle?", false]];
{
    _x params ["_v", "_gap", "_where"];
    ANC_towMenuDef pushBack [
        format ["%1  -  %2 m, %3", getText (configOf _v >> "displayName"), round _gap, _where], [_forEachIndex + 2], "", -5,
        [["expression", format ["[{[['towPick', ANC_menuBoat, player, %1], 'server', 2] call ANC_fnc_remote}, [], 0.1] call CBA_fnc_waitAndExecute;", _forEachIndex]]],
        "1", "1"
    ];
} forEach (_cands select [0, 9]);
// Opened once any menu before it has closed (it's opened from the tow line key's menu: opened at once, the closing of
// that menu took this one with it).
[{commandingMenu isEqualTo ""}, {showCommandingMenu "#USER:ANC_towMenuDef"}, [], 1, {showCommandingMenu "#USER:ANC_towMenuDef"}] call CBA_fnc_waitUntilAndExecute;
