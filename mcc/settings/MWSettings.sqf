//HVT
[
    "MCC_MWHVT",
    "EDITBOX",
    ["HVT (man)","Unit that will be used as high value target"],
    "MCC Mission Generator",
    '["B_officer_F","O_officer_F","I_officer_F","C_Nikos"]',
    true,
    {
        params ["_value"];
        MCC_MWHVT = [_value, '["B_officer_F","O_officer_F","I_officer_F","C_Nikos"]', "MCC_MWHVT"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Radio
[
    "MCC_MWRadio",
    "EDITBOX",
    ["Radio Tower (Land)","Object that will be used in destroy radio missions"],
    "MCC Mission Generator",
    '["Land_TTowerBig_2_F"]',
    true,
    {
        params ["_value"];
        MCC_MWRadio = [_value, '["Land_TTowerBig_2_F"]', "MCC_MWRadio"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Fuel Tanks
[
    "MCC_MWFuelTanks",
    "EDITBOX",
    ["Fuel Tanks (Land)","Object that will be used in destroy fuel tanks missions"],
    "MCC Mission Generator",
    '["Land_dp_smallTank_F","Land_ReservoirTank_V1_F","Land_dp_bigTank_F"]',
    true,
    {
        params ["_value"];
        MCC_MWFuelTanks = [_value, '["Land_dp_smallTank_F","Land_ReservoirTank_V1_F","Land_dp_bigTank_F"]', "MCC_MWFuelTanks"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Radar(Land)
[
    "MCC_MWradar",
    "EDITBOX",
    ["Radar (Land)","Object that will be used in destroy radar missions"],
    "MCC Mission Generator",
    '["Land_Radar_Small_F","B_Radar_System_01_F","O_Radar_System_02_F"]',
    true,
    {
        params ["_value"];
        MCC_MWradar = [_value, '["Land_Radar_Small_F","B_Radar_System_01_F","O_Radar_System_02_F"]', "MCC_MWradar"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Armor
[
    "MCC_MWTanks",
    "EDITBOX",
    ["Armored Vehicles (Vehicle)","Vehicle that will be used in destroy armored vehicle missions"],
    "MCC Mission Generator",
    '["B_MBT_01_cannon_F","O_MBT_02_cannon_F"]',
    true,
    {
        params ["_value"];
        MCC_MWTanks = [_value, '["B_MBT_01_cannon_F","O_MBT_02_cannon_F"]', "MCC_MWTanks"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Air
[
    "MCC_MWAir",
    "EDITBOX",
    ["Air Vehicles (Vehicle)","Vehicle that will be used in destroy air vehicle missions"],
    "MCC Mission Generator",
    '["O_Heli_Attack_02_F","O_Heli_Attack_02_black_F","O_UAV_02_F","O_UAV_02_CAS_F","B_Heli_Attack_01_F","I_Plane_Fighter_03_CAS_F","I_Plane_Fighter_03_AA_F"]',
    true,
    {
        params ["_value"];
        MCC_MWAir = [_value, '["O_Heli_Attack_02_F","O_Heli_Attack_02_black_F","O_UAV_02_F","O_UAV_02_CAS_F","B_Heli_Attack_01_F","I_Plane_Fighter_03_CAS_F","I_Plane_Fighter_03_AA_F"]', "MCC_MWAir"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Anti-Air(Vehicle)
[
    "MCC_MWAA",
    "EDITBOX",
    ["Anti-Air (Vehicle)","Vehicle that will be used in destroy anti-air missions"],
    "MCC Mission Generator",
    '["B_APC_Tracked_01_AA_F","O_APC_Tracked_02_AA_F","I_APC_Wheeled_03_cannon_F"]',
    true,
    {
        params ["_value"];
        MCC_MWAA = [_value, '["B_APC_Tracked_01_AA_F","O_APC_Tracked_02_AA_F","I_APC_Wheeled_03_cannon_F"]', "MCC_MWAA"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Artillery
[
    "MCC_MWArtillery",
    "EDITBOX",
    ["Artillery (Vehicle)","Vehicle that will be used in destroy artillery missions"],
    "MCC Mission Generator",
    '["B_MBT_01_arty_F","B_MBT_01_mlrs_F","O_MBT_02_arty_F","O_Mortar_01_F","I_Mortar_01_F"]',
    true,
    {
        params ["_value"];
        MCC_MWArtillery = [_value, '["B_MBT_01_arty_F","B_MBT_01_mlrs_F","O_MBT_02_arty_F","O_Mortar_01_F","I_Mortar_01_F"]', "MCC_MWArtillery"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Ammo cache (Box)
[
    "MCC_MWcache",
    "EDITBOX",
    ["Ammo cache (Box)","Ammo box that will be used in destroy cache vehicle missions"],
    "MCC Mission Generator",
    '["Box_East_AmmoVeh_F","Land_Pallet_MilBoxes_F"]',
    true,
    {
        params ["_value"];
        MCC_MWcache = [_value, '["Box_East_AmmoVeh_F","Land_Pallet_MilBoxes_F"]', "MCC_MWcache"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;



//Intel Objects(Small Items)
[
    "MCC_MWIntelObjects",
    "EDITBOX",
    ["Intel Objects (Small Items)","Object that will be used in find intel missions"],
    "MCC Mission Generator",
    '["Land_File2_F","Land_FilePhotos_F","Land_Laptop_unfolded_F","Land_SatellitePhone_F","Land_Suitcase_F"]',
    true,
    {
        params ["_value"];
        MCC_MWIntelObjects = [_value, '["Land_File2_F","Land_FilePhotos_F","Land_Laptop_unfolded_F","Land_SatellitePhone_F","Land_Suitcase_F"]', "MCC_MWIntelObjects"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//IED(Small Items)
[
    "MCC_MWIED",
    "EDITBOX",
    ["IED (Small Items)","Object that will be used in disarm IED missions"],
    "MCC Mission Generator",
    '["IEDLandSmall_Remote_Ammo","IEDLandBig_Remote_Ammo","IEDUrbanSmall_Remote_Ammo","IEDUrbanBig_Remote_Ammo"]',
    true,
    {
        params ["_value"];
        MCC_MWIED = [_value, '["IEDLandSmall_Remote_Ammo","IEDLandBig_Remote_Ammo","IEDUrbanSmall_Remote_Ammo","IEDUrbanBig_Remote_Ammo"]', "MCC_MWIED"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Composition Civ
[
    "MCC_MWSITES",
    "EDITBOX",
    ["Compositions civilians",'Will be used as compositions for civilians must be defined in ("CfgGroups" >> "Empty")'],
    "MCC Mission Generator",
    '[["Guerrilla","Camps","CampA"],["Guerrilla","Camps","CampB"],["Guerrilla","Camps","CampC"],["Guerrilla","Camps","CampD"],["Guerrilla","Camps","CampE"],["Guerrilla","Camps","CampF"],["MCC_comps","civilians","slums"],["MCC_comps","Guerrilla","campSite"]]',
    true,
    {
        params ["_value"];
        MCC_MWSITES = [_value, '[["Guerrilla","Camps","CampA"],["Guerrilla","Camps","CampB"],["Guerrilla","Camps","CampC"],["Guerrilla","Camps","CampD"],["Guerrilla","Camps","CampE"],["Guerrilla","Camps","CampF"],["MCC_comps","civilians","slums"],["MCC_comps","Guerrilla","campSite"]]', "MCC_MWSITES"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Composition Military
[
    "MCC_MWSITESmilitary",
    "EDITBOX",
    ["Compositions military",'Will be used as compositions for military must be defined in ("CfgGroups" >> "Empty")'],
    "MCC Mission Generator",
    '[["Military","Outposts","OutpostA"],["Military","Outposts","OutpostB"],["Military","Outposts","OutpostC"],["Military","Outposts","OutpostD"],["Military","Outposts","OutpostE"],["Military","Outposts","OutpostF"]]',
    true,
    {
        params ["_value"];
        MCC_MWSITESmilitary = [_value, '[["Military","Outposts","OutpostA"],["Military","Outposts","OutpostB"],["Military","Outposts","OutpostC"],["Military","Outposts","OutpostD"],["Military","Outposts","OutpostE"],["Military","Outposts","OutpostF"]]', "MCC_MWSITESmilitary"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

[
    "MCC_MWIEDDisarmMode",
    "LIST",
    ["Disarm IED","How players deal with the Mission Generator's 'Disarm IED' objective.\nSafe disarm: hold the action key at the IED for 10 s - it cannot go wrong.\nDisarm: MCC's original - hold the MCC interaction key, with a chance to fail.\nBomb manual: another player reads the Bomb Manual (map diary) to you.\nPlace Charge: blow it up with a demo charge - the task always fails."],
    "MCC Mission Generator",
    [[0,1,2,3],["Safe disarm (hold action key)","Disarm (MCC interaction key)","Bomb manual","Place Charge"],0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_spawnPacing",
    "SLIDER",
    ["Spawn pacing","Seconds between each group or vehicle the Mission Generator spawns.\nSpreads the spawning out so the game does not stall when a mission is\ngenerated. 0 = all at once (as the original MCC)."],
    "MCC Mission Generator",
    [0, 2, 0.5, 1],
    true
] call CBA_Settings_fnc_init;
