class MCC_evacDialogControls:MCC_RscControlsGroup
{
	idc = 507;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.223438 * safezoneW;
	h = 0.400000 * safezoneH;

	class Controls
	{
		class MCC_evacDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};
			
			w = 0.223438* safezoneW;
			h = 0.400000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		
		class MCC_evacTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			idc = -1;

			text = "Evac"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.207438* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
		};
		
		class MCC_evacFactionTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Faction"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.146138* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_evacFaction: MCC_RscCombo
		{
			idc = 45;
			onLBSelChanged = "if (((_this select 0) lbData (_this select 1)) != '') then {missionNamespace setVariable ['MCCMK_evacFaction', (_this select 0) lbData (_this select 1)]; [] call MCC_fnc_evacFillClass}";

			x = 0.008000* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.146138* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_evacSearchClear: MCCBTN_S
		{
			idc = -1;
			text = "Clear";
			tooltip = "Clear the faction search";
			x = 0.158138* safezoneW;
			y = 0.040000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 47) ctrlSetText ''; [] call MCC_fnc_evacFillFactions";
		};
		class MCC_evacSearch: MCC_RscText
		{
			idc = 47;
			type = 2;
			tooltip = "Search the faction list";
			x = 0.158138* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			onKeyUp = "[] call MCC_fnc_evacFillFactions";
		};
		class MCC_evacSeats: MCC_RscText
		{
			style = 1;
			idc = 46;
			text = "";
			x = 0.158138* safezoneW;
			y = 0.162000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_evacTypeTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Type"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.207438* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_evacClassTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Class"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.207438* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_evacType: MCC_RscCombo
		{
			idc = 40;
			onLBSelChanged = "[_this select 1] call MCC_fnc_evacFillClass";

			x = 0.008000* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.146138* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_evacClass: MCC_RscCombo
		{
			idc = 41;

			x = 0.008000* safezoneW;
			y = 0.160000* safezoneH;
			w = 0.146138* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_evacSpawn: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\evac\request_heli.sqf'");

			text = "Spawn"; //--- ToDo: Localize;
			x = 0.158138* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Spawn Evac Vehicle on map click"; //--- ToDo: Localize;
		};
		class MCC_evacSelected: MCC_RscCombo
		{
			idc = 42;
			onLBSelChanged = __EVAL("[0] execVM '"+MCCPATH+"mcc\general_scripts\evac\evac_focus.sqf'");

			x = 0.008000* safezoneW;
			y = 0.238000* safezoneH;
			w = 0.146138* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_evacSelectedTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Evac"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.220000* safezoneH;
			w = 0.207438* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_evacWp: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\evac\add_wp_heli.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 507) ctrlShow false";

			text = "1 WP"; //--- ToDo: Localize;
			x = 0.158138* safezoneW;
			y = 0.286000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add Evac WP"; //--- ToDo: Localize;
		};
		class MCC_evac3Wp: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\evac\move_heli.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 507) ctrlShow false";

			text = "3 WP"; //--- ToDo: Localize;
			x = 0.158138* safezoneW;
			y = 0.238000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add 3 Evac way points"; //--- ToDo: Localize;
		};
		class MCC_evacInsertionTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Insertion"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.268000* safezoneH;
			w = 0.207438* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_evacInsertion: MCC_RscCombo
		{
			idc = 43;

			x = 0.008000* safezoneW;
			y = 0.286000* safezoneH;
			w = 0.146138* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_evacDelHeli: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[2] execVM '"+MCCPATH+"mcc\general_scripts\evac\delete_heli.sqf'");

			text = "Del. Evac"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.190000* safezoneH;
			w = 0.066479* safezoneW;
			h = 0.022000* safezoneH;
			color[] = {1,0,0,0.7};
			tooltip = "Delete the evac vehicle"; //--- ToDo: Localize;
		};
		class MCC_evacFlightHightTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Flight Height"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.316000* safezoneH;
			w = 0.207438* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_evacFlightHight: MCC_RscCombo
		{
			idc = 44;

			x = 0.008000* safezoneW;
			y = 0.334000* safezoneH;
			w = 0.207438* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_evacDelPilot: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\general_scripts\evac\delete_heli.sqf'");

			text = "Del. Driver"; //--- ToDo: Localize;
			x = 0.078479* safezoneW;
			y = 0.190000* safezoneH;
			w = 0.066479* safezoneW;
			h = 0.022000* safezoneH;
			color[] = {1,0,0,0.7};
			tooltip = "Delete the evac driver"; //--- ToDo: Localize;
		};
		class MCC_evacResHeli: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\evac\delete_heli.sqf'");

			text = "Res. Driver"; //--- ToDo: Localize;
			x = 0.148959* safezoneW;
			y = 0.190000* safezoneH;
			w = 0.066479* safezoneW;
			h = 0.022000* safezoneH;
			color[] = {0,1,0,0.7};
			tooltip = "Revive the evac driver"; //--- ToDo: Localize;
		};
		class MCC_evacClose: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 507) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.370000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};