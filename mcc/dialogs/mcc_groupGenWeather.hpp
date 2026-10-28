class MCC_WeatherDialogControls:MCC_RscControlsGroup
{
	idc = 501;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.269271 * safezoneW;
	h = 0.370000 * safezoneH;

	class Controls
	{

		class MCC_weatherDialogframe: MCC_RscText
		{
			idc = -1;
			text = ""; //--- ToDo: Localize;
			colorBackground[] = {0.11,0.12,0.13,0.96};

			w = 0.269271* safezoneW;
			h = 0.370000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};

		class MCC_weatherDialogTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			idc = -1;
			text = "Weather"; //--- ToDo: Localize;
			colorText[] = {0.89,0.90,0.91,1};

			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.253271* safezoneW;
			h = 0.030000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};

		class MCC_fogTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Fog"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.253271* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};

		class MCC_fogSlider: MCC_RscSlider
		{
			idc = 10;
			onSliderPosChanged = "(_this select 0) ctrlSetTooltip str (_this select 1)";

			x = 0.008000* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.219271* safezoneW;
			h = 0.022000* safezoneH;
		};

		class MCC_rainTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Rain"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.253271* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};

		class MCC_rainSlider: MCC_RscSlider
		{
			idc = 11;
			onSliderPosChanged = "(_this select 0) ctrlSetTooltip str (_this select 1)";

			x = 0.008000* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.219271* safezoneW;
			h = 0.022000* safezoneH;
		};

		class MCC_windTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Wind"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.253271* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};

		class MCC_windSlider: MCC_RscSlider
		{
			idc = 14;
			onSliderPosChanged = "(_this select 0) ctrlSetTooltip str (_this select 1)";

			x = 0.008000* safezoneW;
			y = 0.160000* safezoneH;
			w = 0.219271* safezoneW;
			h = 0.022000* safezoneH;
		};

		class MCC_wavesTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Waves"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.190000* safezoneH;
			w = 0.253271* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};
		class MCC_wavesSlider: MCC_RscSlider
		{
			idc = 13;
			onSliderPosChanged = "(_this select 0) ctrlSetTooltip str (_this select 1)";

			x = 0.008000* safezoneW;
			y = 0.208000* safezoneH;
			w = 0.219271* safezoneW;
			h = 0.022000* safezoneH;
		};

		class MCC_overcastTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Overcast"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.238000* safezoneH;
			w = 0.253271* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};

		class MCC_overcastSlider: MCC_RscSlider
		{
			idc = 12;
			onSliderPosChanged = "(_this select 0) ctrlSetTooltip str (_this select 1)";

			x = 0.008000* safezoneW;
			y = 0.256000* safezoneH;
			w = 0.219271* safezoneW;
			h = 0.022000* safezoneH;
		};

		class MCC_timeTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Time";
			x = 0.008000* safezoneW;
			y = 0.286000 * safezoneH;
			w = 0.253271* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};

		class MCC_timeSlider: MCC_RscSlider
		{
			idc = 11225;
			onSliderPosChanged = "(_this select 0) ctrlSetTooltip (format ['%1 Minutes',floor ((_this select 1)*6)])";

			x = 0.008000* safezoneW;
			y = 0.304000 * safezoneH;
			w = 0.219271* safezoneW;
			h = 0.022000* safezoneH;
		};

		class MCC_weatherDialogClose: MCCBTN_S
		{
			idc = -1;
			text = "Close"; //--- ToDo: Localize;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 501) ctrlShow false";

			x = 0.008000* safezoneW;
			y = 0.340000 * safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
		class MCC_weatherDialogConfirm: MCCBTN_S
		{
			idc = -1;
			text = "Confirm"; //--- ToDo: Localize;
			onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\pop_menu\mission_settings.sqf'");

			x = 0.203971* safezoneW;
			y = 0.340000 * safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
		class MCC_fogMaxTittle: MCC_RscText
		{
			idc = -1;

			text = "max"; //--- ToDo: Localize;
			x = 0.231271* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.030000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_rainMaxTittle: MCC_RscText
		{
			idc = -1;

			text = "max"; //--- ToDo: Localize;
			x = 0.231271* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.030000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};

		class MCC_windMaxTittle: MCC_RscText
		{
			idc = -1;

			text = "max"; //--- ToDo: Localize;
			x = 0.231271* safezoneW;
			y = 0.160000* safezoneH;
			w = 0.030000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_wavesMaxTittle: MCC_RscText
		{
			idc = -1;

			text = "max"; //--- ToDo: Localize;
			x = 0.231271* safezoneW;
			y = 0.208000* safezoneH;
			w = 0.030000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_overcastMaxTittle: MCC_RscText
		{
			idc = -1;

			text = "max"; //--- ToDo: Localize;
			x = 0.231271* safezoneW;
			y = 0.256000* safezoneH;
			w = 0.030000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_timeMaxTittle: MCC_RscText
		{
			idc = -1;

			text = "max"; //--- ToDo: Localize;
			x = 0.231271* safezoneW;
			y = 0.304000 * safezoneH;
			w = 0.030000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
	};
};
