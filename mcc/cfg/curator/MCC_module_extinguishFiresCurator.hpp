class MCC_module_extinguishFiresCurator : MCC_Module_Base
{
	scope = 2;
	isGlobal = 0;
	scopeCurator = 2;
	category = "MCC_Environment";
	displayName = "Extinguish Fires";
	function = "MCC_fnc_ambientFireExtinguish";
	portrait = "a3\ui_f\data\Map\LocationTypes\vegetationBroadleaf_CA.paa";
	icon = "a3\ui_f\data\Map\LocationTypes\vegetationBroadleaf_CA.paa";
	picture = "a3\ui_f\data\Map\LocationTypes\vegetationBroadleaf_CA.paa";

	class Attributes: AttributesBase
	{
		class ModuleDescription: ModuleDescription{};
	};

	class ModuleDescription: ModuleDescription
	{
		description = "Puts out all MCC ambient fires within 300 m of where it is placed and stops them spreading further.";
	};
};
