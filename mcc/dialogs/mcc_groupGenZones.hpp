class MCC_zoneControls: MCC_RscControlsGroup
{
	idc = -1;
	x = 0.198000 * safezoneW + safezoneX;
	y = 0.603076 * safezoneH + safezoneY;
	w = 0.155 * safezoneW;
	h = 0.026000 * safezoneH;

	class Controls
	{
		class MCC_zoneFrame: MCC_RscText
		{
			idc = -1;
			w = 0.155000 * safezoneW;
			h = 0.026000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};


		class MCC_zone: MCC_RscCombo
		{
			tooltip = "Zone Number";
			idc = 1023;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onLBSelChanged = __EVAL("[0,0,0] execVM '"+MCCPATH+"mcc\pop_menu\zones.sqf'");

			x = 0.000000 * safezoneW;
			y = 0.002000 * safezoneH;
			w = 0.025000 * safezoneW;
			h = 0.022000 * safezoneH;
		};

		class MCC_zoneUpdate: MCCBTN_S
		{
			idc = -1;
			text = "Create Zone";
			tooltip = "Click and drag on the minimap to make a zone";
			onButtonClick = "if (mcc_missionmaker == (name player)) then {MCC_zone_drawing= true;} else {player globalchat 'Access Denied'};";

			x = 0.094000 * safezoneW;
			y = 0.000000 * safezoneH;
			w = 0.058000 * safezoneW;
			h = 0.026000 * safezoneH;
		};


		class MCC_gaiaBehaviorCombo: MCC_RscCombo
		{
			tooltip = "Behaviour";
			idc = 1;
			onLBSelChanged = "MCC_behavior_index = (lbcurSel (_this select 0))";

			x = 0.028000 * safezoneW;
			y = 0.002000 * safezoneH;
			w = 0.060000 * safezoneW;
			h = 0.022000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};


	};
};