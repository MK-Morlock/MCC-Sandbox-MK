// By: Shay_gman
// Version: 1.1 (May 2012)
#define MCC_SQLPDA_IDD 2996
#define MCC_MINIMAP 9120
#define MCC_CONSOLEINFOTEXT 9150
#define MCC_CONSOLEINFOLIVEFEED 9151

//-----------------------------------------------------------------------------
// Main dialog
//-----------------------------------------------------------------------------
class MCCDLG_NAME
{
	idd = MCC_SQLPDA_IDD;
	movingEnable = 1;
	onLoad = __EVAL("_this execVM '"+MCCPATH+"mcc\dialogs\sqlPDA\mcc_sqlpda_init.sqf'");

	controlsBackground[] =
	{
		mcc_sqlpdaPic,
		MCC_sqlpdaMapBackground,
		MCC_sqlpdaMap,
		MCC_mapContour,
		MCC_ConsoleInfoText
	};


	//---------------------------------------------
	objects[] =
	{
	};

	controls[] =
	{
		MCC_mapLayersRound,
		MCC_mapLayersIcon,
		MCC_mapLayersBtn,
		MCC_sqlpdaMenuBg0,
		MCC_sqlpdaMenuBg1,
		MCC_sqlpdaMenuBg2,
		MCC_sqlpdaMenu0,
		MCC_sqlpdaMenu1,
		MCC_sqlpdaMenu2,
		MCC_ConsoleInfoLiveFeed,
		MCC_sqlpdaScaleButton,
		MCC_sqlpdaCloseLiveFeedButton,
		MCC_sqlpdaMove2BcgButton,
		MCC_sqlpdaExitButton
	};

	//========================================= Background========================================
	class mcc_sqlpdaPic: MCC_RscPicture
	{
		idc = 21;
		moving = true;
		text = __EVAL(MCCPATH +"mcc\dialogs\sqlPDA\data\pda_frame_ca.paa");
		x = 0.116146 * safezoneW + safezoneX;
		y = 0.434 * safezoneH + safezoneY;
		w = 0.35 * safezoneW;
		h = 0.53 * safezoneH;
	};

	//===========================================Map==============================================
	class MCC_sqlpdaMapBackground : MCC_RscPicture
	{
		idc = 22;
		moving = true;
		x = 0.139062 * safezoneW + safezoneX;
		y = 0.533 * safezoneH + safezoneY;
		w = 0.27 * safezoneW;
		h = 0.341 * safezoneH;
	};
	class MCC_sqlpdaMap : MCC_RscMapControl {
		idc = MCC_MINIMAP;
		moving = true;
		x = 0.139062 * safezoneW + safezoneX;
		y = 0.533 * safezoneH + safezoneY;
		w = 0.27 * safezoneW;
		h = 0.341 * safezoneH;
		onMouseButtonDown = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\pda\mouseDown.sqf'");
		onMouseButtonUp = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\pda\mouseUp.sqf'");
		onMouseButtonDblClick = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\pda\mouseDblClick.sqf'");
		onMouseMoving = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\pda\mouseMoving.sqf'");
	};
	class MCC_mapContour : MCC_sqlpdaMap
	{
		idc = 9130;
		maxSatelliteAlpha = 0;
		colorOutside[] = {0.718,0.794,0.900,1};
		colorBackground[] = {0.969,0.957,0.949,1};
	};
	//MK: map layers button (positioned top right of the map by MCC_fnc_consoleMapLayers)
	class MCC_mapLayersRound: MCC_RscText
	{
		idc = 9131;
		style = 48;
		text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
		colorText[] = {1,1,1,1};
		x = 0; y = 0; w = 0.020625 * safezoneW; h = 0.033 * safezoneH;
	};
	class MCC_mapLayersIcon: MCC_RscText
	{
		idc = 9132;
		style = 2096;
		text = "\mcc_sandbox_mod\data\mk_maplayers_ca.paa";
		colorText[] = {0.88,0.89,0.90,1};
		x = 0; y = 0; w = 0.014625 * safezoneW; h = 0.024 * safezoneH;
	};
	class MCC_mapLayersBtn: MCC_RscButton
	{
		idc = 9133;
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
		action = "['toggle', 'pda'] call MCC_fnc_consoleMapLayers";
		x = 0; y = 0; w = 0.020625 * safezoneW; h = 0.033 * safezoneH;
	};


	class MCC_ConsoleInfoLiveFeed: MCCBTN_R
	{
		idc = 3;
		text = "Live Feed";
		x = 0.217813 * safezoneW + safezoneX;
		y = 0.668037 * safezoneH + safezoneY;
		w = 0.06 * safezoneW;
		h = 0.03 * safezoneH;
		onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\general_scripts\pda\liveFeed.sqf'");
		class TextPos {left = 0; top = "((0.03 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
	};

	class MCC_ConsoleInfoText: MCC_RscStructuredText
		{
			idc = 4;
			x = 0.1 * safezoneW + safezoneX;
			y = 0.1 * safezoneH + safezoneY;
			w = 0.1 * safezoneW;
			h = 0.1 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.5)";
			colorBackground[] = {0.11,0.12,0.13,0.96};
		};


	//Rounded background under menu 0 (kept on the menu by mcc_sqlpda_init.sqf); the list itself is see-through
	class MCC_sqlpdaMenuBg0: MCC_RscText
	{
		idc = 31;
		style = 48;
		text = "\mcc_sandbox_mod\data\mcc_round_hl_ca.paa";
		colorText[] = {0.1,0.11,0.1,0.85};
		colorBackground[] = {0,0,0,0};
		x = 0;
		y = 0;
		w = 0;
		h = 0;
	};
	//Rounded background under menu 1 (kept on the menu by mcc_sqlpda_init.sqf); the list itself is see-through
	class MCC_sqlpdaMenuBg1: MCC_RscText
	{
		idc = 32;
		style = 48;
		text = "\mcc_sandbox_mod\data\mcc_round_hl_ca.paa";
		colorText[] = {0.1,0.11,0.1,0.85};
		colorBackground[] = {0,0,0,0};
		x = 0;
		y = 0;
		w = 0;
		h = 0;
	};
	//Rounded background under menu 2 (kept on the menu by mcc_sqlpda_init.sqf); the list itself is see-through
	class MCC_sqlpdaMenuBg2: MCC_RscText
	{
		idc = 33;
		style = 48;
		text = "\mcc_sandbox_mod\data\mcc_round_hl_ca.paa";
		colorText[] = {0.1,0.11,0.1,0.85};
		colorBackground[] = {0,0,0,0};
		x = 0;
		y = 0;
		w = 0;
		h = 0;
	};
	class MCC_sqlpdaMenu0: MCC_RscListbox
	{
		idc = 0;
		moving = true;
		colorBackground[] = {0,0,0,0};
		x = 0 * safezoneW + safezoneX;
		y = 0 * safezoneH + safezoneY;
		w = 0 * safezoneW;
		h = 0.4 * safezoneH;
	};

	class MCC_sqlpdaMenu1 : MCC_RscListbox
	{
		idc = 1;
		moving = true;
		colorBackground[] = {0,0,0,0};
		x = 0 * safezoneW + safezoneX;
		y = 0 * safezoneH + safezoneY;
		w = 0 * safezoneW;
		h = 0.4 * safezoneH;
	};

	class MCC_sqlpdaMenu2 : MCC_RscListbox
	{
		idc = 2;
		moving = true;
		colorBackground[] = {0,0,0,0};
		x = 0 * safezoneW + safezoneX;
		y = 0 * safezoneH + safezoneY;
		w = 0 * safezoneW;
		h = 0.4 * safezoneH;
	};

	//=================================Buttons=============================================
	class MCC_sqlpdaExitButton: MCC_RscActivePicture
	{
		color[] = {0.9,0.9,0.9,1};	//raised PDA button, a little brighter under the mouse
		colorActive[] = {1,1,1,1};
		shadow = 0;
		idc = 23;
		moving = true;
		text = __EVAL(MCCPATH +"mcc\dialogs\sqlPDA\data\pda_btn_power_ca.paa");
		x = 0.190625 * safezoneW + safezoneX;
		y = 0.885 * safezoneH + safezoneY;
		w = 0.0328125 * safezoneW;
		h = 0.0420094 * safezoneH;
		action = "closedialog 0;";
	};

	class MCC_sqlpdaScaleButton: MCC_RscActivePicture
	{
		color[] = {0.9,0.9,0.9,1};	//raised PDA button, a little brighter under the mouse
		colorActive[] = {1,1,1,1};
		shadow = 0;
		idc = 24;
		moving = true;
		x = 0.190625 * safezoneW + safezoneX;
		y = 0.885 * safezoneH + safezoneY;
		w = 0.0328125 * safezoneW;
		h = 0.0420094 * safezoneH;
	};

	class MCC_sqlpdaCloseLiveFeedButton: MCC_RscActivePicture
	{
		color[] = {0.9,0.9,0.9,1};	//raised PDA button, a little brighter under the mouse
		colorActive[] = {1,1,1,1};
		shadow = 0;
		idc = 25;
		moving = true;
		text = __EVAL(MCCPATH +"mcc\dialogs\sqlPDA\data\pda_btn_back_ca.paa");
		x = 0.190625 * safezoneW + safezoneX;
		y = 0.885 * safezoneH + safezoneY;
		w = 0.0328125 * safezoneW;
		h = 0.0420094 * safezoneH;
		action = __EVAL("[3] execVM '"+MCCPATH+"mcc\general_scripts\pda\liveFeed.sqf'");
	};

	class MCC_sqlpdaMove2BcgButton: MCC_RscActivePicture
	{
		color[] = {0.9,0.9,0.9,1};	//raised PDA button, a little brighter under the mouse
		colorActive[] = {1,1,1,1};
		shadow = 0;
		idc = 26;
		moving = true;
		text = __EVAL(MCCPATH +"mcc\dialogs\sqlPDA\data\pda_btn_pin_ca.paa");
		x = 0.190625 * safezoneW + safezoneX;
		y = 0.885 * safezoneH + safezoneY;
		w = 0.0328125 * safezoneW;
		h = 0.0420094 * safezoneH;
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.65)";
		action = "0 spawn {(['MCC_SQLPDA_rsc'] call BIS_fnc_rscLayer) cutRsc ['MCC_SQLPDA_rsc', 'PLAIN']};";
	};
};
