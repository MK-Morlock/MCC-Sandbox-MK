#define UNIT_TYPE 3010
#define UNIT_CLASS 3011
#define MCC_GGUNIT_TYPE 3012
#define MCC_GGUNIT_BEHAVIOR 3030
#define MCC_GroupGenCurrentGroup_IDD 9003
#define MCC_GGListBoxIDC 3013
#define MCC_GGADDIDC 3014
#define MCC_GGCLEARIDC 3015
#define MCC_GGUNIT_EMPTY 3016
#define MCC_GGUNIT_EMPTYTITLE 3017
#define mcc_groupGen_CurrentgroupNameTittle_IDC 3018
#define mcc_groupGen_CurrentgroupNameText_IDC 3019
#define MCC_GGSAVE_GROUPIDC 3020
#define MCC_GGVREATE_IDC 3021

class MCC_spawnDialogControls:MCC_RscControlsGroup
{
	idc = 506;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.360938 * safezoneW;
	h = 0.398000 * safezoneH;

	class Controls
	{
			
		class MCC_spawnDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};
			
			w = 0.360938* safezoneW;
			h = 0.398000* safezoneH;
		};

		class mcc_groupGen_SpawnTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			idc = -1;

			text = "Spawn"; //--- ToDo: Localize;
			colorText[] = {0.89,0.90,0.91,1};
			
			x = 0.008000* safezoneW;
			y =0.008000* safezoneH;
			w = 0.344938* safezoneW;
			h = 0.030000* safezoneH;
		};

		class mcc_groupGen_typeTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Type"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class mcc_groupGen_typeComboBox: MCC_RscCombo
		{
			idc = MCC_GGUNIT_TYPE;
			onLBSelChanged = "['type', _this select 1] call MCC_fnc_spawnLists";	//the row the event reports: the list itself could still give the old row

			x = 0.008000* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class mcc_groupGen_BranchTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Branch"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class mcc_groupGen_branchComboBox: MCC_RscCombo
		{
			idc = UNIT_TYPE;
			onLBSelChanged = "['branch', _this select 1] call MCC_fnc_spawnLists";	//the row the event reports: the list itself could still give the old row

			x = 0.008000* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class mcc_groupGen_classTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Class"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class mcc_groupGen_classComboBox: MCC_RscCombo
		{
			idc = UNIT_CLASS;

			x = 0.008000* safezoneW;
			y = 0.160000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class mcc_groupGen_BehaviorTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Behavior"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.190000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class mcc_groupGen_BehaviorComboBox: MCC_RscCombo
		{
			idc = MCC_GGUNIT_BEHAVIOR;

			x = 0.008000* safezoneW;
			y = 0.208000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class mcc_groupGen_EmptyTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = MCC_GGUNIT_EMPTYTITLE;

			text = "Empty"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.238000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class mcc_groupGen_EmptyComboBox: MCC_RscCombo
		{
			idc = MCC_GGUNIT_EMPTY;

			x = 0.008000* safezoneW;
			y = 0.256000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class mcc_groupGen_CurrentgroupListBox: MCC_RscListbox
		{
			idc = MCC_GroupGenCurrentGroup_IDD;
			colorBorder[] = {1,1,1,1};

			x = 0.184469* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.130000* safezoneH;
		};
		class mcc_groupGen_CurrentgroupNameTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = mcc_groupGen_CurrentgroupNameTittle_IDC;

			text = "Name"; //--- ToDo: Localize;
			x = 0.184469* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class mcc_groupGen_CurrentgroupNameText: MCC_RscText
		{
			idc = mcc_groupGen_CurrentgroupNameText_IDC;
			type = 2;

			x = 0.184469* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class mcc_groupGen_classAddButton: MCCBTN_S
		{
			idc = MCC_GGADDIDC;
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\group_change.sqf'");

			text = "Add to List"; //--- ToDo: Localize;
			x = 0.184469* safezoneW;
			y = 0.232000* safezoneH;
			w = 0.082234* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add the selected unit to the list"; //--- ToDo: Localize;
		};
		class mcc_groupGen_groupListBoxClearButton: MCCBTN_S
		{
			idc = MCC_GGCLEARIDC;
			onButtonClick = __EVAL("[2] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\group_change.sqf'");

			text = "Clear List"; //--- ToDo: Localize;
			x = 0.270703* safezoneW;
			y = 0.232000* safezoneH;
			w = 0.082234* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Remove all units from the list"; //--- ToDo: Localize;
		};
		class mcc_groupGen_groupListSaveButton: MCCBTN_S
		{
			idc = MCC_GGSAVE_GROUPIDC;
			onButtonClick = __EVAL("[4] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\group_change.sqf'");

			text = "Save as Custom"; //--- ToDo: Localize;
			x = 0.184469* safezoneW;
			y = 0.262000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Save the group as a custom group"; //--- ToDo: Localize;
		};
		class mcc_groupGen_groupListBoxCreaterButton: MCCBTN_S
		{
			idc = MCC_GGVREATE_IDC;
			onButtonClick = "[0] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\groupGen\spawn_request.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 506) ctrlShow false";	//hides the panel so the map can be clicked

			text = "Create"; //--- ToDo: Localize;
			x = 0.295638* safezoneW;
			y = 0.368000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Click on the map to create the group/unit - hold Ctrl to spawn several"; //--- ToDo: Localize;
		};
		class mcc_groupGen_groupListBoxAddToZoneButton: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\spawn_request.sqf'");

			text = "Spawn in zone"; //--- ToDo: Localize;
			x = 0.234338* safezoneW;
			y = 0.368000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Create the group in the selected zone"; //--- ToDo: Localize;
		};
		class MCC_zoneLocTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Location"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.286000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_zoneLoc: MCC_RscCombo
		{
			idc = 0;
			onLBSelChanged = "mcc_hc = (MCC_ZoneLocation select (lbCurSel (_this select 0))) select 1;";

			x = 0.008000* safezoneW;
			y = 0.304000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_spawnCommandableTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Commandable";
			x = 0.184000* safezoneW;
			y = 0.286000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_spawnCommandable: MCC_RscCombo
		{
			idc = 3078;
			tooltip = "Yes: can be commanded from the Commander Console and RTS, and counts towards food and bunks. Ignored for GAIA behaviours in a zone (GAIA controls them).";
			onLBSelChanged = "MCC_spawnCommandable = ((_this select 1) == 1);";

			x = 0.184000* safezoneW;
			y = 0.304000* safezoneH;
			w = 0.168469* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		
		class MCC_delayedSpawnText: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Delayed"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.334000* safezoneH;
			w = 0.045000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		
		class MCC_delayedCacheText: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Cache"; //--- ToDo: Localize;
			x = 0.078000* safezoneW;
			y = 0.334000* safezoneH;
			w = 0.045000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		
		class MCC_delayedSpawn: MCC_RscCheckbox
		{
			idc = 3022;
			tooltip = "Units will not spawn until players are nearby";
			x = 0.057000* safezoneW;
			y = 0.334000* safezoneH;
			w = 0.017000* safezoneW;
			h = 0.022000* safezoneH;
		};
		
		class MCC_CacheSpawn: MCC_RscCheckbox
		{
			idc = 3023;
			tooltip = "Units will spawn and cache automatically";
			x = 0.127000* safezoneW;
			y = 0.334000* safezoneH;
			w = 0.017000* safezoneW;
			h = 0.022000* safezoneH;
		};

		class mcc_groupGen_spawnCloseButton: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "_mccdialog = (uiNamespace getVariable 'MCC_groupGen_Dialog');(_mccdialog displayCtrl 506) ctrlShow false; mcc_delayed_spawn = if (cbChecked  (_mccdialog displayctrl 3022)) then {true} else {false};mcc_caching = if (cbChecked  (_mccdialog displayctrl 3023)) then {true} else {false};";
			text = "Close"; //--- ToDo: Localize;
			
			x = 0.008000* safezoneW;
			y = 0.368000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};