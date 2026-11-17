params [["_u", objNull, [objNull]]];
private _c = missionNamespace getVariable ["MCCMK_boatHereC", [-1, false]];
if ((time - (_c select 0)) < 1) exitWith {_c select 1};
private _ship = ([_u] call MCCMK_fnc_boardState) select 1;
private _r = !isNull _ship && {([_ship] call MCCMK_fnc_boatsAlongside) isNotEqualTo []};
MCCMK_boatHereC = [time, _r];
_r
