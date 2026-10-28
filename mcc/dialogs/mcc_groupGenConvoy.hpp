class MCC_convoyDialogControls:MCC_RscControlsGroup
{
	idc = 509;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.292188 * safezoneW;
	h = 0.320000 * safezoneH;

	class Controls
	{		
		class MCC_convoyDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};
				
			w = 0.292188* safezoneW;
			h = 0.320000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_ConvoyTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			idc = -1;

			text = "Convoy"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.276188* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
		};
		class MCC_ConvoyCar1Tittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Car1"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_ConvoyCar2Tittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Car2"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_ConvoyCar3Tittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Car3"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_ConvoyCar4Tittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Car4"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.190000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_ConvoyCar5Tittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Car5"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.238000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_ConvoyCar1: MCC_RscCombo
		{
			idc = 50;

			x = 0.008000* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_ConvoyCar2: MCC_RscCombo
		{
			idc = 51;

			x = 0.008000* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_ConvoyCar3: MCC_RscCombo
		{
			idc = 52;

			x = 0.008000* safezoneW;
			y = 0.160000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_ConvoyCar4: MCC_RscCombo
		{
			idc = 53;

			x = 0.008000* safezoneW;
			y = 0.208000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_ConvoyCar5: MCC_RscCombo
		{
			idc = 54;

			x = 0.008000* safezoneW;
			y = 0.256000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_ConvoyHVTTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "HVT"; //--- ToDo: Localize;
			x = 0.150094* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_ConvoyHVTCarTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "HVT Car"; //--- ToDo: Localize;
			x = 0.150094* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_ConvoyHVT: MCC_RscCombo
		{
			idc = 55;

			x = 0.150094* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_ConvoyHVTCar: MCC_RscCombo
		{
			idc = 56;

			x = 0.150094* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.134094* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_convoySpawn: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[3] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\convoy\make_convoy_WP.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 509) ctrlShow false";	//hides the panel so the map can be clicked

			text = "Spawn"; //--- ToDo: Localize;
			x = 0.150094* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.065047* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Spawn convoy and set WP"; //--- ToDo: Localize;
		};
		class MCC_convoyRemove: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\convoy\remove_convoy.sqf')";

			text = "Remove";	//delete the convoy (vehicles, crews, waypoints) and stop placing; Spawn starts again
			x = 0.219141* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.065047* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Delete the convoy: all its vehicles, crews and waypoints"; //--- ToDo: Localize;
		};
		class MCC_convoyReset: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[3] execVM '"+MCCPATH+"mcc\general_scripts\convoy\reset_convoy_WP.sqf'");

			text = "Reset"; //--- ToDo: Localize;
			x = 0.150094* safezoneW;
			y = 0.172000* safezoneH;
			w = 0.065047* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Reset convoy's waypoints"; //--- ToDo: Localize;
		};
		class MCC_convoyStart: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[3] execVM '"+MCCPATH+"mcc\general_scripts\convoy\start_convoy.sqf'");

			text = "Start"; //--- ToDo: Localize;
			x = 0.219141* safezoneW;
			y = 0.172000* safezoneH;
			w = 0.065047* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Start convoy movement"; //--- ToDo: Localize;
		};
		class MCC_convoyClose: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 509) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.290000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};