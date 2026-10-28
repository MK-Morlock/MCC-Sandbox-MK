#define MCC_BRIEFING_TEXT 3055

class MCC_briefingDialogControls: MCC_RscControlsGroup
{
	idc = 512;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.332292 * safezoneW;
	h = 0.236000 * safezoneH;

	class Controls
	{	
		class MCC_briefingDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};

			w = 0.332292* safezoneW;
			h = 0.236000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		
		class MCC_briefingGeneratorTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			idc = -1;

			text = "Briefing Generator"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.316292* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
		};
		class MCC_briefingtext: MCC_RscText
		{
			idc = MCC_BRIEFING_TEXT;
			type = 2;

			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.316292* safezoneW;
			h = 0.088000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_briefingTextFrame: MCC_RscFrame
		{
			idc = -1;

			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.316292* safezoneW;
			h = 0.088000* safezoneH;
		};
		
		class MCC_briefingBriefing: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\pop_menu\briefing.sqf'");

			text = "Situation"; //--- ToDo: Localize;
			x = 0.114764* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.102764* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add the given text to the mission briefing"; //--- ToDo: Localize;
		};
		class MCC_briefingEnemy: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\pop_menu\briefing.sqf'");

			text = "Enemy forces"; //--- ToDo: Localize;
			x = 0.221528* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.102764* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add the given text to the mission's enemy forces intel"; //--- ToDo: Localize;
		};
		class MCC_briefingFriendly: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[2] execVM '"+MCCPATH+"mcc\pop_menu\briefing.sqf'");

			text = "Friendly forces"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.172000* safezoneH;
			w = 0.102764* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add the given text to the mission's friendly forces intel"; //--- ToDo: Localize;
		};
		class MCC_briefingMission: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[3] execVM '"+MCCPATH+"mcc\pop_menu\briefing.sqf'");

			text = "Mission"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.102764* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add the given text to the mission overview"; //--- ToDo: Localize;
		};
		class MCC_briefingSpecial: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[4] execVM '"+MCCPATH+"mcc\pop_menu\briefing.sqf'");

			text = "Special Tasks"; //--- ToDo: Localize;
			x = 0.114764* safezoneW;
			y = 0.172000* safezoneH;
			w = 0.102764* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add the given text to the mission's special tasks"; //--- ToDo: Localize;
		};
		class MCC_briefingSupport: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[5] execVM '"+MCCPATH+"mcc\pop_menu\briefing.sqf'");

			text = "Support"; //--- ToDo: Localize;
			x = 0.221528* safezoneW;
			y = 0.172000* safezoneH;
			w = 0.102764* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add the given text to the mission's support intel"; //--- ToDo: Localize;
		};
		class MCC_briefingClose: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 512) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.206000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};
	

