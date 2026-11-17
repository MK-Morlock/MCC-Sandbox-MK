/*
    ANC_fnc_savePoint  (server)
    Saves (or with [] clears) an adjusted attachment point for a boat type, keeps it in the server's profile so it
    lasts between missions, and shares it with every player.
*/
if (!isServer) exitWith {};
params [["_class", "", [""]], ["_name", "", [""]], ["_point", [], [[]]]];
if (_class isEqualTo "" || {_name isEqualTo ""}) exitWith {};
private _all = missionNamespace getVariable ["ANC_pointOverrides", createHashMap];
private _forClass = _all getOrDefault [_class, createHashMap];
if (count _point == 3) then {_forClass set [_name, _point]} else {_forClass deleteAt _name};
_all set [_class, _forClass];
ANC_pointOverrides = _all;
publicVariable "ANC_pointOverrides";
// Stored as plain arrays: [[class, [[name, point], ...]], ...]
profileNamespace setVariable ["ANC_pointOverridesSaved", (keys _all) apply {
    private _cls = _x;
    private _m = _all get _cls;
    [_cls, (keys _m) apply {[_x, _m get _x]}]
}];
saveProfileNamespace;
