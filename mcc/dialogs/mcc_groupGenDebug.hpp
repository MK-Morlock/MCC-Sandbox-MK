class MCC_debugDialogControls:MCC_RscControlsGroup
{
	idc = 504;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.235166 * safezoneW;
	h = 0.210000 * safezoneH;

	class Controls
	{
		class MCC_debugDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};
			
			x = 0.000000* safezoneW;
			y = 0.000000* safezoneH;
			w = 0.235166* safezoneW;
			h = 0.210000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};

		class MCC_debugTitle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			idc = -1;
			text = "Debug"; //--- ToDo: Localize;
			colorText[] = {0.89,0.90,0.91,1};
			
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.219166* safezoneW;
			h = 0.030000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class MCC_Debug: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "['RscDisplayDebugPublic'] call MCC_fnc_openDebug";

			text = "Debug"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.107583* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Open BIS Debug Console"; //--- ToDo: Localize;
		};
		class MCC_DebugExtra: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "['RscDisplayDebug'] call MCC_fnc_openDebug";

			text = "Adv. Debug"; //--- ToDo: Localize;
			x = 0.119583* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.107583* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Open BIS Advanced Debug Console"; //--- ToDo: Localize;
		};
		class MCC_CommandLineTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Command line"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.076000* safezoneH;
			w = 0.219166* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_CommandLineText: MCC_RscText
		{
			idc = 24;
			type = 2;

			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.219166* safezoneW;
			h = 0.044000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_CommandLineTextFrmae: MCC_RscFrame
		{
			idc = -1;

			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.219166* safezoneW;
			h = 0.044000* safezoneH;
		};
		class MCC_commandlineTextSmall: MCCBTN_S
		{
			idc = -1;
			onButtonClick =  __EVAL("[3] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\commandLine.sqf'");

			text = "text"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.146000* safezoneH;
			w = 0.051791* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Broadcast the command line phrase to all clients - small fonts"; //--- ToDo: Localize;
		};
		class MCC_commandlineTextBig: MCCBTN_S
		{
			idc = -1;
			onButtonClick =  __EVAL("[4] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\commandLine.sqf'");

			text = "TEXT"; //--- ToDo: Localize;
			x = 0.063792* safezoneW;
			y = 0.146000* safezoneH;
			w = 0.051791* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Broadcast the command line phrase to all clients - big fonts"; //--- ToDo: Localize;
		};
		class MCC_commandlineLocal: MCCBTN_S
		{
			idc = -1;
			onButtonClick =  __EVAL("[0] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\commandLine.sqf'");

			text = "Local"; //--- ToDo: Localize;
			x = 0.119583* safezoneW;
			y = 0.146000* safezoneH;
			w = 0.051791* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Execute the command line phrase only on the mission maker's computer"; //--- ToDo: Localize;
		};
		class MCC_commandlineGlobal: MCCBTN_S
		{
			idc = -1;
			onButtonClick =  __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\commandLine\commandLine.sqf'");

			text = "Global"; //--- ToDo: Localize;
			x = 0.175374* safezoneW;
			y = 0.146000* safezoneH;
			w = 0.051791* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Execute the command line phrase on all clients and the server"; //--- ToDo: Localize;
		};
		class MCC_commandlineCloseButton: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 504) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.180000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};

