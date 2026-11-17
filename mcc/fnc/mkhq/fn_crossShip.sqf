params [["_mode", "alone", [""]]];
private _to = [player] call MCCMK_fnc_crossTarget;
if (isNull _to) exitWith {["Cross to ship: you need to be on a ship's deck, close to another ship."] call MCCMK_fnc_hint};
private _who = [_mode, "deck"] call MCCMK_fnc_boardUnits;
[_who, _to] spawn MCCMK_fnc_shipBoardUnits;
["INFO", "boarding", "%1 crossed to %2 with %3 (%4)", [name player, _to getVariable ["MCC_LHDDisplayName", "ship"], count _who - 1, _mode]] call MCC_fnc_log;
