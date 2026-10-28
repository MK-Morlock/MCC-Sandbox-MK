class MCC_TimeDialogControls:MCC_RscControlsGroup
{
	idc = 502;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.189063 * safezoneW;
	h = 0.197923 * safezoneH;

	class Controls
	{
		class MCC_timeDialogframe: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;

			w = 0.189063 * safezoneW;
			h = 0.197923 * safezoneH;
			colorBackground[] = {0,0,0,0};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_timeDialogTittle: MCC_RscStructuredText
		{
			idc = 20;
			colorText[] = {0.89,0.90,0.91,1};

			x = 0.00572965 * safezoneW;
			y = 0.0109958 * safezoneH;
			w = 0.15 * safezoneW;
			h = 0.0329871 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class MCC_timeS1Tittle: MCC_RscText
		{
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			idc = -1;

			text = "/"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.0114583 * safezoneW;
			h = 0.0329871 * safezoneH;
		};
		class MCC_timeDialogConfirm: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[3] execVM '"+MCCPATH+"mcc\pop_menu\mission_settings.sqf'");
			text = "Confirm"; //--- ToDo: Localize;

			x = 0.123771* safezoneW;
			y = 0.15394 * safezoneH;
			w = 0.0572917 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_timeDialogClose: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 502) ctrlShow false";
			text = "Close"; //--- ToDo: Localize;

			x = 0.008000* safezoneW;
			y = 0.15394 * safezoneH;
			w = 0.0572917 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_timeMonthCombo: MCC_RscCombo
		{
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			idc = 15;
			onLBSelChanged=__EVAL("[5] execVM '"+MCCPATH+"mcc\pop_menu\mission_settings.sqf'");
			x = 0.00572965 * safezoneW;
			y = 0.0584366 * safezoneH;
			w = 0.0515625 * safezoneW;
			h = 0.0260715 * safezoneH;
		};
		class MCC_timeDayCombo: MCC_RscCombo
		{
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			idc = 16;
			onLBSelChanged=__EVAL("[5] execVM '"+MCCPATH+"mcc\pop_menu\mission_settings.sqf'");
			x = 0.0687497 * safezoneW;
			y = 0.0584366 * safezoneH;
			w = 0.0515625 * safezoneW;
			h = 0.0260715 * safezoneH;
		};
		class MCC_timeYearCombo: MCC_RscCombo
		{
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			idc = 17;
			onLBSelChanged=__EVAL("[5] execVM '"+MCCPATH+"mcc\pop_menu\mission_settings.sqf'");
			x = 0.131771 * safezoneW;
			y = 0.0584366 * safezoneH;
			w = 0.0515625 * safezoneW;
			h = 0.0260715 * safezoneH;
		};
		class MCC_timeHourCombo: MCC_RscCombo
		{
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			idc = 18;
			x = 0.0343746 * safezoneW;
			y = 0.1024196 * safezoneH;
			w = 0.0515625 * safezoneW;
			h = 0.0260715 * safezoneH;
		};
		class MCC_timeMinuteCombo: MCC_RscCombo
		{
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			idc = 19;
			x = 0.0973957 * safezoneW;
			y = 0.1024196 * safezoneH;
			w = 0.0515625 * safezoneW;
			h = 0.0260715 * safezoneH;
		};
		class MCC_timeS2Tittle: MCC_RscText
		{
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			idc = -1;

			text = "/"; //--- ToDo: Localize;
			x = 0.120313 * safezoneW;
			y = 0.0549788 * safezoneH;
			w = 0.0114583 * safezoneW;
			h = 0.0329871 * safezoneH;
		};
		class MCC_timeS3Tittle: MCC_RscText
		{
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			idc = -1;

			text = ":"; //--- ToDo: Localize;
			x = 0.0859376 * safezoneW;
			y = 0.0989618 * safezoneH;
			w = 0.0114583 * safezoneW;
			h = 0.0329871 * safezoneH;
		};
	};
};
