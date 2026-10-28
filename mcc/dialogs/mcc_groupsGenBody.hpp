class MCCDLG_NAME
{
	idd = groupGen_IDD;
	movingEnable = true;
	onLoad = __EVAL("_this execVM '"+MCCPATH+"mcc\dialogs\mcc_groupGen_init.sqf'");

	controlsBackground[] =
	{
		MCC_consoleTabletFrame,
		mcc_groupGenPic,
		mcc_groupGenPicBottom,
		mcc_groupGenPicLeft,
		mcc_groupGenPicRight,
		MCC_mapBackground,
		MCC_map,
		MCC_mapContour,

		MCC_fram1
	};


	//---------------------------------------------
	objects[] =
	{
	};

	//Thin tablet edge round the whole console (same olive-grey, bevelled style as the MK-SLPDA / MK-CC), 14 px outside
	//the console panels, drawn behind them
	class MCC_consoleTabletFrame: MCC_RscText
	{
		idc = -1;
		moving = 1;	//drag the console by its edge too (as by its background)
		style = 48;
		text = "";
		colorText[] = {1,1,1,1};
		colorBackground[] = {0,0,0,0};
		x = 0.0935283 * safezoneW + safezoneX;
		y = 0.0065287 * safezoneH + safezoneY;
		w = 0.85586 * safezoneW;
		h = 0.843998 * safezoneH;
	};

	class controls
	{
		//========================================= Controls========================================
		//Tittle
		//Layers button: top right of the map, the same distance from the corner as the (?) button on the left
		class MCC_mapLayersRound: MCC_RscText
		{
			idc = 9011;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.912958 * safezoneW + safezoneX;
			y = 0.095 * safezoneH + safezoneY;
			w = 0.020625 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCC_mapLayersIcon: MCC_RscText
		{
			idc = 9012;
			style = 2096;
			text = "\mcc_sandbox_mod\data\mk_maplayers_ca.paa";
			colorText[] = {0.88,0.89,0.90,1};
			x = 0.915958 * safezoneW + safezoneX;
			y = 0.0995 * safezoneH + safezoneY;
			w = 0.014625 * safezoneW;
			h = 0.024 * safezoneH;
		};
		class MCC_mapLayersBtn: MCC_RscButton
		{
			idc = 9013;
			text = "";
			tooltip = "Map Layers";
			colorBackground[] = {0,0,0,0};
			colorBackgroundActive[] = {1,1,1,0.15};
			colorBackgroundDisabled[] = {0,0,0,0};
			colorFocused[] = {0,0,0,0};
			colorBackgroundFocused[] = {0,0,0,0};
			colorBorder[] = {0,0,0,0};
			colorShadow[] = {0,0,0,0};
			offsetPressedX = 0;
			offsetPressedY = 0;
			action = "['toggle'] call MCC_fnc_consoleMapLayers";
			x = 0.912958 * safezoneW + safezoneX;
			y = 0.095 * safezoneH + safezoneY;
			w = 0.020625 * safezoneW;
			h = 0.033 * safezoneH;
		};


		//Faction
		class mcc_groupGen_factionTittle: MCC_RscStructuredText
		{
			idc = -1;
			text = "<t align='center' font='RobotoCondensedBold' color='#8FBF6B' size='1.25'>MCC</t><t align='center' font='RobotoCondensed' color='#E3E5E8' size='0.95'> SANDBOX MK</t>";
			x = 0.105 * safezoneW + safezoneX;
			y = 0.024 * safezoneH + safezoneY;
			w = 0.0802083 * safezoneW;
			h = 0.034 * safezoneH;
			colorBackground[] = {0,0,0,0};
		};

		class mcc_groupGen_factionComboBox: MCC_RscCombo
		{
			tooltip = "Faction used for spawning, supports and generated missions";
			idc = MCC_FACTION;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onLBSelChanged = __EVAL("[2] execVM '"+MCCPATH+"mcc\pop_menu\faction.sqf'");

			x = 0.195 * safezoneW + safezoneX;
			y = 0.0281887 * safezoneH + safezoneY;
			w = 0.114583 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		//Console colour squares: rounded, a little smaller and centred under the sliders (the white frame on the chosen one
		//touched the slider above). Tinted with their colour by MCC_fnc_consoleTheme.
		class MCC_assetsButton: MCCBTN_S
		{
			idc = -1;
			text = "Assets";
			tooltip = "Choose the units, vehicles and objects MCC uses for tasks and support, per enemy faction";
			onButtonClick = "createDialog ('MCC_AssetsDialog' + (['', 'Buttons'] select (profileNamespace getVariable ['MCC_consoleButtons', false])))";

			x = 0.195 * safezoneW + safezoneX;
			y = 0.0601715 * safezoneH + safezoneY;
			w = 0.114583 * safezoneW;
			h = 0.0219914 * safezoneH;
		};


		//Map
		class mcc_groupGen_AllFilterBg: MCC_RscText
		{
			idc = 9201;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.224600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_AllFilterLabel: MCC_RscText
		{
			idc = 9211;
			style = 2;
			text = "All";
			shadow = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
			colorText[] = {0.88,0.89,0.90,1};
			x = 0.224600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_AllButton: MCCBTN_R
		{
			idc = 9221;
			text = "";
			tooltip = "Show all - or, if all are shown, none";
			animTextureNormal = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDisabled = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureFocused = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDefault = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureOver = "\mcc_sandbox_mod\data\mk_hover_ca.paa";
			animTexturePressed = "\mcc_sandbox_mod\data\mk_press_ca.paa";
			onButtonClick = "['toggle', 'all'] call MCC_fnc_consoleFilter";
			x = 0.224600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_PlayersFilterBg: MCC_RscText
		{
			idc = 9202;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.269600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_PlayersFilterLabel: MCC_RscText
		{
			idc = 9212;
			style = 2;
			text = "Players";
			shadow = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
			colorText[] = {0.88,0.89,0.90,1};
			x = 0.269600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_PlayersButton: MCCBTN_R
		{
			idc = 9222;
			text = "";
			tooltip = "Players' groups on / off (whatever their side)";
			animTextureNormal = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDisabled = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureFocused = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDefault = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureOver = "\mcc_sandbox_mod\data\mk_hover_ca.paa";
			animTexturePressed = "\mcc_sandbox_mod\data\mk_press_ca.paa";
			onButtonClick = "['toggle', 'players'] call MCC_fnc_consoleFilter";
			x = 0.269600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_WestFilterBg: MCC_RscText
		{
			idc = 9203;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.314600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_WestFilterLabel: MCC_RscText
		{
			idc = 9213;
			style = 2;
			text = "West";
			shadow = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
			colorText[] = {0.44,0.63,0.85,1};
			x = 0.314600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_WestButton: MCCBTN_R
		{
			idc = 9223;
			text = "";
			tooltip = "West's AI groups on / off";
			animTextureNormal = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDisabled = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureFocused = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDefault = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureOver = "\mcc_sandbox_mod\data\mk_hover_ca.paa";
			animTexturePressed = "\mcc_sandbox_mod\data\mk_press_ca.paa";
			onButtonClick = "['toggle', 'west'] call MCC_fnc_consoleFilter";
			x = 0.314600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_EastFilterBg: MCC_RscText
		{
			idc = 9204;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.359600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_EastFilterLabel: MCC_RscText
		{
			idc = 9214;
			style = 2;
			text = "East";
			shadow = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
			colorText[] = {0.82,0.42,0.37,1};
			x = 0.359600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_EastButton: MCCBTN_R
		{
			idc = 9224;
			text = "";
			tooltip = "East's AI groups on / off";
			animTextureNormal = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDisabled = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureFocused = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDefault = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureOver = "\mcc_sandbox_mod\data\mk_hover_ca.paa";
			animTexturePressed = "\mcc_sandbox_mod\data\mk_press_ca.paa";
			onButtonClick = "['toggle', 'east'] call MCC_fnc_consoleFilter";
			x = 0.359600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_IndFilterBg: MCC_RscText
		{
			idc = 9205;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.404600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_IndFilterLabel: MCC_RscText
		{
			idc = 9215;
			style = 2;
			text = "Ind";
			shadow = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
			colorText[] = {0.56,0.75,0.42,1};
			x = 0.404600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_IndButton: MCCBTN_R
		{
			idc = 9225;
			text = "";
			tooltip = "Independent's AI groups on / off";
			animTextureNormal = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDisabled = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureFocused = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDefault = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureOver = "\mcc_sandbox_mod\data\mk_hover_ca.paa";
			animTexturePressed = "\mcc_sandbox_mod\data\mk_press_ca.paa";
			onButtonClick = "['toggle', 'ind'] call MCC_fnc_consoleFilter";
			x = 0.404600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_CivFilterBg: MCC_RscText
		{
			idc = 9206;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.449600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_CivFilterLabel: MCC_RscText
		{
			idc = 9216;
			style = 2;
			text = "Civ";
			shadow = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
			colorText[] = {0.66,0.55,0.82,1};
			x = 0.449600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class mcc_groupGen_CivButton: MCCBTN_R
		{
			idc = 9226;
			text = "";
			tooltip = "Civilians on / off (incl. armed civilians and suicide bombers)";
			animTextureNormal = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDisabled = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureFocused = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDefault = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureOver = "\mcc_sandbox_mod\data\mk_hover_ca.paa";
			animTexturePressed = "\mcc_sandbox_mod\data\mk_press_ca.paa";
			onButtonClick = "['toggle', 'civ'] call MCC_fnc_consoleFilter";
			x = 0.449600 * safezoneW + safezoneX;
			y = 0.098500 * safezoneH + safezoneY;
			w = 0.042000 * safezoneW;
			h = 0.026000 * safezoneH;
		};



	//---------------------- ZONES --------------------------------
		#include "mcc_groupGenZones.hpp"

	//---------------------------------------- BENCHMARK ----------------------------------------
		class MCC_MissionMakerTittle: MCC_RscText
		{
			idc = -1;
			text = "Mission Maker:";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

			x = 0.366771 * safezoneW + safezoneX;
			y = 0.016857 * safezoneH + safezoneY;
			w = 0.056 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		class MCC_MissionMakerName: MCC_RscText
		{
			idc = MCCMISSIONMAKERNAME;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

			x = 0.424063 * safezoneW + safezoneX;
			y = 0.016857 * safezoneH + safezoneY;
			w = 0.0572917 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		class MCC_clientFPSTittle: MCC_RscText
		{
			idc = -1;
			text = "Client FPS:";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

			x = 0.492813 * safezoneW + safezoneX;
			y = 0.016857 * safezoneH + safezoneY;
			w = 0.0515625 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		class MCC_ServerFPSTittle: MCC_RscText
		{
			idc = -1;
			text = "Server FPS:";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

			x = 0.590209 * safezoneW + safezoneX;
			y = 0.016857 * safezoneH + safezoneY;
			w = 0.0515625 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		class MCC_clientFPS: MCC_RscText
		{
			idc = MCCCLIENTFPS;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

			x = 0.544375 * safezoneW + safezoneX;
			y = 0.016857 * safezoneH + safezoneY;
			w = 0.034375 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		class MCC_ServerFPS: MCC_RscText
		{
			idc = MCCSERVERFPS;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

			x = 0.641771 * safezoneW + safezoneX;
			y = 0.016857 * safezoneH + safezoneY;
			w = 0.034375 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		//---------------------------------------- BUTTONS ------------------------------------------
		class MCC_stopCapture: MCCBTN_S
		{
			idc = MCCSTOPCAPTURE;
			text = "Stop Capturing";
			tooltip = "Once a trigger has been generated, MCC's actions won't be executed but will be saved to the trigger until this button is pressed";
			onButtonClick = "ctrlEnable [1014,false];MCC_capture_state=false;";

			x = 0.879020 * safezoneW + safezoneX;	//under Ambient Warzone (it sat over the help text column)
			y = 0.060172 * safezoneH + safezoneY;
			w = 0.058937 * safezoneW;
			h = 0.0219914 * safezoneH;
		};


		class MCC_occupyButton: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "if (str (getmarkerpos str mcc_active_zone) != str [0,0,0]) then {[str mcc_active_zone] spawn GAIA_fnc_occupy} else {systemchat 'Create a zone first'}";
			tooltip = "Occupy the currently selected zone with the selected faction's units";
			text = "Occupy Zone"; //--- ToDo: Localize;

			x = 0.353000 * safezoneW + safezoneX;
			y = 0.603076 * safezoneH + safezoneY;
			w = 0.058000 * safezoneW;
			h = 0.026000 * safezoneH;
		};
		class MCC_deleteZoneButton: MCCBTN_S
		{

			idc = -1;

			onButtonClick = "[] spawn MCC_fnc_deleteZone";
			tooltip = "Delete the zone chosen in the Zone drop-down";
			text = "Delete Zone";

			x = 0.414000 * safezoneW + safezoneX;
			y = 0.603076 * safezoneH + safezoneY;
			w = 0.058000 * safezoneW;
			h = 0.026000 * safezoneH;
		};

		class MCC_ambientBFBg: MCC_RscText
		{
			idc = 1016;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_wide_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.816083 * safezoneW + safezoneX;
			y = 0.0601715 * safezoneH + safezoneY;
			w = 0.058937 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_ambientBFLabel: MCC_RscText
		{
			idc = 1017;
			style = 2;
			text = "Ambient Warzone";
			shadow = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			colorText[] = {0.88,0.89,0.90,1};
			x = 0.816083 * safezoneW + safezoneX;
			y = 0.0601715 * safezoneH + safezoneY;
			w = 0.058937 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_ambientBFButton: MCCBTN_S
		{
			idc = 1015;
			text = "";
			tooltip = "Ambient Warzone: random ambient battlefield around the player - press to switch on / off";
			animTextureNormal = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDisabled = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureFocused = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureDefault = "#(argb,8,8,3)color(0,0,0,0)";
			animTextureOver = "\mcc_sandbox_mod\data\mk_hover_ca.paa";
			animTexturePressed = "\mcc_sandbox_mod\data\mk_press_ca.paa";
			onButtonClick = "MCC_GAIA_AC = !(missionNamespace getVariable ['MCC_GAIA_AC', false]); publicVariable 'MCC_GAIA_AC'; [ctrlParent (_this select 0)] call MCC_fnc_consoleAmbientLook;";
			x = 0.816083 * safezoneW + safezoneX;
			y = 0.0601715 * safezoneH + safezoneY;
			w = 0.058937 * safezoneW;
			h = 0.0219914 * safezoneH;
		};




		class MCC_ghostMode: MCCBTN_R
		{
			idc = -1;
			text = "Ghost Mode";
			tooltip = "Make the mission maker invisible to enemies";
			onButtonClick = "if (mcc_missionmaker == (name player)) then {if (captive player) then {player setcaptive false;if (MCC_Chat) then {['Mission maker is no longer cheating'] remoteExec ['MCC_fnc_globalHint',0,false];};} else {player setcaptive true; if (MCC_Chat) then {['Mission maker is cheating'] remoteExec ['MCC_fnc_globalHint',0,false];}};} else {player globalchat 'Access Denied'};";
			x = 0.425958 * safezoneW + safezoneX;
			y = 0.0491758 * safezoneH + safezoneY;
			w = 0.06 * safezoneW;
			h = 0.0329871 * safezoneH;
		};

		class MCC_spectator: MCCBTN_R
		{
			idc = -1;
			text = "Spectator";
			tooltip = "Open Spectator Mode";
			onButtonClick = __EVAL("[4] execVM '"+MCCPATH+"mcc\Pop_menu\mission_settings.sqf'");

			x = 0.491458 * safezoneW + safezoneX;
			y = 0.0491758 * safezoneH + safezoneY;
			w = 0.06 * safezoneW;
			h = 0.0329871 * safezoneH;
		};

		class MCC_Teleport: MCCBTN_R
		{
			idc = -1;
			text = "Teleport";
			tooltip = "Teleport the mission maker and any vehicle he is in to a new location";
			onButtonClick = "if (mcc_missionmaker == (name player)) then {hint 'Click on the map';onMapSingleClick 'vehicle player setPos _pos;onMapSingleClick '''';true;'} else {player globalchat 'Access Denied'};";

			x = 0.556958 * safezoneW + safezoneX;
			y = 0.0491758 * safezoneH + safezoneY;
			w = 0.06 * safezoneW;
			h = 0.0329871 * safezoneH;
		};

		class MCC_MissionWIn: MCCBTN_R
		{
			color2[] = {0.56,0.75,0.42,1};
			colorFocused[] = {0.56,0.75,0.42,1};
			color[] = {0.56,0.75,0.42,1};
			idc = -1;
			onButtonClick = __EVAL("[5] execVM '"+MCCPATH+"mcc\pop_menu\tasks_req.sqf'");
			text = "Mission Won"; //--- ToDo: Localize;
			colorText[] = {0.56,0.75,0.42,1};
			tooltip = "End mission with - Mission Accomplished"; //--- ToDo: Localize;

			x = 0.323062 * safezoneW + safezoneX;
			y = 0.0491758 * safezoneH + safezoneY;
			w = 0.097396 * safezoneW;
			h = 0.0329871 * safezoneH;
		};

		class MCC_MissionLost: MCCBTN_R
		{
			color2[] = {0.82,0.42,0.37,1};
			colorFocused[] = {0.82,0.42,0.37,1};
			color[] = {0.82,0.42,0.37,1};
			idc = -1;
			onButtonClick = __EVAL("[6] execVM '"+MCCPATH+"mcc\pop_menu\tasks_req.sqf'");
			text = "Mission Failed"; //--- ToDo: Localize;
			colorText[] = {0.82,0.42,0.37,1};
			tooltip = "End mission with - Mission Failed"; //--- ToDo: Localize;

			x = 0.622458 * safezoneW + safezoneX;
			y = 0.0491758 * safezoneH + safezoneY;
			w = 0.097396 * safezoneW;
			h = 0.0329871 * safezoneH;
		};





		//Left
		#include "mcc_groupGenSidebar.hpp"
		#include "mcc_groupGenSpawn.hpp"
		#include "mcc_groupGenCAS.hpp"
		#include "mcc_groupGenArtillery.hpp"
		#include "mcc_groupGenEvac.hpp"
		#include "mcc_groupGenIED.hpp"
		#include "mcc_groupGenConvoy.hpp"
		#include "mcc_groupGenAirdrop.hpp"
		#include "mcc_groupGenParadrop.hpp"
		#include "mcc_groupGenDelete.hpp"

		//Right
		#include "mcc_groupGenWeather.hpp"
		#include "mcc_groupGenTime.hpp"
		#include "mcc_groupGenRespawn.hpp"
		#include "mcc_groupGenDebug.hpp"
		#include "mcc_groupGenMarkers.hpp"
		#include "mcc_groupGenBriefings.hpp"
		#include "mcc_groupGenTasks.hpp"
		#include "mcc_groupGenJukebox.hpp"
		#include "mcc_groupGenTriggers.hpp"
		#include "mcc_groupGenCS.hpp"

		#include "mcc_groupGenUM.hpp"
		class MCC_displaySettingsRound: MCC_RscText
		{
			idc = -1;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.924260 * safezoneW + safezoneX;
			y = 0.024000 * safezoneH + safezoneY;
			w = 0.013700 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_displaySettingsIcon: MCC_RscText
		{
			idc = -1;
			style = 48 + 2048;
			text = "\mcc_sandbox_mod\data\mk_settings_ca.paa";
			colorText[] = {0.88,0.89,0.90,1};
			colorBackground[] = {0,0,0,0};
			x = 0.926260 * safezoneW + safezoneX;
			y = 0.027000 * safezoneH + safezoneY;
			w = 0.009700 * safezoneW;
			h = 0.016000 * safezoneH;
		};
		class MCC_displaySettingsBtn: MCC_RscButtonConsoleKey
		{
			idc = 9171;
			tooltip = "Display settings: console colour, window and map transparency, button style";
			onButtonClick = "private _g = (ctrlParent (_this select 0)) displayCtrl 9170; _g ctrlShow !(ctrlShown _g);";
			x = 0.924260 * safezoneW + safezoneX;
			y = 0.024000 * safezoneH + safezoneY;
			w = 0.013700 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_displaySettings: MCC_RscControlsGroup
		{
			idc = 9170;
			x = 0.767960 * safezoneW + safezoneX;
			y = 0.040200 * safezoneH + safezoneY;
			w = 0.170000 * safezoneW;
			h = 0.128000 * safezoneH;
			class Controls
			{
				class MCC_displaySettingsFrame: MCC_RscText
				{
					idc = -1;
					style = 48;
					text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
					colorText[] = {0.09,0.10,0.11,1};
					colorBackground[] = {0,0,0,0};
					x = 0;
					y = 0;
					w = 0.170000 * safezoneW;
					h = 0.128000 * safezoneH;
				};
				class MCC_displaySettingsSolid: MCC_RscText
				{
					idc = -1;
					colorBackground[] = {0.09,0.10,0.11,1};
					x = 0.004 * safezoneW;
					y = 0.006 * safezoneH;
					w = 0.162000 * safezoneW;
					h = 0.116000 * safezoneH;
				};
				class MCC_dsColourLabel: MCC_RscText
				{
					style = 2;
					idc = -1;
					text = "Console colour";
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
					colorText[] = {0.62,0.65,0.68,1};
					x = 0.006 * safezoneW;
					y = 0.004000 * safezoneH;
					w = 0.158000 * safezoneW;
					h = 0.02 * safezoneH;
				};
				class MCC_dsWindowLabel: MCC_RscText
				{
					idc = -1;
					text = "Window transparency";
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
					colorText[] = {0.62,0.65,0.68,1};
					x = 0.006 * safezoneW;
					y = 0.042000 * safezoneH;
					w = 0.06 * safezoneW;
					h = 0.02 * safezoneH;
				};
				class MCC_dsMapLabel: MCC_RscText
				{
					idc = -1;
					text = "Map transparency";
					sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
					colorText[] = {0.62,0.65,0.68,1};
					x = 0.006 * safezoneW;
					y = 0.068000 * safezoneH;
					w = 0.06 * safezoneW;
					h = 0.02 * safezoneH;
				};
				class MCC_consoleThemeBlack: MCC_RscActivePicture
				{
					idc = 9150;
					text = "\mcc_sandbox_mod\data\mcc_round_swatch_ca.paa";
					shadow = 0;
					tooltip = "Console colour: Black";
					action = "[0] call MCC_fnc_consoleTheme";
					x = 0.022500 * safezoneW;
					y = 0.024000 * safezoneH;
					w = 0.015 * safezoneW;
					h = 0.015 * safezoneH;
				};
				class MCC_consoleThemeSilver: MCC_RscActivePicture
				{
					idc = 9151;
					text = "\mcc_sandbox_mod\data\mcc_round_swatch_ca.paa";
					shadow = 0;
					tooltip = "Console colour: Gunmetal";
					action = "[1] call MCC_fnc_consoleTheme";
					x = 0.044500 * safezoneW;
					y = 0.024000 * safezoneH;
					w = 0.015 * safezoneW;
					h = 0.015 * safezoneH;
				};
				class MCC_consoleThemeGreen: MCC_RscActivePicture
				{
					idc = 9152;
					text = "\mcc_sandbox_mod\data\mcc_round_swatch_ca.paa";
					shadow = 0;
					tooltip = "Console colour: Olive";
					action = "[2] call MCC_fnc_consoleTheme";
					x = 0.066500 * safezoneW;
					y = 0.024000 * safezoneH;
					w = 0.015 * safezoneW;
					h = 0.015 * safezoneH;
				};
				class MCC_consoleThemeBlue: MCC_RscActivePicture
				{
					idc = 9153;
					text = "\mcc_sandbox_mod\data\mcc_round_swatch_ca.paa";
					shadow = 0;
					tooltip = "Console colour: Navy";
					action = "[3] call MCC_fnc_consoleTheme";
					x = 0.088500 * safezoneW;
					y = 0.024000 * safezoneH;
					w = 0.015 * safezoneW;
					h = 0.015 * safezoneH;
				};
				class MCC_consoleThemeOrange: MCC_RscActivePicture
				{
					idc = 9154;
					text = "\mcc_sandbox_mod\data\mcc_round_swatch_ca.paa";
					shadow = 0;
					tooltip = "Console colour: Burgundy";
					action = "[4] call MCC_fnc_consoleTheme";
					x = 0.110500 * safezoneW;
					y = 0.024000 * safezoneH;
					w = 0.015 * safezoneW;
					h = 0.015 * safezoneH;
				};
				class MCC_consoleThemePurple: MCC_RscActivePicture
				{
					idc = 9155;
					text = "\mcc_sandbox_mod\data\mcc_round_swatch_ca.paa";
					shadow = 0;
					tooltip = "Console colour: Teal";
					action = "[5] call MCC_fnc_consoleTheme";
					x = 0.132500 * safezoneW;
					y = 0.024000 * safezoneH;
					w = 0.015 * safezoneW;
					h = 0.015 * safezoneH;
				};
				class MCC_consoleThemeFrame: MCC_RscText
				{
					idc = 9160;	//rounded white ring round the chosen colour (placed by MCC_fnc_consoleTheme)
					style = 48;
					text = "\mcc_sandbox_mod\data\mcc_round_ring_ca.paa";
					colorText[] = {1,1,1,0};
					colorBackground[] = {0,0,0,0};
					x = 0.004000 * safezoneW;
					y = 0.021500 * safezoneH;
					w = 0.019 * safezoneW;
					h = 0.02 * safezoneH;
				};
				class MCC_consoleAlphaSlider: MCC_RscXSliderH
				{
					idc = 9120;
					tooltip = "Window transparency";
					onSliderPosChanged = "[_this select 1] call MCC_fnc_consoleAlpha";
					x = 0.070000 * safezoneW;
					y = 0.046000 * safezoneH;
					w = 0.094000 * safezoneW;
					h = 0.012000 * safezoneH;
				};
				class MCC_consoleMapAlphaSlider: MCC_RscXSliderH
				{
					idc = 9121;
					tooltip = "Map transparency: right = map fully visible, left = map hidden";
					onSliderPosChanged = "[nil, _this select 1] call MCC_fnc_consoleAlpha";
					x = 0.070000 * safezoneW;
					y = 0.079800 * safezoneH;
					w = 0.094000 * safezoneW;
					h = 0.012000 * safezoneH;
				};
				class MCC_dsFlatConsole: MCCBTN_S
				{
					idc = 9174;
					text = "Flat";
					tooltip = "Flat buttons";
					onButtonClick = "if (profileNamespace getVariable ['MCC_consoleButtons', false]) then {profileNamespace setVariable ['MCC_consoleButtons', false]; saveProfileNamespace; closeDialog 0; [] spawn {waitUntil {isNull (findDisplay 2994)}; createDialog 'mcc_groupGen'}};";
					x = 0.006 * safezoneW;
					y = 0.098000 * safezoneH;
					w = 0.077000 * safezoneW;
					h = 0.0219914 * safezoneH;
				};
				class MCC_dsButtonsConsole: MCCBTN_S
				{
					idc = 9175;
					text = "Buttons";
					tooltip = "3D buttons";
					onButtonClick = "if !(profileNamespace getVariable ['MCC_consoleButtons', false]) then {profileNamespace setVariable ['MCC_consoleButtons', true]; saveProfileNamespace; closeDialog 0; [] spawn {waitUntil {isNull (findDisplay 2994)}; createDialog 'mcc_groupGenButtons'}};";
					x = 0.087000 * safezoneW;
					y = 0.098000 * safezoneH;
					w = 0.077000 * safezoneW;
					h = 0.0219914 * safezoneH;
				};
			};
		};
		class MCC_HelpRound: MCC_RscText
		{
			idc = -1;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";	//square with rounded corners (the wide button texture looked square at this size)
			colorText[] = {1,1,1,1};
			x = 0.195 * safezoneW + safezoneX;
			y = 0.095 * safezoneH + safezoneY;
			w = 0.020625 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCC_HelpLabel: MCC_RscText
		{
			idc = -1;
			style = 2;	//(?) centred on the button both ways (structured text is drawn from the top)
			text = "?";
			shadow = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.195 * safezoneW + safezoneX;
			y = 0.095 * safezoneH + safezoneY;
			w = 0.020625 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCC_Help: MCC_RscStructuredText
		{
			idc = -1;
			text = "";	//(?) is the label under it; this control only opens the help
			colorBackground[] = {0,0,0,0};	//the rounded button under it is MCC_HelpRound
			onMouseEnter = "[_this, true,[13,13],'mccmain'] spawn MCC_fnc_help";

			x = 0.195 * safezoneW + safezoneX;
			y = 0.095 * safezoneH + safezoneY;
			w = 0.020625 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCC_UMKick: MCCBTN_S
		{
			idc = MCC_UM_KICK;
			onButtonClick = __EVAL("[15] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");

			text = "Kick"; //--- ToDo: Localize;
			x = 0.866638 * safezoneW + safezoneX;
			y = 0.704559 * safezoneH + safezoneY;
			w = 0.033375 * safezoneW;
			h = 0.021991 * safezoneH;
			tooltip = "Kick selected player from the server"; //--- ToDo: Localize;
		};
		class MCC_UMBan: MCCBTN_S
		{
			idc = MCC_UM_BAN;
			onButtonClick = __EVAL("[16] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");

			text = "Ban"; //--- ToDo: Localize;
			x = 0.902013 * safezoneW + safezoneX;
			y = 0.704559 * safezoneH + safezoneY;
			w = 0.033375 * safezoneW;
			h = 0.021991 * safezoneH;
			tooltip = "Ban selected player from the server"; //--- ToDo: Localize;
		};
		class MCC_login: MCCBTN_S
		{
			idc = -1;
			text = "Logout";
			x = 0.866638 * safezoneW + safezoneX;
			y = 0.732550 * safezoneH + safezoneY;
			w = 0.068750 * safezoneW;
			h = 0.021991 * safezoneH;
			tooltip = "Login or logout as the mission maker";
			onButtonClick = "_null = [] spawn MCC_fnc_loginDialog";
		};
		class MCC_saveLoad: MCCBTN_S
		{
			idc = -1;
			text = "Save/Load";
			x = 0.866638 * safezoneW + safezoneX;
			y = 0.760542 * safezoneH + safezoneY;
			w = 0.068750 * safezoneW;
			h = 0.021991 * safezoneH;
			onButtonClick = "if (mcc_missionmaker == (name player)) then {createDialog ('MCC_SaveLoadScreen' + (['', 'Buttons'] select (profileNamespace getVariable ['MCC_consoleButtons', false])));} else {player globalchat 'Access Denied'};";
		};
		class closeGeneratorButton: MCCBTN_S
		{
			idc = -1;

			text = "Close";
			action = "closeDialog 0;";

			x = 0.866638 * safezoneW + safezoneX;
			y = 0.788533 * safezoneH + safezoneY;
			w = 0.068750 * safezoneW;
			h = 0.021991 * safezoneH;
		};
		#include "mcc_groupGenWaypoints.hpp"
		#include "MCC_GroupGenInfo.hpp"
	};

 //========================================= Background========================================
	class mcc_groupGenPic: MCC_RscText
	{
			colorText[] = {0.11,0.12,0.13,0.96};
			style = 48;
		idc = MCC_BACK;
		moving = 1;	//drag the console by its background
		text = "\mcc_sandbox_mod\data\panel_top_ca.paa";
		colorBackground[] = {0,0,0,0};

		//Only the part above the map: the console background is cut round the map (with the bottom, left and right
		//pieces below), so the map transparency slider shows the world through the map, not a black panel
		x = 0.0989583 * safezoneW + safezoneX;
		y = 0.0161887 * safezoneH + safezoneY;
		w = 0.845 * safezoneW;
		h = 0.0769699 * safezoneH;
	};
	class mcc_groupGenPicBottom: mcc_groupGenPic
	{
			colorBackground[] = {0,0,0,0};
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_bottom_ca.paa";
			style = 48;
		idc = 9006;	//(9003 is the Spawn panel group list)
		x = 0.0989583 * safezoneW + safezoneX;
		y = 0.636576 * safezoneH + safezoneY;
		w = 0.845 * safezoneW;
		h = 0.204291 * safezoneH;
	};
	class mcc_groupGenPicLeft: mcc_groupGenPic
	{
			colorBackground[] = {0.11,0.12,0.13,0.96};
			text = "";
			style = 0;
		idc = 9004;
		x = 0.0989583 * safezoneW + safezoneX;
		y = 0.0931586 * safezoneH + safezoneY;
		w = 0.0916667 * safezoneW;
		h = 0.543417 * safezoneH;
	};
	class mcc_groupGenPicRight: mcc_groupGenPic
	{
			colorBackground[] = {0.11,0.12,0.13,0.96};
			text = "";
			style = 0;
		idc = 9005;
		x = 0.937958 * safezoneW + safezoneX;
		y = 0.0931586 * safezoneH + safezoneY;
		w = 0.006000 * safezoneW;
		h = 0.543417 * safezoneH;
	};

//===========================================Map==============================================
	class MCC_mapBackground : MCC_RscText
	{
		idc = MCC_MINIMAPBACK;

		x = 0.190625 * safezoneW + safezoneX;
		y = 0.0931586 * safezoneH + safezoneY;
		w = 0.747333 * safezoneW;
		h = 0.543417 * safezoneH;

		colorBackground[] = {0.17,0.18,0.20,1};
		colorText[] = { 1, 1, 1, 0};
		text = "";
	};

	class MCC_map : MCC_RscMapControl
	{
		idc = MCC_MINIMAP;

		x = 0.190625 * safezoneW + safezoneX;
		y = 0.0931586 * safezoneH + safezoneY;
		w = 0.747333 * safezoneW;
		h = 0.543417 * safezoneH;

		text = "";
		onMouseButtonDown = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\mouseDown.sqf'");
		onMouseButtonUp = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\mouseUp.sqf'");
		onMouseButtonDblClick = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\mouseDblClick.sqf'");
		onMouseMoving = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\mouseMoving.sqf'");
	};
	class MCC_mapContour : MCC_map
	{
		idc = 9010;
		maxSatelliteAlpha = 0;
		colorOutside[] = {0.718,0.794,0.900,1};
		colorBackground[] = {0.969,0.957,0.949,1};
	};

	class MCC_fram1: MCC_RscText
	{
		idc = -1;
		colorBackground[] = {0,0,0,0};

		x = 0.463333 * safezoneW + safezoneX;
		y = 0.043458 * safezoneH + safezoneY;
		w = 0.189063 * safezoneW;
		h = 0.0439828 * safezoneH;
	};
};

