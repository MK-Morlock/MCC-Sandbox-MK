params [["_mode", "alone", [""]], ["_incl", true, [true]]];
([player] call MCCMK_fnc_boardState) params ["_st", "_ship"];
if (_st != "deck") exitWith {[]};
private _boats = [_ship] call MCCMK_fnc_boatsAlongside;
if (count _boats < 2) exitWith {[]};
MCCMK_aceBoats = _boats;
private _out = [];
{
	_out pushBack [[format ["MCCMK_boat_%1", _forEachIndex], [_x, _ship] call MCCMK_fnc_boatLabel, "", compile format ["['%1', (missionNamespace getVariable ['MCCMK_aceBoats', []]) param [%2, objNull], %3] call MCCMK_fnc_boardBoat", _mode, _forEachIndex, _incl], {true}] call ace_interact_menu_fnc_createAction, [], player];
} forEach (_boats select [0, 6]);
_out
