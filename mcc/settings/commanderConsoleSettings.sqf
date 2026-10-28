// ==================== Commander Console ==========================================
//Commander Console
[
    "MCC_allowConsole",
    "CHECKBOX",
    ["Commander Console Enabled","Player can become a side commander from the MCC respawn screen"],
   "MCC Commander Console",
    true,
    true
] call CBA_Settings_fnc_init;

//RTS
[
    "MCC_allowRTS",
    "CHECKBOX",
    ["RTS","Enable Real Time Strategy mod from the commander console, build,\nexpand and conquer"],
    "MCC Commander Console",
    true,
    true
] call CBA_Settings_fnc_init;

[
    "MCC_rtsPersonnelMode",
    "LIST",
    ["Personnel that use food and bunks","Which soldiers count towards the RTS personnel limit, hourly food use and bunks."],
    ["MCC Commander Console","RTS / Base"],
    [[0,1,2],["Players and controllable groups","Also AI in players' squads","All friendly AI on the side"],0],
    true
] call CBA_Settings_fnc_init;

//-=================================================== Air support ===---

//Commander Console Purchable airDrops
[
    "MCC_defaultSupplyDropsEnabled",
    "CHECKBOX",
    ["Purchase air drop","Commander can trade resources for air Drops - works only on mission restart"],
    ["MCC Commander Console","Air support"],
    true,
    true
] call CBA_Settings_fnc_init;

//AC-130 up time
[
    "MCC_ConsoleACTime",
    "SLIDER",
    ["AC-130 uptime","How long in seconds can an AC-130 stay in the air before he is RTB"],
    ["MCC Commander Console","Air support"],
    [0, 1200, 360, 0],
    true
] call CBA_Settings_fnc_init;

//Commander Console Purchable CAS
[
    "MCC_defaultCASEnabled",
    "CHECKBOX",
    ["Purchase CAS","Commander can trade resources for close air support - works only on\nmission restart"],
    ["MCC Commander Console","Air support"],
    true,
    true
] call CBA_Settings_fnc_init;

//-==================== Tracking ==================----------
//Commander Console Show units without GPS
[
    "MCC_ConsoleOnlyShowUnitsWithGPS",
    "CHECKBOX",
    ["Show units without GPS","Blueforce tracker show units without GPS on commander console"],
    ["MCC Commander Console","Tracking"],
    true,
    true
] call CBA_Settings_fnc_init;

//Commander Show friendly WP
[
    "MCC_ConsolePlayersCanSeeWPonMap",
    "CHECKBOX",
    ["Show friendly WP","Show friendly group way points on console"],
    ["MCC Commander Console","Tracking"],
    true,
    true
] call CBA_Settings_fnc_init;

//Commander Console Can command AI
[
    "MCC_ConsoleCanCommandAI",
    "CHECKBOX",
    ["Command AI","Commander can issue order to AI groups given to him by mission maker"],
    ["MCC Commander Console","Tracking"],
    true,
    true
] call CBA_Settings_fnc_init;

//Live feed helmet
[
    "MCC_ConsoleLiveFeedHelmetsOnly",
    "CHECKBOX",
    ["Restrict live feed","Restrict live feed to vehicles and units wearing one of the specific\nhelmets only"],
    ["MCC Commander Console","Live Feed"],
    false,
    true
] call CBA_Settings_fnc_init;

//Live feed helmet
[
    "MCC_ConsoleLiveFeedHelmets",
    "EDITBOX",
    ["Live feed helmets","Restrict live feed to vehicles and units wearing one of the specific\nhelmets only"],
    ["MCC Commander Console","Live Feed"],
    '["H_HelmetB","H_HelmetB_paint","H_HelmetB_light","H_HelmetO_ocamo","H_HelmetLeaderO_ocamo","H_HelmetSpecO_ocamo","H_HelmetSpecO_blk"]',
    true,
    {
        params ["_value"];
        MCC_ConsoleLiveFeedHelmets = [_value, '["H_HelmetB","H_HelmetB_paint","H_HelmetB_light","H_HelmetO_ocamo","H_HelmetLeaderO_ocamo","H_HelmetSpecO_ocamo","H_HelmetSpecO_blk"]', "MCC_ConsoleLiveFeedHelmets"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;