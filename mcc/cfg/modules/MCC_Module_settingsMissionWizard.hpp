class MCC_Module_settingsMissionWizard : Module_F
{
	category = "MCC";
	displayName = "(Settings) Mission Generator";
	function = "MCC_fnc_settingsMissionWizard";
	scope = 2;
	isGlobal = 1;

	class Attributes : AttributesBase
	{
		class VariableName : Combo
		{
			displayName = "Objectives Variable";
			description = "Which variable will change";
			typeName = "NUMBER";
			property = "MCC_Module_settingsMissionWizard_Variable";

			class values
			{
				class MCC_MWHVT
				{
					name = "HVT(man)";
					value = 0;
					default = 1;
				};
				class MCC_MWRadio
				{
					name = "Radio Tower(Land)";
					value = 1;
				};
				class MCC_MWFuelTanks
				{
					name = "Fuel Tanks(Land)";
					value = 2;
				};

				class MCC_MWTanks
				{
					name = "Armored Vehicles(Vehicle)";
					value = 3;
				};

				class MCC_MWAir
				{
					name = "Air Vehicles(Vehicle)";
					value = 4;
				};

				class MCC_MWcache
				{
					name = "Ammo cache (Box)";
					value = 5;
				};

				class MCC_MWradar
				{
					name = "Radar(Land)";
					value = 6;
				};

				class MCC_MWIntelObjects
				{
					name = "Intel Objects(Small Items)";
					value = 7;
				};

				class MCC_MWIED
				{
					name = "IED(Small Items)";
					value = 8;
				};

				class MCC_MWAA
				{
					name = "Anti-Air(Vehicle)";
					value = 9;
				};

				class MCC_MWArtillery
				{
					name = "Artillery(Vehicle)";
					value = 10;
				};
			};
		};

		class VariableClass : Edit
		{
			displayName = "Variable Class";
			description = "Class names for the list chosen in Objectives Variable, e.g. [""O_officer_F"",""C_Nikos""]. Objects synced to this module are added (and removed from the map at start). Left at the default with nothing synced, the list is not changed.";
			typeName = "STRING";
			defaultValue = '["B_officer_F","O_officer_F","I_officer_F","C_Nikos"]';
			property = "MCC_Module_settingsMissionWizard_displayName";
		};

		class enemyFaction : Edit
		{
			control = "MCC_AttributeFactionOptional";	//drop-down of all loaded factions (mod factions included)
			displayName = "Enemy Faction (Mission Generator)";
			description = "Enemy faction the Mission Generator starts on in this mission (you can still change it in its Rival Faction list). Not set: a faction of the side opposite the player.";
			typeName = "STRING";
			defaultValue = """""";
			property = "MCC_Module_settingsMissionWizard_enemyFaction";
		};

		class civFaction : Edit
		{
			control = "MCC_AttributeFactionOptional";
			displayName = "Civilian Faction (Mission Generator)";
			description = "Civilian faction the Mission Generator starts on in this mission (you can still change it). Leave empty for the first in the list, as before.";
			typeName = "STRING";
			defaultValue = """""";
			property = "MCC_Module_settingsMissionWizard_civFaction";
		};

		class players : Edit
		{
			displayName = "# Players (Mission Generator)";
			description = "Starting value of the Mission Generator # Players slider in this mission (more players = more enemies and a larger area). 0 = leave the slider as it is.";
			typeName = "NUMBER";
			defaultValue = 0;
			property = "MCC_Module_settingsMissionWizard_players";
		};

		class ModuleDescription: ModuleDescription{};
	};

	class ModuleDescription: ModuleDescription
	{
		description = 'Define classes for the mission Generator -Synced vehicles or array of strings typed in "Variable Class" will be used in the mission wizard';
		sync[] = {"AnyVehicle"};

		class AnyVehicle
		{
			description = "Any vehicle. No persons or static objects.";
			displayName = "Any vehicle";
			icon = "iconCar";
			side = 4;
			position = 1;
			direction = 1;
			optional = 0;
			duplicate = 1;
		};
	};
};