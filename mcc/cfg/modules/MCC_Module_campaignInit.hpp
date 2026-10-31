class MCC_Module_campaignInit : Module_F
{
	scope = 2;
	isGlobal = 0;
	category = "MCC";
	displayName = "Campaign init";
	function = "MCC_fnc_curatorCampaignInit";

	class Attributes: AttributesBase
	{
		class factionPlayer : Edit
		{
			control = "MCC_AttributeFaction";	//drop-down of all loaded factions (mod factions included)
			displayName = "Players Faction";
			description = "Config name";
			typeName = "STRING";
			defaultValue = """BLU_F""";
			property = "MCC_Module_campaignInit_factionPlayer";
		};

		class playerContent : Combo
		{
			displayName = "Players Content";
			description = "Which units and vehicles the players' faction may use: its own, plus Creator DLC, or every loaded mod";
			typeName = "NUMBER";
			property = "MCC_Module_campaignInit_playerContent";
			class values
			{
				class own
				{
					name = "Faction only";
					value = 0;
				};
				class creatorDLC
				{
					name = "Faction + Creator DLC";
					value = 1;
					default = 1;
				};
				class allMods
				{
					name = "All loaded mods";
					value = 2;
				};
			};
		};

		class factionRivalPlayer : Combo
		{
			displayName = "Rival Players Side";
			description = "Players on the rival side gain resources by killing the main faction's players";
			typeName = "NUMBER";
			property = "MCC_Module_campaignInit_factionRivalPlayer";

			class values
			{
				class none
				{
					name = "None";
					value = 7;
					default = 1;
				};
				class BLUFOR
				{
					name = "$STR_WEST";
					value = 1;
				};
				class OPFOR
				{
					name = "$STR_EAST";
					value = 0;
				};
				class Independent
				{
					name = "$STR_GUERRILA";
					value = 2;
				};
				class Civilian
				{
					name = "$STR_CIVILIAN";
					value = 3;
				};
			};
		};

		class factionEnemy : Edit
		{
			control = "MCC_AttributeFaction";	//drop-down of all loaded factions (mod factions included)
			displayName = "Enemy Faction";
			typeName = "STRING";
			description = "Config name";
			defaultValue = """OPF_F""";
			property = "MCC_Module_campaignInit_factionEnemy";
		};

		class enemyContent : Combo
		{
			displayName = "Enemy Content";
			description = "Which units and vehicles the enemy faction may use: its own, plus Creator DLC, or every loaded mod";
			typeName = "NUMBER";
			property = "MCC_Module_campaignInit_enemyContent";
			class values
			{
				class own
				{
					name = "Faction only";
					value = 0;
				};
				class creatorDLC
				{
					name = "Faction + Creator DLC";
					value = 1;
					default = 1;
				};
				class allMods
				{
					name = "All loaded mods";
					value = 2;
				};
			};
		};

		class factionCiv : Edit
		{
			control = "MCC_AttributeFaction";	//drop-down of all loaded factions (mod factions included)
			displayName = "Civilian Faction";
			typeName = "STRING";
			description = "Config name";
			defaultValue = """CIV_F""";
			property = "MCC_Module_campaignInit_factionCiv";
		};

		class civContent : Combo
		{
			displayName = "Civilian Content";
			description = "Which units and vehicles the civilian faction may use: its own, plus Creator DLC, or every loaded mod";
			typeName = "NUMBER";
			property = "MCC_Module_campaignInit_civContent";
			class values
			{
				class own
				{
					name = "Faction only";
					value = 0;
				};
				class creatorDLC
				{
					name = "Faction + Creator DLC";
					value = 1;
					default = 1;
				};
				class allMods
				{
					name = "All loaded mods";
					value = 2;
				};
			};
		};

		class forceSpread : Combo
		{
			displayName = "Force Spread";
			description = "Where enemy forces start: Tight = near the centre, Normal = original MCC, Wide = evenly over the zone";
			typeName = "NUMBER";
			property = "MCC_Module_campaignInit_forceSpread";
			class values
			{
				class tight
				{
					name = "Tight";
					value = 0;
				};
				class normal
				{
					name = "Normal";
					value = 1;
					default = 1;
				};
				class wide
				{
					name = "Wide";
					value = 2;
				};
			};
		};

		class missionMax : Combo
		{
			displayName = "Number of Missions";
			description = "Until Campaign Ends - 0 means no mission will be generated";
			typeName = "NUMBER";
			property = "MCC_Module_campaignInit_missionMax";
			class values
			{
				class five
				{
					name = "5";
					value = 5;
				};
				class ten
				{
					name = "10";
					value = 10;
					default = 1;
				};
				class fifteen
				{
					name = "15";
					value = 15;
				};
				class unlimited
				{
					name = "unlimited";
					value = 9999;
				};
			};
		};

		class difficulty : Combo
		{
			displayName = "Difficulty";
			description = "Easy, Medium and Hard give about 5, 10 or 20 enemies per player, and rise 10% after each mission. Higher difficulty also means more vehicles, armour, artillery and objectives.";
			typeName = "NUMBER";
			property = "MCC_Module_campaignInit_difficulty";

			class values
			{
				class easy
				{
					name = "Easy";
					value = 10;
				};
				class Medium
				{
					name = "Medium";
					value = 20;
					default = 1;
				};
				class Hard
				{
					name = "Hard";
					value = 40;
				};
			};
		};

		class playMusic : Combo
		{
			displayName = "Intro";
			typeName = "NUMBER";
			property = "MCC_Module_campaignInit_playMusic";

			class values
			{
				class all
				{
					name = "Cinematic";
					value = 0;
				};
				class popup
				{
					name = "Pop-Up";
					value = 1;
					default = 1;
				};
				class none
				{
					name = "None";
					value = 2;
				};
			};
		};

		class tickets : Edit
		{
			displayName = "Starting Tickets";
			typeName = "NUMBER";
			defaultValue = 100;
			property = "MCC_Module_campaignInit_tickets";
		};

		class playersCount : Edit
		{
			displayName = "Players (enemy scaling)";
			description = "Enemy numbers are sized for at least this many players (0 = count the real players). Enemies per mission: about 5, 10 or 20 per player (Easy / Medium / Hard), rising 10% after each mission.";
			typeName = "NUMBER";
			defaultValue = 0;
			property = "MCC_Module_campaignInit_playersCount";
		};

		class missionRotation : Edit
		{
			displayName = "Missions Rotation";
			description = "How many missions are played in the same area before the campaign moves to a new area (1 = a new area for every mission)";
			typeName = "NUMBER";
			defaultValue = 1;
			property = "MCC_Module_campaignInit_missionRotation";
		};

		class tileSize : Edit
		{
			displayName = "Tile Size";
			description = "MCC divides the map into tiles - the default size of a tile";
			typeName = "NUMBER";
			defaultValue = 400;
			property = "MCC_Module_campaignInit_tileSize";
		};

		class tileTransparency : Default
		{
			displayName = "Map Overlay Transparency";
			description = "Makes the red/blue territory squares on the map more see-through. Shading differences between squares are kept; 100% hides them completely. Territory, enemy spawns and saving are not affected.";
			tooltip = "Makes the red/blue territory squares on the map more see-through. Shading differences between squares are kept; 100% hides them completely. Territory, enemy spawns and saving are not affected.";
			control = "Slider";
			typeName = "NUMBER";
			defaultValue = "0";
			property = "MCC_Module_campaignInit_tileTransparency";
		};

		class objectiveMarkers : Combo
		{
			displayName = "Objective Markers";
			tooltip = "Area: task markers are placed up to ~400 m from the objective and must be searched for (classic MCC campaign). Precise: markers sit on the objective with a 3D icon.";
			typeName = "NUMBER";
			property = "MCC_Module_campaignInit_objectiveMarkers";
			defaultValue = "1";

			class values
			{
				class area
				{
					name = "Area (search)";
					value = 0;
				};
				class precise
				{
					name = "Precise";
					value = 1;
					default = 1;
				};
			};
		};

		class overStorage : Combo
		{
			displayName = "Resources Over Storage Limit";
			description = "What happens to resources above your storage limit (HQ + Storage Areas) when a campaign mission ends. Cut: anything over the limit is lost at once (original MCC). Keep: only the new reward is capped; stock already over the limit stays and is lost at 10% per in-game hour instead.";
			tooltip = "What happens to resources above your storage limit (HQ + Storage Areas) when a campaign mission ends. Cut: anything over the limit is lost at once (original MCC). Keep: only the new reward is capped; stock already over the limit stays and is lost at 10% per in-game hour instead.";
			typeName = "NUMBER";
			property = "MCC_Module_campaignInit_overStorage";
			defaultValue = "0";

			class values
			{
				class cut
				{
					name = "Cut at mission end (original)";
					value = 0;
					default = 1;
				};
				class keep
				{
					name = "Keep (lose 10% per hour)";
					value = 1;
				};
			};
		};

		class loadDB : Checkbox
		{
			displayName = "Load from DB";
			description = "Load saved campaign data from the database";
			property = "MCC_Module_campaignInit_loadDB";
		};

		class ModuleDescription: ModuleDescription{};
	};

	class ModuleDescription: ModuleDescription
	{
		description = "Creates a Campaign. MCC will generate missions and the players will gain resources to expand their base. Every in-game day the enemy faction behavior will change according to the players advance";
		sync[] = {"mcc_sandbox_moduleStartLocations","mcc_sandbox_moduleMissionSettings"};

		class mcc_sandbox_moduleStartLocations
		{
			description[] = {
				"Set at least one HQ start location"
			};
			position = 0;
			direction = 0;
			optional = 0;
			duplicate = 0;
			synced[] = {"AnyVehicle"};
		};
		class mcc_sandbox_moduleMissionSettings
		{
			description[] = {
				"Recommanded to use Role Selection and time acceleration"
			};
			position = 0;
			direction = 0;
			optional = 0;
			duplicate = 0;
			synced[] = {"AnyVehicle"};
		};
	};
};