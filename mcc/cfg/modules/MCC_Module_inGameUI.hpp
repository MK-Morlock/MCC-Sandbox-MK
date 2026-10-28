class MCC_Module_inGameUI : Module_F
{
	category = "MCC";
	author = "shay_gman";
	displayName = "(Settings) HUD";
	icon = "\mcc_sandbox_mod\data\mccModule.paa";
	picture = "\mcc_sandbox_mod\data\mccModule.paa";
	vehicleClass = "Modules";
	function = "MCC_fnc_inGameUI";
	scope = 2;
	isGlobal = 1;

	class Arguments
	{
		class mode
		{
			displayName = "Allow 3rd Person";
			typeName = "NUMBER";
			class values
			{
				class disabled
				{
					name = "Everyone";
					value = -1;
				};

				class noOne
				{
					name = "No One";
					value = 0;
					default = 1;
				};

				class vehicles
				{
					name = "All Vehicles";
					value = 1;
				};

				class air
				{
					name = "Air Vehicles Only";
					value = 2;
				};
			};
		};

		class compass
		{
			displayName = "Compass HUD";
			typeName = "BOOL";
			class values
			{
				class disable
				{
					name = "Disable";
					value = false;
				};

				class enable
				{
					name = "Enable";
					value = true;
					default = 1;
				};
			};
		};

		class compassTeamMates
		{
			displayName = "Compass Show Squad";
			typeName = "BOOL";
			class values
			{
				class disable
				{
					name = "Disable";
					value = false;
				};

				class enable
				{
					name = "Enable";
					value = true;
					default = 1;
				};
			};
		};

		class nameTags
		{
			displayName = "Name Tags";
			description = "Show in-game name tags, ranks (role and health stats while Role Selection is active)";
			typeName = "NUMBER";
			class values
			{
				class disable
				{
					name = "Disable";
					value = 0;
					default = 1;
				};

				class enableDirect
				{
					name = "Enable - Pointing";
					value = 1;
				};

				class enableRadius
				{
					name = "Enable - Radius";
					value = 2;
				};
			};
		};

		class suppression
		{
			displayName = "Suppression";
			description = "Activate client side suppression effects";
			typeName = "BOOL";
			class values
			{
				class disable
				{
					name = "Disable";
					value = false;
					default = 1;
				};

				class enable
				{
					name = "Enable";
					value = true;
				};
			};
		};

		class suppressionLevel
		{
			displayName = "Suppression strength";
			description = "How strong the suppression effects (blur, red tint, screen shake) are. Maximum = the original effect.";
			typeName = "NUMBER";
			class values
			{
				class minimal
				{
					name = "Minimal";
					value = 1;
				};
				class average
				{
					name = "Average";
					value = 2;
				};
				class maximum
				{
					name = "Maximum";
					value = 3;
					default = 1;
				};
			};
		};

		class hitRadar
		{
			displayName = "Fire Direction indicator";
			description = "Indicate the general direction of enemies firing on the player";
			typeName = "BOOL";
			class values
			{
				class realistic
				{
					name = "Realistic";
					value = 0;
					default = 1;
				};

				class Arcade
				{
					name = "Arcade";
					value = 1;
				};

				class off
				{
					name = "Off";
					value = 2;
				};
			};
		};

		class tickets
		{
			displayName = "Tickets";
			description = "Show the opposing sides and their remaining tickets";
			typeName = "BOOL";
			class values
			{
				class disable
				{
					name = "Disable";
					value = false;
					default = 1;
				};

				class enable
				{
					name = "Enable";
					value = true;
				};
			};
		};

		class groupMarkers
		{
			displayName = "Squads Markers";
			description = "Show squad markers on the map for all players while playing in a squad from the Squad Dialog";
			typeName = "NUMBER";
			class values
			{
				class addonOptions
				{
					name = "Players choose (Addon Options)";
					value = -1;
					default = 1;
				};
				class disable
				{
					name = "Force Disable";
					value = 0;
				};
				class enable
				{
					name = "Force Enable";
					value = 1;
				};
			};
		};

		class indevidualMarkers
		{
			displayName = "Units Markers";
			description = "Show unit markers on the map for all players while playing in a squad from the Squad Dialog";
			typeName = "NUMBER";
			class values
			{
				class addonOptions
				{
					name = "Players choose (Addon Options)";
					value = -1;
					default = 1;
				};
				class disable
				{
					name = "Force Disable";
					value = 0;
				};
				class enable
				{
					name = "Force Enable";
					value = 1;
				};
			};
		};

		class tutorials
		{
			displayName = "MCC Tutorials";
			description = "Enable MCC tutorials such as the Squad Leader role, etc.";
			typeName = "BOOL";
			class values
			{
				class disable
				{
					name = "Disable";
					value = false;
				};

				class enable
				{
					name = "Enable";
					value = true;
					default = 1;
				};
			};
		};
	};

	class ModuleDescription: ModuleDescription
	{
		description = "Set MCC in-game UI and HUD options";
	};
};