class MCC_ResourcesControlsGroup: MCC_RscControlsGroupNoScrollbars
{
	idc = 80;
	x = 0.226719 * safezoneW + safezoneX;
	y = 0.786 * safezoneH + safezoneY;
	w = 0.15 * safezoneW;
	h = 0.209 * safezoneH;
	class controls
	{
		class MCC_AmmoText: MCC_RscText
		{
			idc = 81;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";

			x = 0.025781 * safezoneW;
			y = 0.011 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.022 * safezoneH;
		};

		class MCC_RepairText: MCC_RscText
		{
			idc = 82;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";

			x = 0.025781 * safezoneW;
			y = 0.044 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.022 * safezoneH;
		};

		class MCC_FuelText: MCC_RscText
		{
			idc = 83;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";

			x = 0.025781 * safezoneW;
			y = 0.077 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class MCC_FoodText: MCC_RscText
		{
			idc = 84;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";

			x = 0.025781 * safezoneW;
			y = 0.11 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class MCC_MedText: MCC_RscText
		{
			idc = 85;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";

			x = 0.025781 * safezoneW;
			y = 0.143 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class MCC_unitsText: MCC_RscText
		{
			idc = 86;

			x = 0.025781 * safezoneW;
			y = 0.176 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.022 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_Ammo: MCC_RscPicture
		{
			idc = -1;

			style = 2096;
			colorText[] = { 0.9, 0, 0, 1 };
			text =  __EVAL(MCCPATH +"data\IconAmmo.paa");
			tooltip = "Ammo";

			x = 0.00515598 * safezoneW;
			y = 0.011 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class MCC_Repair: MCC_RscPicture
		{
			idc = -1;

			style = 2096;
			colorText[] = { 0, 0.5, 0.9, 1 };
			text = __EVAL(MCCPATH +"data\IconRepair.paa");
			tooltip = "Supplies";

			x = 0.00515598 * safezoneW;
			y = 0.044 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class MCC_Fuel: MCC_RscPicture
		{
			idc = -1;

			style = 2096;
			tooltip = "Fuel";
			text = __EVAL(MCCPATH +"data\IconFuel.paa");
			colorText[] = { 0, 0.9, 0.5, 1 };

			x = 0.00515598 * safezoneW;
			y = 0.077 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class MCC_FoodPic: MCC_RscPicture
		{
			idc = -1;

			style = 2096;
			tooltip = "Food";
			text = __EVAL(MCCPATH +"data\IconFood.paa");
			colorText[] = { 0.77, 0.51, 0.08, 1 };

			x = 0.00515598 * safezoneW;
			y = 0.11 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class MCC_MedPic: MCC_RscPicture
		{
			idc = -1;

			style = 2096;
			tooltip = "Meds";
			text = __EVAL(MCCPATH +"data\IconMed.paa");
			colorText[] = { 0, 0.9, 0.9, 1 };

			x = 0.00515598 * safezoneW;
			y = 0.143 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class MCC_unitsPic: MCC_RscPicture
		{
			idc = -1;

			style = 2096;
			text = __EVAL(MCCPATH +"data\IconMen.paa");

			x = 0.00515598 * safezoneW;
			y = 0.176 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class MCC_resTrack0: MCC_RscText
		{
			idc = -1;
			x = 0.025781 * safezoneW;
			y = 0.033 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {1,1,1,0.10};
		};
		class MCC_resFill0: MCC_RscText
		{
			idc = 181;
			x = 0.025781 * safezoneW;
			y = 0.033 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {1,0.42,0.29,1};
		};
		class MCC_resFull0: MCC_RscText
		{
			idc = 191;
			tooltip = "Build a Workshop and upgrade its\nStorage Area to increase capacity";
			style = 2;
			text = "FULL";
			font = "RobotoCondensedBold";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.48)";
			colorText[] = {0.14,0.11,0.08,1};
			colorBackground[] = {0.93,0.83,0.55,0.25};
			x = 0.115 * safezoneW;
			y = 0.0225 * safezoneH;
			w = 0.02 * safezoneW;
			h = 0.014 * safezoneH;
		};
		class MCC_resTrack1: MCC_RscText
		{
			idc = -1;
			x = 0.025781 * safezoneW;
			y = 0.066 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {1,1,1,0.10};
		};
		class MCC_resFill1: MCC_RscText
		{
			idc = 182;
			x = 0.025781 * safezoneW;
			y = 0.066 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {0.31,0.64,1,1};
		};
		class MCC_resFull1: MCC_RscText
		{
			idc = 192;
			tooltip = "Build a Workshop and upgrade its\nStorage Area to increase capacity";
			style = 2;
			text = "FULL";
			font = "RobotoCondensedBold";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.48)";
			colorText[] = {0.14,0.11,0.08,1};
			colorBackground[] = {0.93,0.83,0.55,0.25};
			x = 0.115 * safezoneW;
			y = 0.0555 * safezoneH;
			w = 0.02 * safezoneW;
			h = 0.014 * safezoneH;
		};
		class MCC_resTrack2: MCC_RscText
		{
			idc = -1;
			x = 0.025781 * safezoneW;
			y = 0.099 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {1,1,1,0.10};
		};
		class MCC_resFill2: MCC_RscText
		{
			idc = 183;
			x = 0.025781 * safezoneW;
			y = 0.099 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {0.24,0.83,0.54,1};
		};
		class MCC_resFull2: MCC_RscText
		{
			idc = 193;
			tooltip = "Build a Workshop and upgrade its\nStorage Area to increase capacity";
			style = 2;
			text = "FULL";
			font = "RobotoCondensedBold";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.48)";
			colorText[] = {0.14,0.11,0.08,1};
			colorBackground[] = {0.93,0.83,0.55,0.25};
			x = 0.115 * safezoneW;
			y = 0.0885 * safezoneH;
			w = 0.02 * safezoneW;
			h = 0.014 * safezoneH;
		};
		class MCC_resTrack3: MCC_RscText
		{
			idc = -1;
			x = 0.025781 * safezoneW;
			y = 0.132 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {1,1,1,0.10};
		};
		class MCC_resFill3: MCC_RscText
		{
			idc = 184;
			x = 0.025781 * safezoneW;
			y = 0.132 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {0.95,0.71,0.27,1};
		};
		class MCC_resFull3: MCC_RscText
		{
			idc = 194;
			tooltip = "Build a Workshop and upgrade its\nStorage Area to increase capacity";
			style = 2;
			text = "FULL";
			font = "RobotoCondensedBold";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.48)";
			colorText[] = {0.14,0.11,0.08,1};
			colorBackground[] = {0.93,0.83,0.55,0.25};
			x = 0.115 * safezoneW;
			y = 0.1215 * safezoneH;
			w = 0.02 * safezoneW;
			h = 0.014 * safezoneH;
		};
		class MCC_resTrack4: MCC_RscText
		{
			idc = -1;
			x = 0.025781 * safezoneW;
			y = 0.165 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {1,1,1,0.10};
		};
		class MCC_resFill4: MCC_RscText
		{
			idc = 185;
			x = 0.025781 * safezoneW;
			y = 0.165 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {0.25,0.84,0.84,1};
		};
		class MCC_resFull4: MCC_RscText
		{
			idc = 195;
			tooltip = "Build a Workshop and upgrade its\nStorage Area to increase capacity";
			style = 2;
			text = "FULL";
			font = "RobotoCondensedBold";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.48)";
			colorText[] = {0.14,0.11,0.08,1};
			colorBackground[] = {0.93,0.83,0.55,0.25};
			x = 0.115 * safezoneW;
			y = 0.1545 * safezoneH;
			w = 0.02 * safezoneW;
			h = 0.014 * safezoneH;
		};
		class MCC_resTrack5: MCC_RscText
		{
			idc = -1;
			x = 0.025781 * safezoneW;
			y = 0.198 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {1,1,1,0.10};
		};
		class MCC_resFill5: MCC_RscText
		{
			idc = 186;
			x = 0.025781 * safezoneW;
			y = 0.198 * safezoneH;
			w = 0.08 * safezoneW;
			h = 0.0035 * safezoneH;
			colorBackground[] = {0.70,0.61,1,1};
		};
	};
};