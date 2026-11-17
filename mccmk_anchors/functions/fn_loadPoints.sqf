/*
    ANC_fnc_loadPoints  (server, postInit)
    Loads the adjusted attachment points saved in the server's profile and shares them with every player.
*/
if (!isServer) exitWith {};
private _saved = profileNamespace getVariable ["ANC_pointOverridesSaved", []];
private _all = createHashMap;
{
    _x params ["_class", "_pairs"];
    _all set [_class, createHashMapFromArray _pairs];
} forEach _saved;
ANC_pointOverrides = _all;
publicVariable "ANC_pointOverrides";
if (count _saved > 0) then {if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Loaded adjusted attachment points for %1 boat type(s).", count _saved]}};

// Boats' own points for this mission ("this boat only", saved under the boat's variable name -
// ANC_fnc_saveBoatPoints): put back on each boat that has that name in this mission, once, here at the start.
private _forMission = createHashMapFromArray ((createHashMapFromArray (profileNamespace getVariable ["ANC_boatPointsSaved", []])) getOrDefault [missionName, []]);
private _n = 0;
{
    private _b = missionNamespace getVariable [_x, objNull];
    if (_b isEqualType objNull && {!isNull _b}) then {_b setVariable ["ANC_boatPoints", _y, true]; _n = _n + 1};
} forEach _forMission;
if (_n > 0) then {if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Loaded the own attachment points of %1 named boat(s) for mission '%2'.", _n, missionName]}};
