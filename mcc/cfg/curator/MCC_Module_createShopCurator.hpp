class MCC_Module_createShopCurator : MCC_Module_Base
{
	scope = 2;
	isGlobal = 1;
	scopeCurator = 2;
	category = "MCC_RTS";
	displayName = "Weapon Shop";
	function = "MCC_fnc_weaponShopInit";
	icon = "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa";
	portrait = "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa";
	picture = "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\rearm_ca.paa";

	class Attributes : AttributesBase
	{
		class tittle : Edit
		{
			displayName = "Action Text";
			typeName = "STRING";
			defaultValue = """Open Shop""";
			property = "MCC_Module_createShopCurator_tittle";
		};

		class prices : Combo
		{
			displayName = "Prices";
			description = "How expensive the prices will be";
			typeName = "NUMBER";
			property = "MCC_Module_createShopCurator_prices";

			class values
			{
				class veryCheap
				{
					name = "Very Low";
					value = 10;
				};
				class Cheap
				{
					name = "Low";
					value = 30;
				};
				class fair
				{
					name = "Fair";
					value = 50;
					default = 1;
				};
				class expensive
				{
					name = "Expensive";
					value = 70;
				};
				class veryExpensive
				{
					name = "Very Expensive";
					value = 100;
				};
			};
		};


		class persistent : Checkbox
		{
			displayName = "Persistent";
			description = "Items in the shop will be saved across mission restarts";
			property = "MCC_Module_createShopCurator_persistent";
		};

		class persistentName : Edit
		{
			displayName = "Unique name";
			description = "Unique seed name for the persistent shop file";
			typeName = "STRING";
			defaultValue = """testShop""";
			property = "MCC_Module_createShopCurator_persistentName";
		};

		class ModuleDescription: ModuleDescription{};
	};

	class ModuleDescription: ModuleDescription
	{
		description = "Sync it with one box and one other object or unit to create a weapon shop. The content of the box will be displayed as the items to be sold in the shop";
		sync[] = {"Anything","ReammoBox"};

		class Anything
		{
			description = "Any object/vehicle/unit.";
			displayName = "Any object/vehicle/unit";
			side = 4;
			position = 1;
			direction = 1;
			optional = 0;
			duplicate = 1;
		};

		class ReammoBox
		{
			description = "The contents of the box will be displayed as the items sold in the shop";
			displayName = "Ammobox";
			side = 4;
			position = 1;
			direction = 1;
			optional = 0;
			duplicate = 1;
		};
	};
};