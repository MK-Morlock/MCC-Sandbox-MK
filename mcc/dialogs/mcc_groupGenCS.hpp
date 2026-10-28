#define MCCVIEWDISTANCE 1006
#define MCCGRASSDENSITY 1007

class MCC_csDialogControls: MCC_RscControlsGroup
{
	idc = 516;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.166146 * safezoneW;
	h = 0.178000 * safezoneH;

	class Controls
	{			
		class MCC_CSDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};

			w = 0.166146* safezoneW;
			h = 0.178000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};

		class MCC_CSSettings: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			idc = -1;

			text = "Client Side Settings"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.150146* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
		};
		class MCC_viewDistanceTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "View"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.150146* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};
		class MCC_grassDensityTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Grass"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.150146* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};
		class MCC_viewDistance: MCC_RscCombo
		{
			idc = MCCVIEWDISTANCE;
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onLBSelChanged =  __EVAL("[2] execVM '"+MCCPATH+"mcc\Pop_menu\mission_settings.sqf'");			

			x = 0.008000* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.150146* safezoneW;
			h = 0.022000* safezoneH;
			
		};
		class MCC_grassDensity: MCC_RscCombo
		{
			idc = MCCGRASSDENSITY;
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onLBSelChanged =  __EVAL("[1] execVM '"+MCCPATH+"mcc\Pop_menu\mission_settings.sqf'");

			x = 0.008000* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.150146* safezoneW;
			h = 0.022000* safezoneH;
		};
		class MCC_CSClose: MCCBTN_S
		{
			idc = -1;
			text = "Close"; //--- ToDo: Localize;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 516) ctrlShow false";
			
			x = 0.008000* safezoneW;
			y = 0.148000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};


