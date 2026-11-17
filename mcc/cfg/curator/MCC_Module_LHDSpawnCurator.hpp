class MCC_Module_LHDSpawnCurator : MCC_Module_Base
{
	scope = 2;
	isGlobal = 1;
	scopeCurator = 2;
	category = "MCC_Carrier";
	displayName = "Spawn Ship";
	function = "MCC_fnc_curatorLHDSpawn";
	icon = "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\boat_ca.paa";
	portrait = "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\boat_ca.paa";
	picture = "a3\ui_f\data\IGUI\Cfg\simpleTasks\types\boat_ca.paa";
	class EventHandlers: EventHandlers
	{
		dragged3DEN = "params ['_e']; private _p = getPosWorld _e; if (surfaceIsWater _p) then {private _d = -(getTerrainHeightASL _p); if (abs (((getPosATL _e) select 2) - (_d + 3)) > 0.5) then {_e set3DENAttribute ['position', [_p select 0, _p select 1, _d + 3]]};};";
		registeredToWorld3DEN = "params ['_e']; private _p = getPosWorld _e; if (surfaceIsWater _p) then {private _d = -(getTerrainHeightASL _p); if (abs (((getPosATL _e) select 2) - (_d + 3)) > 0.5) then {_e set3DENAttribute ['position', [_p select 0, _p select 1, _d + 3]]};};";
	};


	class Attributes : AttributesBase
	{
		class side : Combo
		{
			displayName = "Side";
			description = "Which side the carrier belongs to";
			typeName = "NUMBER";
			property = "MCC_Module_LHDSpawnCurator_side";

			class values
			{
				class BLUFOR
				{
					name = "$STR_WEST";
					value = 1;
					default = 1;
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
			};
		};

		class hq : Checkbox
		{
			displayName = "Make HQ (start position)";
			description = "Ticked: the ship becomes your side's HQ (start position) and your current HQ becomes an F.O.B. Unticked: the ship is an F.O.B. - a respawn point, with vehicle purchasing and rearm if ticked below";
			typeName = "BOOL";
			property = "MCC_Module_LHDSpawnCurator_hq";
			defaultValue = "false";
		};

		class store : Checkbox
		{
			displayName = "Vehicles Purchasing";
			description = "Enable players to purchase vehicles from the main deck";
			typeName = "BOOL";
			property = "MCC_Module_LHDSpawnCurator_store";
		};

		class rearm : Checkbox
		{
			displayName = "Rearm and Refuel";
			description = "Enable rearming, refueling and repairing vehicles on the main deck";
			typeName = "BOOL";
			property = "MCC_Module_LHDSpawnCurator_rearm";
		};

		class lhdType : Combo
		{
			displayName = "Ship type";
			description = "LHD Requires CUP addon";
			typeName = "NUMBER";
			property = "MCC_Module_LHDSpawnCurator_lhdType";

			class values
			{
				class Independent
				{
					name = "Destroyer";
					value = 0;
					default = 1;
				};

				class carrier
				{
					name = "Aircraft Carrier";
					value = 1;
				};

				class submarine
				{
					name = "Submarine";
					value = 2;
				};

				class lhd
				{
					name = "CUP LHD";
					value = 3;
				};
			};
		};

		class displayName : Edit
		{
			displayName = "Ship Name";
			description = "Display Name";
			typeName = "STRING";
			property = "MCC_Module_LHDSpawnCurator_displayName";
		};

		class ModuleDescription: ModuleDescription{};
	};

	class ModuleDescription: ModuleDescription
	{
		description = "Spawn static ship that will act as a base";
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
