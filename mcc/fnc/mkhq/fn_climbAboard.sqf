params [["_mode", "alone", [""]]];
([player] call MCCMK_fnc_boardState) params ["_st", "_ship"];
if (_st != "climb") exitWith {["Climb aboard: get your boat close to the ship and nearly stopped, or swim close to the hull."] call MCCMK_fnc_hint};
private _who = [_mode, "climb"] call MCCMK_fnc_boardUnits;
[_who, _ship] spawn MCCMK_fnc_shipBoardUnits;
["INFO", "boarding", "%1 climbed aboard %2 with %3 (%4)", [name player, _ship getVariable ["MCC_LHDDisplayName", "ship"], count _who - 1, _mode]] call MCC_fnc_log;
