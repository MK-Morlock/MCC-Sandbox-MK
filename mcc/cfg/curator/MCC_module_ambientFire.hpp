class MCC_module_ambientFireCurator : MCC_Module_Base
{
	scope = 2;
	isGlobal = 1;
	scopeCurator = 2;
	category = "MCC_Environment";
	displayName = "$STR_Module__ambientFire_displayName";
	function = "MCC_fnc_ambientFireInit";
	portrait = "a3\ui_f\data\Map\LocationTypes\vegetationBroadleaf_CA.paa";
	icon = "a3\ui_f\data\Map\LocationTypes\vegetationBroadleaf_CA.paa";
	picture = "a3\ui_f\data\Map\LocationTypes\vegetationBroadleaf_CA.paa";

	class Attributes: AttributesBase
	{
		class vehicleChance : Edit
		{
			displayName = "Vehicle fire chance %";
			description = "0-100. Chance a destroyed vehicle starts a fire. -1 = use the CBA setting.";
			typeName = "NUMBER";
			defaultValue = "-1";
			property = "MCC_ambientFire_vehicleChance";
		};
		class explosivesChance : Edit
		{
			displayName = "Explosives fire chance";
			description = "0-100. Chance an explosive round starts a fire (scaled by how explosive it is). -1 = use the CBA setting.";
			typeName = "NUMBER";
			defaultValue = "-1";
			property = "MCC_ambientFire_explosivesChance";
		};
		class spreadChance : Edit
		{
			displayName = "Fire spread chance %";
			description = "0-100. Chance a burning tree or house starts a new fire around it. -1 = use the CBA setting.";
			typeName = "NUMBER";
			defaultValue = "-1";
			property = "MCC_ambientFire_spreadChance";
		};
		class ModuleDescription: ModuleDescription{};
	};

	class ModuleDescription: ModuleDescription
	{
		description = "$STR_Module__ambientFire_description";
	};
};