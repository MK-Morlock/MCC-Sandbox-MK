class MCCDLG_NAME {
	idd = -1;
	movingEnable = false;
	onLoad =  __EVAL("_this execVM '"+CPPATH+"mcc\roleSelection\scripts\respawnPanel_init.sqf'");
	onUnLoad = "missionNameSpace setvariable ['CP_respawnPanelOpen',false];";

	controlsBackground[] =
	{
	};


	//---------------------------------------------
	objects[] =
	{
	};

	class controls
	{
		class CP_respawnPanelBckg1: CP_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			x = 0.005 * safezoneW + safezoneX;
			y = 0.00500001 * safezoneH + safezoneY;
			w = 0.149531 * safezoneW;
			h = 1.001 * safezoneH;
			colorBackground[] = {0,0,0,0};
		};

		class upperCtrlsGroup: MCC_RscControlsGroupNoScrollbars
		{
			idc = 2300;
			x = 0.164844 * safezoneW + safezoneX;
			y = 0.00500001 * safezoneH + safezoneY;
			w = 0.840469 * safezoneW;
			h = 0.11 * safezoneH;
			class controls
			{

				class upperBckg1: CP_RscText
				{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
					idc = -1;
					x = 0 * safezoneW;
					y = 0 * safezoneH;
					w = 0.840469 * safezoneW;
					h = 0.11 * safezoneH;
					colorBackground[] = {0,0,0,0};
				};
				class CP_missionName: CP_RscText
				{
					idc = 1021;
					font = "RobotoCondensedBold";

					x = 0.00515628 * safezoneW;
					y = 0.055 * safezoneH;
					w = 0.175313 * safezoneW;
					h = 0.033 * safezoneH;
				};

				class commanderTittle: CP_RscPicture
				{
					idc = -1;
					text = "\A3\Ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";
					tooltip = "Commander";
					x = 0.00515628 * safezoneW;
					y = 0.011 * safezoneH;
					w = 0.04 * safezoneW;
					h = 0.044 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
					colorBackground[] = {0,1,1,1};
				};
				class commanderName: CP_RscText
				{
					idc = 919191;
					font = "RobotoCondensedBold";
					x = 0.045 * safezoneW;
					y = 0.011 * safezoneH;
					w = 0.0928125 * safezoneW;
					h = 0.044 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
					colorText[] = {0.89,0.90,0.91,1};
				};
				class commanderButton: MCCBTN_R
				{
					idc = 919192;
					text = "Take";
					action =  "0 spawn MCC_fnc_RSTakeCommander";

					x = 0.144375 * safezoneW;
					y = 0.0165 * safezoneH;
					w = 0.05 * safezoneW;
					h = 0.0329871 * safezoneH;
				};

				class CP_exitButton: MCCBTN_R
				{
					action = "endMission 'END1' ";

					idc = 1006;
					text = "Exit Game";
					x = 0.737343 * safezoneW;
					y = 0.0385 * safezoneH;
					w = 0.0928125 * safezoneW;
					h = 0.0329871 * safezoneH;
				};

				class CP_flag: CP_RscPicture
				{
					idc = 20;

					x = 0.62 * safezoneW;	//2:1 like a flag (it was 3:1, stretched), a little up and to the right
					y = 0.034 * safezoneH;
					w = 0.05 * safezoneW;
					h = 0.0444 * safezoneH;
				};
				class CP_side1: CP_RscText
				{
					idc = 21;
					style = 2;
					font = "RobotoCondensedBold";

					x = 0.53625 * safezoneW;
					y = 0.033 * safezoneH;
					w = 0.034375 * safezoneW;
					h = 0.0219914 * safezoneH;
					colorText[] = {0.89,0.90,0.91,1};
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
				};
				class CP_side1Score: CP_RscText
				{
					idc = 22;
					font = "RobotoCondensedBold";
					style = 2;

					x = 0.53625 * safezoneW;
					y = 0.055 * safezoneH;
					w = 0.034375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
				};
				class CP_side2: CP_RscText
				{
					idc = 23;
					style = 2;
					font = "RobotoCondensedBold";

					x = 0.5775 * safezoneW;
					y = 0.033 * safezoneH;
					w = 0.034375 * safezoneW;
					h = 0.0219914 * safezoneH;
					colorText[] = {0.89,0.90,0.91,1};
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
				};
				class CP_side2Score: CP_RscText
				{
					idc = 24;
					font = "RobotoCondensedBold";
					style = 2;

					x = 0.5775 * safezoneW;
					y = 0.055 * safezoneH;
					w = 0.034375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
				};
				class CP_side3: CP_RscText
				{
					idc = 25;
					style = 2;
					font = "RobotoCondensedBold";

					x = 0.61875 * safezoneW;
					y = 0.033 * safezoneH;
					w = 0.034375 * safezoneW;
					h = 0.0219914 * safezoneH;
					colorText[] = {0.89,0.90,0.91,1};
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
				};
				class CP_side3Score: CP_RscText
				{
					idc = 26;
					font = "RobotoCondensedBold";
					style = 2;

					x = 0.61875 * safezoneW;
					y = 0.055 * safezoneH;
					w = 0.034375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
				};

				class MCC_ResourcesControlsGroup: MCC_RscControlsGroupNoScrollbars
				{
					idc = 80;

					x = 0.226875 * safezoneW;
					y = 0.011 * safezoneH;
					w = 0.268125 * safezoneW;
					h = 0.088 * safezoneH;
					class controls
					{
						class MCC_AmmoText: MCC_RscText
						{
							idc = 81;
							tooltip = "Ammo: your side's ammunition stock (used to build and buy in RTS mode)";
							style = 2;
							sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

							x = 0.04125 * safezoneW;
							y = 0.033 * safezoneH;
							w = 0.0360937 * safezoneW;
							h = 0.033 * safezoneH;
						};

						class MCC_RepairText: MCC_RscText
						{
							idc = 82;
							tooltip = "Supplies: your side's repair / building supplies (used to build and buy in RTS mode)";
							style = 2;
							sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

							x = 0.0825002 * safezoneW;
							y = 0.033 * safezoneH;
							w = 0.0360937 * safezoneW;
							h = 0.033 * safezoneH;
						};

						class MCC_FuelText: MCC_RscText
						{
							idc = 83;
							tooltip = "Fuel: your side's fuel stock (used to build and buy in RTS mode)";
							style = 2;
							sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

							x = 0.12375 * safezoneW;
							y = 0.033 * safezoneH;
							w = 0.0360937 * safezoneW;
							h = 0.033 * safezoneH;
						};
						class MCC_FoodText: MCC_RscText
						{
							idc = 84;
							tooltip = "Food: your side's food stock (used to build and buy in RTS mode)";
							style = 2;
							sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

							x = 0.165 * safezoneW;
							y = 0.033 * safezoneH;
							w = 0.0360937 * safezoneW;
							h = 0.033 * safezoneH;
						};
						class MCC_MedText: MCC_RscText
						{
							idc = 85;
							tooltip = "Medical: your side's medical supplies (used to build and buy in RTS mode)";
							style = 2;
							sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

							x = 0.20625 * safezoneW;
							y = 0.033 * safezoneH;
							w = 0.0360937 * safezoneW;
							h = 0.033 * safezoneH;
						};
						class MCC_ValorText: MCC_RscText
						{
							idc = 86;
							tooltip = "Valor: your own valor points (used to build and buy in RTS mode)";
							style = 2;
							sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

							x = 0 * safezoneW;
							y = 0.033 * safezoneH;
							w = 0.0360937 * safezoneW;
							h = 0.033 * safezoneH;
						};
						class MCC_Ammo: MCC_RscPicture
						{
							idc = 91;
							style = 2096;
							tooltip = "Ammo";
							text =  __EVAL(MCCPATH +"data\IconAmmo.paa");
							colorText[] = {0.9,0,0,1};

							x = 0.0515627 * safezoneW;
							y = 0 * safezoneH;
							w = 0.0154689 * safezoneW;
							h = 0.033 * safezoneH;
						};
						class MCC_Repair: MCC_RscPicture
						{
							idc = 92;
							style = 2096;
							tooltip = "Supplies";
							text = __EVAL(MCCPATH +"data\IconRepair.paa");
							colorText[] = {0,0.5,0.9,1};

							x = 0.0928127 * safezoneW;
							y = -1.63913e-008 * safezoneH;
							w = 0.0154689 * safezoneW;
							h = 0.033 * safezoneH;
						};
						class MCC_Fuel: MCC_RscPicture
						{
							idc = 93;
							style = 2096;
							tooltip = "Fuel";
							text = __EVAL(MCCPATH +"data\IconFuel.paa");
							colorText[] = { 0, 0.9, 0.5, 1 };

							x = 0.134063 * safezoneW;
							y = -1.63913e-008 * safezoneH;
							w = 0.0154689 * safezoneW;
							h = 0.033 * safezoneH;
						};
						class MCC_FoodPic: MCC_RscPicture
						{
							idc = 94;
							style = 2096;
							tooltip = "Food";
							text = __EVAL(MCCPATH +"data\IconFood.paa");
							colorText[] = { 0.77, 0.51, 0.08, 1 };

							x = 0.175313 * safezoneW;
							y = -1.63913e-008 * safezoneH;
							w = 0.0154689 * safezoneW;
							h = 0.033 * safezoneH;
						};
						class MCC_MedPic: MCC_RscPicture
						{
							idc = 95;
							style = 2096;
							tooltip = "Meds";
							text = __EVAL(MCCPATH +"data\IconMed.paa");
							colorText[] = { 0, 0.9, 0.9, 1 };

							x = 0.216563 * safezoneW;
							y = -1.63913e-008 * safezoneH;
							w = 0.0154689 * safezoneW;
							h = 0.033 * safezoneH;
						};
						class MCC_ValorPic: MCC_RscPicture
						{
							idc = 96;
							style = 2096;
							tooltip = "Credits";
							text = __EVAL(MCCPATH +"mcc\rts\data\valorIcon.paa");
							colorText[] = { 0.9, 0.9, 0, 1 };

							x = 0.010313 * safezoneW;
							y = -1.63913e-008 * safezoneH;
							w = 0.0154689 * safezoneW;
							h = 0.033 * safezoneH;
						};
					};
				};
			};
		};

		class CP_deployPanelMiniMapBckg: CP_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = 44;
			colorBackground[] = {0,0,0,0};

			x = 0.1648 * safezoneW + safezoneX;
			y = 0.115 * safezoneH + safezoneY;
			w = 0.835312 * safezoneW;
			h = 0.793 * safezoneH;
		};

		class CP_deployPanelMiniMap: CP_RscMapControl
		{
			idc = 4;
			text = "#(argb,8,8,3)color(1,1,1,1)";

			x = 0.17 * safezoneW + safezoneX;
			y = 0.117 * safezoneH + safezoneY;
			w = 0.81 * safezoneW;
			h = 0.79 * safezoneH;
		};

		class bottomCtrlsGroup: MCC_RscControlsGroupNoScrollbars
		{
			idc = 2301;
			x = 0.164844 * safezoneW + safezoneX;
			y = 0.890 * safezoneH + safezoneY;
			w = 0.840469 * safezoneW;
			h = 0.11 * safezoneH;
			class controls
			{
				class bottomBckg: CP_RscText
				{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
					idc = -1;
					x = 0 * safezoneW;
					y = 0 * safezoneH;
					w = 0.840469 * safezoneW;
					h = 0.11 * safezoneH;
					colorBackground[] = {0,0,0,0};
				};
				class CP_feedback: CP_RscText
				{
					idc = 9999;
					style = 2;

					x = 0.460000 * safezoneW;
					y = 0 * safezoneH;	//upper part of the bar: the mission timer is under it
					w = 0.324844 * safezoneW;
					h = 0.05 * safezoneH;
					colorText[] = {1,0,0,0.8};
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
				};
				class timeLeft: CP_RscText
				{
					idc = 1919;
					style = 2;	//mission time left, centred on the screen, small like the resource numbers at the top
					font = "RobotoCondensed";
					shadow = 0;

					x = 0.345235 * safezoneW;
					y = 0.077 * safezoneH;
					w = 0.15 * safezoneW;
					h = 0.03 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				class CP_deployPanelButton: MCCBTN_R
				{
					idc = 32;
					text = "Deploy"; //--- ToDo: Localize;

					x = 0.265547 * safezoneW;
					y = 0.011 * safezoneH;
					w = 0.139219 * safezoneW;
					h = 0.066 * safezoneH;
					tooltip = "Press Deploy to get into the action"; //--- ToDo: Localize;
					action = __EVAL("[1] execVM '"+CPPATH+"mcc\roleSelection\scripts\respawnPanel_cmd.sqf'");
				};

				class CP_XPProgress: MCC_RscProgress
				{
					idc = 104;
					style = 2;

					x = 0.460000 * safezoneW;
					y = 0.052 * safezoneH;
					w = 0.324844 * safezoneW;
					h = 0.022 * safezoneH;
					colorText[] = {1,0,0,0.8};
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
					colorFrame[] = {1,1,1,0.8};
					colorBackground[] = {0,0,0,0.3};
				};
				class RscText_1005: CP_RscStructuredText
				{
					idc = 102;
					style = 2;

					x = 0.460000 * safezoneW;
					y = 0.074 * safezoneH;
					w = 0.324844 * safezoneW;
					h = 0.033 * safezoneH;
					colorText[] = {1,0,0,0.8};
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
				};
				class CP_XP: CP_RscText
				{
					idc = 103;
					text = "XP";
					x = 0.429063 * safezoneW;
					y = 0.049 * safezoneH;
					w = 0.0257812 * safezoneW;
					h = 0.033 * safezoneH;
				};
			};
		};


		class CP_sglogo: CP_RscPicture
		{
			idc = -1;
			x = 0.0101562 * safezoneW + safezoneX;
			y = 0.016 * safezoneH + safezoneY;
			w = 0.139219 * safezoneW;
			h = 0.099 * safezoneH;
			text = __EVAL(CPPATH+"mcc\roleSelection\data\sgLogo.paa");
			colorText[] = {1,1,1,1.8};
		};


		class CP_squadPanelButton: MCCBTN_R
		{
			idc = 28;
			type = 16;
			text = "Squad"; //--- ToDo: Localize;
			x = 0.0101562 * safezoneW + safezoneX;
			y = 0.126 * safezoneH + safezoneY;
			w = 0.0670311 * safezoneW;
			h = 0.044 * safezoneH;
			action = __EVAL("[0] execVM '"+CPPATH+"mcc\roleSelection\scripts\switchDialog.sqf'");
		};
		class CP_gearPanelButton: MCCBTN_R
		{
			idc = 29;
			type = 16;
			text = "Role"; //--- ToDo: Localize;
			x = 0.0823437 * safezoneW + safezoneX;
			y = 0.126 * safezoneH + safezoneY;
			w = 0.0670311 * safezoneW;
			h = 0.044 * safezoneH;
			action = __EVAL("[1] execVM '"+CPPATH+"mcc\roleSelection\scripts\switchDialog.sqf'");
		};

		class CP_squadList: MCC_RscControlsGroup
		{
			idc = 2302;
			x = 0.0101562 * safezoneW + safezoneX;
			y = 0.17 * safezoneH + safezoneY;
			w = 0.14 * safezoneW;
			h = 1 * safezoneH;
			class controls
			{
				class CP_squadListBckg: CP_RscText
				{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
					idc = -1;

					x = 0 * safezoneW;
					y = 0 * safezoneH;
					w = 0.14 * safezoneW;
					h = 1 * safezoneH;
					colorBackground[] = {0,0,0,0};
				};
			};

		};

		class CreateSquad: MCCBTN_R
		{
			idc = -1;
			text = "Create Squad";
			onButtonClick = "_this spawn MCC_fnc_RSSquadCreate";
			x = 0.0410937 * safezoneW + safezoneX;
			y = 0.951 * safezoneH + safezoneY;
			w = 0.08 * safezoneW;
			h = 0.033 * safezoneH;
		};
	};
};
