#define MCC_TRIGGERS_ACTIVATE 3064
#define MCC_TRIGGERS_CONDITION 3065
#define MCC_TRIGGERS_SHAPE 3066
#define MCC_TRIGGERS_LIST 3067
#define MCC_TRIGGERS_NAME 3068 
#define MCC_TRIGGERS_TIME_MIN 3071
#define MCC_TRIGGERS_TIME_MAX 3072
#define MCC_TRIGGERS_STAT_COND 3073
#define MCC_TRIGGERS_STAT_DEACTIVE 3075

class MCC_triggersDialogControls: MCC_RscControlsGroup
{
	idc = 515;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.320833 * safezoneW;
	h = 0.342000 * safezoneH;

	class Controls
	{			
		class MCC_jukeboxDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};

			w = 0.320833* safezoneW;
			h = 0.342000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		
		class MCC_triggerGenTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			idc = -1;
			text = "Triggers Generator"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.304833* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class MCC_triggerGenActivateTittle: MCC_RscText
		{
			idc = -1;
			text = "Activate"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_triggerGenConditionTittle: MCC_RscText
		{
			idc = -1;
			text = "Condition"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_triggerGenShapeTittle: MCC_RscText
		{
			idc = -1;
			text = "Shape"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.212000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_triggerGenNameTittle: MCC_RscText
		{
			idc = -1;
			text = "Name"; //--- ToDo: Localize;
			x = 0.164416* safezoneW;
			y = 0.212000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_triggerGenTriggerTittle: MCC_RscText
		{
			idc = -1;
			text = "Available Triggers"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.260000* safezoneH;
			w = 0.304833* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_triggerGenActivate: MCC_RscCombo
		{
			idc = MCC_TRIGGERS_ACTIVATE;
			x = 0.008000* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_triggerGenCondition: MCC_RscCombo
		{
			idc = MCC_TRIGGERS_CONDITION;
			x = 0.008000* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_triggerGenShape: MCC_RscCombo
		{
			idc = MCC_TRIGGERS_SHAPE;
			x = 0.008000* safezoneW;
			y = 0.230000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_triggerGenTrigger: MCC_RscCombo
		{
			idc = MCC_TRIGGERS_LIST;
			x = 0.008000* safezoneW;
			y = 0.278000* safezoneH;
			w = 0.243533* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_triggerGenName: MCC_RscText
		{
			idc = MCC_TRIGGERS_NAME;
			type = MCCCT_EDIT;
			x = 0.164416* safezoneW;
			y = 0.230000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_triggerGenNameFrame: MCC_RscFrame
		{
			idc = -1;
			x = 0.164416* safezoneW;
			y = 0.230000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.022000* safezoneH;
		};
		class MCC_triggerGenCreate: MCCBTN_S
		{
			idc = -1;
			text = "Create"; //--- ToDo: Localize;
			x = 0.255533* safezoneW;
			y = 0.312000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			onButtonClick = "[0] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\triggers\triggers.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 515) ctrlShow false";	//hides the panel so the map can be clicked
			tooltip = "Create trigger"; //--- ToDo: Localize;
		};
		class MCC_triggerGenMove: MCCBTN_S
		{
			idc = -1;
			text = "Move"; //--- ToDo: Localize;
			x = 0.255533* safezoneW;
			y = 0.278000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			onButtonClick = "[2] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\triggers\triggers.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 515) ctrlShow false";	//hides the panel so the map can be clicked
			tooltip = "Move the selected trigger"; //--- ToDo: Localize;
		};
		class MCC_triggerGenTimeMinTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			
			text = "Time Min"; //--- ToDo: Localize;
			x = 0.164416* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_triggerGenTimeMaxTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Time Max"; //--- ToDo: Localize;
			x = 0.164416* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_triggerGenTimeMin: MCC_RscText
		{
			idc = MCC_TRIGGERS_TIME_MIN;
			type = MCCCT_EDIT;
			text = "0";
			x = 0.164416* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_triggerGenTimeMinFrame: MCC_RscFrame
		{
			idc = -1;
			x = 0.164416* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_triggerGenTimeMax: MCC_RscText
		{
			idc = MCC_TRIGGERS_TIME_MAX;
			type = MCCCT_EDIT;
			text = "0";
			x = 0.164416* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_triggerGenTimeMaxFrame: MCC_RscFrame
		{
			idc = -1;
			x = 0.164416* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_triggerStatCondTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Condition"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_triggerStatCond: MCC_RscText
		{
			idc = MCC_TRIGGERS_STAT_COND;
			text = "this";
			type = MCCCT_EDIT;
			x = 0.008000* safezoneW;
			y = 0.160000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.044000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_triggerStatCondFrame: MCC_RscFrame
		{
			idc = -1;

			x = 0.008000* safezoneW;
			y = 0.160000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.044000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_triggerStatDeactive: MCC_RscText
		{
			idc = MCC_TRIGGERS_STAT_DEACTIVE;
			type = MCCCT_EDIT;
			x = 0.164416* safezoneW;
			y = 0.160000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.044000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_triggerStatDeactiveFrame: MCC_RscFrame
		{
			idc = -1;

			x = 0.164416* safezoneW;
			y = 0.160000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.044000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_triggerStatDeactiveTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "On Dea"; //--- ToDo: Localize;
			x = 0.164416* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.148416* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		
		class MCC_triggersClose: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 515) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.312000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Link the sound or music to the selected zone"; //--- ToDo: Localize;
		};
	};
};
