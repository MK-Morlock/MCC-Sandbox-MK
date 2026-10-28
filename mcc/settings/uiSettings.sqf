[
    "MCC_dropCutscene",
    "CHECKBOX",
    ["Drop cut-scene","Show the short film of the aircraft before a parachute, HALO or drop\npod jump. Off: stay in your own first or third person view in the\naircraft."],
    "MCC User Interface",
    true,
    false
] call CBA_Settings_fnc_init;

[
    "MCC_chaseSens",
    "SLIDER",
    ["Chase camera mouse sensitivity","How fast the chase camera turns round the aircraft or pod when you move the\nmouse (before a parachute, HALO or drop pod jump). Arma's own mouse sensitivity\ncannot be read by a script - set this to feel like yours."],
    "MCC User Interface",
    [0.1, 3, 0.6, 2],
    false
] call CBA_Settings_fnc_init;

if (count (allMissionObjects "MCC_Module_inGameUI") == 0) then {
    //View Distance
    [
        "MCC_Settings_ViewDistance",
        "SLIDER",
        ["View Distance","Set the current player view distance"],
        "MCC User Interface",
        [200, 15000, 5000, 0],
        false,
        {
            params ["_value"];
            setViewDistance _value;
        }
    ] call CBA_Settings_fnc_init;

    //Grass
    [
        "MCC_Settings_grassDetail",
        "SLIDER",
        ["Grass Detail","Set the current player grass Detail"],
        "MCC User Interface",
        [1, 50, 10, 0],
        false,
        {
            params ["_value"];
            setTerrainGrid (50 - _value);
        }
    ] call CBA_Settings_fnc_init;

    //MCC Action in mouse wheel
    [
        "MCC_showActionKey",
        "CHECKBOX",
        ["Action Menu","Show MCC action in mouse wheel actions"],
        "MCC User Interface",
        true,
        true
    ] call CBA_Settings_fnc_init;

    //3D person view
    [
        "MCC_Settings_forceCamera",
        "LIST",
        ["Allow 3rd Person","Force first person camera"],
        "MCC User Interface",
        [[0,1,2,3], ["Never","In all vehicles","In aircraft only","Always"], 3],
        true,
        {
            params ["_value"];
            [_value] call MCC_fnc_forceCamera;
        }
    ] call CBA_Settings_fnc_init;

    //Compass
    [
        "MCC_Settings_compassEnabled",
        "LIST",
        "Interactive Compass HUD",
        ["MCC User Interface","Compass"],
        [[0,1,2],["Only Compass","Show group's units","Disabled"],2],
        true,
        {
            params ["_value"];
            switch (_value) do
            {
                case 2:
                {
                    missionNamespace setVariable ["MCC_initCompassHUD",false];
                    (["MCC_hud"] call BIS_fnc_rscLayer) cutText ["","Plain"];
                    ["MCC_fnc_compHudEVH", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
                };

                default
                {
                    (_value == 1) spawn MCC_fnc_initCompassHUD;
                };
            };
        }
    ] call CBA_Settings_fnc_init;

    //Group Markers - a per-player display preference (client setting); a mission or server can still force it
    [
        "MCC_groupMarkers",
        "CHECKBOX",
        ["Group Markers","Squad markers (Squad Dialog squads) shown on the map"],
        ["MCC User Interface","Map"],
        false,
        false,
        {
            params [["_on", false, [true]]];
            if (!isNil "MCC_fnc_log") then {["INFO", "uiSettings", "addon option: group markers %1", [["OFF","ON"] select _on]] call MCC_fnc_log};
        }
    ] call CBA_Settings_fnc_init;

    //Unit Markers
    [
        "MCC_indevidualMarkers",
        "CHECKBOX",
        ["Unit Markers","Markers for each member of your own squad shown on the map"],
        ["MCC User Interface","Map"],
        false,
        false
    ] call CBA_Settings_fnc_init;

    //name Tags
    [
        "MCC_nameTags",
        "CHECKBOX",
        ["Name Tags","Show nearby units names"],
        ["MCC User Interface","Name Tags"],
        false,
        false
    ] call CBA_Settings_fnc_init;

    //name Tags Direct
    [
        "MCC_NameTags_direct",
        "CHECKBOX",
        ["Name Tags only when pointing","Show nearby units names only when pointing"],
        ["MCC User Interface","Name Tags"],
        false,
        false
    ] call CBA_Settings_fnc_init;

    //Move to server
    //suppression
    [
        "MCC_suppressionOn",
        "CHECKBOX",
        "Suppression Effects",
        ["MCC User Interface","suppression"],
        false,
        true,
        {
            params ["_value"];

            if (_value) then {
                if !(missionNamespace getVariable ["MCC_initSupression",false]) then {[] spawn MCC_fnc_supressionInit};
            } else {
                missionNamespace setVariable ["MCC_initSupression",false];
                ["MCC_initSupression", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
            };
        }
    ] call CBA_Settings_fnc_init;

    //Video feeds (MCC console unit feed, live feed)
    [
        "MCC_pipResolution",
        "LIST",
        ["Video feed resolution","Resolution of MCC video feeds (MCC console unit feed, Broadcast,\nCommander Console feeds). Higher = sharper, costs some performance."],
        ["MCC User Interface","Video feeds"],
        [[256,512,1024,2048],["Low (256)","Medium (512, original)","High (1024)","Very high (2048)"],2],
        false,
        {}
    ] call CBA_Settings_fnc_init;
    [
        "MCC_pipSmoothing",
        "SLIDER",
        ["Unit feed smoothing","How smoothly the unit feed camera (and a Broadcast of it) follows the\nunit. 0 = rigid, higher = smoother but lags a little behind turns"],
        ["MCC User Interface","Video feeds"],
        [0,0.95,0.85,2],
        false,
        {}
    ] call CBA_Settings_fnc_init;

    //Suppression strength (GitHub #59)
    [
        "MCC_suppressionLevel",
        "LIST",
        ["Suppression strength","How strong the blur, red tint and screen shake are when shot at.\nMaximum = the original effect."],
        ["MCC User Interface","suppression"],
        [[1,2,3],["Minimal","Average","Maximum"],2],
        true,
        {}
    ] call CBA_Settings_fnc_init;

    //MCC_hitRadar
    [
        "MCC_hitRadar",
        "LIST",
        "Hit direction Effects",
        ["MCC User Interface","suppression"],
        [[0,1,2],["Realistics","Arcade","Off"],0],
        true,
        {
            params ["_value"];

            if (_value != 2) then {
                if !(missionNamespace getVariable ["MCC_initSupression",false]) then {[] spawn MCC_fnc_supressionInit};
            } else {
                missionNamespace setVariable ["MCC_initSupression",false];
                ["MCC_initSupression", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
            };
        }
    ] call CBA_Settings_fnc_init;

    [
        "MCCMK_missionStatusHUD",
        "LIST",
        ["Mission status HUD (tickets and zones)", "Arma's panel on the right of the screen with the respawn tickets and\nthe zones (A, B, C ...). Hidden: only the panel - tickets are still\ncounted and zones still captured."],
        "MCC User Interface",
        [[0, 1], ["Show", "Hide"], 0],
        false,
        {
            params ["_value"];
            [_value == 1] call MCCMK_fnc_missionStatusHUD;
        }
    ] call CBA_Settings_fnc_init;

    //MCC_hitRadar
    [
        "MCC_UIModuleTickets",
        "CHECKBOX",
        "PvP Interface",
        "MCC User Interface",
        false,
        true,
        {
            params ["_value"];

            if (_value) then {
                [] spawn MCC_fnc_PvPInterface
            };
        }
    ] call CBA_Settings_fnc_init;
};