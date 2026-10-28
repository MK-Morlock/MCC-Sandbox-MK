class mcc_sandbox_moduleRestrictedZone : Module_F
{
	category = "MCC";
	author = "shay_gman";
	displayName = "Restricted zones";
	function = "MCC_fnc_createRestrictedZones";
	icon = "\mcc_sandbox_mod\data\mccModule.paa";
	picture = "\mcc_sandbox_mod\data\mccModule.paa";
	_generalMacro = "ModuleZoneRestriction_F";
	scope = 2;
	isGlobal = 2;
	isTriggerActivated = 0;

	class Attributes: AttributesBase
	{
		class sides : Combo
		{
			displayName = "Restricted Sides";
			description = "Enter the restricted sides as array [west,east,resistance,civilian]";
			typeName = "NUMBER";
			property = "mcc_sandbox_moduleRestrictedZone_sides";

			class values
			{
				class All
				{
					name = "All";
					value = -1;
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

		class time : Edit
		{
			displayName = "Time Before Punishment";
			description = "How many seconds a player of a restricted side has to leave the zone before he is killed";
			typeName = "NUMBER";
			defaultValue = "10";
			property = "mcc_sandbox_moduleRestrictedZone_time";
		};

		class air : Checkbox
		{
			displayName = "Allow aircraft (above 20 m)";
			description = "Ticked: aircraft flying more than 20 m above the ground may cross the zone without being punished. Unticked: aircraft are punished like everyone else";
			typeName = "BOOL";
			property = "mcc_sandbox_moduleRestrictedZone_air";
		};

		class createMarker : Checkbox
		{
			displayName = "Create markers";
			description = "Create markers at the triggers' locations";
			typeName = "BOOL";
			property = "mcc_sandbox_moduleRestrictedZone_createMarker";
		};

		class keepAIOut : Checkbox
		{
			displayName = "Keep AI out";
			description = "AI of the restricted sides (civilians included) are turned back at the edge of the zones, on foot and in vehicles, and their waypoints inside a zone are moved just outside. Players are handled as before";
			typeName = "BOOL";
			defaultValue = "false";
			property = "mcc_sandbox_moduleRestrictedZone_keepAIOut";
		};
		class aiInside : Combo
		{
			displayName = "AI already inside at the start";
			description = "With Keep AI out: AI of the restricted sides already in a zone when the mission starts";
			typeName = "NUMBER";
			property = "mcc_sandbox_moduleRestrictedZone_aiInside";
			class values
			{
				class moveOut
				{
					name = "Move them out";
					value = 0;
					default = 1;
				};
				class leave
				{
					name = "Leave them (only newcomers turned back)";
					value = 1;
				};
			};
		};
		class exemptions : Edit
		{
			displayName = "Exemptions";
			description = "Variable names allowed into the zones, separated by commas or spaces (e.g. civ1, civ2, informant): a unit, a vehicle (its crew) or a group (all its members). Players with one of these names are not punished either";
			typeName = "STRING";
			defaultValue = """""";
			property = "mcc_sandbox_moduleRestrictedZone_exemptions";
		};
		class ModuleDescription: ModuleDescription{};
	};

	class ModuleDescription: ModuleDescription
	{
		description = "Sync with any trigger to create restricted areas (straight to this module, or through a Location / Area)";
		sync[] = {"EmptyDetector", "LocationArea_F"};

		class EmptyDetector
		{
			description[] = {
				"Any trigger: its area is a restricted zone"
			};
			optional = 1;
			duplicate = 1;
		};
		class LocationArea_F
		{
			description[] = {
				"Sync with any trigger"
			};
			optional = 1;
			duplicate = 1;
			synced[] = {"EmptyDetector"};
		};
	};
};
