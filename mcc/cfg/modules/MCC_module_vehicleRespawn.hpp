class MCC_module_vehicleRespawn : Module_F
{
	category = "MCC";
	displayName = "Vehicle Respawn";
	function = "MCC_fnc_vehicleRespawn";
	scope = 2;
	isGlobal = 0;

	class Attributes: AttributesBase
	{
		class abondanDistance : Edit
		{
			displayName = "Abandon Distance";
			description = "How far away a unit must be before an empty vehicle is forced to respawn (leave empty for none)";
			typeName = "NUMBER";
			defaultValue = 300;
			property = "MCC_module_vehicleRespawn_abondanDistance";
		};

		class waitTime : Edit
		{
			displayName = "Wait Time";
			description = "How long before the vehicle respawns, in seconds";
			typeName = "NUMBER";
			defaultValue = 5;
			property = "MCC_module_vehicleRespawn_waitTime";
		};

		class tickets : Edit
		{
			displayName = "Respawns";
			description = "How many times the vehicle can respawn, leave empty for infinite";
			typeName = "NUMBER";
			property = "MCC_module_vehicleRespawn_tickets";
		};

		class destroyEffect : Checkbox
		{
			displayName = "Explosion Effect";
			description = "The vehicle wreck will explode before it is deleted";
			typeName = "BOOL";
			property = "MCC_module_vehicleRespawn_destroyEffect";
		};

		class respawnDisabled : Checkbox
		{
			displayName = "Disabled Vehicles";
			description = "Respawn Disabled Vehicles";
			typeName = "BOOL";
			property = "MCC_module_vehicleRespawn_respawnDisabled";
		};

		class code : Edit
		{
			displayName = "Code";
			description = "Code to execute on respawn; the vehicle is referred to as _this";
			typeName = "STRING";
			defaultValue = "";
			property = "MCC_module_vehicleRespawn_code";
		};

		class ModuleDescription: ModuleDescription{};
	};

	class ModuleDescription: ModuleDescription
	{
		description = "Sync it with any vehicles to respawn";
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