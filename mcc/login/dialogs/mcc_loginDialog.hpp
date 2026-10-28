#define MCC_LoginDIalog_IDD 2990

class mcc_loginDialog
{
	idd = MCC_LoginDIalog_IDD;
	movingEnable = true;
	onLoad = __EVAL("_this execVM '"+MCCPATH+"mcc\login\scripts\mcc_loginDialog_init.sqf'");

	controlsBackground[] =
	{
	};


	//---------------------------------------------
	objects[] =
	{
	};

	class controls
	{
		class MCC_loginFrame: MCC_RscText
		{
			idc = -1;
			colorBackground[] = {0.11,0.12,0.13,0.96};

			x = 0.29375 * safezoneW + safezoneX;
			y = 0.225 * safezoneH + safezoneY;
			w = 0.423958 * safezoneW;
			h = 0.394 * safezoneH;
		};

		class mcc_loginDialogFrame: MCC_RscText
		{
			idc = -1;

			colorBackground[] = {0.11,0.12,0.13,0.96};
			x = 0.299479 * safezoneW + safezoneX;
			y = 0.236 * safezoneH + safezoneY;
			w = 0.4125 * safezoneW;
			h = 0.372 * safezoneH;
		};
		class MCC_CSClose: MCC_RscButtonRound
		{
			idc = -1;
			onButtonClick = "closeDialog 0";

			text = "Close";
			x = 0.305208 * safezoneW + safezoneX;
			y = 0.564 * safezoneH + safezoneY;
			w = 0.06875 * safezoneW;
			h = 0.032987 * safezoneH;
			
		};

		class MCC_login: MCC_RscButtonRound
		{
			idc = -1;
			action = "_null = [] spawn MCC_fnc_loginDialog";

			text = "Login"; //--- ToDo: Localize;
			x = 0.6375 * safezoneW + safezoneX;
			y = 0.564 * safezoneH + safezoneY;
			w = 0.06875 * safezoneW;
			h = 0.032987 * safezoneH;
			
			tooltip = "Login as the mission maker"; //--- ToDo: Localize;
		};

	};
};