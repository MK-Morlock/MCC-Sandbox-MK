#define MCC_MINIMAP 9000
#define MCCMWDialog_IDD 2989

class MCCDLG_NAME
{
	idd = MCCMWDialog_IDD;
	movingEnable = true;
	onLoad = __EVAL("_this execVM '"+MCCPATH+"mcc\dialogs\mcc_mw_init.sqf'");
	onUnload = "if (isNull (findDisplay 2994)) then {{str _x setMarkerAlphaLocal 0; (format ['LABEL_%1', _x]) setMarkerAlphaLocal 0} forEach (missionNamespace getVariable ['MCC_zones_numbers', []])}";

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
			colorBackground[] = {0.11,0.12,0.13,0.96};

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
			y = 0.445021 * safezoneH + safezoneY;
			w = 0.303646 * safezoneW;
			h = 0.0549786 * safezoneH;
		};

		class MCCMWDialogClose: MCCBTN_S
		{
			idc = -1;
			text = "Close"; //--- ToDo: Localize;
			action = "MCC_mcc_screen = 2;closeDialog 0;";

			x = 0.233000 * safezoneW + safezoneX;
			y = 0.8455 * safezoneH + safezoneY;	//(MK) the console's Logout size, clear of the window's bottom edge
			w = 0.06875 * safezoneW;
			h = 0.021991 * safezoneH;
		};


		//Generate
		class MCC_MWGenerate: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\missionWizard\scripts\missionWizardInit.sqf'");
			text = "Generate Mission"; //--- ToDo: Localize;

			x = 0.69825 * safezoneW + safezoneX;	//(MK) right edge where it was
			y = 0.8455 * safezoneH + safezoneY;
			w = 0.06875 * safezoneW;
			h = 0.021991 * safezoneH;
			tooltip = "Generate a mission "; //--- ToDo: Localize;
		};

		class MCC_mapBackground : MCC_RscText
		{
			idc = -1;

			x = 0.230729 * safezoneW + safezoneX;
			y = 0.126146 * safezoneH + safezoneY;
			w = 0.540625 * safezoneW;
			h = 0.318876 * safezoneH;

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
			h = 0.318876 * safezoneH;

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
		class MCC_mapLayersRound: MCC_RscText
		{
			idc = 9011;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.746354 * safezoneW + safezoneX;
			y = 0.127987 * safezoneH + safezoneY;
			w = 0.020625 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCC_mapLayersIcon: MCC_RscText
		{
			idc = 9012;
			style = 2096;
			text = "\mcc_sandbox_mod\data\mk_maplayers_ca.paa";
			colorText[] = {0.88,0.89,0.90,1};
			x = 0.749354 * safezoneW + safezoneX;
			y = 0.132487 * safezoneH + safezoneY;
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
			action = "['toggle', 'mw'] call MCC_fnc_consoleMapLayers";
			x = 0.746354 * safezoneW + safezoneX;
			y = 0.127987 * safezoneH + safezoneY;
			w = 0.020625 * safezoneW;
			h = 0.033 * safezoneH;
		};

		class MCCMWZoneTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Zone";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";

			x = 0.540104 * safezoneW + safezoneX;
			y = 0.456017 * safezoneH + safezoneY;
			w = 0.0458333 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		class MCCMWZoneCombo: MCC_RscCombo
		{
			idc = 1023;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onLBSelChanged = __EVAL("[0,0,0] execVM '"+MCCPATH+"mcc\pop_menu\zones.sqf'");

			x = 0.591667 * safezoneW + safezoneX;
			y = 0.456017 * safezoneH + safezoneY;
			w = 0.06 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		class MCCMWZoneUpdateButton: MCCBTN_S
		{
			idc = -1;
			text = "Update Zone";
			tooltip = "Click and drag on the minimap to make a zone";
			onButtonClick = "if (mcc_missionmaker == (name player)) then {MCC_zone_drawing= true;} else {player globalchat 'Access Denied'};";

			x = 0.700521 * safezoneW + safezoneX;
			y = 0.456017 * safezoneH + safezoneY;	//(MK) the Zone drop-down's row and height
			w = 0.06875 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		#include "mcc_MWcontrols.hpp"
	};
};
