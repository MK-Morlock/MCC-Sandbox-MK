#define MCC_TRAPS_TYPE 2007
#define MCC_TRAPS_OBJECT 2008
#define MCC_TRAPS_EXPLOSIN_SIZE 2009
#define MCC_TRAPS_EXPLOSIN_TYPE 2010
#define MCC_TRAPS_TARGET_FACTION 2011
#define MCC_TRAPS_JAMMABLE 2012
#define MCC_TRAPS_DISARM 2013
#define MCC_TRAPS_TRIGGER 2014
#define MCC_TRAPS_PROXIMITY 2015
#define MCC_TRAPS_AMBUSH 2016

class MCC_IEDDialogControls:MCC_RscControlsGroup
{
	idc = 508;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.303646 * safezoneW;
	h = 0.380000 * safezoneH;

	class Controls
	{
		class MCC_IEDDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};

			w = 0.303646* safezoneW;
			h = 0.380000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};

		class MCC_trapsTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			idc = -1;

			text = "IED & Ambush"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.287646* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
		};
		class MCC_trapsTypeTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Type"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.106000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_trapsObjectTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Object"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.154000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_trapsExplosionSizeTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Explosion Size"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.202000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_trapsExplosionTypeTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Explosion Type"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.250000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_trapsDisarmDurationTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Disarm Duration"; //--- ToDo: Localize;
			x = 0.155823* safezoneW;
			y = 0.154000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_trapsJammableTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Jammable"; //--- ToDo: Localize;
			x = 0.155823* safezoneW;
			y = 0.106000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_trapsTargetFactionTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Target Faction"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.298000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_trapsTriggerTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Trigger Type"; //--- ToDo: Localize;
			x = 0.155823* safezoneW;
			y = 0.202000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_trapsProximityTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Proximity"; //--- ToDo: Localize;
			x = 0.155823* safezoneW;
			y = 0.250000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_trapsAmbushGroupTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Ambush Group"; //--- ToDo: Localize;
			x = 0.155823* safezoneW;
			y = 0.298000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_trapsType: MCC_RscCombo
		{
			idc = MCC_TRAPS_TYPE;
			onLBSelChanged = __EVAL("[0] execVM '"+MCCPATH+"mcc\fnc\ied\scripts\trap_change.sqf'");

			x = 0.008000* safezoneW;
			y = 0.124000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_trapsObject: MCC_RscCombo
		{
			idc = MCC_TRAPS_OBJECT;

			x = 0.008000* safezoneW;
			y = 0.172000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_trapsExplosionSize: MCC_RscCombo
		{
			idc = MCC_TRAPS_EXPLOSIN_SIZE;

			x = 0.008000* safezoneW;
			y = 0.220000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_trapsExplosionType: MCC_RscCombo
		{
			idc = MCC_TRAPS_EXPLOSIN_TYPE;

			x = 0.008000* safezoneW;
			y = 0.268000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_trapsTargetFaction: MCC_RscCombo
		{
			idc = MCC_TRAPS_TARGET_FACTION;

			x = 0.008000* safezoneW;
			y = 0.316000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_trapsJammable: MCC_RscCheckBox
		{
			w = 0.017000 * safezoneW;
			idc = MCC_TRAPS_JAMMABLE;

			x = 0.155823* safezoneW;
			y = 0.124000* safezoneH;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_trapsDisarm: MCC_RscCombo
		{
			idc = MCC_TRAPS_DISARM;

			x = 0.155823* safezoneW;
			y = 0.172000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_trapsTrigger: MCC_RscCombo
		{
			idc = MCC_TRAPS_TRIGGER;

			x = 0.155823* safezoneW;
			y = 0.220000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_trapsProximity: MCC_RscCombo
		{
			idc = MCC_TRAPS_PROXIMITY;

			x = 0.155823* safezoneW;
			y = 0.268000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_trapsAmbushGroup: MCC_RscCombo
		{
			idc = MCC_TRAPS_AMBUSH;

			x = 0.155823* safezoneW;
			y = 0.316000* safezoneH;
			w = 0.139823* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_trapsCreateIED: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[0] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\fnc\ied\scripts\trap_request.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 508) ctrlShow false";	//hides the panel so the map can be clicked

			text = "Create IED"; //--- ToDo: Localize;
			x = 0.177046* safezoneW;
			y = 0.350000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Create an IED at the given position"; //--- ToDo: Localize;
		};
		class MCC_trapsCreateAmbush: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[1] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\fnc\ied\scripts\trap_request.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 508) ctrlShow false";	//hides the panel so the map can be clicked

			text = "Create Ambush"; //--- ToDo: Localize;
			x = 0.238346* safezoneW;
			y = 0.350000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Place an ambush group on the map (hold Shift and drag a line between a group and an IED to sync them) "; //--- ToDo: Localize;
		};
		class MCC_trapsExplainTittle: MCC_RscText
		{
			idc = -1;

			text = "*Press Ctrl + left mouse button to trigger an IED or ambushing party"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.287646* safezoneW;
			h = 0.020000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.58)";
		};
		class MCC_trapsExplainTittle2: MCC_RscText
		{
			idc = -1;

			text = "*Hold Shift + left click and draw a line to link IEDs and/or ambush parties"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.076000* safezoneH;
			w = 0.287646* safezoneW;
			h = 0.020000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.58)";
		};
		class MCC_trapsCloseButton: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 508) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.350000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};