#define MCC_MINIMAP 9000
#define MCCFrontLineDialog_IDD 29891

#define FACTIONCOMBO 1001
#define MCC_MWDifficultyIDC 6006
#define MCC_MWVehiclesIDC 6010
#define MCC_MWArmorIDC 6011
#define MCC_MWIEDIDC 6012
#define MCC_MWIEDMARKERSIDC 6013
#define MCC_MWFortificationIDC 6016
#define MCC_MWFortificationMARKERSIDC 6017
#define MCC_MWDebugComboIDC 6019
#define MCC_MWArtilleryIDC 6021

class MCCFrontLineDialog
{
	idd = MCCFrontLineDialog_IDD;
	movingEnable = true;
	onLoad = __EVAL("_this execVM '"+MCCPATH+"mcc\dialogs\MCCFrontLineDialog_init.sqf'");

	controlsBackground[] =
	{
	};


	//---------------------------------------------
	objects[] =
	{
	};

	class controls
	{
		class MCCMWDialogFrame: MCC_RscText
		{
			idc = -1;
			colorBackground[] = { 0.051, 0.051, 0.051,1};

			x = 0.225 * safezoneW + safezoneX;
			y = 0.11515 * safezoneH + safezoneY;
			w = 0.55 * safezoneW;
			h = 0.76 * safezoneH;
		};

		class MCCMWDialoghelptext: MCC_RscStructuredText
		{
			idc = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.6)";

			x = 0.230729 * safezoneW + safezoneX;
			y = 0.46 * safezoneH + safezoneY;
			w = 0.303646 * safezoneW;
			h = 0.0549786 * safezoneH;
		};

		class MCCMWDialogClose: MCC_RscButtonMenu
		{
			idc = -1;
			text = "Close"; //--- ToDo: Localize;
			action = "MCC_mcc_screen = 2;closeDialog 0;";

			x = 0.694792 * safezoneW + safezoneX;
			y = 0.83 * safezoneH + safezoneY;
			w = 0.0744792 * safezoneW;
			h = 0.0329871 * safezoneH;
		};


		//Generate
		class MCC_MWGenerate: MCC_RscButton
		{
			idc = -1;
			onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\missionWizard\scripts\FrontLineInit.sqf'");
			text = "Generate Front Line"; //--- ToDo: Localize;

			x = 0.45 * safezoneW + safezoneX;
			y = 0.83 * safezoneH + safezoneY;
			w = 0.085 * safezoneW;
			h = 0.0329871 * safezoneH;
			tooltip = "Click and hold left mouse button to draw the front line"; //--- ToDo: Localize;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};

		class MCC_mapBackground : MCC_RscText
		{
			idc = -1;

			x = 0.230729 * safezoneW + safezoneX;
			y = 0.126146 * safezoneH + safezoneY;
			w = 0.540625 * safezoneW;
			h = 0.33 * safezoneH;

			colorBackground[] = { 1, 1, 1, 1};
			colorText[] = { 1, 1, 1, 0};
			text = "";
		};

		class MCC_map : MCC_RscMapControl
		{
			idc = MCC_MINIMAP;

			x = 0.230729 * safezoneW + safezoneX;
			y = 0.126146 * safezoneH + safezoneY;
			w = 0.540625 * safezoneW;
			h = 0.33 * safezoneH;

			text = "";
			onMouseButtonDown = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\mouseDown.sqf'");
			onMouseButtonUp = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\mouseUp.sqf'");
			onMouseButtonDblClick = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\mouseDblClick.sqf'");
			onMouseMoving = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\mouseMoving.sqf'");
		};

		//--> Controls
		class MCC_FLControls: MCC_RscControlsGroup
		{
			idc = -1;
			x = 0.230729 * safezoneW + safezoneX;
			y = 0.5 * safezoneH + safezoneY;
			w = 0.538542 * safezoneW;
			h = 0.33 * safezoneH;

			class Controls
			{
				class MCC_FLControlsFrame: MCC_RscText
				{
					idc = -1;
					text = "";
					colorBackground[] = { 0.150, 0.150, 0.150,1};

					w = 0.538542 * safezoneW;
					h = 0.32 * safezoneH;
				};

				class MCC_FLTittle: MCC_RscText
				{
					idc = -1;

					text = "Front Line Generator"; //--- ToDo: Localize;
					x = 0.189063 * safezoneW;
					y = 0.0109958 * safezoneH;
					w = 0.15 * safezoneW;
					h = 0.0329871 * safezoneH;
					colorText[] = {0,1,1,1};
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
				};

				//Faction
				class MCC_FLRivalFactionTittle: MCC_RscText
				{
					idc = -1;

					text = "Faction:"; //--- ToDo: Localize;
					x = 0.00572965 * safezoneW;
					y = 0.0549788 * safezoneH;
					w = 0.06875 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				class MCC_factionCombo: MCC_RscCombo
				{
					idc = FACTIONCOMBO;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
					onLBSelChanged = __EVAL("[0] execVM '"+MCCPATH+"mcc\pop_menu\mcc_guiTab1Change.sqf'");
					onSetFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText 'Who are we fighting here'";
					onKillFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText ''";

					x = 0.0802087 * safezoneW;
					y = 0.0549788 * safezoneH;
					w = 0.0859375 * safezoneW;
					h = 0.0219914 * safezoneH;
				};

				//Difficulty
				class MCC_FLDifficultyTittle: MCC_RscText
				{
					idc = -1;

					text = "Difficulty:"; //--- ToDo: Localize;
					x = 0.00572965 * safezoneW;
					y = 0.0879658 * safezoneH;
					w = 0.06875 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				class MCC_FLDifficultyCombo: MCC_CheckBoxes
				{
					idc = MCC_MWDifficultyIDC;
					onCheckBoxesSelChanged = "[_this,3,'MCC_MWDifficultyIndex','profile'] spawn MCC_fnc_checkBox;";
					onSetFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText 'Harder difficulty means more enemies'";
					onKillFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText ''";

					columns = 3;
					rows = 1;
					strings[] = {"Easy","Medium","Hard"};
					checked_strings[] = {"Easy","Medium","Hard"};

					x = 0.0802087 * safezoneW;
					y = 0.0879658 * safezoneH;
					w = 0.0859375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};


				//Markers
				class MCC_FLDebugText: MCC_RscText
				{
					idc = -1;

					text = "Markers:"; //--- ToDo: Localize;
					x = 0.00572965 * safezoneW;
					y = 0.120953 * safezoneH;
					w = 0.06875 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};
				class MCC_FLDebugCombo: MCC_CheckBoxes
				{
					idc = MCC_MWDebugComboIDC;
					onCheckBoxesSelChanged = "[_this,3,'MCC_MWDebugIndex','profile'] spawn MCC_fnc_checkBox;";
					onSetFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText 'Front Lines will be marked on the map'";
					onKillFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText ''";

					columns = 2;
					rows = 1;
					strings[] = {"Disabled","Enabled"};
					checked_strings[] = {"Disabled","Enabled"};

					x = 0.0802087 * safezoneW;
					y = 0.120953 * safezoneH;
					w = 0.0859375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				//Cars
				class MCC_FLVehiclesTittle: MCC_RscText
				{
					idc = -1;

					text = "Vehicles:"; //--- ToDo: Localize;
					x = 0.00572965 * safezoneW;
					y = 0.15394 * safezoneH;
					w = 0.06875 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				class MCC_FLVehiclesCombo: MCC_CheckBoxes
				{
					idc = MCC_MWVehiclesIDC;
					onCheckBoxesSelChanged = "[_this,3,'MCC_MWVehiclesIndex','profile'] spawn MCC_fnc_checkBox;";
					onSetFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText 'Will there be vehicles'";
					onKillFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText ''";

					columns = 3;
					rows = 1;
					strings[] = {"Disabled","Enabled","Random"};
					checked_strings[] = {"Disabled","Enabled","Random"};


					x = 0.0802087 * safezoneW;
					y = 0.15394 * safezoneH;
					w = 0.0859375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};


				//Armor
				class MCC_FLArmorTittle: MCC_RscText
				{
					idc = -1;

					text = "Armor:"; //--- ToDo: Localize;
					x = 0.00572965 * safezoneW;
					y = 0.186927 * safezoneH;
					w = 0.06875 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				class MCC_FLArmorCombo: MCC_CheckBoxes
				{
					idc = MCC_MWArmorIDC;
					onCheckBoxesSelChanged = "[_this,3,'MCC_MWArmorIndex','profile'] spawn MCC_fnc_checkBox;";
					onSetFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText 'Will there be armored vehicles'";
					onKillFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText ''";

					columns = 3;
					rows = 1;
					strings[] = {"Disabled","Enabled","Random"};
					checked_strings[] = {"Disabled","Enabled","Random"};

					x = 0.0802087 * safezoneW;
					y = 0.186927 * safezoneH;
					w = 0.0859375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				//Artilllery
				class MCC_FLArtilleryTittle: MCC_RscText
				{
					idc = -1;

					text = "Artillery:"; //--- ToDo: Localize;
					x = 0.00572965 * safezoneW;
					y = 0.219914 * safezoneH;
					w = 0.06875 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				class MCC_FLArtilleryCombo: MCC_RscCombo
				{
					idc = MCC_MWArtilleryIDC;
					onLBSelChanged = "profileNamespace setVariable ['MCC_MWArtilleryIndex',_this select 1]";
					onSetFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText 'Will spawn artillery units to support the enemy units in the area'";
					onKillFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText ''";

					x = 0.0802087 * safezoneW;
					y = 0.219914 * safezoneH;
					w = 0.0859375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				//minefields
				class MCC_FLIEDTittle: MCC_RscText
				{
					idc = -1;

					text = "minefields:"; //--- ToDo: Localize;
					x = 0.00572965 * safezoneW;
					y = 0.252902 * safezoneH;
					w = 0.06875 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				class MCC_FLIEDCombo: MCC_CheckBoxes
				{
					idc = MCC_MWIEDIDC;
					onCheckBoxesSelChanged = "[_this,3,'MCC_MWIEDIndex','profile'] spawn MCC_fnc_checkBox;";
					onSetFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText 'Spawn minefields'";
					onKillFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText ''";

					columns = 3;
					rows = 1;
					strings[] = {"Disabled","Enabled","Random"};
					checked_strings[] = {"Disabled","Enabled","Random"};

					x = 0.0802087 * safezoneW;
					y = 0.252902 * safezoneH;
					w = 0.0859375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				//minefields markers
				class MCC_FLIEDmarkersTittle: MCC_RscText
				{
					idc = -1;

					text = "Minefields Markers:"; //--- ToDo: Localize;
					x = 0.00572965 * safezoneW;
					y = 0.28589 * safezoneH;
					w = 0.06875 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				class MCC_FLIEDmarkersCombo: MCC_CheckBoxes
				{
					idc = MCC_MWIEDMARKERSIDC;
					onCheckBoxesSelChanged = "[_this,3,'MCC_FLIEDmarkersTittleIndex','profile'] spawn MCC_fnc_checkBox;";
					onSetFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText 'Minefields visable on map'";
					onKillFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText ''";

					columns = 2;
					rows = 1;
					strings[] = {"Disabled","Enabled"};
					checked_strings[] = {"Disabled","Enabled"};

					x = 0.0802087 * safezoneW;
					y = 0.28589 * safezoneH;
					w = 0.0859375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				//Fortifications
				class MCC_FLFortificationsTittle: MCC_RscText
				{
					idc = -1;

					text = "Fortifications:"; //--- ToDo: Localize;
					x = 0.189063 * safezoneW;
					y = 0.0549788 * safezoneH;
					w = 0.06875 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				class MCC_MWFortificationsCombo: MCC_CheckBoxes
				{
					idc = MCC_MWFortificationIDC;
					onCheckBoxesSelChanged = "[_this,3,'MCC_MWRoadBlockIndex','profile'] spawn MCC_fnc_checkBox;";
					onSetFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText 'Generates fortifications'";
					onKillFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText ''";

					columns = 3;
					rows = 1;
					strings[] = {"Disabled","Enabled","Random"};
					checked_strings[] = {"Disabled","Enabled","Random"};

					x = 0.263542 * safezoneW;
					y = 0.0549788 * safezoneH;
					w = 0.0859375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				//Fortifications markers
				class MCC_FLFortificationsmarkersTittle: MCC_RscText
				{
					idc = -1;

					text = "Fortifications Markers:"; //--- ToDo: Localize;
					x = 0.189063 * safezoneW;
					y = 0.0879658 * safezoneH;
					w = 0.06875 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

				class MCC_FLFortificationsmarkersCombo: MCC_CheckBoxes
				{
					idc = MCC_MWFortificationMARKERSIDC;
					onCheckBoxesSelChanged = "[_this,3,'MCC_FLFortificationsmarkersCombo','profile'] spawn MCC_fnc_checkBox;";
					onSetFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText 'Fortifications visable on map'";
					onKillFocus = "((uiNamespace getVariable 'MCC_FLDialog') displayCtrl 0) ctrlSetText ''";

					columns = 2;
					rows = 1;
					strings[] = {"Disabled","Enabled"};
					checked_strings[] = {"Disabled","Enabled"};

					x = 0.263542 * safezoneW;
					y = 0.0879658 * safezoneH;
					w = 0.0859375 * safezoneW;
					h = 0.0219914 * safezoneH;
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
				};

			};
		};

	};
};
