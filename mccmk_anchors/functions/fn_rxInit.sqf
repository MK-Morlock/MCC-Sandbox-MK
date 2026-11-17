/*
    ANC_fnc_rxInit  (125; every computer, preInit)
    Receives what ANC_fnc_remote sends (through CBA's events - nothing for a server to whitelist in CfgRemoteExec,
    nothing for BattlEye to filter).
*/
["ANC_rx", {
    params [["_name", "", [""]], ["_args", []]];
    if !(_args isEqualType []) then {_args = [_args]};
    switch (_name) do {
        // ---- to the server ----
        case "server":        {if (isServer) then {_args call ANC_fnc_server}};
        case "aiOrder":       {if (isServer) then {_args call ANC_fnc_aiOrder}};
        case "savePoint":     {if (isServer) then {_args call ANC_fnc_savePoint}};
        case "saveBoatPoints": {if (isServer) then {_args call ANC_fnc_saveBoatPoints}}; // a named boat's own points
        case "lineBoats":     {if (isServer) then {call ANC_fnc_lineBoats}};
        case "boatInitLine":  {if (isServer) then {_args call ANC_fnc_boatInitLine}};
        // ---- to a player ----
        case "notify":        {_args call ANC_fnc_notify};
        case "notice":        {_args call ANC_fnc_notice};
        case "raftMenu":      {_args call ANC_fnc_raftMenu};
        case "raftBreak":     {if (isServer) then {_args call ANC_fnc_raftBreak}}; // the hold let go // several boats in reach for Raft-Up / Tether // Arma's notification box, top right
        case "cargoMove":     {if (isServer) then {_args call ANC_fnc_cargoMove}}; // Boat Cargo
        case "cargoDump":     {if (isServer) then {_args call ANC_fnc_cargoDump}}; // Overboard
        case "cargoRefresh":  {_args call ANC_fnc_cargoRefresh};
        case "menu":          {_args call ANC_fnc_menu};
        case "towMenu":       {_args call ANC_fnc_towMenu};
        case "shoreFollow":   {_args call ANC_fnc_shoreFollow};
        // ---- to every computer ----
        case "splash":        {_args call ANC_fnc_splash};
        case "pushBoat":      {if (local (_args param [0, objNull])) then {_args call ANC_fnc_pushBoat}}; // Push boat
        case "setVelocity":   {_args params [["_v", objNull, [objNull]], ["_vel", [0, 0, 0], [[]]]]; if (!isNull _v && {local _v}) then {_v setVelocity _vel}}; // where the boat is local
        case "disableCollisionWith": {_args params [["_a", objNull, [objNull]], ["_b", objNull, [objNull]]]; if (!isNull _a && {!isNull _b}) then {_a disableCollisionWith _b}};
        // ---- where a unit is local ----
        case "disableAI":     {_args params [["_u", objNull, [objNull]], ["_f", "", [""]]]; if (local _u) then {_u disableAI _f}};
        case "engineOff":     {_args params [["_v", objNull, [objNull]]]; if (!isNull _v && {local _v}) then {_v engineOn false}}; // a boat with nobody at the wheel (ANC_fnc_deadHelm)
        case "enableAI":      {_args params [["_u", objNull, [objNull]], ["_f", "", [""]]]; if (local _u) then {_u enableAI _f}};
        case "playActionNow": {_args params [["_u", objNull, [objNull]], ["_a", "", [""]]]; if (local _u) then {_u playActionNow _a}};
        default {if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Ignored an unknown remote request: %1", _name]}};
    };
}] call CBA_fnc_addEventHandler;
