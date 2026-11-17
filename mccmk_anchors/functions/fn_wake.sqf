/*
    ANC_fnc_wake  (every computer)
    A boat exists: every Anchors timer starts (once) - wind drift, the rope physics, pulling boats by hand, the AI
    watch (server), and the Board Boat / Push boat / rope bag checks (players). They all stop again when the last boat
    is gone (ANC_fnc_sleep, from ANC_fnc_driftTick) - with no boats on the map, nothing of Anchors runs.
*/
if (missionNamespace getVariable ["ANC_boatsOn", false]) exitWith {};
ANC_boatsOn = true;
if (isNil "ANC_pfh") then {ANC_pfh = []};
ANC_rodeLastTick = diag_tickTime;
ANC_sleepCheck = time + 5;
ANC_pfh pushBack ([{call ANC_fnc_driftTick}, 0.1] call CBA_fnc_addPerFrameHandler);
ANC_pfh pushBack ([{call ANC_fnc_rodeTick}, 0.05] call CBA_fnc_addPerFrameHandler);
if (!isNil "ANC_dragTick") then {ANC_pfh pushBack ([{call ANC_dragTick}, 0] call CBA_fnc_addPerFrameHandler)};
if (isServer) then {ANC_pfh pushBack ([{call ANC_fnc_aiWatch}, 2] call CBA_fnc_addPerFrameHandler)};
if (hasInterface) then {call ANC_fnc_boatNear; call ANC_fnc_pushNear; call ANC_fnc_bagNear};
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log "[Anchors] Boats on the map - Anchors' timers started."};
