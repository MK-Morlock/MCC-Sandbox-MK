/*
    ANC_fnc_menu  (client)
    Numbered choice when the anchor key has more than one option, e.g. "1 - Anchor", "2 - Moor"; while moored "1 -
    Cast off", "2 - Moor". Number keys or mouse.
*/
params [["_boat", objNull, [objNull]], ["_options", [], [[]]], ["_title", "Anchor / moor", [""]]];
if (!hasInterface || {isNull _boat} || {count _options == 0}) exitWith {};
ANC_menuBoat = _boat;
ANC_menuDef = [[_title, false]];
{
    _x params ["_label", "_key"];
    ANC_menuDef pushBack [
        _label, [_forEachIndex + 2], "", -5,
        [["expression", format ["[['choose', ANC_menuBoat, player, '%1'], 'server', 2] call ANC_fnc_remote;", _key]]],
        "1", "1"
    ];
} forEach _options;
// opened once any menu still closing has gone: a menu opened straight from another menu's choice (the tow list)
// would otherwise be closed along with it
[{commandingMenu isEqualTo ""}, {showCommandingMenu "#USER:ANC_menuDef"}, [], 1, {showCommandingMenu "#USER:ANC_menuDef"}] call CBA_fnc_waitUntilAndExecute;
