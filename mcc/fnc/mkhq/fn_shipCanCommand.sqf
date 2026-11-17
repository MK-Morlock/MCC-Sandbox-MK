params [["_u", objNull, [objNull]], ["_side", sideUnknown, [sideUnknown]]];
if (isNull _u) exitWith {false};
if (_side isEqualTo sideUnknown) then {_side = side group _u};
(((missionNamespace getVariable ["MCC_server", objNull]) getVariable [format ["CP_commander%1", _side], ""]) == getPlayerUID _u) || {(missionNamespace getVariable ["MCC_makeHQWho", 0]) == 1 && {leader group _u == _u}}
