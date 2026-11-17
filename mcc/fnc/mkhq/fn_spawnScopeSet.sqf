params [["_i", -1, [0]]];
private _cur = missionNamespace getVariable ["MCCMK_spawnScope", ((profileNamespace getVariable ["MCCMK_spawnScope", 2]) max 0) min 5];
if (_i < 0 || {_i > 5} || {_i == _cur}) exitWith {};
MCCMK_spawnScope = _i;
profileNamespace setVariable ["MCCMK_spawnScope", _i];
[missionNamespace getVariable ["mcc_faction", ""]] call MCCMK_fnc_spawnScopeLists;
if (!isNull (findDisplay 2994)) then {["branch", -1] call MCC_fnc_spawnLists};
