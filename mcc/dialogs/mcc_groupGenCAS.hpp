class MCC_CASDialogControls:MCC_RscControlsGroup
{
	idc = 500;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.280729 * safezoneW;
	h = 0.190000 * safezoneH;

	class Controls
	{
		class MCC_CASDialog: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};

			w = 0.280729 * safezoneW;
			h = 0.190000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};

		class MCC_CASTitle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			idc = -1;

			text = "Close Air Support"; //--- ToDo: Localize;
			x = 0.008000 * safezoneW;
			y = 0.008000 * safezoneH;
			w = 0.264729 * safezoneW;
			h = 0.030000 * safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class MCC_casFilterFactionText: MCC_RscText
		{
			style = 1;
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Faction";
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.024000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_casFilterFaction: MCC_RscCheckbox
		{
			idc = 1070;
			tooltip = "Ticked: only your faction's aircraft (and its variants). Unticked: every aircraft on your side";
			x = 0.033000* safezoneW;
			y = 0.048000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_casMem') then {MCCMK_casMem = createHashMap}; MCCMK_casMem set ['facOnly', (_this select 1) == 1]; [] call MCCMK_fnc_casAirList";
		};
		class MCC_casFilterHeliText: MCC_RscText
		{
			style = 1;
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Helicopters";
			x = 0.049500* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.036000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_casFilterHeli: MCC_RscCheckbox
		{
			idc = 1071;
			tooltip = "Show helicopters in the CAS aircraft list";
			x = 0.086500* safezoneW;
			y = 0.048000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_casMem') then {MCCMK_casMem = createHashMap}; MCCMK_casMem set ['heli', (_this select 1) == 1]; [] call MCCMK_fnc_casAirList";
		};
		class MCC_casFilterPlaneText: MCC_RscText
		{
			style = 1;
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Planes";
			x = 0.103000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.024000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_casFilterPlane: MCC_RscCheckbox
		{
			idc = 1072;
			tooltip = "Show planes in the CAS aircraft list";
			x = 0.128000* safezoneW;
			y = 0.048000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_casMem') then {MCCMK_casMem = createHashMap}; MCCMK_casMem set ['plane', (_this select 1) == 1]; [] call MCCMK_fnc_casAirList";
		};
		class MCC_casSearchClear: MCCBTN_S
		{
			idc = -1;
			text = "Clear";
			tooltip = "Clear the CAS aircraft search";
			x = 0.215429* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 1073) ctrlSetText ''; [] call MCCMK_fnc_casAirList";
		};
		class MCC_casSearch: MCC_RscText
		{
			idc = 1073;
			type = 2;
			tooltip = "Search the CAS aircraft list";
			x = 0.215429* safezoneW;
			y = 0.076000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			onKeyUp = "[] call MCCMK_fnc_casAirList";
		};
		class MCC_CASPlaneType: MCC_RscCombo
		{
			idc = 25;
			onLBSelChanged = "if (isNil 'MCCMK_casMem') then {MCCMK_casMem = createHashMap}; MCCMK_casMem set ['air', (_this select 0) lbData (_this select 1)]; [ctrlParent (_this select 0), _this select 1] call MCC_fnc_casFillTypes";

			x = 0.008000 * safezoneW;
			y = 0.076000 * safezoneH;
			w = 0.203429 * safezoneW;
			h = 0.022000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_CASTypeTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Attack"; //--- ToDo: Localize;
			x = 0.008000 * safezoneW;
			y = 0.106000 * safezoneH;
			w = 0.264729 * safezoneW;
			h = 0.018000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};
		class MCC_CASType: MCC_RscCombo
		{
			idc = 26;

			x = 0.008000 * safezoneW;
			y = 0.124000 * safezoneH;
			w = 0.264729 * safezoneW;
			h = 0.022000 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_CASCall: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[1] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\cas\cas_request.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 500) ctrlShow false";

			text = "Call"; //--- ToDo: Localize;
			x = 0.215429 * safezoneW;
			y = 0.160000 * safezoneH;
			w = 0.057300 * safezoneW;
			h = 0.022000 * safezoneH;
			tooltip = "Call CAS - drag and draw a line on the minimap to call CAS"; //--- ToDo: Localize;
		};
		class MCC_CASAdd: MCCBTN_S
		{
			idc = 27; // idc set to allow hiding button when no mcc_console available
			onButtonClick = __EVAL("[2] execVM '"+MCCPATH+"mcc\general_scripts\cas\cas_request.sqf'");

			text = "Add"; //--- ToDo: Localize;
			x = 0.154129 * safezoneW;
			y = 0.160000 * safezoneH;
			w = 0.057300 * safezoneW;
			h = 0.022000 * safezoneH;
			tooltip = "Add CAS to MCC Console"; //--- ToDo: Localize;
		};

		class MCC_CASClose: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 500) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			x = 0.008000 * safezoneW;
			y = 0.160000 * safezoneH;
			w = 0.057300 * safezoneW;
			h = 0.022000 * safezoneH;
			tooltip = "Call CAS - drag and draw a line on the minimap to call CAS"; //--- ToDo: Localize;
		};
	};
};
 

