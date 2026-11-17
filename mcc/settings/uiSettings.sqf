[
    "MCC_dropCutscene",
    "CHECKBOX",
    ["Drop cut-scene","Show the short film of the aircraft before a parachute,\nHALO or drop pod jump. Off: stay in your own first or\nthird person view in the aircraft."],
    "MCCMK User Interface",
    true,
    false
] call CBA_Settings_fnc_init;

[
    "MCC_chaseSens",
    "SLIDER",
    ["Chase camera mouse sensitivity","How fast the chase camera turns round the aircraft or\npod with the mouse (before a parachute, HALO or pod\njump). Arma's own mouse sensitivity can't be read by\nscripts - set this to feel like yours."],
    "MCCMK User Interface",
    [0.1, 3, 0.6, 2],
    false
] call CBA_Settings_fnc_init;

if (count (allMissionObjects "MCC_Module_inGameUI") == 0) then {
    //View Distance
    [
        "MCC_Settings_ViewDistance",
        "SLIDER",
        ["View Distance","Set the current player view distance"],
        "MCCMK User Interface",
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
        "MCCMK User Interface",
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
        "MCCMK User Interface",
        true,
        true
    ] call CBA_Settings_fnc_init;

    //3D person view
    [
        "MCC_Settings_forceCamera",
        "LIST",
        ["Allow 3rd Person","Force first person camera"],
        "MCCMK User Interface",
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
        ["MCCMK User Interface", "Compass"],
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
        ["MCCMK User Interface", "Map"],
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
        ["Unit Markers","Markers for each member of your own squad shown on the\nmap"],
        ["MCCMK User Interface", "Map"],
        false,
        false
    ] call CBA_Settings_fnc_init;

    //(MK) Map Intel (MCCMK_fnc_mapIntel)
    [
        "MCCMK_mapIntel",
        "CHECKBOX",
        ["Map Intel", "Spotted groups as NATO symbols (last known position for\n3 minutes, hover for numbers) and gunfire as white streaks,\non the main map and Commander Console; gunfire only on the\nMCC console. Each map has its own checkbox bottom right.\nA server can force it."],
        ["MCCMK User Interface", "Map"],
        true,
        false
    ] call CBA_Settings_fnc_init;
    [
        "MCCMK_mapIntelContent",
        "LIST",
        ["Map Intel: Arma's map content", "With Map Intel on - Show all: Arma's own friendly units,\nknown enemies, mines and pings, whatever the difficulty.\nDifficulty's own: as the difficulty sets them.\nHide units (the original script's): friendly and enemy unit\nmarkers hidden, mines and pings shown - only Map Intel's\nmarkers show units, your own squad's men included.\nA server can force it."],
        ["MCCMK User Interface", "Map"],
        [[0, 1, 2], ["Show all", "Difficulty's own", "Hide units (original)"], 0],
        false
    ] call CBA_Settings_fnc_init;

    //name Tags
    [
        "MCC_nameTags",
        "CHECKBOX",
        ["Name Tags","Show nearby units names"],
        ["MCCMK User Interface", "Name Tags"],
        false,
        false
    ] call CBA_Settings_fnc_init;

    //name Tags Direct
    [
        "MCC_NameTags_direct",
        "CHECKBOX",
        ["Name Tags only when pointing","Show nearby units names only when pointing"],
        ["MCCMK User Interface", "Name Tags"],
        false,
        false
    ] call CBA_Settings_fnc_init;

    //Move to server
    //suppression
    [
        "MCC_suppressionOn",
        "CHECKBOX",
        "Suppression Effects",
        ["MCCMK User Interface", "suppression"],
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
        ["Video feed resolution","Resolution of MCC video feeds (MCC console unit feed,\nBroadcast, Commander Console feeds). Higher = sharper,\ncosts some\nperformance."],
        ["MCCMK User Interface", "Video feeds"],
        [[256,512,1024,2048],["Low (256)","Medium (512, original)","High (1024)","Very high (2048)"],2],
        false,
        {}
    ] call CBA_Settings_fnc_init;
    [
        "MCC_pipSmoothing",
        "SLIDER",
        ["Unit feed smoothing","How smoothly the unit feed camera (and a Broadcast of\nit) follows the unit. 0 = rigid, higher = smoother but\nlags a little behind turns"],
        ["MCCMK User Interface", "Video feeds"],
        [0,0.95,0.85,2],
        false,
        {}
    ] call CBA_Settings_fnc_init;

    //Suppression strength (GitHub #59)
    [
        "MCC_suppressionLevel",
        "LIST",
        ["Suppression strength","How strong the blur, red tint and screen shake are when\nshot at.\nMaximum = the original effect."],
        ["MCCMK User Interface", "suppression"],
        [[1,2,3],["Minimal","Average","Maximum"],2],
        true,
        {}
    ] call CBA_Settings_fnc_init;

    //MCC_hitRadar
    [
        "MCC_hitRadar",
        "LIST",
        "Hit direction Effects",
        ["MCCMK User Interface", "suppression"],
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
        ["Mission status HUD (tickets and zones)", "Arma's panel on the right of the screen with the\nrespawn tickets and the zones (A, B, C ...). Hidden:\nonly the panel - tickets are still counted and zones\nstill captured."],
        "MCCMK User Interface",
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
        "MCCMK User Interface",
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

//(MK) 3D View (the MCC console's 3D View button: fnc\mkhq\altView\MCCMK_altView.sqf).
// Each player's own (not forced by the server); the defaults are the view's own. The keys are under Controls > MCCMK > 3D View.
[
    "MCCMK_BombViewEnabled",
    "CHECKBOX",
    ["Bomb view", "Left-click in the 3D view to follow each bomb or missile\nthe vehicle fires (and loads it drops) until it lands.\nApplies at once."],
    "MCCMK 3D View",
    true,
    false
] call CBA_Settings_fnc_init;
[
    "MCCMK_CockpitViewEnabled",
    "CHECKBOX",
    ["Cockpit view", "The first-person (crewman's eye) view in the 3D view.\nOff: third person only. Applies at once."],
    "MCCMK 3D View",
    true,
    false
] call CBA_Settings_fnc_init;
[
    "MCCMK_AltViewSoundMatch",
    "CHECKBOX",
    ["Sound follows camera", "Sound comes from where the camera is: cabin sound on\nthe crewman's eye inside a vehicle, outside sound\notherwise. Off: always cabin sound. Applies at once."],
    "MCCMK 3D View",
    true,
    false
] call CBA_Settings_fnc_init;
[
    "MCCMK_AltViewMuteRadio",
    "CHECKBOX",
    ["Silence watched unit's radio", "Silences the radio of the unit watched, his group and\nhis vehicle's crew while he is watched. Your own radio\nis still heard. Applies at once."],
    "MCCMK 3D View",
    true,
    false
] call CBA_Settings_fnc_init;
[
    "MCCMK_av_sens",
    "SLIDER",
    ["Mouse speed", "How fast the mouse turns the 3D view's camera.\n(Page Up / Page Down change it in the view too.)"],
    "MCCMK 3D View",
    [0.1, 3, 0.6, 2],
    false
] call CBA_Settings_fnc_init;
[
    "MCCMK_av_lookLag",
    "SLIDER",
    ["Camera smoothing", "Seconds the third-person orbit and zoom take to ease\nto where the mouse puts them. 0 = no smoothing."],
    "MCCMK 3D View",
    [0, 0.5, 0.1, 2],
    false
] call CBA_Settings_fnc_init;
[
    "MCCMK_av_moveSpd",
    "SLIDER",
    ["Camera move speed", "Metres a second the arrow keys move the first-person\ncamera off the crewman's eye."],
    "MCCMK 3D View",
    [0.5, 10, 3, 1],
    false
] call CBA_Settings_fnc_init;
[
    "MCCMK_av_fineSpd",
    "SLIDER",
    ["Fine move speed", "Metres a second the camera moves with the fine\nmovement key (Right Shift) held."],
    "MCCMK 3D View",
    [0.1, 2, 0.5, 1],
    false
] call CBA_Settings_fnc_init;
[
    "MCCMK_av_moveMax",
    "SLIDER",
    ["Camera move limit", "How far (metres) the arrow keys can move the camera\nfrom the crewman's eye."],
    "MCCMK 3D View",
    [5, 100, 20, 0],
    false
] call CBA_Settings_fnc_init;
