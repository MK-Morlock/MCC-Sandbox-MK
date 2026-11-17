//HVT
[
    "MCC_MWHVT",
    "EDITBOX",
    ["HVT (man)","Unit that will be used as high value target"],
    "MCCMK Mission Generator",
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
    "MCCMK Mission Generator",
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
    "MCCMK Mission Generator",
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
    "MCCMK Mission Generator",
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
    ["Armored Vehicles (Vehicle)","Vehicle that will be used in destroy armored vehicle\nmissions"],
    "MCCMK Mission Generator",
    '["B_MBT_01_cannon_F","O_MBT_02_cannon_F","I_MBT_03_cannon_F"]',
    true,
    {
        params ["_value"];
        MCC_MWTanks = [_value, '["B_MBT_01_cannon_F","O_MBT_02_cannon_F","I_MBT_03_cannon_F"]', "MCC_MWTanks"] call MCC_fnc_parseSetting;
    }
] call CBA_Settings_fnc_init;

//Air
[
    "MCC_MWAir",
    "EDITBOX",
    ["Air Vehicles (Vehicle)","Vehicle that will be used in destroy air vehicle\nmissions"],
    "MCCMK Mission Generator",
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
    "MCCMK Mission Generator",
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
    "MCCMK Mission Generator",
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
    ["Ammo cache (Box)","Ammo box that will be used in destroy cache vehicle\nmissions"],
    "MCCMK Mission Generator",
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
    "MCCMK Mission Generator",
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
    "MCCMK Mission Generator",
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
    "MCCMK Mission Generator",
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
    "MCCMK Mission Generator",
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
    ["Disarm IED","How players clear the 'Disarm IED' objective.\nSafe disarm: hold the action key for 10 s - it can't go\nwrong.\nDisarm: MCC's original, with a chance to fail.\nBomb manual: another player reads you the Bomb Manual.\nPlace Charge: blow it up - the task fails."],
    "MCCMK Mission Generator",
    [[0,1,2,3],["Safe disarm (hold action key)","Disarm (MCC interaction key)","Bomb manual","Place Charge"],0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_MWParkedCivMax",
    "LIST",
    ["Parked civilian vehicles per task", "With civilians on, the most empty civilian cars the\nMission Generator parks along the roads around each\ntask (objective) of a mission - campaign missions too.\n(It parks fewer where there are few buildings.)"],
    "MCCMK Mission Generator",
    [[2, 4, 8], ["2 per task", "4 per task", "8 per task (as the original MCC)"], 1],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_spawnPacing",
    "SLIDER",
    ["Spawn pacing","Seconds between each group or vehicle the Mission\nGenerator spawns.\nSpreads the spawning out so the game does not stall\nwhen a mission is generated. 0 = all at once (as the\noriginal MCC)."],
    "MCCMK Mission Generator",
    [0, 2, 0.5, 1],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_MWVehicleSpawnMode",
    "LIST",
    ["Vehicle groups","How the Mission Generator spends a mission's vehicle\nbudget.\nModified: mostly single vehicles; about 1 pick in 4 is\na pair, or a vehicle with its squad. A mission gets the\nsame number of vehicles either way.\nOriginal: MCC's calculation - groups of any size, but\ninfantry groups are rare and mechanised infantry almost\nnever appears."],
    "MCCMK Mission Generator",
    [[0, 1], ["Original", "Modified"], 1],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_MWBoats",
    "LIST",
    ["Boats","Enemy boat patrols in generated missions.\nAuto: as original MCC - when there is water within 2.5\ntimes the mission radius (at least 2 m deep and 15 m\nfrom shore, up to 1 km out). Small ponds get none.\nOff: never."],
    "MCCMK Mission Generator",
    [[0, 1], ["Auto", "Off"], 0],
    true
] call CBA_Settings_fnc_init;

// (Generated Mission Rewards moved to Addon Options -> MCC Resources: "Resources - without a campaign")

[
    "MCC_aiCountAsPlayers",
    "CHECKBOX",
    ["AI Count As Players","On: AI in the players' force count towards the player\nnumber that sets mission size and rewards. AI in a\nplayer's squad count as a half or a quarter each (AI\nSquadmate Value), AI the commander controls as a\nquarter. Drones don't count.\nExample: 1 player + 12 AI squadmates = 7 players.\nOff: only human players count (original MCC)."],
    "MCCMK Mission Generator",
    true,
    true
] call CBA_Settings_fnc_init;

[
    "MCC_aiSquadmateValue",
    "LIST",
    ["AI Squadmate Value","How much each AI in a player's squad counts, when AI\nCount As Players is on.\nHalf: 1 player + 12 AI = 7 players (about 80 enemies\nper Medium campaign mission).\nQuarter: the same squad = 4 players (about 50 enemies).\nAI the commander controls always count as a quarter."],
    "MCCMK Mission Generator",
    [[0.25, 0.5], ["Quarter", "Half"], 1],
    true
] call CBA_Settings_fnc_init;

//(MK) Campaign patrols' infantry: the faction's own ready-made groups like the generated missions (a recon, sniper or
// support team one time in five), or squads MCC builds itself from ordinary soldiers (the original)
[
    "MCCMK_campaignPatrolInf",
    "LIST",
    ["Campaign patrol infantry","Faction's own groups: each infantry patrol is one of the\nfaction's ready-made groups, like the generated missions\n(a recon, sniper or support team one time in five).\nMCC-built squads: ordinary soldiers, as the original did."],
    "MCCMK Mission Generator",
    [[0, 1], ["Faction's own groups", "MCC-built squads (original)"], 0],
    true
] call CBA_Settings_fnc_init;

//(MK) Campaign missions: civilians the same way the Mission Generator adds them (off: none)
[
    "MCCMK_campaignCivilians",
    "CHECKBOX",
    ["Campaign Civilians","Campaign missions add civilians the same way the\nMission Generator does when its Civilians option is on.\nOff: campaign missions have no civilians (as before)."],
    "MCCMK Mission Generator",
    false,
    true
] call CBA_Settings_fnc_init;

[
    "MCC_cleanupMissions",
    "CHECKBOX",
    ["Cleanup: Finished Missions","Removes a finished generated or campaign mission\n(compositions, enemies, markers) once no player is near\nor can see it. Hidden map objects come back. Anything\nplayers built or used is kept."],
    "MCCMK Mission Generator",
    true,
    true
] call CBA_Settings_fnc_init;

[
    "MCC_cleanupDistance",
    "SLIDER",
    ["Cleanup: Distance (m)","A finished mission is removed once no player is within\nthis distance or can see it."],
    "MCCMK Mission Generator",
    [200, 3000, 1000, 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_cleanupWait",
    "SLIDER",
    ["Cleanup: Wait (minutes)","How long a finished mission must stay out of every\nplayer's range and sight before it is removed."],
    "MCCMK Mission Generator",
    [1, 30, 5, 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_cleanupBackstop",
    "SLIDER",
    ["Cleanup: Backstop (minutes)","If players stay near a finished mission (holding it as\na base, say), its leftovers go after this long, piece\nby piece, when nobody is within 50 m or looking.\n0 = off."],
    "MCCMK Mission Generator",
    [0, 240, 60, 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_cleanupBodies",
    "SLIDER",
    ["Cleanup: Bodies (minutes)","Enemy bodies from generated and campaign missions are\nremoved this long after death, once nobody is within 50\nm or looking at them.\n0 = never."],
    "MCCMK Mission Generator",
    [0, 120, 20, 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_cleanupWrecks",
    "SLIDER",
    ["Cleanup: Wrecks (minutes)","Wrecks, and enemy vehicles left empty or disabled, are\nremoved this long after - from missions and everywhere\nelse - when nobody is within 50 m (an enemy vehicle: 300\nm) or looking. Never within 300 m of a base, never a\nvehicle players have been in, never player-side vehicles\nor supply pods. Sunk wrecks too (a diver can salvage them).\n0 = never."],
    "MCCMK Mission Generator",
    [0, 240, 60, 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_MWmaxPlayers",
    "SLIDER",
    ["Max Players","Highest value on the Mission Generator's players\nslider.\nEnemies are about 2, 4 or 6 per player\n(Easy/Medium/Hard): 100 players on Medium is about 400\nenemies."],
    "MCCMK Mission Generator",
    [10, 100, 100, 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_MWAirDefenceChance",
    "SLIDER",
    ["Air Defence: Site Chance (%)","Chance that a generated mission gets an air-defence\nsite (a SAM launcher with a radar).\nRolled separately for each mission: 0 = never, 100 =\nalways."],
    "MCCMK Mission Generator",
    [0, 100, 25, 0],
    true
] call CBA_Settings_fnc_init;

[
    "MCC_MWAirDefenceFallback",
    "CHECKBOX",
    ["Air Defence: Standard SAM And Radar","Air-defence sites use the enemy faction's own SAM\nlauncher and radar, or Arma's standard ones when it has\nnone.\nUntick: no air-defence site for factions without them."],
    "MCCMK Mission Generator",
    true,
    true
] call CBA_Settings_fnc_init;
