class MCC_artilleryDialogControls:MCC_RscControlsGroup
{
	idc = 505;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.20625 * safezoneW;
	h = 0.274000 * safezoneH;

	class Controls
	{
	
		class MCC_artilleryDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};
			
			w = 0.206250 * safezoneW;
			h = 0.274000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};

		class MCC_artilleryTitle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			idc = -1;
			text = "Artillery"; //--- ToDo: Localize;
			colorText[] = {0.89,0.90,0.91,1};
			
			x = 0.008000 * safezoneW;
			y = 0.008000 * safezoneH;
			w = 0.190250 * safezoneW;
			h = 0.030000 * safezoneH;
		};
		class MCC_artilleryTypeTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Type"; //--- ToDo: Localize;
			x = 0.008000 * safezoneW;
			y = 0.046000 * safezoneH;
			w = 0.190250 * safezoneW;
			h = 0.018000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};
		class MCC_artillerySpreadTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Spread"; //--- ToDo: Localize;
			x = 0.008000 * safezoneW;
			y = 0.094000 * safezoneH;
			w = 0.190250 * safezoneW;
			h = 0.018000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};
		class MCC_artilleryNumberTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Shells"; //--- ToDo: Localize;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			
			x = 0.008000 * safezoneW;
			y = 0.142000 * safezoneH;
			w = 0.190250 * safezoneW;
			h = 0.018000 * safezoneH;
		};
		class MCC_artilleryType: MCC_RscCombo
		{
			idc = 30;

			x = 0.008000 * safezoneW;
			y = 0.064000 * safezoneH;
			w = 0.190250 * safezoneW;
			h = 0.022000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_artillerySpread: MCC_RscCombo
		{
			idc = 31;

			x = 0.008000 * safezoneW;
			y = 0.112000 * safezoneH;
			w = 0.190250 * safezoneW;
			h = 0.022000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_artilleryNumber: MCC_RscCombo
		{
			idc = 32;

			x = 0.008000 * safezoneW;
			y = 0.160000 * safezoneH;
			w = 0.190250 * safezoneW;
			h = 0.022000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_artilleryDelayText: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Delay"; //--- ToDo: Localize;
			x = 0.008000 * safezoneW;
			y = 0.190000 * safezoneH;
			w = 0.190250 * safezoneW;
			h = 0.018000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};
		class MCC_artilleryDelayCombo: MCC_RscCombo
		{
			idc = 33;

			x = 0.008000 * safezoneW;
			y = 0.208000 * safezoneH;
			w = 0.190250 * safezoneW;
			h = 0.022000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_artilleryCall: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[0] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\artillery\artillery_request.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 505) ctrlShow false";

			text = "Call"; //--- ToDo: Localize;
			x = 0.140950 * safezoneW;
			y = 0.244000 * safezoneH;
			w = 0.057300 * safezoneW;
			h = 0.022000 * safezoneH;
			tooltip = "Call artillery on a map position - hold Ctrl for multiple calls"; //--- ToDo: Localize;
		};
		class MCC_artilleryAdd: MCCBTN_S
		{
			idc = 27; // idc set to allow hiding button when no mcc_console available
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\artillery\artillery_request.sqf'");

			text = "Add"; //--- ToDo: Localize;
			x = 0.079650 * safezoneW;
			y = 0.244000 * safezoneH;
			w = 0.057300 * safezoneW;
			h = 0.022000 * safezoneH;
			tooltip = "Add artillery to MCC Console "; //--- ToDo: Localize;
		};
		class MCC_artilleryDialogClose: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 505) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			x = 0.008000 * safezoneW;
			y = 0.244000 * safezoneH;
			w = 0.057300 * safezoneW;
			h = 0.022000 * safezoneH;
		};
	};
};
