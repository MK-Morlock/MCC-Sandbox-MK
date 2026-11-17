/*
    ANC_fnc_shoreRopeKeep  (106; server)
    The shore line's rope is always tied from the fitting on the boat to the fitting on the line's end. If it's gone,
    it's tied again at once (a touch longer than the gap). [boat]
*/
params ["_boat"];
private _rope = _boat getVariable ["ANC_rope", objNull];
if (!isNull _rope) exitWith {};
private _from = _boat getVariable ["ANC_shoreBoatHelper", objNull];
private _to = _boat getVariable ["ANC_helper", objNull];
if (isNull _from || {isNull _to}) exitWith {};
private _len = ((getPosASL _from) distance (getPosASL _to)) + 0.05;
_rope = ropeCreate [_from, [0, 0, 0], _to, [0, 0, 0], _len max 0.5];
_boat setVariable ["ANC_rope", _rope];
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Shore line rope re-tied (it had broken) - %1 m", _len toFixed 1]};
