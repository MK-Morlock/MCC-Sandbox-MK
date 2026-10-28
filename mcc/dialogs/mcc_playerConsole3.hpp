// By: Shay_gman
// Version: 1.1 (April 2013)

#define mcc_playerConsole3_IDD 5010

#define MCC_CONSOLE_AC_BCKG 5011
#define MCC_CONSOLE_AC_MISSILE_COUNT 5012
#define MCC_CONSOLE_AC_MISSILE_COUNT2 5019
#define MCC_CONSOLE_AC_MISSILE_COUNT3 5020
#define MCC_CONSOLE_AC_VISION_TEXT 5013
#define MCC_CONSOLE_AC_TIME_TEXT 5014
#define MCC_CONSOLE_AC_ZOOM_TEXT 5015
#define MCC_CONSOLE_AC_TARGET 5016
#define MCC_CONSOLE_AC_WEAPON 5017
#define MCC_CONSOLE_ACPIP 5018
#define MCC_CONSOLE_AC_DIR_TEXT 5021
#define MCC_CONSOLE_COMPASS_N 9116
#define MCC_CONSOLE_COMPASS_E 9117
#define MCC_CONSOLE_COMPASS_S 9118
#define MCC_CONSOLE_COMPASS_W 9119
#define MCC_CONSOLE_AC_MAP 5022

#define MCC_CONSOLEUAVFLIGHTHIGHT 9121
#define MCC_CONSOLEUAVFLIGHTHIGHTTEXT 9122

//-----------------------------------------------------------------------------
// Main dialog
//-----------------------------------------------------------------------------
class MCCDLG_NAME {
  idd = mcc_playerConsole3_IDD;
  movingEnable = 1;
  onLoad = __EVAL("[] execVM '"+MCCPATH+"mcc\dialogs\mcc_playerConsole3_init.sqf'");

  controlsBackground[] =
  {
  mcc_ConsolePic,
  mcc_ConsoleBackground,
  MCC_ConsoleACFeedFrame,
  MCC_ConsoleACFeed,
  MCC_ConsoleACFeedBckg
  };


  //---------------------------------------------
  objects[] =
  {
  };

  controls[] =
  {
  mcc_consoleF1,
  mcc_consoleF2,
  mcc_consoleF3,
  mcc_consoleF4,
  mcc_consoleF5,
  mcc_consoleF6,
  MCC_ConsoleExitButton,
  MCC_ConsoleACFeedTargetPic,
  MCC_ConsoleACFeedFake,
  MCC_ConsoleACCamBtn0,
  MCC_ConsoleACCamBtn1,
  MCC_ConsoleACCamBtn2,
  MCC_ConsoleACMissileCount,
  MCC_ConsoleACMissileCount2,
  MCC_ConsoleACMissileCount3,
  MCC_ConsoleACVisionText,
  MCC_ConsoleACTimeText,
  MCC_ConsoleACZoomText,
  MCC_ConsoleACWpnBtn0,
  MCC_ConsoleACWpnBtn1,
  MCC_ConsoleACWpnBtn2,
  MCC_ConsoleACAmmoBtn,
  MCC_ConsoleACDirText,
  MCC_ConsoleCompassN,
  MCC_ConsoleCompassE,
  MCC_ConsoleCompassS,
  MCC_ConsoleCompassW,
  MCC_mapConsole,
  MCC_ConsoleACMap,
  MCC_ConsoleACGunner1,
  MCC_ConsoleACGunner2,
  MCC_ConsoleUAVFlightHight,
  MCC_ConsoleUAVFlightHightText
  };

 //========================================= Background========================================
	class mcc_ConsolePic: MCC_RscPicture	{idc = -1;text = __EVAL(MCCPATH +"data\mk_cc_ca.paa");
		x = -0.0446875 * safezoneW + safezoneX;
		y = 0.0939094 * safezoneH + safezoneY;
		w = 1.00406 * safezoneW;
		h = 0.840187 * safezoneH;
	};
	class mcc_ConsoleBackground: MCC_RscText	{idc = -1;text = "";colorBackground[] = { 0, 0, 0, 1};x = 0.204688 * safezoneW + safezoneX;y = 0.2025 * safezoneH + safezoneY;w = 0.590625 * safezoneW;h = 0.595 * safezoneH;};
	class MCC_ConsoleEvacFrame: MCC_RscFrame {
		idc = -1;
		x = 0.217813 * safezoneW + safezoneX;
		y = 0.401978 * safezoneH + safezoneY;
		w = 0.229687 * safezoneW;
		h = 0.0700156 * safezoneH;
	};
//============================================Buttons==========================================
class mcc_consoleF1: MCC_RscButtonConsoleKey	//invisible key over the tablet picture, as in the main commander console
{
	idc = -1;
	x = 0.310937 * safezoneW + safezoneX;
	y = 0.829871 * safezoneH + safezoneY;
	w = 0.0229167 * safezoneW;
	h = 0.0329871 * safezoneH;
	text = "F1";
	onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\console\conoleSwitchMenu.sqf'");
	tooltip = "Main Menu";
};
class mcc_consoleF2: MCC_RscButtonConsoleKey	//invisible key over the tablet picture, as in the main commander console
{
	idc = 9196;
	x = 0.339583 * safezoneW + safezoneX;
	y = 0.829871 * safezoneH + safezoneY;
	w = 0.0229167 * safezoneW;
	h = 0.0329871 * safezoneH;
	text = "F2";
	onButtonClick = "[2] spawn MCC_fnc_consoleFKey";
	tooltip = "UAV Control";
};
class mcc_consoleF3: MCC_RscButtonConsoleKey	//invisible key over the tablet picture, as in the main commander console
{
	idc = 9197;
	x = 0.368229 * safezoneW + safezoneX;
	y = 0.829871 * safezoneH + safezoneY;
	w = 0.0229167 * safezoneW;
	h = 0.0329871 * safezoneH;
	text = "F3";
	onButtonClick = "[3] spawn MCC_fnc_consoleFKey";
	tooltip = "AC-130 Control";
};
class mcc_consoleF4: MCC_RscButtonConsoleKey	//invisible key over the tablet picture, as in the main commander console
{
	idc = -1;
	x = 0.396875 * safezoneW + safezoneX;
	y = 0.829871 * safezoneH + safezoneY;
	w = 0.0229167 * safezoneW;
	h = 0.0329871 * safezoneH;
	text = "F4";
	tooltip = "Forward observer artillery's interface";
	onButtonClick = __EVAL("[0,0,0,[1]] execVM '"+MCCPATH+"mcc\general_scripts\console\conoleOpenMenu.sqf'");
};
class mcc_consoleF5: MCC_RscButtonConsoleKey	//invisible key over the tablet picture, as in the main commander console
{
	idc = -1;
	x = 0.425521 * safezoneW + safezoneX;
	y = 0.829871 * safezoneH + safezoneY;
	w = 0.0229167 * safezoneW;
	h = 0.0329871 * safezoneH;
	text = "F5";
	tooltip = "Open RTS interface";
	onButtonClick ="while {dialog} do {closeDialog 0}; createDialog 'MCC_LOGISTICS_BASE_BUILD'";
};
class mcc_consoleF6: MCC_RscButtonConsoleKey	//invisible key over the tablet picture, as in the main commander console
{
	idc = -1;
	x = 0.454167 * safezoneW + safezoneX;
	y = 0.829871 * safezoneH + safezoneY;
	w = 0.0229167 * safezoneW;
	h = 0.0329871 * safezoneH;
	text = "F6";
	tooltip = "Fleet Management";
	onButtonClick ="while {dialog} do {closeDialog 0}; [0,0,0] spawn MCC_fnc_LHDspawnMenuInit";
};
class MCC_ConsoleExitButton: MCC_RscButtonConsoleKey
{
		idc = -1;
		text = "";
		x = 0.480312 * safezoneW + safezoneX;
		y = 0.822072 * safezoneH + safezoneY;
		w = 0.0328125 * safezoneW;
		h = 0.0420094 * safezoneH;
		colorBackground[] = {0,0,0,0};
		colorFocused[] = {1,1,1,0.2};
		colorShadow[] = { 0, 0, 0, 0};
		colorBorder[] = { 0, 0, 0, 0 };
		colorBackgroundActive[] = {0,0,0,0};
		colorDisabled[] = {0,0,0,0};
		colorBackgroundDisabled[] = {0,0,0,0};
		tooltip = "Close the console";
		onButtonClick = "closedialog 0;";
};
	//=============================UAV========================================================
	class MCC_ConsoleACFeed: MCC_RscPicture
	{
		idc = MCC_CONSOLE_ACPIP;
		text = "#(argb,512,512,1)r2t(rendertarget8,1.0);";
		x = 0.219271 * safezoneW + safezoneX;
		y = 0.225107 * safezoneH + safezoneY;
		w = 0.561458 * safezoneW;
		h = 0.472816 * safezoneH;
	};
	class MCC_ConsoleACFeedBckg: MCC_RscText
	{
		idc = MCC_CONSOLE_AC_BCKG;
		text = "";
		style = MCCST_CENTER;
		x = 0.219271 * safezoneW + safezoneX;
		y = 0.225107 * safezoneH + safezoneY;
		w = 0.561458 * safezoneW;
		h = 0.472816 * safezoneH;

	};
	class MCC_ConsoleACFeedTargetPic: MCC_RscPicture
	{
		idc = MCC_CONSOLE_AC_TARGET;
		x = 0.219271 * safezoneW + safezoneX;
		y = 0.225107 * safezoneH + safezoneY;
		w = 0.561458 * safezoneW;
		h = 0.472816 * safezoneH;

	};
	class MCC_ConsoleACFeedFrame: MCC_RscFrame
	{
		idc = -1;
		x = 0.219271 * safezoneW + safezoneX;
		y = 0.225107 * safezoneH + safezoneY;
		w = 0.561458 * safezoneW;
		h = 0.472816 * safezoneH;
	};
	class MCC_ConsoleACFeedFake: MCC_RscListBox
	{
		//invisible mouse area over the video feed: no background (the themed list colour covered the feed, 95% dark)
		colorBackground[] = {0,0,0,0};
		colorSelectBackground[] = {0,0,0,0};
		colorSelectBackground2[] = {0,0,0,0};
		idc = -1;
		x = 0.219271 * safezoneW + safezoneX;
		y = 0.225107 * safezoneH + safezoneY;
		w = 0.561458 * safezoneW;
		h = 0.472816 * safezoneH;
		onMouseButtonDown = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\console\ACmouseDown.sqf'");
		onMouseButtonUp = "MCC_consoleACmousebuttonUp = true;";
		onMouseZChanged = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\console\ACmousez.sqf'");
		onMouseMoving = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\console\ACmouseMoving.sqf'");
	};
	//(was a switch bar; now rounded buttons like the MCC console)
	class MCC_ConsoleACCamBtn0: MCCBTN_R
	{
		idc = 9175;
		text = "Regular";
		onButtonClick = "[controlNull, 0] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\console\ac_camView.sqf'); [findDisplay 5010, 9175, 0] call MCC_fnc_consoleModeButtons";
		x = 0.2193 * safezoneW + safezoneX;
		y = 0.708919 * safezoneH + safezoneY;
		w = 0.0426 * safezoneW;
		h = 0.0329871 * safezoneH;
	};
	class MCC_ConsoleACCamBtn1: MCCBTN_R
	{
		idc = 9176;
		text = "N/V";
		onButtonClick = "[controlNull, 1] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\console\ac_camView.sqf'); [findDisplay 5010, 9175, 1] call MCC_fnc_consoleModeButtons";
		x = 0.2639 * safezoneW + safezoneX;
		y = 0.708919 * safezoneH + safezoneY;
		w = 0.0426 * safezoneW;
		h = 0.0329871 * safezoneH;
	};
	class MCC_ConsoleACCamBtn2: MCCBTN_R
	{
		idc = 9177;
		text = "Thermal";
		onButtonClick = "[controlNull, 2] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\console\ac_camView.sqf'); [findDisplay 5010, 9175, 2] call MCC_fnc_consoleModeButtons";
		x = 0.3085 * safezoneW + safezoneX;
		y = 0.708919 * safezoneH + safezoneY;
		w = 0.0426 * safezoneW;
		h = 0.0329871 * safezoneH;
	};

	//(was a switch bar; now rounded buttons like the MCC console)
	class MCC_ConsoleACWpnBtn0: MCCBTN_R
	{
		idc = 9180;
		text = "25mm";
		onButtonClick = "[controlNull, 0] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\console\ac_weaponChange.sqf'); [findDisplay 5010, 9180, 0] call MCC_fnc_consoleModeButtons";
		x = 0.4000 * safezoneW + safezoneX;
		y = 0.708919 * safezoneH + safezoneY;
		w = 0.0426 * safezoneW;
		h = 0.0329871 * safezoneH;
	};
	class MCC_ConsoleACWpnBtn1: MCCBTN_R
	{
		idc = 9181;
		text = "40mm";
		onButtonClick = "[controlNull, 1] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\console\ac_weaponChange.sqf'); [findDisplay 5010, 9180, 1] call MCC_fnc_consoleModeButtons";
		x = 0.4446 * safezoneW + safezoneX;
		y = 0.708919 * safezoneH + safezoneY;
		w = 0.0426 * safezoneW;
		h = 0.0329871 * safezoneH;
	};
	class MCC_ConsoleACWpnBtn2: MCCBTN_R
	{
		idc = 9182;
		text = "105mm";
		onButtonClick = "[controlNull, 2] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\console\ac_weaponChange.sqf'); [findDisplay 5010, 9180, 2] call MCC_fnc_consoleModeButtons";
		x = 0.4892 * safezoneW + safezoneX;
		y = 0.708919 * safezoneH + safezoneY;
		w = 0.0426 * safezoneW;
		h = 0.0329871 * safezoneH;
	};
	class MCC_ConsoleACAmmoBtn: MCCBTN_R
	{
		idc = 9185;
		text = "HE";
		onButtonClick = "[] call MCC_fnc_acAmmoToggle";
		x = 0.5470 * safezoneW + safezoneX;
		y = 0.708919 * safezoneH + safezoneY;
		w = 0.0426 * safezoneW;
		h = 0.0329871 * safezoneH;
	};


	class MCC_ConsoleACMissileCount: MCC_RscText
	{
		idc = MCC_CONSOLE_AC_MISSILE_COUNT;
		x = 0.682708 * safezoneW + safezoneX;
		y = 0.5 * safezoneH + safezoneY;
		w = 0.0859375 * safezoneW;
		h = 0.05 * safezoneH;
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	};

	class MCC_ConsoleACMissileCount2: MCC_RscText
	{
		idc = MCC_CONSOLE_AC_MISSILE_COUNT2;
		x = 0.682708 * safezoneW + safezoneX;
		y = 0.56 * safezoneH + safezoneY;
		w = 0.0859375 * safezoneW;
		h = 0.05 * safezoneH;
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	};

	class MCC_ConsoleACMissileCount3: MCC_RscText
	{
		idc = MCC_CONSOLE_AC_MISSILE_COUNT3;
		x = 0.682708 * safezoneW + safezoneX;
		y = 0.62 * safezoneH + safezoneY;
		w = 0.0859375 * safezoneW;
		h = 0.05 * safezoneH;
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	};

	class MCC_ConsoleACVisionText: MCC_RscText
	{
		idc = MCC_CONSOLE_AC_VISION_TEXT;
		x = 0.230729 * safezoneW + safezoneX;
		y = 0.637963 * safezoneH + safezoneY;
		w = 0.103125 * safezoneW;
		h = 0.0439828 * safezoneH;
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	};
	class MCC_ConsoleACTimeText: MCC_RscStructuredText
	{
		idc =MCC_CONSOLE_AC_TIME_TEXT;
		style = MCCST_MULTI;
		x = 0.6 * safezoneW + safezoneX;
		y = 0.236103 * safezoneH + safezoneY;
		w = 0.18 * safezoneW;
		h = 0.239828 * safezoneH;
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	};
	class MCC_ConsoleACZoomText: MCC_RscText
	{
		idc = MCC_CONSOLE_AC_ZOOM_TEXT;

		x = 0.230729 * safezoneW + safezoneX;
		y = 0.236103 * safezoneH + safezoneY;
		w = 0.0916667 * safezoneW;
		h = 0.0439828 * safezoneH;
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	};
	class MCC_ConsoleACDirText: MCC_RscText
	{
		idc = MCC_CONSOLE_AC_DIR_TEXT;

		x = 0.45 * safezoneW + safezoneX;
		y = 0.236103 * safezoneH + safezoneY;
		w = 0.0916667 * safezoneW;
		h = 0.0439828 * safezoneH;
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	};
		class MCC_ConsoleCompassN: MCC_RscText
	{
		idc = MCC_CONSOLE_COMPASS_N;
		text = "N";

		x = 0.5 * safezoneW + safezoneX;
		y = 0.25 * safezoneH + safezoneY;
		w = 0.05 * safezoneW;
		h = 0.05 * safezoneH;
		colorText[] = {1,0,0,0.7};
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	};
	class MCC_ConsoleCompassE: MCC_ConsoleCompassN
	{
		idc = MCC_CONSOLE_COMPASS_E;
		colorText[] = {1,1,1,1};
		text = "E";
	};
	class MCC_ConsoleCompassS: MCC_ConsoleCompassE
	{
		idc = MCC_CONSOLE_COMPASS_S;
		text = "S";
	};
	class MCC_ConsoleCompassW: MCC_ConsoleCompassE
	{
		idc = MCC_CONSOLE_COMPASS_W;
		text = "W";
	};
		class MCC_mapConsole : MCC_RscMapControl {
		idc = MCC_MINIMAP;
		moving = true;
		x = 0.788749 * safezoneW + safezoneX;
		y = 0.212936 * safezoneH + safezoneY;
		w = 0.01 * safezoneW;
		h = 0.01 * safezoneH;
	};

	class MCC_ConsoleACMap: MCCBTN_R
	{
		idc = MCC_CONSOLE_AC_MAP;
		x = 0.6 * safezoneW + safezoneX;
		y = 0.708919 * safezoneH + safezoneY;
		w = 0.07 * safezoneW;
		h = 0.0329871 * safezoneH;
		text = "Open Map";
		onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\console\conoleMap.sqf'");
	};
	/*
	class MCC_ConsoleACFullScreen: MCCBTN_R
	{
		idc = 5055;
		x = 0.7 * safezoneW + safezoneX;
		y = 0.708919 * safezoneH + safezoneY;
		w = 0.07 * safezoneW;
		h = 0.0329871 * safezoneH;
		text = "Full Screen";
		onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\general_scripts\console\fn_ConsoleACFullScreen.sqf'");
	};
	*/
	class MCC_ConsoleACGunner1: MCCBTN_S
	{
		idc = 9186;
		text = "Gunner 1";
		x = 0.675 * safezoneW + safezoneX;
		y = 0.7144 * safezoneH + safezoneY;
		w = 0.05 * safezoneW;
		h = 0.022 * safezoneH;
		onButtonClick = "[[1]] execVM ((missionNamespace getVariable ['MCC_path', '\mcc_sandbox_mod\']) + 'mcc\general_scripts\console\consoleACGunner.sqf')";
	};
	class MCC_ConsoleACGunner2: MCCBTN_S
	{
		idc = 9187;
		text = "Gunner 2";
		x = 0.729 * safezoneW + safezoneX;
		y = 0.7144 * safezoneH + safezoneY;
		w = 0.05 * safezoneW;
		h = 0.022 * safezoneH;
		onButtonClick = "[[2]] execVM ((missionNamespace getVariable ['MCC_path', '\mcc_sandbox_mod\']) + 'mcc\general_scripts\console\consoleACGunner.sqf')";
	};
	class MCC_ConsoleUAVFlightHight: MCC_RscSlider
	{
		idc = MCC_CONSOLEUAVFLIGHTHIGHT;
		x = 0.391146 * safezoneW + safezoneX;
		y = 0.75 * safezoneH + safezoneY;
		w = 0.15 * safezoneW;
		h = 0.0280063 * safezoneH;
		onSliderPosChanged = __EVAL("[2,_this] execVM '"+MCCPATH+"mcc\general_scripts\console\uavControl.sqf'");
	};
	class MCC_ConsoleUAVFlightHightText: MCC_RscText
	{
		idc = MCC_CONSOLEUAVFLIGHTHIGHTTEXT;

		text = "Flight Hight"; //--- ToDo: Localize;
		x = 0.425521 * safezoneW + safezoneX;
		y = 0.77 * safezoneH + safezoneY;
		w = 0.0916667 * safezoneW;
		h = 0.0219914 * safezoneH;
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
	};
};
