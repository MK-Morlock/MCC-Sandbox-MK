// Made By: Shay_gman
// Version: 1.1 (February 2011)

//-----------------------------------------------------------------------------
// IDD's & IDC's
//-----------------------------------------------------------------------------
#define MCC3D_IDD 8000
#define MCC_FACTION 8008
#define MCC_UNIT_TYPE 8001
#define MCC_UNIT_CLASS 8002
#define MCC_NAMEBOX 8003
#define MCC_INITBOX 8004
#define MCC_PRESETS 8005
#define MCC_SETTING_EMPTY 8006
#define MCC_ZONE_LOC 8007

#define MCC3DOpenCompIDC 8010

//-----------------------------------------------------------------------------
// Main dialog
//-----------------------------------------------------------------------------
class MCCDLG_NAME
{
	idd = MCC3D_IDD;
	movingEnable = false;
	onLoad = __EVAL("_this execVM '"+MCCPATH+"mcc\dialogs\mcc_3d_init.sqf'");
	onKeyDown = "if ((_this select 1) == 57) exitWith {closeDialog 0; [] spawn {sleep 0.05; if (!isNil 'MCC_3D_place') then {[] call MCC_3D_place}}; true}; if (((_this select 1) == 45) && {!(_this select 3)}) exitWith {closeDialog 0; true}; false";

	controlsBackground[] =
	{
		MCC_Bckgrnd,		//mcc background
		nameBackground,
		initBackground
	};


	//---------------------------------------------
	objects[] =
	{
	};

	class controls
	{
		 //========================================= Controls========================================
		//-------------------------------------------ComboBox----------------------------------------
		class faction : MCC_RscCombo
		{
			idc=MCC_FACTION;
			style=MCCST_LEFT;
			colorText[]={1,1,1,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";

			x = 0.053125 * safezoneW + safezoneX;
			y = 0.0491758 * safezoneH + safezoneY;
			w = 0.120313 * safezoneW;
			h = 0.0219914 * safezoneH;
			onLBSelChanged = __EVAL("[1] execVM '"+MCCPATH+"mcc\pop_menu\faction.sqf'");
		};
		class factionSearch : MCC_RscText
		{
			idc = 8031;
			type = MCCCT_EDIT;
			style = MCCST_MULTI;
			colorBackground[] = {0,0,0,0};
			colorText[] = {0.88,0.89,0.90,1};
			colorSelection[] = {1,1,1,1};
			colorBorder[] = { 1, 1, 1, 1 };
			BorderSize = 0.01;
			autocomplete = false;
			tooltip = "Type to find a faction";
			onKeyUp = __EVAL("[0] execVM '"+MCCPATH+"mcc\dialogs\mcc_3d_factionSearch.sqf'");
			x = 0.053125 * safezoneW + safezoneX;
			y = 0.0821629 * safezoneH + safezoneY;
			w = 0.085 * safezoneW;
			h = 0.0219914 * safezoneH;
			sizeEx = 0.028;
			text = "";
		};
		class factionSearchReset : MCCBTN_S
		{
			idc = -1;
			text = "Reset";
			tooltip = "Clear the search and go back to the previous faction";
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\dialogs\mcc_3d_factionSearch.sqf'");
			x = 0.1406 * safezoneW + safezoneX;
			y = 0.0821629 * safezoneH + safezoneY;
			w = 0.0328 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class factionSearchTitle : MCC_RscText
		{
			idc = -1;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00156247 * safezoneW + safezoneX;
			y = 0.0821629 * safezoneH + safezoneY;
			w = 0.0458333 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "Search";
		};
		class MCC3DSpawnButton: MCCBTN_R
		{
			idc = -1;
			text = "Spawn";
			tooltip = "Attach the selected object to the cursor again, ready to place";
			onButtonClick = __EVAL("[] execVM '"+MCCPATH+"mcc\dialogs\mcc_3d_spawnButton.sqf'");
			x = 0.107708 * safezoneW + safezoneX;
			y = 0.459000 * safezoneH + safezoneY;
			w = 0.0714583 * safezoneW;
			h = 0.03 * safezoneH;
			class TextPos {left = 0; top = "((0.03 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};
		};


		class unit_type : MCC_RscCombo
		{
			idc=MCC_UNIT_TYPE;
			x = 0.053125 * safezoneW + safezoneX;
			y = 0.115163 * safezoneH + safezoneY;
			w = 0.120313 * safezoneW;
			h = 0.0219914 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onLBSelChanged=__EVAL("[0] execVM '"+MCCPATH+"mcc\pop_menu\group_change3d.sqf'");
		};

		class unit_Class : MCC_RscCombo
		{
			idc=MCC_UNIT_CLASS;
			x = 0.053125 * safezoneW + safezoneX;
			y = 0.148150 * safezoneH + safezoneY;
			w = 0.120313 * safezoneW;
			h = 0.0219914 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onLBSelChanged=__EVAL("[1] execVM '"+MCCPATH+"mcc\pop_menu\spawn_group3d.sqf'");
		};

		class setting_Empty : MCC_RscCombo
		{
			idc=MCC_SETTING_EMPTY;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.053125 * safezoneW + safezoneX;
			y = 0.181137 * safezoneH + safezoneY;
			w = 0.120313 * safezoneW;
			h = 0.0219914 * safezoneH;
			onLBSelChanged=__EVAL("[1] execVM '"+MCCPATH+"mcc\pop_menu\spawn_group3d.sqf'");
		};
		class behaviour3D : MCC_RscCombo
		{
			idc = 8034;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			tooltip = "What placed soldiers, crews and groups do when they spawn";
			onLBSelChanged = "MCC_3D_beh = (_this select 0) lbData (_this select 1); if (!isNil 'MCC_3D_panel') then {[] call MCC_3D_panel};";
			x = 0.053125 * safezoneW + safezoneX;
			y = 0.214 * safezoneH + safezoneY;
			w = 0.120313 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class commandable3D : MCC_RscCombo
		{
			idc = 8035;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			tooltip = "Yes: can be commanded from the Commander Console and RTS, and counts towards food and bunks";
			onLBSelChanged = "MCC_3D_cmd = ((_this select 1) == 1); if (!isNil 'MCC_3D_panel') then {[] call MCC_3D_panel};";
			x = 0.053125 * safezoneW + safezoneX;
			y = 0.247 * safezoneH + safezoneY;
			w = 0.120313 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class behaviour3DTitle : MCC_RscText
		{
			idc = -1;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00156247 * safezoneW + safezoneX;
			y = 0.214 * safezoneH + safezoneY;
			w = 0.0458333 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "Behaviour";
		};
		class commandable3DTitle : MCC_RscText
		{
			idc = -1;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00156247 * safezoneW + safezoneX;
			y = 0.247 * safezoneH + safezoneY;
			w = 0.0458333 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "Commandable";
		};


		class nameBox : MCC_RscText
		{
			idc = MCC_NAMEBOX;
			type = MCCCT_EDIT;
			style = MCCST_MULTI;
			colorBackground[] = {0,0,0,0};
			colorText[] = {0.88,0.89,0.90,1};
			colorSelection[] = {1,1,1,1};
			colorBorder[] = { 1, 1, 1, 1 };
			BorderSize = 0.01;
			autocomplete = true;

			x = 0.053125 * safezoneW + safezoneX;
			y = 0.280124 * safezoneH + safezoneY;
			w = 0.120313 * safezoneW;
			h = 0.0219914 * safezoneH;
			sizeEx = 0.028;text = "";
		};

		class initBox : MCC_RscText
		{
			idc = MCC_INITBOX;
			type = MCCCT_EDIT;
			style = MCCST_MULTI;
			colorBackground[] = {0,0,0,0};
			colorText[] = {0.88,0.89,0.90,1};
			colorSelection[] = {1,1,1,1};
			colorBorder[] = { 1, 1, 1, 1 };
			BorderSize = 0.01;
			autocomplete = true;

			x = 0.053125 * safezoneW + safezoneX;
			y = 0.324107 * safezoneH + safezoneY;
			w = 0.120313 * safezoneW;
			h = 0.0549786 * safezoneH;
			sizeEx = 0.028;
			text = "";
		};

		class presetsCombo : MCC_RscCombo
		{
			idc=MCC_PRESETS;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.053125 * safezoneW + safezoneX;
			y = 0.390081 * safezoneH + safezoneY;
			w = 0.0916667 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		//-------------------------------------------Titels-----------------------------------------
		class factionTittle : MCC_RscText
		{
			idc = -1;
			style=MCCST_LEFT;
			colorBackground[]={1,1,1,0};
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00156247 * safezoneW + safezoneX;
			y = 0.0491758 * safezoneH + safezoneY;
			w = 0.0458333 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "Faction";
		};

		class mcc3DTitle : MCC_RscText
		{
			idc = -1;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00729163 * safezoneW + safezoneX;
			y = 0.00519296 * safezoneH + safezoneY;
			w = 0.0859375 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "MCC 3D Editor";
		};

		class UnitTitle : MCC_RscText
		{
			idc = -1;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00156247 * safezoneW + safezoneX;
			y = 0.115163 * safezoneH + safezoneY;
			w = 0.0458333 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "Type";
		};

		class UnitTypeTitle : MCC_RscText
		{
			idc = -1;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00156247 * safezoneW + safezoneX;
			y = 0.148150 * safezoneH + safezoneY;
			w = 0.0458333 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "Class";
		};
		class EmptyTitle : MCC_RscText
		{
			idc = -1;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00156247 * safezoneW + safezoneX;
			y = 0.181137 * safezoneH + safezoneY;
			w = 0.0458333 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "Empty";
		};
		class unitNameTitle : MCC_RscText
		{
			idc = -1;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00156247 * safezoneW + safezoneX;
			y = 0.280124 * safezoneH + safezoneY;
			w = 0.0458333 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "Name";
		};

		class initTitle : MCC_RscText
		{
			idc = -1;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00156247 * safezoneW + safezoneX;
			y = 0.324107 * safezoneH + safezoneY;
			w = 0.0401042 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "Init";
		};

		class presetsTitle : MCC_RscText
		{
			idc = -1;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00156247 * safezoneW + safezoneX;
			y = 0.390081 * safezoneH + safezoneY;
			w = 0.0458333 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "Presets";
		};

		class Zone_LocTitle : MCC_RscText
		{
			idc = -1;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.00156247 * safezoneW + safezoneX;
			y = 0.423069 * safezoneH + safezoneY;
			w = 0.0458333 * safezoneW;
			h = 0.0219914 * safezoneH;
			text = "Spawn";
		};

		//-------------------------------------------Buttons----------------------------------------
		class Zone_Loc : MCC_RscCombo
		{
			idc=MCC_ZONE_LOC;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.053125 * safezoneW + safezoneX;
			y = 0.423069 * safezoneH + safezoneY;
			w = 0.108854 * safezoneW;
			h = 0.0219914 * safezoneH;
		};

		class addPresetButton: MCCBTN_S
		{
			idc=-1; colorDisabled[]={1,0.4,0.3,0.8};
			x = 0.150521 * safezoneW + safezoneX;
			y = 0.390081 * safezoneH + safezoneY;
			w = 0.0286458 * safezoneW;
			h = 0.0219914 * safezoneH;

			text="Add";
			onButtonClick=__EVAL("[2] execVM '"+MCCPATH+"mcc\pop_menu\spawn_group3d.sqf'");
		};

		class MCC3DOpenComp: MCCBTN_R
		{
			idc = MCC3DOpenCompIDC;
			onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\general_scripts\docobject\compositionManager.sqf'");
			tooltip = "Open DOC Generator";

			text = "DOC -->"; //--- ToDo: Localize;
			x = 0.107708 * safezoneW + safezoneX;
			y = 0.529000 * safezoneH + safezoneY;
			w = 0.0714583 * safezoneW;
			h = 0.03 * safezoneH;
			class TextPos {left = 0; top = "((0.03 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};

		class MCC3DOpenCargo: MCCBTN_R
		{
			idc = -1;
			onButtonClick = __EVAL("_this execVM '"+MCCPATH+"mcc\general_scripts\boxGen\mcc_boxGen_init.sqf'");
			tooltip = "Open Cargo Generator";

			text = "Cargo -->"; //--- ToDo: Localize;
			x = 0.107708 * safezoneW + safezoneX;
			y = 0.564000 * safezoneH + safezoneY;
			w = 0.0714583 * safezoneW;
			h = 0.03 * safezoneH;
			class TextPos {left = 0; top = "((0.03 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};

		#include "mcc_boxGen.hpp"
		#include "mcc_3dDOC.hpp"


		//---------------------- new ---------------------

		class MCC_3DCompassMapBackground : MCC_RscText
		{
			idc = -1;

			x = 0.78073 * safezoneW + safezoneX;
			y = 0.719914 * safezoneH + safezoneY;
			w = 0.223438 * safezoneW;
			h = 0.285889 * safezoneH;

			colorBackground[] = { 1, 1, 1, 1};
			colorText[] = { 1, 1, 1, 0};
			text = "";
		};

		class MCC_3DCompassMap: MCC_RscMapControl
		{
			idc = 0;
			onMouseButtonDblClick =  __EVAL("[_this,1] execVM '"+MCCPATH+"mcc\general_scripts\3Deditor\mouseDown.sqf'");

			x = 0.78073 * safezoneW + safezoneX;
			y = 0.719914 * safezoneH + safezoneY;
			w = 0.223438 * safezoneW;
			h = 0.285889 * safezoneH;
		};

		class MCC3DOpenCurator: MCCBTN_R
		{
			idc = -1;
			onButtonClick = __EVAL("_this execVM '"+MCCPATH+"mcc\general_scripts\3Deditor\openZeus.sqf'");
			tooltip = "Open Zeus";

			text = "Zeus"; //--- ToDo: Localize;
			x = 0.107708 * safezoneW + safezoneX;
			y = 0.900 * safezoneH + safezoneY;
			w = 0.0714583 * safezoneW;
			h = 0.03 * safezoneH;
			class TextPos {left = 0; top = "((0.03 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};

		class MCC_3DClose: MCCBTN_R
		{
			idc = -1;
			text = "Close";
			action = "closeDialog 0";
			x = 0.107708 * safezoneW + safezoneX;
			y = 0.940 * safezoneH + safezoneY;
			w = 0.0714583 * safezoneW;
			h = 0.03 * safezoneH;
			class TextPos {left = 0; top = "((0.03 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
	};

	//========================================= Background======================================
	class MCC_Bckgrnd : MCC_RscText {idc = -1;
		x = -0.00416669 * safezoneW + safezoneX;
		y = -0.00580276 * safezoneH + safezoneY;
		w = 0.194792 * safezoneW;
		h = 1.01161 * safezoneH;
		text = "";colorBackground[] = {0,0,0,0.7};};
	class nameBackground : MCC_RscText {idc = -1;moving = true;colorBackground[] = { 0, 0, 0, 1 };colorText[] = { 1, 1, 1, 0 };
		x = 0.053125 * safezoneW + safezoneX;
		y = 0.324107 * safezoneH + safezoneY;
		w = 0.120313 * safezoneW;
		h = 0.0549786 * safezoneH;
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		text = "";};
	class initBackground : MCC_RscText {idc = -1;
		x = 0.053125 * safezoneW + safezoneX;
		y = 0.324107 * safezoneH + safezoneY;
		w = 0.120313 * safezoneW;
		h = 0.0549786 * safezoneH;
		sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		text = "";};
};