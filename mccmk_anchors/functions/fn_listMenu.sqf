/*
    ANC_fnc_listMenu  (client)
    A numbered menu in the same style as the anchor and tow line menus (number keys or mouse). Opened once any menu
    that is still closing has gone (so it can follow straight on from another menu's choice).
    [title, labels, code run with the index picked]
*/
params [["_title", "", [""]], ["_labels", [], [[]]], ["_code", {}, [{}]], ["_note", "", [""]]];	// (MK) _note: a greyed first line
if (!hasInterface || {count _labels == 0}) exitWith {};
ANC_listMenuCode = _code;
ANC_listMenuDef = [[_title, false]];
if (_note != "") then {ANC_listMenuDef pushBack [_note, [], "", -5, [["expression", ""]], "1", "0"]};	// (MK) shown, not choosable
{
    ANC_listMenuDef pushBack [_x, [_forEachIndex + 2], "", -5,
        [["expression", format ["[{[%1] call ANC_listMenuCode}, [], 0.1] call CBA_fnc_waitAndExecute;", _forEachIndex]]], "1", "1"];
} forEach (_labels select [0, 9]);
[{commandingMenu isEqualTo ""}, {showCommandingMenu "#USER:ANC_listMenuDef"}, [], 1, {showCommandingMenu "#USER:ANC_listMenuDef"}] call CBA_fnc_waitUntilAndExecute;
