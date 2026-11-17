/*
    ANC_fnc_saveBoatPoints  (server)
    Keeps a boat's own attachment points ("this boat only" in the attachment point editor) in the server's profile, so
    they come back every time this mission is played - filed under the mission's name and the boat's variable name
    (the name given to it in the Eden editor). Loaded at mission start by ANC_fnc_loadPoints. Written only when
    someone saves; nothing is checked in between.
    [variable name, points ([[name, point], ...] - empty to forget them)]
*/
if (!isServer) exitWith {};
params [["_var", "", [""]], ["_list", [], [[]]]];
if (_var isEqualTo "") exitWith {};
private _all = createHashMapFromArray (profileNamespace getVariable ["ANC_boatPointsSaved", []]);
private _forMission = createHashMapFromArray (_all getOrDefault [missionName, []]);
if (_list isEqualTo []) then {_forMission deleteAt _var} else {_forMission set [_var, _list]};
_all set [missionName, (keys _forMission) apply {[_x, _forMission get _x]}];
profileNamespace setVariable ["ANC_boatPointsSaved", (keys _all) apply {[_x, _all get _x]}];
saveProfileNamespace;
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Saved %1's own attachment points for mission '%2' (%3 points).", _var, missionName, count _list]};
