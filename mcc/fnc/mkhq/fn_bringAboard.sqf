params [["_mode", "squad", [""]]];
([player] call MCCMK_fnc_boardState) params ["_st", "_ship"];
if (_st != "deck") exitWith {["Bring aboard: you need to be on the ship's deck."] call MCCMK_fnc_hint};
private _who = ([_mode, "climb", false] call MCCMK_fnc_boardUnits) select {(([_x] call MCCMK_fnc_boardState) select 1) == _ship};
if (_who isEqualTo []) exitWith {["Bring aboard: none of them is in the water or a boat beside this ship."] call MCCMK_fnc_hint};
[_who, _ship] spawn MCCMK_fnc_shipBoardUnits;
["INFO", "boarding", "%1 brought %2 aboard %3 (%4)", [name player, count _who, _ship getVariable ["MCC_LHDDisplayName", "ship"], _mode]] call MCC_fnc_log;
