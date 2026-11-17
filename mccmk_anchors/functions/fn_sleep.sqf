/*
    ANC_fnc_sleep  (every computer)
    No boats left (and no lines out): every Anchors timer stops until a boat appears again (ANC_fnc_wake).
*/
{[_x] call CBA_fnc_removePerFrameHandler} forEach (missionNamespace getVariable ["ANC_pfh", []]);
ANC_pfh = [];
ANC_boatsOn = false;
ANC_nearBoats = [];
ANC_nearBoardBoats = [];
ANC_footBoats = [];
ANC_pushTarget = objNull;
ANC_bagBoat = objNull;
ANC_bagHome = false;
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log "[Anchors] No boats left - Anchors' timers stopped."};
