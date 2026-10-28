class MCC_rscBroadcast
{
	idd = 29910;
	duration = 1e+011;
	fadeIn = 0.3;
	fadeOut = 0.3;
	onLoad = "uiNamespace setVariable ['MCC_rscBroadcast', _this select 0]";
	class controls
	{
		class MCC_bcBack: MCC_RscText
		{
			idc = -1;
			colorBackground[] = {0.07,0.08,0.09,0.95};
			x = 0.893 * safezoneW + safezoneX;
			y = 0.640 * safezoneH + safezoneY;
			w = 0.094 * safezoneW;
			h = 0.124 * safezoneH;
		};
		class MCC_bcPicture: MCC_RscPicture
		{
			idc = 1;
			text = "";
			x = 0.895 * safezoneW + safezoneX;
			y = 0.644 * safezoneH + safezoneY;
			w = 0.090 * safezoneW;
			h = 0.116 * safezoneH;
		};
	};
};
