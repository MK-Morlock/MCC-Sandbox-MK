/*
    ANC_fnc_addBoatHandlers  (server)
    Cleans up anchors / mooring lines when the boat is destroyed or deleted, whoever's computer the boat is on. Added
    once, on the server.
*/
params [["_boat", objNull, [objNull]]];
if (!isServer || {isNull _boat}) exitWith {};
if (_boat getVariable ["ANC_handlersAdded", false]) exitWith {};
_boat setVariable ["ANC_handlersAdded", true];
_boat addMPEventHandler ["MPKilled", {
    params ["_boat"];
    if (isServer) then {[_boat] call ANC_fnc_cleanup; [_boat] call ANC_fnc_xlDrop};
}];
_boat addEventHandler ["Deleted", {
    params ["_boat"];
    [_boat] call ANC_fnc_cleanup;
    [_boat] call ANC_fnc_xlDrop;
}];
