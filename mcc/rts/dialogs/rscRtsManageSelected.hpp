class interactionControlsGroup: MCC_RscControlsGroupNoScrollbars
{
	idc = -1;
	x = 0.654688 * safezoneW + safezoneX;
	y = 0.766 * safezoneH + safezoneY;
	w = 0.340312 * safezoneW;
	h = 0.229 * safezoneH;
	class controls
	{
		class status1Text: MCC_RscText
		{
			style = 1;	//right-aligned, ending where "Offline" ended
			idc = 950;

			text = "Click HQ to Build"; //--- ToDo: Localize;
			colorText[] = {1,0.48,0.41,1};
			x = 0.153594 * safezoneW;
			y = 0.004 * safezoneH;
			w = 0.18 * safezoneW;
			h = 0.022 * safezoneH;
		};
		/*
		class status2Text: MCC_RscText
		{
			idc = 951;

			text = "Offline"; //--- ToDo: Localize;
			x = 0.309375 * safezoneW;
			y = 0.031 * safezoneH;
			w = 0.020625 * safezoneW;
			h = 0.022 * safezoneH;
		};

		class constructionTab: MCC_RscButtonRoundSmall
		{
			idc = 952;

			text = "Build"; //--- ToDo: Localize;
			x = 0.190781 * safezoneW;
			y = 0.031 * safezoneH;
			w = 0.020625 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class unitsTab: MCC_RscButtonRoundSmall
		{
			idc = 953;

			text = "Units"; //--- ToDo: Localize;
			x = 0.216563 * safezoneW;
			y = 0.031 * safezoneH;
			w = 0.020625 * safezoneW;
			h = 0.022 * safezoneH;
		};
		*/
		class statusTrack: MCC_RscText
		{
			idc = 956;
			x = 0.190781 * safezoneW;
			y = 0.028 * safezoneH;
			w = 0.139219 * safezoneW;
			h = 0.004 * safezoneH;
			colorBackground[] = {1,1,1,0.10};
		};
		class statusFill: MCC_RscText
		{
			idc = 955;
			x = 0.190781 * safezoneW;
			y = 0.028 * safezoneH;
			w = 0.139219 * safezoneW;
			h = 0.004 * safezoneH;
			colorBackground[] = {0.24,0.83,0.54,1};
		};
		class action1Tile: MCC_RscText
		{
			idc = 19101;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.190781 * safezoneW;
			y = 0.06 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action2Tile: MCC_RscText
		{
			idc = 19102;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.226875 * safezoneW;
			y = 0.06 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action3Tile: MCC_RscText
		{
			idc = 19103;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.262969 * safezoneW;
			y = 0.06 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action4Tile: MCC_RscText
		{
			idc = 19104;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.299063 * safezoneW;
			y = 0.06 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action5Tile: MCC_RscText
		{
			idc = 19105;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.190782 * safezoneW;
			y = 0.116 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action6Tile: MCC_RscText
		{
			idc = 19106;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.226875 * safezoneW;
			y = 0.116 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action7Tile: MCC_RscText
		{
			idc = 19107;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.262969 * safezoneW;
			y = 0.116 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action8Tile: MCC_RscText
		{
			idc = 19108;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.299063 * safezoneW;
			y = 0.116 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action9Tile: MCC_RscText
		{
			idc = 19109;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.190781 * safezoneW;
			y = 0.172 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action10Tile: MCC_RscText
		{
			idc = 19110;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.226875 * safezoneW;
			y = 0.172 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action11Tile: MCC_RscText
		{
			idc = 19111;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.262969 * safezoneW;
			y = 0.172 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action12Tile: MCC_RscText
		{
			idc = 19112;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.299062 * safezoneW;
			y = 0.172 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action1: MCC_RscActivePicture
		{
			idc = 9101;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.190781 * safezoneW;
			y = 0.06 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action2: MCC_RscActivePicture
		{
			idc = 9102;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.226875 * safezoneW;
			y = 0.06 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action3: MCC_RscActivePicture
		{
			idc = 9103;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.262969 * safezoneW;
			y = 0.06 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action4: MCC_RscActivePicture
		{
			idc = 9104;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.299063 * safezoneW;
			y = 0.06 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action5: MCC_RscActivePicture
		{
			idc = 9105;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.190782 * safezoneW;
			y = 0.116 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action6: MCC_RscActivePicture
		{
			idc = 9106;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.226875 * safezoneW;
			y = 0.116 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action7: MCC_RscActivePicture
		{
			idc = 9107;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.262969 * safezoneW;
			y = 0.116 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action8: MCC_RscActivePicture
		{
			idc = 9108;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.299063 * safezoneW;
			y = 0.116 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action9: MCC_RscActivePicture
		{
			idc = 9109;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.190781 * safezoneW;
			y = 0.172 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action10: MCC_RscActivePicture
		{
			idc = 9110;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.226875 * safezoneW;
			y = 0.172 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action11: MCC_RscActivePicture
		{
			idc = 9111;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.262969 * safezoneW;
			y = 0.172 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class action12: MCC_RscActivePicture
		{
			idc = 9112;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.299062 * safezoneW;
			y = 0.172 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};

		class respic1: MCC_RscPicture
		{
			idc = 120;

			style = 2096;

			x = 0.0464065 * safezoneW;
			y = 0.042 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class resText1: MCC_RscText
		{
			idc = 121;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

			x = 0.0618752 * safezoneW;
			y = 0.042 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class respic2: MCC_RscPicture
		{
			idc = 122;

			style = 2096;

			x = 0.0825002 * safezoneW;
			y = 0.042 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class resText2: MCC_RscText
		{
			idc = 123;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

			x = 0.097969 * safezoneW;
			y = 0.042 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class respic3: MCC_RscPicture
		{
			idc = 124;

			style = 2096;

			x = 0.118594 * safezoneW;
			y = 0.042 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class resText3: MCC_RscText
		{
			idc = 125;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

			x = 0.134063 * safezoneW;
			y = 0.042 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class respic4: MCC_RscPicture
		{
			idc = 126;

			style = 2096;

			x = 0.154688 * safezoneW;
			y = 0.042 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class resText4: MCC_RscText
		{
			idc = 127;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

			x = 0.170156 * safezoneW;
			y = 0.042 * safezoneH;
			w = 0.0154688 * safezoneW;
			h = 0.022 * safezoneH;
		};
		class desc: MCC_RscStructuredText
		{
			idc = 150;
			size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";

			x = 0.0464067 * safezoneW;
			y = 0.064 * safezoneH;
			w = 0.139219 * safezoneW;
			h = 0.154 * safezoneH;
		};


		class upgrade0Tile: MCC_RscText
		{
			idc = 19163;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.0103125 * safezoneW;
			y = 0.004 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class upgrade1Tile: MCC_RscText
		{
			idc = 19160;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.0103127 * safezoneW;
			y = 0.06 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class upgrade2Tile: MCC_RscText
		{
			idc = 19161;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.0103125 * safezoneW;
			y = 0.116 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class upgrade3Tile: MCC_RscText
		{
			idc = 19162;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.0103122 * safezoneW;
			y = 0.172 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class upgrade0: MCC_RscActivePicture
		{
			idc = 9163;
			colorActive[] = {0.80,0.86,0.62,1};
			x = 0.0103125 * safezoneW;
			y = 0.004 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class upgrade1: MCC_RscActivePicture
		{
			idc = 9160;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.0103127 * safezoneW;
			y = 0.06 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class upgrade2: MCC_RscActivePicture
		{
			idc = 9161;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.0103125 * safezoneW;
			y = 0.116 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
		class upgrade3: MCC_RscActivePicture
		{
			idc = 9162;
			colorActive[] = {0.80,0.86,0.62,1};

			x = 0.0103122 * safezoneW;
			y = 0.172 * safezoneH;
			w = 0.0309375 * safezoneW;
			h = 0.040 * safezoneH;
		};
	};
};