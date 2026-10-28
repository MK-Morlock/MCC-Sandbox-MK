// By: Ollem
// Version: 1.0 (February 2013)
#define MCC_SaveLoadScreen_IDD 7000
#define MCC_SAVE_LIST 7010
#define MCC_SAVE_DIS 7011
#define MCC_SAVE_NAME 7012
#define MCC_SAVE_PERSISTENT 7013

#define MCC_LOAD_INPUT 7001

#define MCCST_CENTER 0x02
#define MCCST_MULTI 16
#define MCCCT_EDIT 2

//-----------------------------------------------------------------------------
// Main dialog
//-----------------------------------------------------------------------------
class MCCDLG_NAME
{
	idd = MCC_SaveLoadScreen_IDD;
	movingEnable = true;
	onLoad = __EVAL("_this execVM '"+MCCPATH+"mcc\dialogs\MCC_SaveLoadScreenInit.sqf'");

	class controlsBackground 	{
		class MCC_SaveLoadBackground: MCC_RscText
		{
			idc = -1;
			moving = true;
			x = 0.276563 * safezoneW + safezoneX;
			y = 0.247099 * safezoneH + safezoneY;
			w = 0.446875 * safezoneW;
			h = 0.516798 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
		};
	};


	//---------------------------------------------
	objects[] =
	{
	};

	class controls {
		//========================================= Input ========================================
		class MCC_SaveLoadHeader: MCC_RscText
		{
			style = MCCST_CENTER;
			idc = -1;
			text = "Save / Load MCC configuration";
			x = 0.276563 * safezoneW + safezoneX;
			y = 0.247099 * safezoneH + safezoneY;
			w = 0.446875 * safezoneW;
			h = 0.0439828 * safezoneH;
			colorBackground[] = {0,0,0,0.5};
		};

		class MCC_LoadHeader: MCC_RscText
		{
			idc = -1;
			text = "Paste (crtl-v) MCC configuration code here:";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.283437 * safezoneW + safezoneX;
			y = 0.434 * safezoneH + safezoneY;
			w = 0.221719 * safezoneW;
			h = 0.033 * safezoneH;
			colorText[] = {0.88,0.89,0.90,1};
			colorBackground[] = {1,0,1,0};
		};

		//========================================= Text Input Box =========================================
		//class MCC_LoadInput : MCC_RscText {idc = MCC_LOAD_INPUT;type = MCCCT_EDIT;style = MCCST_MULTI;colorBackground[] = { 0, 0, 0, 0 };colorText[] = { 1, 1, 1, 1 };colorSelection[] = { 1, 1, 1, 1 };colorBorder[] = { 1, 1, 1, 1 };BorderSize = 0.01;autocomplete = false;x = 0.5; y = 0.275;w = 0.4; h = 0.04;sizeEx = 0.03;text = "";};

		class MCC_LoadFrame: MCC_RscText
		{
			idc = MCC_LOAD_INPUT;
			text = "";
			type = MCCCT_EDIT;
			style = MCCST_MULTI;
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.288021 * safezoneW + safezoneX;
			y = 0.302077 * safezoneH + safezoneY;
			w = 0.429688 * safezoneW;
			h = 0.142944 * safezoneH;
			colorSelection[] = { 1, 1, 1, 1 };
			colorDisabled[] = { 0, 0, 0, 1 };
			autocomplete = false;
			access = ReadAndWrite;
		};

		//========================================= Buttons ========================================
		class MCC_SaveButton: MCCBTN_R		//Save to clipboard
		{
			idc = 0;
			text = "Save To Clipboard";
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.283437 * safezoneW + safezoneX;
			y = 0.467 * safezoneH + safezoneY;
			w = 0.103125 * safezoneW;
			h = 0.032987 * safezoneH;
			tooltip = "Save the current MCC configuration to the clipboard";
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\mcc_loadConfig.sqf'");
		};

		class MCC_LoadButton: MCCBTN_R		//Load from clipboard
		{
			idc = -1;
			text = "Load From Clipboard";
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			x = 0.396875 * safezoneW + safezoneX;
			y = 0.467 * safezoneH + safezoneY;
			w = 0.108854 * safezoneW;
			h = 0.032987 * safezoneH;
			tooltip = "Paste the MCC mission configuration code from the clipboard (Ctrl+V) into the text box first";
			onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\mcc_loadConfig.sqf'");
		};

		class MCC_CancelButton: MCCBTN_R	//Close dialog
		{
			idc = -1;
			text = "Close";
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			x = 0.288000 * safezoneW + safezoneX;
			y = 0.719914 * safezoneH + safezoneY;
			w = 0.0802083 * safezoneW;
			h = 0.0329871 * safezoneH;
			onButtonClick = "closeDialog 0;";
		};

		class MCC_saveList: MCC_RscListBox	//List of all the save slots
		{
			idc = MCC_SAVE_LIST;
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			x = 0.282292 * safezoneW + safezoneX;
			y = 0.510996 * safezoneH + safezoneY;
			w = 0.20625 * safezoneW;
			h = 0.15394 * safezoneH;
			onLBSelChanged = __EVAL("[3] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\mcc_loadConfig.sqf'");
		};

		class MCC_saveDescription: MCC_RscText	//Description fo the saved mission
		{
			idc = MCC_SAVE_DIS;
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			x = 0.5 * safezoneW + safezoneX;
			y = 0.510996 * safezoneH + safezoneY;
			w = 0.217708 * safezoneW;
			h = 0.15394 * safezoneH;
			text = "";
			type = MCCCT_EDIT;
			style = MCCST_MULTI;
			autocomplete = false;
			access = ReadAndWrite;
		};

		class MCC_saveName: MCC_RscText	//Name of the saved mission
		{
			idc = MCC_SAVE_NAME;
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			x = 0.342604 * safezoneW + safezoneX;
			y = 0.675931 * safezoneH + safezoneY;
			w = 0.103125 * safezoneW;
			h = 0.0329871 * safezoneH;
			text = "";
			type = MCCCT_EDIT;
			style = MCCST_MULTI;
			autocomplete = false;
			access = ReadAndWrite;
		};

		class MCC_saveNameTittle: MCC_RscText
		{
			idc = -1;
			text = "Save Name"; //--- ToDo: Localize;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.288021 * safezoneW + safezoneX;
			y = 0.675931 * safezoneH + safezoneY;
			w = 0.06875 * safezoneW;
			h = 0.0329871 * safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
		};

		class MCC_saveUIButton: MCCBTN_R	//Save to UI
		{
			idc = -1;
			onButtonClick = __EVAL("[2] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\mcc_loadConfig.sqf'");
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			tooltip = "Save a mission to the profile namespace - choose a slot from the list above first";
			text = "Save To Profile"; //--- ToDo: Localize;
			x = 0.5 * safezoneW + safezoneX;
			y = 0.675931 * safezoneH + safezoneY;
			w = 0.103125 * safezoneW;
			h = 0.0329871 * safezoneH;
		};

		class MCC_loadUIButton: MCCBTN_R	//Load from UI
		{
			idc = -1;
			onButtonClick = __EVAL("[4] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\mcc_loadConfig.sqf'");
			sizeEx ="(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			tooltip = "Load a mission from the profile namespace - choose a slot from the list above first";
			text = "Load From Profile"; //--- ToDo: Localize;
			x = 0.620312 * safezoneW + safezoneX;
			y = 0.675931 * safezoneH + safezoneY;
			w = 0.0973958 * safezoneW;
			h = 0.0329871 * safezoneH;
		};

		class MCC3DSaveAllToSQM: MCCBTN_R
		{
			idc = -1;
			onButtonClick = __EVAL("[5] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\mcc_loadConfig.sqf'");
			tooltip = "Save all of the mission's objects in SQM format and copy them to the clipboard."; //--- ToDo: Localize;
			text = "Save All (SQM)"; //--- ToDo: Localize;
			x = 0.507100 * safezoneW + safezoneX;
			y = 0.719914 * safezoneH + safezoneY;
			w = 0.103125 * safezoneW;
			h = 0.0329871 * safezoneH;
		};

		class MCC3DSaveToSQM: MCCBTN_R
		{
			idc = -1;
			onButtonClick = __EVAL("[7] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\mcc_loadConfig.sqf'");
			tooltip = "Save only the MCC/Zeus objects in SQM format and copy them to the clipboard."; //--- ToDo: Localize;
			text = "Save MCC (SQM)"; //--- ToDo: Localize;
			x = 0.614200 * safezoneW + safezoneX;
			y = 0.719914 * safezoneH + safezoneY;
			w = 0.103125 * safezoneW;
			h = 0.0329871 * safezoneH;
		};

		class MCC3DSaveToComp: MCCBTN_R
		{
			idc = -1;
			onButtonClick = __EVAL("[6] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\mcc_loadConfig.sqf'");
			tooltip = "Save MCC's 3D editor placements in composition format to the clipboard and the RPT file"; //--- ToDo: Localize;
			text = "Save Comp"; //--- ToDo: Localize;
			x = 0.614200 * safezoneW + safezoneX;
			y = 0.719914 * safezoneH + safezoneY;
			w = 0.103125 * safezoneW;
			h = 0.0329871 * safezoneH;
		};

		//Persistent saving
		class activatePersistent: MCCBTN_R
		{
			idc = MCC_SAVE_PERSISTENT;
			text = "Activate Persistent"; //--- ToDo: Localize;
			x = 0.520625 * safezoneW + safezoneX;
			y = 0.456 * safezoneH + safezoneY;
			w = 0.0773437 * safezoneW;
			h = 0.044 * safezoneH;
			onButtonClick = __EVAL("[8] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\mcc_loadConfig.sqf'");
			tooltip = "Activate persistent data saving and loading from the DB"; //--- ToDo: Localize;
			class TextPos {left = 0; top = "((0.044 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class clearPersistent: MCCBTN_R
		{
			idc = -1;
			text = "Clear Persistent"; //--- ToDo: Localize;
			x = 0.628906 * safezoneW + safezoneX;
			y = 0.456 * safezoneH + safezoneY;
			w = 0.0773437 * safezoneW;
			h = 0.044 * safezoneH;
			onButtonClick = __EVAL("[9] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\mcc_loadConfig.sqf'");
			tooltip = "Clear the default persistent data from the DB"; //--- ToDo: Localize;
			class TextPos {left = 0; top = "((0.044 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
	};
};
