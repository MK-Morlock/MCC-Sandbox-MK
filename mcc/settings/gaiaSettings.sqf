//AI Skill(overall)
[
    "MCC_AI_Skill_Index",
    "SLIDER",
   	"AI Skill(overall)",
    ["MCCMK GAIA", "AI Skill"],
    [1, 10, 5, 0],
    true,
    {
    	MCC_AI_Skill = MCC_AI_Skill_Index/10;
    	publicVariable "MCC_AI_Skill";
    }
] call CBA_Settings_fnc_init;

//AI Skill(aim)
[
    "MCC_AI_AimIndex",
    "SLIDER",
   	"AI Skill(Aim)",
    ["MCCMK GAIA", "AI Skill"],
    [1, 10, 5, 0],
    true,
    {
    	MCC_AI_Aim = MCC_AI_AimIndex/10;
    	publicVariable "MCC_AI_Aim";
    }
] call CBA_Settings_fnc_init;

//AI Skill(Spot)
[
    "MCC_AI_SpotIndex",
    "SLIDER",
   	"AI Skill(Spot)",
    ["MCCMK GAIA", "AI Skill"],
    [1, 10, 5, 0],
    true,
    {
    	MCC_AI_Spot = MCC_AI_SpotIndex/10;
    	publicVariable "MCC_AI_Spot";
    }
] call CBA_Settings_fnc_init;

//AI Skill(Command)
[
    "MCC_AI_CommandIndex",
    "SLIDER",
   	"AI Skill(Command)",
    ["MCCMK GAIA", "AI Skill"],
    [1, 10, 5, 0],
    true,
    {
    	MCC_AI_Command = MCC_AI_CommandIndex/10;
    	publicVariable "MCC_AI_Command";
    }
] call CBA_Settings_fnc_init;


//AI use smoke grenade and flares
[
    "MCC_GAIA_AMBIANT",
    "CHECKBOX",
   	"AI Use Smoke Grenades & flares",
   	["MCCMK GAIA", "AI Smoke & Flares"],
    false,
    true
] call CBA_Settings_fnc_init;

//AI use smoke grenade and flares
[
    "MCC_GAIA_AMBIANT_CHANCE",
    "SLIDER",
   	"Smoke/flares Chance",
  	["MCCMK GAIA", "AI Smoke & Flares"],
    [20, 80, 50, 0],
    true
] call CBA_Settings_fnc_init;

//AI Cache
[
    "GAIA_CACHE_STAGE_1",
    "SLIDER",
   	["Cache Distance","How far any player should be from a unit before it is\ncached"],
  	"MCCMK GAIA",
    [1000, 10000, 3000, 0],
    true
] call CBA_Settings_fnc_init;

//AI use smoke grenade and flares
[
    "MCC_GAIA_ATTACKS_FOR_NONGAIA",
    "CHECKBOX",
   	["GAIA Controls All","If set to everyone, GAIA will give orders to all\navailable units, even players"],
   	"MCCMK GAIA",
    false,
    true
] call CBA_Settings_fnc_init;

[
    "MCC_aiDrones",
    "CHECKBOX",
    ["AI drones","Enemy UAV and ground-robot operators launch the drone\nin their backpack: when their group knows of an enemy,\nor every 15-30 minutes to circle their group. One drone\nper mission at a time; 10-minute battery, 15-minute\nrecharge. Groups within 400 m learn what it sees. Can\nbe turned off per mission."],
    ["MCCMK GAIA", "AI Drones"],
    true,
    true
] call CBA_Settings_fnc_init;

//(MK) the same for the friendly side - and what players see of it
[
    "MCC_aiDronesFriendly",
    "CHECKBOX",
    ["Friendly AI drones", "Friendly AI UAV and ground-robot operators (not in a\nplayer's group) launch the drone in their backpack too,\nby the same rules as the enemy's: when their group knows\nof an enemy, or now and then to circle it. One friendly\ndrone at a time per side. Friendly groups within 400 m\nof the operator learn what it sees."],
    ["MCCMK GAIA", "AI Drones"],
    true,
    true
] call CBA_Settings_fnc_init;
[
    "MCC_aiDroneSightings",
    "LIST",
    ["Friendly drone sightings", "What players see of a friendly AI drone's sightings.\nArma's map icons: given to the players' groups, shown\nby Arma's own enemy map icons where the difficulty\nallows them. On any difficulty: the same, and matching\nicons drawn where the difficulty hides enemy icons\n(only what the drone saw, faded out over 60 s)."],
    ["MCCMK GAIA", "AI Drones"],
    [[0, 1, 2], ["Off", "Arma's map icons", "Arma's map icons on any difficulty"], 1],
    true
] call CBA_Settings_fnc_init;