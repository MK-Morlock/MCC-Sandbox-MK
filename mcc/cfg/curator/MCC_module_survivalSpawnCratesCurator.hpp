class MCC_module_survivalSpawnCratesCurator : MCC_Module_Base
{
	scope = 2;
	isGlobal = 1;
	scopeCurator = 2;
	category = "MCC";
	displayName = "Survival: Spawn loot in buildings";
	icon = "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\backpack_ca.paa";
	portrait = "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\backpack_ca.paa";
	picture = "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\backpack_ca.paa";
	function = "MCC_fnc_spawnCratesInHousesInit";
	author = "shay_gman";

	class Attributes: AttributesBase
	{
		class radius : Edit
		{
			displayName = "Radius";
			description = "Radius in meters around the module";
			typeName = "NUMBER";
			defaultValue = 300;
			property = "MCC_module_survivalSpawnCratesCurator_radius";
		};

		class density : Edit
		{
			displayName = "Density";
			description = "Density from 1 to 10, where 10 is the maximum";
			typeName = "NUMBER";
			defaultValue = 3;
			property = "MCC_module_survivalSpawnCratesCurator_density";
		};

		class markers : Checkbox
		{
			displayName = "Markers";
			description = "Create markers";
			typeName = "BOOL";
			property = "MCC_module_survivalSpawnCratesCurator_markers";
		};

		class ModuleDescription: ModuleDescription{};
	};

	class ModuleDescription: ModuleDescription
	{
		description = "Spawn loot crates in buildings either around the module or in any of the synced triggers";
		sync[] = {"TriggerArea"};

		class TriggerArea
		{
			description[] = {
				"Sync triggers with the module",
				"Spawns loot in buildings"
			};
			area = 1;
			position = 1;
			direction = 1;
			optional = 0;
			duplicate = 0;
			vehicle = "EmptyDetector";
		};
	};
};