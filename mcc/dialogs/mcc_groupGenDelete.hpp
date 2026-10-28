#define MCCDELETEBRUSH 1030

class MCC_deleteDialogControls:MCC_RscControlsGroup
{
	idc = 518;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.217708 * safezoneW;
	h = 0.112000 * safezoneH;

	class Controls
	{
		class MCC_deleteDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};

			w = 0.217708* safezoneW;
			h = 0.112000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_deleteBrushTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			idc = -1;

			text = "Apply Brush"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.201708* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class MCC_deleteBrushCombo: MCC_RscCombo
		{
			idc = MCCDELETEBRUSH;

			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.140408* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_deleteBrush: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "hint 'Mark the area you want to delete'; MCC_delete_drawing = true;";	//the Brushes panel stays open for more brushes (Close closes it)

			text = "Brush"; //--- ToDo: Localize;
			x = 0.152408* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Apply brush to an area"; //--- ToDo: Localize;
		};
		class MCC_deleteClose: MCCBTN_S
		{
			idc = -1;
			text = "Close"; //--- ToDo: Localize;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 518) ctrlShow false";

			x = 0.008000* safezoneW;
			y = 0.082000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};