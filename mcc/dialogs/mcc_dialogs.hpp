#define FontHTML "Bitstream"
// Constants to standardize and help simplify positioning and sizing
#define MCCDlg_ROWS 36 // determines default text and control height
#define MCCDlg_COLS 90 // guide for positioning controls

#define MCCDlg_CONTROLHGT ((100/MCCDlg_ROWS)/100)
#define MCCDlg_COLWIDTH ((100/MCCDlg_COLS)/100)

// modifiers
#define MCCMCCDlg_TEXTHGT_MOD 0.9
#define MCCDlg_ROWSPACING_MOD 1.3

#define MCCDlg_ROWHGT (MCCDlg_CONTROLHGT*MCCDlg_ROWSPACING_MOD)
#define MCCDlg_TEXTHGT (MCCDlg_CONTROLHGT*MCCMCCDlg_TEXTHGT_MOD)

//-----------------------------------------------------------------------------
// Fonts
#define MCCFontM "RobotoCondensed"	//(was PuristaMedium)
#define MCCFontHTML "RobotoCondensed"
//"CourierNewB64" "TahomaB" "Bitstream" "Zeppelin32"

//-----------------------------------------------------------------------------
// Control Types
#define MCCCT_STATIC 0
#define MCCCT_BUTTON 1
#define MCCCT_EDIT 2
#define MCCCT_SLIDER 3
#define MCCCT_COMBO 4
#define MCCCT_LISTBOX 5
#define MCCCT_TOOLBOX 6
#define MCCCT_CHECKBOXES 7
#define MCCCT_PROGRESS 8
#define MCCCT_HTML 9
#define MCCCT_STATIC_SKEW 10
#define MCCCT_ACTIVETEXT 11
#define MCCCT_TREE 12
#define MCCCT_STRUCTURED_TEXT 13
#define MCCCT_CONTEXT_MENU 14
#define MCCCT_CONTROLS_GROUP 15

#define MCCCT_XKEYDESC 40
#define MCCCT_XBUTTON 41
#define MCCCT_XLISTBOX 42
#define MCCCT_XSLIDER 43
#define MCCCT_XCOMBO 44
#define MCCCT_ANIMATED_TEXTURE 45

#define MCCCT_OBJECT 80
#define MCCCT_OBJECT_ZOOM 81
#define MCCCT_OBJECT_CONTAINER 82
#define MCCCT_OBJECT_CONT_ANIM 83

#define MCCCT_LINEBREAK 98
#define MCCCT_USER 99
#define MCCCT_MAP 100
#define MCCCT_MAP_MAIN 101

#define MCCCT_SL_DIR 0x400
#define MCCCT_SL_VERT 0
#define MCCCT_SL_HORZ 0x400

//-----------------------------------------------------------------------------
// Static styles
#define MCCST_POS 0x0F
#define MCCST_HPOS 0x03
#define MCCST_VPOS 0x0C

#define MCCST_LEFT 0x00
#define MCCLB_TEXTURES 0x10
#define MCCST_RIGHT 0x01
#define MCCST_CENTER 0x02
#define MCCST_DOWN 0x04
#define MCCST_UP 0x08

#define MCCST_VCENTER 0x0c
#define MCCST_TYPE 0xF0

#define MCCST_SINGLE 0
#define MCCST_MULTI 16
#define MCCST_TITLE_BAR 32
#define MCCST_PICTURE 48
#define MCCST_FRAME 64
#define MCCST_BACKGROUND 80
#define MCCST_GROUP_BOX 96
#define MCCST_GROUP_BOX2 112
#define MCCST_HUD_BACKGROUND 128
#define MCCST_TILE_PICTURE 144
#define MCCST_WITH_RECT 160
#define MCCST_LINE 176
#define MCCLB_MULTI 0x20
#define MCCSL_VERT 0

//-----------------------------------------------------------------------------
// standard base dialog control class definitions
//-----------------------------------------------------------------------------
class MCC_RscText
{
  access = 0;
  type = 0;
  style = 0;
  colorBackground[] = {0,0,0,0};
  colorDisabled[] = {0,0,0,0.5};
  colorShadow[] = {0,0,0,0.5};
  colorText[] = {0.88,0.89,0.90,1};
  autocomplete = "";
  colorSelection[] = {0.82,0.42,0.37,1};
  fixedWidth = 0;
  font = MCCFontM;
  h = 0.037;
  linespacing = 1;
  shadow = 0;
  SizeEx = "(((((safezoneW/safezoneH) min 1.2) / 1.2) / 25) * 1)";
  text = "";
  w = 0.3;
  x = 0.0;
  y = 0.0;
};
//----------------------------------------------------------
class MCC_RscControlsGroupNoScrollbars
{
	h = 1;
	idc = -1;
	shadow = 0;
	style = 16;
	type = 15;
	w = 1;
	x = 0;
	y = 0;

	class Controls;
	class HScrollbar
	{
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		autoScrollDelay = 5;
		autoScrollEnabled = 0;
		autoScrollRewind = 0;
		autoScrollSpeed = -1;
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		color[] = {1,1,1,1};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		height = 0;
		scrollSpeed = 0.06;
		shadow = 0;
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		width = 0;
	};

	class VScrollbar
	{
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		autoScrollDelay = 5;
		autoScrollEnabled = 1;
		autoScrollRewind = 0;
		autoScrollSpeed = -1;
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		color[] = {1,1,1,1};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		height = 0;
		scrollSpeed = 0.06;
		shadow = 0;
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		width = 0;
	};
};

class MCC_RscControlsGroup
{
	h = 1;
	idc = -1;
	shadow = 0;
	style = 16;
	type = 15;
	w = 1;
	x = 0;
	y = 0;

	class Controls;
	class HScrollbar
	{
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		autoScrollDelay = 5;
		autoScrollEnabled = 0;
		autoScrollRewind = 0;
		autoScrollSpeed = -1;
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		color[] = {1,1,1,1};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		height = 0;
		scrollSpeed = 0.06;
		shadow = 0;
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		width = 0;
	};

	class VScrollbar
	{
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		autoScrollDelay = 5;
		autoScrollEnabled = 1;
		autoScrollRewind = 0;
		autoScrollSpeed = -1;
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		color[] = {1,1,1,1};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		height = 0;
		scrollSpeed = 0.06;
		shadow = 0;
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		width = 0;
	};

	class ScrollBar
	{
        arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		autoScrollDelay = 5;
		autoScrollEnabled = 0;
		autoScrollRewind = 0;
		autoScrollSpeed = -1;
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		color[] = {1,1,1,1};
		colorActive[] = {1,1,1,1};
		colorDisabled[] = {1,1,1,0.3};
		height = 0;
		scrollSpeed = 0.06;
		shadow = 0;
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		width = 0;
	};
};


class MCC_RscProgress
{
	access = 0;
	colorBar[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.69])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.75])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.5])","(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])"};
	colorFrame[] = {0,0,0,0};
	h = 0.0261438;
	shadow = 2;
	style = 0;
	texture = "\A3\ui_f\data\GUI\RscCommon\RscProgress\progressbar_ca.paa";
	type = 8;
	w = 0.313726;
	x = 0.344;
	y = 0.619;
};

class MCC_RscIGProgress
{
	access = 0;
	colorBar[] = {"(profilenamespace getvariable ['IGUI_TEXT_RGB_R',0])","(profilenamespace getvariable ['IGUI_TEXT_RGB_G',1])","(profilenamespace getvariable ['IGUI_TEXT_RGB_B',1])","(profilenamespace getvariable ['IGUI_TEXT_RGB_A',0.8])"};
	colorFrame[] = {0.706,0.098,0.9294,0};
	deletable = 0;
	fade = 0;
	h = 0.178;
	shadow = 2;
	style = 1;
	texture = "#(argb,8,8,3)color(1,1,1,1)";
	type = 8;
	w = 0.009;
	x = 0.344;
	y = 0.619;
};

class MCC_RscButton
{
  access = 0;
  borderSize = 0;
  colorBackground[] = {0.22,0.24,0.26,1};
  colorBackgroundActive[] = {0.77,0.51,0.08,1};
  colorBackgroundDisabled[] = {0.15,0.16,0.17,1};
  colorBorder[] = {0,0,0,1};
  colorDisabled[] = {0.55,0.56,0.57,1};
  colorFocused[] = {0.30,0.32,0.34,1};
  colorBackgroundFocused[] = {0.30,0.32,0.34,1};
  colorShadow[] = {0,0,0,0};
  colorText[] = {0.88,0.89,0.90,1};
  font = "RobotoCondensed";
  h = 0.039216;
  offsetPressedX = 0.001;
  offsetPressedY = 0.001;
  offsetX = 0;
  offsetY = 0;
  shadow = 0;
  sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
  soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.07,1};
  soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.09,1};
  soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
  soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.09,1};
  style = 2;
  text = "";
  type = 1;
  w = 0.095589;
  x = 0;
  y = 0;
};

class MCC_RscSideItem: MCC_RscButton
{
	style = 0;
	colorBackground[] = {0,0,0,0};
	colorBackgroundActive[] = {1,1,1,0.10};
	colorBackgroundDisabled[] = {0,0,0,0};
	colorFocused[] = {0,0,0,0};
	colorBackgroundFocused[] = {0,0,0,0};
	colorBorder[] = {0,0,0,0};
	colorText[] = {0.84,0.85,0.87,1};
	offsetPressedX = 0;
	offsetPressedY = 0;
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
};
//Invisible click area: commander console F-keys (over the keys printed on the console picture) and the console video feed
class MCC_RscButtonConsoleKey: MCC_RscButton
{
	text = "";
	colorText[] = {0,0,0,0};
	colorBackground[] = {0,0,0,0};
	colorBackgroundActive[] = {1,1,1,0.08};
	colorBackgroundDisabled[] = {0,0,0,0};
	colorFocused[] = {0,0,0,0};
	colorBackgroundFocused[] = {0,0,0,0};
	colorShadow[] = {0,0,0,0};
	colorBorder[] = {0,0,0,0};
	colorDisabled[] = {0,0,0,0};
	shadow = 0;
	offsetPressedX = 0;
	offsetPressedY = 0;
	offsetX = 0;
	offsetY = 0;
};

class MCC_RscCheckBox
{
	checked = 0;
	color[] = {1,1,1,0.7};
	colorBackground[] = {0,0,0,0};
	colorBackgroundDisabled[] = {0,0,0,0};
	colorBackgroundFocused[] = {0,0,0,0};
	colorBackgroundHover[] = {0,0,0,0};
	colorBackgroundPressed[] = {0,0,0,0};
	colorDisabled[] = {1,1,1,0.2};
	colorFocused[] = {1,1,1,1};
	colorHover[] = {1,1,1,1};
	colorPressed[] = {1,1,1,1};
	h = "0.04 * safezoneH";
	idc = -1;
	soundClick[] = {"",0.1,1};
	soundEnter[] = {"",0.1,1};
	soundEscape[] = {"",0.1,1};
	soundPush[] = {"",0.1,1};
	style = 0;
	textureChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureDisabledChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureDisabledUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	textureFocusedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureFocusedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	textureHoverChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	textureHoverUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	texturePressedChecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_checked_ca.paa";
	texturePressedUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	textureUnchecked = "\A3\Ui_f\data\GUI\RscCommon\RscCheckBox\CheckBox_unchecked_ca.paa";
	tooltipColorBox[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.65};
	tooltipColorText[] = {1,1,1,1};
	type = 77;
	w = "0.025 * safezoneW";
	x = "0.375 * safezoneW + safezoneX";
	y = "0.36 * safezoneH + safezoneY";
};

class MCC_CheckBoxes
{
	idc = -1;
	type = 7; // CT_CHECKBOXES
	style = 2; // ST_CENTER

	x = 0.25;
	y = 0.25;
	w = 0.5;
	h = 0.5;

	colorSelectedBg[] = {0, 0, 0, 0.2}; // selected item bg color

	colorText[] = {0.6, 0.6, 0.6, 0.6}; // checkbox unchecked color
	colorTextSelect[] = {1, 1, 1, 1}; // checkbox checked color

	colorBackground[] = {0, 0, 0, 0.2}; // control generic BG color

	font = "RobotoCondensed";
	sizeEx = 0.04;

	onCheckBoxesSelChanged = "hint str _this";

	columns = 8;
	rows = 4;
	strings[] = {"0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"};
	checked_strings[] = {"[0]","[1]","[2]","[3]","[4]","[5]","[6]","[7]","[8]","[9]","[10]","[11]","[12]","[13]","[14]","[15]","[16]","[17]","[18]","[19]","[20]","[21]","[22]","[23]","[24]","[25]","[26]","[27]","[28]","[29]","[30]","[31]"};
};

class MCC_RscButtonMenu : MCC_RscButton
{
  action = "";
  animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)";
  animTextureDisabled = "#(argb,8,8,3)color(1,1,1,1)";
  animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)";
  animTextureNormal = "#(argb,8,8,3)color(1,1,1,1)";
  animTextureOver = "#(argb,8,8,3)color(1,1,1,0.5)";
  animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)";
  color2[] = {1,1,1,1};
  color[] = {0.88,0.89,0.90,1};
  colorBackground2[] = {0.77,0.51,0.08,1};
  colorBackground[] = {0.22,0.24,0.26,1};
  colorDisabled[] = {1,1,1,0.25};
  colorText[] = {0.88,0.89,0.90,1};
  default = 0;
  font = "RobotoCondensed";
  h = 0.039216;
  period = 1.2;
  periodFocus = 1.2;
  periodOver = 1.2;
  shadow = 0;
  shortcuts[] = {};
  size = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
  sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
  soundClick[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundClick",0.09,1};
  soundEnter[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEnter",0.09,1};
  soundEscape[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEscape",0.09,1};
  soundPush[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundPush",0.09,1};
  style = 2;	//centred, like the other MCC buttons
  text = "";
  textureNoShortcut = "#(argb,8,8,3)color(0,0,0,0)";
  type = 1;	//standard button (was a textured shortcut button: text left/top, a different look)
  w = 0.095589;
  x = 0;
  y = 0;
  class Attributes
	{
		align = "left";
		color = "#E5E5E5";
		font = "RobotoCondensedLight";
		shadow = "false";
	};
  class AttributesImage
	{
		align = "left";
		color = "#E5E5E5";
		font = "RobotoCondensed";
	};
   class HitZone
	{
		bottom = 0;
		left = 0;
		right = 0;
		top = 0;
	};
   class ShortcutPos
	{
		h = 0.03;
		left = "(6.25 * 			(			((safezoneW / safezoneH) min 1.2) / 40)) - 0.0225 - 0.005";
		top = 0.005;
		w = 0.0225;
	};
   class TextPos
	{
		bottom = 0;
		left = "0.25 * 			(			((safezoneW / safezoneH) min 1.2) / 40)";
		right = 0.005;
		top = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) - 		(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)) / 2";
	};
};

class MCC_RscButtonMenuOK : MCC_RscButtonMenu
{
  idc = 1;
  color2[] = {0,0,0,1};
  color[] = {1,1,1,1};
  colorBackground2[] = {0.75,0.75,0.75,1};
  colorBackground[] = {0,0,0,0.8};
  colorBackgroundFocused[] = {1,1,1,1};
  colorDisabled[] = {1,1,1,0.25};
  colorFocused[] = {0,0,0,1};
  colorText[] = {1,1,1,1};
  default = 1;
  shortcuts[] = {"0x00050000 + 0",28,57,156};
  text = "OK";
};

class MCC_RscButtonMenuCancel : MCC_RscButtonMenuOK
{
  idc = 2;
  color2[] = {0,0,0,1};
  color[] = {1,1,1,1};
  colorBackground2[] = {0.75,0.75,0.75,1};
  colorBackground[] = {0,0,0,0.8};
  colorBackgroundFocused[] = {1,1,1,1};
  colorDisabled[] = {1,1,1,0.25};
  colorFocused[] = {0,0,0,1};
  colorText[] = {1,1,1,1};
  default = 0;
  shortcuts[] = {"0x00050000 + 1"};
  text = "Cancel";
};

class MCC_RscButtonMenuStd : MCC_RscButtonMenu
{
  idc = -1;
  color2[] = {0,0,0,1};
  color[] = {1,1,1,1};
  colorBackground2[] = {0.75,0.75,0.75,1};
  colorBackground[] = {0,0,0,0.8};
  colorBackgroundFocused[] = {1,1,1,1};
  colorDisabled[] = {1,1,1,0.25};
  colorFocused[] = {0,0,0,1};
  colorText[] = {1,1,1,1};
  shortcuts[] = {"0x00050000 + 0",28,57,156};
  text = "";
};

//Rounded-corner button (main console): a picture button (CT_SHORTCUTBUTTON) with a white rounded texture, tinted by
//the button colour is in the textures (grey, orange under the mouse, dark grey disabled). Only two heights exist so the text can be centred: large 0.0329871 and small 0.0219914 x safezoneH.
class MCC_RscButtonRound
{
	idc = -1;
	type = 16;
	style = 0;
	access = 0;
	default = 0;
	shadow = 0;
	x = 0; y = 0; w = 0.1; h = "0.0329871 * safezoneH";
	text = "";
	tooltip = "";
	font = "RobotoCondensed";
	size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
	color[] = {0.88,0.89,0.90,1};
	colorFocused[] = {0.88,0.89,0.90,1};
	color2[] = {1,1,1,1};
	colorDisabled[] = {0.55,0.56,0.57,1};
	colorBackground[] = {1,1,1,1};
	colorBackgroundFocused[] = {1,1,1,1};
	colorBackground2[] = {1,1,1,1};
	colorBackgroundDisabled[] = {1,1,1,1};
	animTextureNormal = "\mcc_sandbox_mod\data\btn_round_n_ca.paa";
	animTextureDisabled = "\mcc_sandbox_mod\data\btn_round_d_ca.paa";
	animTextureOver = "\mcc_sandbox_mod\data\btn_round_o_ca.paa";
	animTextureFocused = "\mcc_sandbox_mod\data\btn_round_n_ca.paa";
	animTexturePressed = "\mcc_sandbox_mod\data\btn_round_o_ca.paa";
	animTextureDefault = "\mcc_sandbox_mod\data\btn_round_n_ca.paa";
	textureNoShortcut = "#(argb,8,8,3)color(0,0,0,0)";
	period = 1.2;
	periodFocus = 1.2;
	periodOver = 1.2;
	soundEnter[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEnter",0.09,1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundPush",0.09,1};
	soundClick[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundClick",0.09,1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEscape",0.09,1};
	tooltipColorText[] = {1,1,1,1};
	tooltipColorBox[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.65};
	class HitZone {left = 0; top = 0; right = 0; bottom = 0;};
	class ShortcutPos {left = 0; top = 0; w = 0; h = 0;};
	class TextPos {left = 0; top = "((0.0329871 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};
	class Attributes {font = "RobotoCondensed"; color = "#E1E3E5"; align = "center"; shadow = 0;};
	class AttributesImage {font = "RobotoCondensed"; color = "#E1E3E5"; align = "center";};
};

//Rounded-corner button (main console): a picture button (CT_SHORTCUTBUTTON) with a white rounded texture, tinted by
//the button colour is in the textures (grey, orange under the mouse, dark grey disabled). Only two heights exist so the text can be centred: large 0.0219914 and small 0.0219914 x safezoneH.
class MCC_RscButtonRoundSmall
{
	idc = -1;
	type = 16;
	style = 0;
	access = 0;
	default = 0;
	shadow = 0;
	x = 0; y = 0; w = 0.1; h = "0.0219914 * safezoneH";
	text = "";
	tooltip = "";
	font = "RobotoCondensed";
	size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
	color[] = {0.88,0.89,0.90,1};
	colorFocused[] = {0.88,0.89,0.90,1};
	color2[] = {1,1,1,1};
	colorDisabled[] = {0.55,0.56,0.57,1};
	colorBackground[] = {1,1,1,1};
	colorBackgroundFocused[] = {1,1,1,1};
	colorBackground2[] = {1,1,1,1};
	colorBackgroundDisabled[] = {1,1,1,1};
	animTextureNormal = "\mcc_sandbox_mod\data\btn_round_wide_n_ca.paa";
	animTextureDisabled = "\mcc_sandbox_mod\data\btn_round_wide_d_ca.paa";
	animTextureOver = "\mcc_sandbox_mod\data\btn_round_wide_o_ca.paa";
	animTextureFocused = "\mcc_sandbox_mod\data\btn_round_wide_n_ca.paa";
	animTexturePressed = "\mcc_sandbox_mod\data\btn_round_wide_o_ca.paa";
	animTextureDefault = "\mcc_sandbox_mod\data\btn_round_wide_n_ca.paa";
	textureNoShortcut = "#(argb,8,8,3)color(0,0,0,0)";
	period = 1.2;
	periodFocus = 1.2;
	periodOver = 1.2;
	soundEnter[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEnter",0.09,1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundPush",0.09,1};
	soundClick[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundClick",0.09,1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEscape",0.09,1};
	tooltipColorText[] = {1,1,1,1};
	tooltipColorBox[] = {1,1,1,1};
	tooltipColorShade[] = {0,0,0,0.65};
	class HitZone {left = 0; top = 0; right = 0; bottom = 0;};
	class ShortcutPos {left = 0; top = 0; w = 0; h = 0;};
	class TextPos {left = 0; top = "((0.0219914 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};
	class Attributes {font = "RobotoCondensed"; color = "#E1E3E5"; align = "center"; shadow = 0;};
	class AttributesImage {font = "RobotoCondensed"; color = "#E1E3E5"; align = "center";};
};

class MCC_RscListbox
{
	access = 0;
	arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
	arrowFull = "#(argb,8,8,3)color(1,1,1,1)";
	autoScrollDelay = 5;
	autoScrollRewind = 0;
	autoScrollSpeed = -1;
	color[] = {1,1,1,1};
	colorBackground[] = {0.07,0.08,0.09,0.95};
	colorDisabled[] = {1,1,1,0.25};
	colorPictudeDisabled[] = {1,1,1,0.25};
	colorPicture[] = {1,1,1,1};
	colorPictureDisabled[] = {1,1,1,1};
	colorPictureSelected[] = {1,1,1,1};
	colorScrollbar[] = {1,0,0,0};
	colorSelect2[] = {1,1,1,1};
	colorSelect[] = {1,1,1,1};
	colorSelectBackground2[] = {0.77,0.51,0.08,0.6};
	colorSelectBackground[] = {0.77,0.51,0.08,1};
	colorShadow[] = {0,0,0,0.5};
	colorText[] = {0.88,0.89,0.90,1};
	font = "RobotoCondensed";
	h = 0.8;
	maxHistoryDelay = 1;
	period = 1.2;
	rowHeight = 0.03;
	shadow = 0;
	sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	soundSelect[] = {"",0.1,1};
	style = 16;
	type = 5;
	w = 0.4;

	class ListScrollBar
		{
			arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
			arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
			autoScrollDelay = 5;
			autoScrollEnabled = 0;
			autoScrollRewind = 0;
			autoScrollSpeed = -1;
			border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
			color[] = {1,1,1,0.6};
			colorActive[] = {1,1,1,1};
			colorDisabled[] = {1,1,1,0.3};
			height = 0;
			scrollSpeed = 0.06;
			shadow = 0;
			thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
			width = 0;
		};
};

class MCC_RscListNbox
{
	colorBackground[] = {0.07,0.08,0.09,0.95};
	access = 0;
	idc = -1;
	type = 102;
	style = MCCST_LEFT + MCCLB_TEXTURES; // Style
	default = 0;
	blinkingPeriod = 0;

	x = 29 * GUI_GRID_CENTER_W + GUI_GRID_CENTER_X; // Horizontal coordinates
	y = 15 * GUI_GRID_CENTER_H + GUI_GRID_CENTER_Y; // Vertical coordinates
	w = 10 * GUI_GRID_CENTER_W; // Width
	h = 3 * GUI_GRID_CENTER_H; // Height

	colorSelectBackground[] = {0.77,0.51,0.08,1}; // Selected item fill color
	colorSelectBackground2[] = {0.77,0.51,0.08,0.6}; // Selected item fill color (oscillates between this and colorSelectBackground)

	sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	font = "RobotoCondensed";
	shadow = 0; // Shadow (0 - none, 1 - directional, color affected by colorShadow, 2 - black outline)
	colorText[] = {0.88,0.89,0.90,1}; // Text and frame color
	colorDisabled[] = {1,1,1,0.5}; // Disabled text color
	colorSelect[] = {1,1,1,1}; // Text selection color
	colorSelect2[] = {1,1,1,1}; // Text selection color (oscillates between this and colorSelect)
	colorShadow[] = {0,0,0,0.5}; // Text shadow color (used only when shadow is 1)

	tooltip = "CT_LISTNBOX"; // Tooltip text
	tooltipColorShade[] = {0,0,0,1}; // Tooltip background color
	tooltipColorText[] = {1,1,1,1}; // Tooltip text color
	tooltipColorBox[] = {1,1,1,1}; // Tooltip frame color

	columns[] = {0.1}; // Horizontal coordinates of columns (relative to list width, in range from 0 to 1)

	drawSideArrows = 1; // 1 to draw buttons linked by idcLeft and idcRight on both sides of selected line. They are resized to line height
	idcLeft = 1000; // Left button IDC
	idcRight = 1001; // Right button IDC

	period = 1; // Oscillation time between colorSelect/colorSelectBackground2 and colorSelect2/colorSelectBackground when selected

	rowHeight = GUI_GRID_CENTER_H; // Row height
	maxHistoryDelay = 1; // Time since last keyboard type search to reset it

	soundSelect[] = {"\A3\ui_f\data\sound\RscListbox\soundSelect",0.09,1}; // Sound played when an item is selected

	// Scrollbar configuration (applied only when LB_TEXTURES style is used)
	class ListScrollBar
	{
		width = 0; // width of ListScrollBar
		height = 0; // height of ListScrollBar
		scrollSpeed = 0.01; // scrollSpeed of ListScrollBar

		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa"; // Arrow
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa"; // Arrow when clicked on
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa"; // Slider background (stretched vertically)
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa"; // Dragging element (stretched vertically)

		color[] = {1,1,1,1}; // Scrollbar color
	};
};

class MCC_RscTree
{
	access = 0;
	borderSize = 0;
	colorArrow[] = {1,1,1,1};
	colorBackground[] = {0.07,0.08,0.09,0.95};
	colorBorder[] = {0,0,0,0};
	colorDisabled[] = {1,1,1,0.25};
	colorMarked[] = {0,0.3,0.6,1};
	colorMarkedSelected[] = {0,0.3,0.6,1};
	colorMarkedText[] = {0,0,0,1};
	colorSelect[] = {1,1,1,0.7};
	colorSelectBackground[] = {0,0,0,0.5};
	colorSelectText[] = {0,0,0,1};
	colorText[] = {0.88,0.89,0.90,1};
	expandedTexture = "A3\ui_f\data\gui\rsccommon\rsctree\expandedTexture_ca.paa";
	expandOnDoubleclick = 1;
	font = "RobotoCondensed";
	hiddenTexture = "A3\ui_f\data\gui\rsccommon\rsctree\hiddenTexture_ca.paa";
	maxHistoryDelay = 1;
	multiselectEnabled = 0;
	rowHeight = 0.0439091;
	shadow = 0;
	sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	style = 0;
	type = 12;
	class ScrollBar
		{
			arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
			arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
			autoScrollDelay = 5;
			autoScrollEnabled = 0;
			autoScrollRewind = 0;
			autoScrollSpeed = -1;
			border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
			color[] = {1,1,1,0.6};
			colorActive[] = {1,1,1,1};
			colorDisabled[] = {1,1,1,0.3};
			height = 0;
			scrollSpeed = 0.06;
			shadow = 0;
			thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
			width = 0;
		};
};
class MCC_RscCombo
	{
	access = 0;
	arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa";
	arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
	color[] = {1,1,1,1};
	colorActive[] = {0.77,0.51,0.08,1};
	colorBackground[] = {0.149,0.169,0.188,1};
	colorDisabled[] = {1,1,1,0.25};
	colorScrollbar[] = {0.82,0.42,0.37,1};
	colorSelect[] = {1,1,1,1};
	colorSelectBackground[] = {0.77,0.51,0.08,1};
	colorPictudeDisabled[] = {1,1,1,0.25};
	colorPicture[] = {1,1,1,1};
	colorText[] = {0.88,0.89,0.90,1};
	colorPictureDisabled[] = {1,1,1,1};
	colorPictureSelected[] = {1,1,1,1};
	font = "RobotoCondensed";
	h = 0.035;
	maxHistoryDelay = 1;
	shadow = 0;
	sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
	soundCollapse[] = {"\A3\ui_f\data\sound\RscCombo\soundCollapse",0.1,1};
	soundExpand[] = {"\A3\ui_f\data\sound\RscCombo\soundExpand",0.1,1};
	soundSelect[] = {"\A3\ui_f\data\sound\RscCombo\soundSelect",0.1,1};
	style = "0x10 + 0x200";
	type = 4;
	w = 0.12;
	wholeHeight = 0.45;
	x = 0;
	y = 0;
	class ScrollBar
		{
			arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
			arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
			autoScrollDelay = 5;
			autoScrollEnabled = 0;
			autoScrollRewind = 0;
			autoScrollSpeed = -1;
			border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
			color[] = {1,1,1,0.6};
			colorActive[] = {1,1,1,1};
			colorDisabled[] = {1,1,1,0.3};
			height = 0;
			scrollSpeed = 0.06;
			shadow = 0;
			thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
			width = 0;
		};

	class ComboScrollBar
		{
			arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
			arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
			autoScrollDelay = 5;
			autoScrollEnabled = 0;
			autoScrollRewind = 0;
			autoScrollSpeed = -1;
			border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
			color[] = {1,1,1,0.6};
			colorActive[] = {1,1,1,1};
			colorDisabled[] = {1,1,1,0.3};
			height = 0;
			scrollSpeed = 0.06;
			shadow = 0;
			thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
			width = 0;
		};
	};

class MCC_RscStructuredText
	{
		access = 0;
		idc = -1;
		colorText[] = {1,1,1,1};
		colorBackground[] = {0,0,0,0};
		h = 0.035;
		shadow = 1;
		size = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		style = 0;
		text = "";
		type = 13;
		w = 0.1;
		x = 0;
		y = 0;
		class Attributes
			{
				align = "left";
				color = "#ffffff";
				font = "RobotoCondensed";
				shadow = 1;
			};
	};

class MCC_RscMapControl : RscMapControl
{
	//Everything else - colours, fonts, text sizes, map icons, satellite layer - comes from Arma 3's own map control
	access = 0;
	scaleDefault = 0.16;
	scaleMax = 1;
	scaleMin = 0.001;
	moveOnEdges = 1;
	colorOutside[] = {0.439,0.514,0.620,1};
};

class MCC_RscSlider
	{
		access = 0;
		color[] = {1,1,1,0.8};
		colorActive[] = {1,1,1,1};
		h = 0.025;
		shadow = 0;
		style = MCCCT_SL_HORZ;
		type = 3;
		w = 0.3;
	};

class MCC_RscXSliderH
	{
		arrowEmpty = "\A3\ui_f\data\gui\cfg\slider\arrowEmpty_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\slider\arrowFull_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\slider\border_ca.paa";
		color[] = {1,1,1,0.6};
		colorActive[] = {1,1,1,1};
		colorDisable[] = {1,1,1,0.4};
		colorDisabled[] = {1,1,1,0.2};
		h = 0.029412;
		shadow = 0;
		style = "0x400	+ 0x10";
		thumb = "\A3\ui_f\data\gui\cfg\slider\thumb_ca.paa";
		tooltipColorBox[] = {1,1,1,1};
		tooltipColorShade[] = {0,0,0,0.65};
		tooltipColorText[] = {1,1,1,1};
		type = 43;
		w = 0.4;
		x = 0;
		y = 0;
	};

class MCC_RscPicture
	{
		access = 0;
		colorBackground[] = {0,0,0,0};
		colorText[] = {1,1,1,1};
		fixedWidth = 0;
		font = "RobotoCondensed";
		h = 0.15;
		lineSpacing = 0;
		shadow = 0;
		sizeEx = 0;
		style = 48;
		text = "";
		type = 0;
		w = 0.2;
		x = 0;
		y = 0;
	};

class MCC_RscActivePicture
	{
		access = 0;
		color[] = {1,1,1,0.5};
		colorDisable[] = {1,1,1,1.4};
		colorDisabled[] = {1,1,1,1.2};
		colorActive[] = {1,1,1,1};
		colorText[] = {0,0,0,1};
		default = 0;
		font = "RobotoCondensed";
		h = 0.035;
		idc = -1;
		shadow = 2;
		sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		soundClick[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundClick",0.09,1};
		soundEnter[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEnter",0.09,1};
		soundEscape[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEscape",0.09,1};
		soundPush[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundPush",0.09,1};
		style = 48;
		text = "";
		tooltipColorBox[] = {1,1,1,1};
		tooltipColorShade[] = {0,0,0,0.65};
		tooltipColorText[] = {1,1,1,1};
		type = 11;
		w = 0.035;
		x = 0;
		y = 0;
	};

class MCC_RscFrame
	{
		colorBackground[] = {0,0,0,0};
		colorText[] = {1,1,1,1};
		font = "RobotoCondensed";
		shadow = 2;
		sizeEx = 0.02;
		style = 64;
		text = "";
		type = 0;
	};

class MCC_RscToolbox {
	  type = MCCCT_TOOLBOX;  //defined constant (6)
	  style = MCCST_LEFT; //defined constant (2)
	  x = 0.1;
	  y = 0.2;
	  w = 0.2;
	  h = 0.15;
	  colorText[] = {0.82, 0.42, 0.37, 1};
	  color[] = {0, 1, 0, 1};  //seems nothing to change, but define to avaoid errors
	  colorTextSelect[] = {0.56, 0.75, 0.42, 1};
	  colorSelect[] = {0, 0, 0, 1};
	  colorTextDisable[] = {0.4, 0.4, 0.4, 1};
	  colorDisable[] = {0.4, 0.4, 0.4, 1};
	  colorSelectedBg[] = {0.450,0.450,0.450,1};
	  font = "RobotoCondensed";
	  sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.6)";
};
class MCC_keyBindsGroup: MCC_RscControlsGroup
{
	idc = -1;
	x = 0.29375 * safezoneW + safezoneX;
	y = 0.225 * safezoneH + safezoneY;
	w = 0.216563 * safezoneW;
	h = 0.33 * safezoneH;
	class controls
	{
		class MCC_keyBindsOpenMCCtext: MCC_RscText
		{
			idc = -1;

			text = "Open MCC:"; //--- ToDo: Localize;
			x = 0.00515597 * safezoneW;
			y = 0.044 * safezoneH;
			w = 0.0973958 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindsOpenConsoletext: MCC_RscText
		{
			idc = -1;

			text = "Commander Console:"; //--- ToDo: Localize;
			x = 0.00515625 * safezoneW;
			y = 0.077 * safezoneH;
			w = 0.0973958 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindsOpenT2Ttext: MCC_RscText
		{
			idc = -1;

			text = "Teleport to team:"; //--- ToDo: Localize;
			x = 0.00515597 * safezoneW;
			y = 0.143 * safezoneH;
			w = 0.0973958 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindsOpenGroupstext: MCC_RscText
		{
			idc = -1;

			text = "Squad Dialog:"; //--- ToDo: Localize;
			x = 0.00515597 * safezoneW;
			y = 0.176 * safezoneH;
			w = 0.0973958 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindssSQLPDAtext: MCC_RscText
		{
			idc = -1;

			text = "Squad leader PDA:"; //--- ToDo: Localize;
			x = 0.00515597 * safezoneW;
			y = 0.11 * safezoneH;
			w = 0.0973958 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindsMCCinteractiontext: MCC_RscText
		{
			idc = -1;

			text = "Interaction Key:"; //--- ToDo: Localize;
			x = 0.00515597 * safezoneW;
			y = 0.209 * safezoneH;
			w = 0.0973958 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindsMCCinteractionSelftext: MCC_RscText
		{
			idc = -1;

			text = "Interaction Self:"; //--- ToDo: Localize;
			x = 0.00515597 * safezoneW;
			y = 0.242 * safezoneH;
			w = 0.0973958 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_coverSystemClientText: MCC_RscText
		{
			idc = -1;

			text = "Cover System:"; //--- ToDo: Localize;
			x = 0.00515597 * safezoneW;
			y = 0.275 * safezoneH;
			w = 0.0973958 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindsOpenMCCButton: MCC_RscButton
		{
			idc = 8415;
			tooltip = "Click to change";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onMouseButtonUp =  __EVAL("[_this, 0] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\keyBinds.sqf'");

			x = 0.108281 * safezoneW;
			y = 0.044 * safezoneH;
			w = 0.103125 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindsOpenConsoleButton: MCC_RscButton
		{
			idc = 8416;
			tooltip = "Click to change";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onMouseButtonUp =  __EVAL("[_this,1] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\keyBinds.sqf'");

			x = 0.108281 * safezoneW;
			y = 0.077 * safezoneH;
			w = 0.103125 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindsT2TButton: MCC_RscButton
		{
			idc = 8417;
			tooltip = "Click to change";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onMouseButtonUp =  __EVAL("[_this,2] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\keyBinds.sqf'");

			x = 0.108281 * safezoneW;
			y = 0.143 * safezoneH;
			w = 0.103125 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindsGroupsButton: MCC_RscButton
		{
			idc = 8418;
			tooltip = "Click to change";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onMouseButtonUp =  __EVAL("[_this,3] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\keyBinds.sqf'");

			x = 0.108281 * safezoneW;
			y = 0.176 * safezoneH;
			w = 0.103125 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		class MCC_keyBindsMCCinteractionButton: MCC_RscButton
		{
			idc = 8419;
			tooltip = "Click to change";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onMouseButtonUp =  __EVAL("[_this,4] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\keyBinds.sqf'");

			x = 0.108281 * safezoneW;
			y = 0.209 * safezoneH;
			w = 0.103125 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindssSQLPDAButton: MCC_RscButton
		{
			idc = 8420;
			tooltip = "Click to change";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onMouseButtonUp =  __EVAL("[_this,5] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\keyBinds.sqf'");

			x = 0.108281 * safezoneW;
			y = 0.11 * safezoneH;
			w = 0.103125 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_keyBindsMCCinteractionSelfButton: MCC_RscButton
		{
			idc = 8421;
			tooltip = "Click to change";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onMouseButtonUp =  __EVAL("[_this,6] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\keyBinds.sqf'");

			x = 0.108281 * safezoneW;
			y = 0.242 * safezoneH;
			w = 0.103125 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_coverSystemClientButton: MCC_RscButton
		{
			idc = 8499;
			tooltip = "Click to disable client side";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			text = "Disabled"; //--- ToDo: Localize;
			onMouseButtonUp =  __EVAL("[_this,7] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\keyBinds.sqf'");

			x = 0.108281 * safezoneW;
			y = 0.275 * safezoneH;
			w = 0.103125 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
	};
};
// Credit to ACE 3 for buttonbase
class MCC_gui_buttonBase {
  idc = -1;
  type = 16;
  style = ST_LEFT;
  text = "";
  action = "";
  x = 0.0;
  y = 0.0;
  w = 0.25;
  h = 0.04;
  size = 0.03921;
  sizeEx = 0.03921;
  color[] = {1.0, 1.0, 1.0, 1};
  color2[] = {1.0, 1.0, 1.0, 1};
  colorBackground[] = {1,1,1,0.95};
  colorbackground2[] = {1,1,1,0.95};
  colorDisabled[] = {1,1,1,0.6};
  colorFocused[] = {1,1,1,1};
  colorBackgroundFocused[] = {1,1,1,1};
  periodFocus = 1.2;
  periodOver = 0.8;
  default = false;
  class HitZone {
    left = 0.00;
    top = 0.00;
    right = 0.00;
    bottom = 0.00;
  };

  class ShortcutPos {
    left = 0.00;
    top = 0.00;
    w = 0.00;
    h = 0.00;
  };

  class TextPos {
    left = 0.002;
    top = 0.0004;
    right = 0.0;
    bottom = 0.00;
  };
  textureNoShortcut = "";
  animTextureNormal = "#(argb,8,8,3)color(0,0,0,0.9)";
  animTextureDisabled = "#(argb,8,8,3)color(0,0,0,0.8)";
  animTextureOver = "#(argb,8,8,3)color(1,1,1,1)";
  animTextureFocused = "#(argb,8,8,3)color(1,1,1,1)";
  animTexturePressed = "#(argb,8,8,3)color(1,1,1,1)";
  animTextureDefault = "#(argb,8,8,3)color(1,1,1,1)";
  period = 0.5;
  font = FontCSE;
  soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick",0.09,1};
  soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush",0.0,0};
  soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter",0.07,1};
  soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape",0.09,1};
  class Attributes {
    font = FontCSE;
    color = "#E5E5E5";
    align = "center";
    shadow = "true";
  };
  class AttributesImage {
    font = FontCSE;
    color = "#E5E5E5";
    align = "left";
    shadow = "true";
  };
};
