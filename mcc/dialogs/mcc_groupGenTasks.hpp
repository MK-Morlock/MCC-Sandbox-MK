#define MCC_TASKS_NAME 3056
#define MCC_TASKS_DESCRIPTION 3057
#define MCC_TASKS_LIST 3058
#define MCC_TASKS_ICON 30581

class MCC_tasksDialogControls: MCC_RscControlsGroup
{
	idc = 513;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.240625 * safezoneW;
	h = 0.355000 * safezoneH;

	class Controls
	{
		class MCC_tasksDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};

			w = 0.240625* safezoneW;
			h = 0.355000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_TasksGeneratorTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			idc = -1;

			text = "Tasks Generator"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.224625* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
		};
		class MCC_TasksNameTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Name"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.224625* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};

		class MCC_TaskIconText: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Icon"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.165000* safezoneH;
			w = 0.224625* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};

		class MCC_TaskIconList: MCC_RscCombo
		{
			idc = MCC_TASKS_ICON;

			x = 0.008000* safezoneW;
			y = 0.183000* safezoneH;
			w = 0.224625* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};

		class MCC_TasksAvaliableTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Available"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.213000* safezoneH;
			w = 0.224625* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};

		class MCC_TasksDescriptionTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Description"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.224625* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_TasksName: MCC_RscText
		{
			idc = MCC_TASKS_NAME;
			type = 2;

			x = 0.008000* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.163325* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_TasksDescription: MCC_RscText
		{
			idc = MCC_TASKS_DESCRIPTION;
			type = 2;

			x = 0.008000* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.224625* safezoneW;
			h = 0.045000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_Taskslist: MCC_RscCombo
		{
			idc = MCC_TASKS_LIST;

			x = 0.008000* safezoneW;
			y = 0.231000* safezoneH;
			w = 0.224625* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_TasksCreate: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[0] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\pop_menu\tasks_req.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 513) ctrlShow false";	//hides the panel so the map can be clicked

			text = "Create"; //--- ToDo: Localize;
			x = 0.175325* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Create Task with the given name and description"; //--- ToDo: Localize;
		};
		class MCC_TasksWP: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[7] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\pop_menu\tasks_req.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 513) ctrlShow false";	//hides the panel so the map can be clicked

			text = "WP"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.261000* safezoneH;
			w = 0.072208* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add Waypoint to the selected task"; //--- ToDo: Localize;
		};
		class MCC_TasksWPCin: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[1] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\pop_menu\tasks_req.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 513) ctrlShow false";	//hides the panel so the map can be clicked

			text = "WP (cin)"; //--- ToDo: Localize;
			x = 0.084208* safezoneW;
			y = 0.261000* safezoneH;
			w = 0.072208* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add Waypoint to the selected task with an establishing shot"; //--- ToDo: Localize;
		};
		class MCC_TasksSucceed: MCCBTN_S
		{
			idc = -1;
			onButtonClick =  __EVAL("[2] execVM '"+MCCPATH+"mcc\pop_menu\tasks_req.sqf'");

			text = "Succeed"; //--- ToDo: Localize;
			x = 0.160417* safezoneW;
			y = 0.291000* safezoneH;
			w = 0.072208* safezoneW;
			h = 0.022000* safezoneH;
			color[] = {0,1,0,0.5};
			tooltip = "Mark the selected task as succeeded"; //--- ToDo: Localize;
		};
		class MCC_TasksFailed: MCCBTN_S
		{
			idc = -1;
			onButtonClick =  __EVAL("[3] execVM '"+MCCPATH+"mcc\pop_menu\tasks_req.sqf'");

			text = "Failed"; //--- ToDo: Localize;
			x = 0.084208* safezoneW;
			y = 0.291000* safezoneH;
			w = 0.072208* safezoneW;
			h = 0.022000* safezoneH;
			color[] = {1,0,0,0.7};
			tooltip = "Mark the selected task as failed"; //--- ToDo: Localize;
		};
		class MCC_TasksCancled: MCCBTN_S
		{
			idc = -1;
			onButtonClick =  __EVAL("[4] execVM '"+MCCPATH+"mcc\pop_menu\tasks_req.sqf'");

			text = "Cancel"; //--- ToDo: Localize;
			x = 0.160417* safezoneW;
			y = 0.261000* safezoneH;
			w = 0.072208* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Mark the selected task as cancelled"; //--- ToDo: Localize;
		};
		class MCC_TasksDelete: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[8] execVM '"+MCCPATH+"mcc\pop_menu\tasks_req.sqf'");

			text = "Delete"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.291000* safezoneH;
			w = 0.072208* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Delete the selected task"; //--- ToDo: Localize;
		};

		class MCC_tasksClose: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 513) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.325000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};

	};
};