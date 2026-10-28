#define MCC_GroupGenWPCombo_IDC 9015
#define MCC_GroupGenWPformationCombo_IDC 9016
#define MCC_GroupGenWPspeedCombo_IDC 9017
#define MCC_GroupGenWPbehaviorCombo_IDC 9018

class MCC_waypointsDialogControls:MCC_RscControlsGroup
{
	idc = 510;
	x = 0.1 * safezoneW + safezoneX;
	y = 0.1 * safezoneH + safezoneY;
	w = 0.189063 * safezoneW;
	h = 0.219914 * safezoneH;

	class Controls
	{	

		class MCC_GroupGenInfoText: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};

			w = 0.189063 * safezoneW;
			h = 0.219914 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		
		class MCC_GroupGenWPTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			idc = -1;
			text = "Way Points"; //--- ToDo: Localize;
			colorText[] = {0.89,0.90,0.91,1};
			
			x = 0.00572965 * safezoneW;
			y = 0.0109958 * safezoneH;
			w = 0.0916667 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		
		class MCC_GroupGenWPCombo: MCC_RscCombo
		{
			idc = MCC_GroupGenWPCombo_IDC;

			x = 0.0744797 * safezoneW;
			y = 0.0439828 * safezoneH;
			w = 0.108854 * safezoneW;
			h = 0.0219914 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		
		class MCC_GroupGenWPformationCombo: MCC_RscCombo
		{
			idc = MCC_GroupGenWPformationCombo_IDC;

			x = 0.0744797 * safezoneW;
			y = 0.0769698 * safezoneH;
			w = 0.108854 * safezoneW;
			h = 0.0219914 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_GroupGenWPspeedCombo: MCC_RscCombo
		{
			idc = MCC_GroupGenWPspeedCombo_IDC;

			x = 0.0744797 * safezoneW;
			y = 0.109957 * safezoneH;
			w = 0.108854 * safezoneW;
			h = 0.0219914 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_GroupGenWPbehaviorCombo: MCC_RscCombo
		{
			idc = MCC_GroupGenWPbehaviorCombo_IDC;

			x = 0.0744797 * safezoneW;
			y = 0.142944 * safezoneH;
			w = 0.108854 * safezoneW;
			h = 0.0219914 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_GroupGenWPCancel: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "ctrlShow [510, false];";
			tooltip = "Close the waypoint panel - the selected unit and its camera feed stay";
			text = "Cancel";
			x = 0.00572965 * safezoneW;
			y = 0.175932 * safezoneH;
			w = 0.0415 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_GroupGenWPAdd: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\manageWP.sqf'");

			text = "ADD"; //--- ToDo: Localize;
			x = 0.0967 * safezoneW;
			y = 0.175932 * safezoneH;
			w = 0.0415 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Add a waypoint to all selected groups"; //--- ToDo: Localize;
		};
		class MCC_GroupGenWPReplace: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\manageWP.sqf'");

			text = "Replace"; //--- ToDo: Localize;
			x = 0.1422 * safezoneW;
			y = 0.175932 * safezoneH;
			w = 0.0415 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Remove all waypoints from any selected groups and add a new waypoint"; //--- ToDo: Localize;
		};
		class MCC_GroupGenWPClear: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[2] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\manageWP.sqf'");

			text = "Clear"; //--- ToDo: Localize;
			x = 0.0512 * safezoneW;
			y = 0.175932 * safezoneH;
			w = 0.0415 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Remove all waypoints from any selected groups"; //--- ToDo: Localize;
		};
		class MCC_GroupGenWPTypeTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Type"; //--- ToDo: Localize;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			
			x = 0.00572965 * safezoneW;
			y = 0.0439828 * safezoneH;
			w = 0.0572917 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_GroupGenWPFormationTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Formation"; //--- ToDo: Localize;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			
			x = 0.00572965 * safezoneW;
			y = 0.0769698 * safezoneH;
			w = 0.0572917 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_GroupGenWPspeedTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Speed"; //--- ToDo: Localize;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			
			x = 0.00572965 * safezoneW;
			y = 0.109957 * safezoneH;
			w = 0.0572917 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_GroupGenWPbehaviorTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Behavior"; //--- ToDo: Localize;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			
			x = 0.00572965 * safezoneW;
			y = 0.142944 * safezoneH;
			w = 0.0572917 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
	};
};

