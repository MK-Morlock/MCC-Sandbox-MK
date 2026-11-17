params [["_t", objNull, [objNull]], ["_c", objNull, [objNull]]];
if (isNull _t || {isNull _c} || {!alive _t} || {_t getVariable ["dead", false]}) exitWith {false};
private _side = _t getVariable ["side", _t getVariable ["MCC_side", sideUnknown]];
if !((side group _c) isEqualTo _side) exitWith {false};
if ([_t] call MCCMK_fnc_isHQ) exitWith {false};
if ((_t getVariable ["MCCMK_disabled", false]) || {_t getVariable ["MCCMK_sinking", false]}) exitWith {false};
(((missionNamespace getVariable ["MCC_server", objNull]) getVariable [format ["CP_commander%1", _side], ""]) == getPlayerUID _c) || {(missionNamespace getVariable ["MCC_makeHQWho", 0]) == 1 && {leader group _c == _c}}
