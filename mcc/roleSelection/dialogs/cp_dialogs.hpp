#define FontHTML "Bitstream"
// Constants to standardize and help simplify positioning and sizing
#define CPDlg_ROWS 36 // determines default text and control height
#define CPDlg_COLS 90 // guide for positioning controls

#define CPDlg_CONTROLHGT ((100/CPDlg_ROWS)/100)
#define CPDlg_COLWIDTH ((100/CPDlg_COLS)/100)

// modifiers
#define CPCPDlg_TEXTHGT_MOD 0.9
#define CPDlg_ROWSPACING_MOD 1.3

#define CPDlg_ROWHGT (CPDlg_CONTROLHGT*CPDlg_ROWSPACING_MOD)
#define CPDlg_TEXTHGT (CPDlg_CONTROLHGT*CPCPDlg_TEXTHGT_MOD)

//-----------------------------------------------------------------------------
// Fonts
#define CPFontM "RobotoCondensed"
#define CPFontHTML "RobotoCondensed"
//"CourierNewB64" "TahomaB" "Bitstream" "Zeppelin32"

//-----------------------------------------------------------------------------
// Control Types
#define CPCT_STATIC 0
#define CPCT_BUTTON 1
#define CPCT_EDIT 2
#define CPCT_SLIDER 3
#define CPCT_COMBO 4
#define CPCT_LISTBOX 5
#define CPCT_TOOLBOX 6
#define CPCT_CHECKBOXES 7
#define CPCT_PROGRESS 8
#define CPCT_HTML 9
#define CPCT_STATIC_SKEW 10
#define CPCT_ACTIVETEXT 11
#define CPCT_TREE 12
#define CPCT_STRUCTURED_TEXT 13
#define CPCT_CONTEXT_MENU 14
#define CPCT_CONTROLS_GROUP 15

#define CPCT_XKEYDESC 40
#define CPCT_XBUTTON 41
#define CPCT_XLISTBOX 42
#define CPCT_XSLIDER 43
#define CPCT_XCOMBO 44
#define CPCT_ANIMATED_TEXTURE 45

#define CPCT_OBJECT 80
#define CPCT_OBJECT_ZOOM 81
#define CPCT_OBJECT_CONTAINER 82
#define CPCT_OBJECT_CONT_ANIM 83

#define CPCT_LINEBREAK 98
#define CPCT_USER 99
#define CPCT_MAP 100
#define CPCT_MAP_MAIN 101

#define CPCT_SL_DIR 0x400
#define CPCT_SL_VERT 0
#define CPCT_SL_HORZ 0x400

//-----------------------------------------------------------------------------
// Static styles
#define CPST_POS 0x0F
#define CPST_HPOS 0x03
#define CPST_VPOS 0x0C

#define CPST_LEFT 0x00
#define CPST_RIGHT 0x01
#define CPST_CENTER 0x02
#define CPST_DOWN 0x04
#define CPST_UP 0x08

#define CPST_VCENTER 0x0c
#define CPST_TYPE 0xF0

#define CPST_SINGLE 0
#define CPST_MULTI 16
#define CPST_TITLE_BAR 32
#define CPST_PICTURE 48
#define CPST_FRAME 64
#define CPST_BACKGROUND 80
#define CPST_GROUP_BOX 96
#define CPST_GROUP_BOX2 112
#define CPST_HUD_BACKGROUND 128
#define CPST_TILE_PICTURE 144
#define CPST_WITH_RECT 160
#define CPST_LINE 176
#define CPLB_MULTI 0x20
#define CPSL_VERT 0

//-----------------------------------------------------------------------------
// standard base dialog control class definitions
//-----------------------------------------------------------------------------
class CP_RscText
{
  access = 0;
  type = 0;
  style = 0;
  colorBackground[] = {0,0,0,0};
  colorDisabled[] = {0,0,0,0.5};
  colorShadow[] = {0,0,0,0.5};
  colorText[] = {1,1,1,1};
  autocomplete = "";
  colorSelection[] = {0.82,0.42,0.37,1};
  fixedWidth = 0;
  font = CPFontM;
  h = 0.037;
  linespacing = 1;
  shadow = 1;
  SizeEx = "(((((safezoneW/safezoneH) min 1.2) / 1.2) / 25) * 1)";
  text = "";
  w = 0.3;
  x = 0.0;
  y = 0.0;
};
//----------------------------------------------------------

class CP_RscButton
{
	style = 2;
	x = 0;
	y = 0;
	w = 0.095589;
	h = 0.039216;
	shadow = 2;
	font = "RobotoCondensed";
	size = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	colorText[] = {1, 1, 1, 1.0};
	colorDisabled[] = {0.4, 0.4, 0.4, 1};
	colorBackground[] = {0.4, 0.4, 0.4, 1};
	colorBackgroundActive[] = {0.5, 0.5, 0.5, 1};
	colorBackgroundDisabled[] = {0.3, 0.3, 0.3, 1};
	offsetX = 0.003;
	offsetY = 0.003;
	offsetPressedX = 0.002;
	offsetPressedY = 0.002;
	colorFocused[] = {0.4, 0.4, 0.4, 1};
	colorShadow[] = {0, 0, 0, 1};
	colorBorder[] = {0, 0, 0, 1};
	borderSize = 0.0;
	soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1};
	soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1};
	type = 1;
	text = "";
};

class CP_RscButtonMenu
{
	idc = -1;
	style = 2;
	default = 0;
	shadow = 1;
	w = 0.183825;
	h = "(		(		((safezoneW / safezoneH) min 1.2) / 1.2) / 20)";
	color[] = {1, 1, 1, 1.0};
	color2[] = {0.95, 0.95, 0.95, 1};
	colorDisabled[] = {1, 1, 1, 0.25};
	colorBackground[] = {0.4, 0.4, 0.4, 1};
	colorBackgroundFocused[] = {1,1,1,1};
	colorBackground2[] = {0.5, 0.5, 0.5, 1};
	colorBackgroundActive[] = {0.5, 0.5, 0.5, 1};
	colorBackgroundDisabled[] = {0.3, 0.3, 0.3, 1};
	colorFocused[] = {0.4, 0.4, 0.4, 1};
	colorFocusedSecondary[] = {0,0,0,1};
	colorShadow[] = {0, 0, 0, 1};
	colorBorder[] = {0, 0, 0, 1};
	animTextureDefault = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
	animTextureNormal = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
	animTextureDisabled = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\normal_ca.paa";
	animTextureOver = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\over_ca.paa";
	animTextureFocused = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\focus_ca.paa";
	animTexturePressed = "\A3\ui_f\data\GUI\RscCommon\RscShortcutButton\down_ca.paa";
	periodFocus = 1.2;
	periodOver = 0.8;
	type = 16;
	textureNoShortcut = "#(argb,8,8,3)color(0,0,0,0)";
	period = 0.4;
	font = "RobotoCondensed";
	size = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	text = "";
	soundEnter[] = {"\A3\ui_f\data\sound\RscButton\soundEnter", 0.09, 1};
	soundPush[] = {"\A3\ui_f\data\sound\RscButton\soundPush", 0.09, 1};
	soundClick[] = {"\A3\ui_f\data\sound\RscButton\soundClick", 0.09, 1};
	soundEscape[] = {"\A3\ui_f\data\sound\RscButton\soundEscape", 0.09, 1};
	action = "";

	class Attributes {
		font = "RobotoCondensed";
		color = "#E5E5E5";
		align = "left";
		shadow = "true";
	};

	class AttributesImage {
		font = "RobotoCondensed";
		color = "#E5E5E5";
		align = "left";
	};
	class HitZone {
		left = 0.0;
		top = 0.0;
		right = 0.0;
		bottom = 0.0;
	};

	class ShortcutPos {
		left = 0;
		top = "(			(		(		((safezoneW / safezoneH) min 1.2) / 1.2) / 20) - 		(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)) / 2";
		w = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1) * (3/4)";
		h = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
	};
	class TextPos {
		left = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1) * (3/4)";
		top = "(			(		(		((safezoneW / safezoneH) min 1.2) / 1.2) / 20) - 		(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)) / 2";
		right = 0.005;
		bottom = 0.0;
	};
};

class CP_RscListbox
	{
	access = 0;
	arrowEmpty = "#(argb,8,8,3)color(1,1,1,1)";
	arrowFull = "#(argb,8,8,3)color(1,1,1,1)";
	autoScrollDelay = 5;
	autoScrollRewind = 0;
	autoScrollSpeed = -1;
	color[] = {1,1,1,1};
	colorBackground[] = {0,0,0,0.3};
	colorDisabled[] = {1,1,1,0.25};
	colorScrollbar[] = {1,0,0,0};
	colorSelect2[] = {0,0,0,1};
	colorSelect[] = {0,0,0,1};
	colorSelectBackground2[] = {1,1,1,0.5};
	colorSelectBackground[] = {0.95,0.95,0.95,1};
	colorShadow[] = {0,0,0,0.5};
	colorText[] = {1,1,1,1};
	font = "RobotoCondensed";
	h = 0.4;
	maxHistoryDelay = 1;
	period = 1.2;
	rowHeight = 0;
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
			border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
			color[] = {1,1,1,0.6};
			colorActive[] = {1,1,1,1};
			colorDisabled[] = {1,1,1,0.3};
			shadow = 0;
			thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		};
	};

class CP_RscCombo
	{
	access = 0;
	arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa";
	arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
	color[] = {1,1,1,1};
	colorActive[] = {1,0,0,1};
	colorBackground[] = {0,0,0,1};
	colorDisabled[] = {1,1,1,0.25};
	colorScrollbar[] = {0.82,0.42,0.37,1};
	colorSelect[] = {0,0,0,1};
	colorSelectBackground[] = {1,1,1,0.7};
	colorPictudeDisabled[] = {1,1,1,0.25};
	colorPicture[] = {1,1,1,1};
	colorText[] = {0.95,0.95,0.95,1};
	colorPictureDisabled[] = {1,1,1,1};
	colorPictureSelected[] = {1,1,1,1};
	font = "RobotoCondensed";
	h = 0.035;
	maxHistoryDelay = 1;
	shadow = 0;
	sizeEx = "(			(			(			((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
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
			border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
			color[] = {1,1,1,0.6};
			colorActive[] = {1,1,1,1};
			colorDisabled[] = {1,1,1,0.3};
			shadow = 0;
			thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
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

class CP_RscStructuredText
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

class CP_RscMapControl : RscMapControl
{
	//Everything else - colours, fonts, text sizes, map icons, satellite layer - comes from Arma 3's own map control
	access = 0;
	scaleDefault = 0.16;
	scaleMax = 1;
	scaleMin = 0.001;
	moveOnEdges = 1;
};

class CP_RscSlider
	{
		access = 0;
		color[] = {1,1,1,0.8};
		colorActive[] = {1,1,1,1};
		h = 0.025;
		shadow = 0;
		style = CPCT_SL_HORZ;
		type = 3;
		w = 0.3;
	};

class CP_RscPicture
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

class CP_RscFrame
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

class CP_RscToolbox {
	  type = CPCT_TOOLBOX;  //defined constant (6)
	  style = CPST_LEFT; //defined constant (2)
	  x = 0.1;
	  y = 0.2;
	  w = 0.2;
	  h = 0.15;
	  colorText[] = {1, 0, 0, 1};
	  color[] = {0, 1, 0, 1};  //seems nothing to change, but define to avaoid errors
	  colorTextSelect[] = {0, 0.8, 0, 1};
	  colorSelect[] = {0, 0, 0, 1};
	  colorTextDisable[] = {0.4, 0.4, 0.4, 1};
	  colorDisable[] = {0.4, 0.4, 0.4, 1};
	  colorSelectedBg[] = {"(profilenamespace getvariable ['GUI_BCG_RGB_R',0.69])","(profilenamespace getvariable ['GUI_BCG_RGB_G',0.75])","(profilenamespace getvariable ['GUI_BCG_RGB_B',0.5])",0.5};
	  font = "RobotoCondensed";
	  sizeEx = 0.0208333;
};
