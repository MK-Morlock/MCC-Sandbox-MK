class MCC_3DPanel
{
	idd = -1;
	movingEnable = false;
	enableSimulation = true;
	duration = 1e+100;
	fadeIn = 0;
	fadeOut = 0;
	name = "MCC_3DPanel";
	onLoad = "uiNamespace setVariable [""MCC_3DPanel"", _this select 0]";
	class Controls
	{
		class MCC_3DPanelBack: MCC_RscText
		{
			idc = -1;
			style = 48;
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			colorText[] = {0.08,0.10,0.12,0.88};
			colorBackground[] = {0,0,0,0};
			x = 0.805 * safezoneW + safezoneX;
			y = 0.012 * safezoneH + safezoneY;
			w = 0.185 * safezoneW;
			h = 0.50 * safezoneH;
		};
		class MCC_3DPanelText: MCC_RscStructuredText
		{
			idc = 1;
			size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			colorBackground[] = {0,0,0,0};
			x = 0.812 * safezoneW + safezoneX;
			y = 0.024 * safezoneH + safezoneY;
			w = 0.172 * safezoneW;
			h = 0.48 * safezoneH;
		};
	};
};
