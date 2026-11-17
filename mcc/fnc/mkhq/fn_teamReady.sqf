params [["_p", objNull, [objNull]], ["_team", "", [""]], ["_state", "deck", [""]]];
if (leader group _p != _p) exitWith {false};
((units group _p) findIf {alive _x && {!isPlayer _x} && {_team == "" || {(assignedTeam _x) == _team}} && {(_x distance2D _p) < 150} && {([_x] call MCCMK_fnc_boardSit) == _state}}) >= 0
