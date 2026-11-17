params [["_u", objNull, [objNull]]];
if (isNull _u) exitWith {false};
if (!isMultiplayer) exitWith {true};
private _mm = missionNamespace getVariable ["mcc_missionmaker", ""];
((_mm != "") && {name _u == _mm}) || {(admin (owner _u)) > 0} || {!isNull (getAssignedCuratorLogic _u)}
