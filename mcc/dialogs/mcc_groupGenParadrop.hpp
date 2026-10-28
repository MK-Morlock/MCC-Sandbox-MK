class MCC_paradropDialogControls:MCC_RscControlsGroup
{
	idc = 521;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.280729 * safezoneW;
	h = 0.312000 * safezoneH;

	class Controls
	{
		class MCC_pdFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};

			w = 0.280729* safezoneW;
			h = 0.312000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_pdTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			idc = -1;

			text = "Paradrop";
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.264729* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class MCC_pdFilterFactionText: MCC_RscText
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
		class MCC_pdFilterFaction: MCC_RscCheckbox
		{
			idc = 1050;
			tooltip = "Ticked: only your faction's aircraft (and its variants). Unticked: every aircraft on your side";
			x = 0.033000* safezoneW;
			y = 0.048000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_pdMem') then {MCCMK_pdMem = createHashMap}; MCCMK_pdMem set ['facOnly', (_this select 1) == 1]; [] call MCCMK_fnc_paradropPanel";
		};
		class MCC_pdFilterHeliText: MCC_RscText
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
		class MCC_pdFilterHeli: MCC_RscCheckbox
		{
			idc = 1051;
			tooltip = "Show helicopters in the aircraft list";
			x = 0.086500* safezoneW;
			y = 0.048000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_pdMem') then {MCCMK_pdMem = createHashMap}; MCCMK_pdMem set ['heli', (_this select 1) == 1]; [] call MCCMK_fnc_paradropPanel";
		};
		class MCC_pdFilterPlaneText: MCC_RscText
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
		class MCC_pdFilterPlane: MCC_RscCheckbox
		{
			idc = 1052;
			tooltip = "Show planes in the aircraft list";
			x = 0.128000* safezoneW;
			y = 0.048000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_pdMem') then {MCCMK_pdMem = createHashMap}; MCCMK_pdMem set ['plane', (_this select 1) == 1]; [] call MCCMK_fnc_paradropPanel";
		};
		class MCC_pdSearchClear: MCCBTN_S
		{
			idc = -1;
			text = "Clear";
			tooltip = "Clear the aircraft search";
			x = 0.215429* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 1053) ctrlSetText ''; [] call MCCMK_fnc_paradropPanel";
		};
		class MCC_pdSearch: MCC_RscText
		{
			idc = 1053;
			type = 2;
			tooltip = "Search the aircraft list";
			x = 0.215429* safezoneW;
			y = 0.076000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			onKeyUp = "[] call MCCMK_fnc_paradropPanel";
		};
		class MCC_pdParaTittle: MCC_RscText
		{
			idc = -1;

			text = "Paratroopers - aircraft for Airdrop>Paradrop";
			x = 0.008000* safezoneW;
			y = 0.078000* safezoneH;
			w = 0.175000* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_pdParaSeats: MCC_RscText
		{
			style = 1;
			idc = 1056;

			text = "";
			x = 0.111714* safezoneW;
			y = 0.078000* safezoneH;
			w = 0.099714* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_pdHaloTittle: MCC_RscText
		{
			idc = -1;

			text = "HALO";
			x = 0.008000* safezoneW;
			y = 0.176000* safezoneH;
			w = 0.100000* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_pdHaloSeats: MCC_RscText
		{
			style = 1;
			idc = 1057;

			text = "";
			x = 0.111714* safezoneW;
			y = 0.176000* safezoneH;
			w = 0.099714* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_pdHaloFixed: MCC_RscText
		{
			tooltip = "HALO height is fixed so the formation timings work (4,950 m when players jump)";
			idc = -1;

			text = "4,000 m";
			x = 0.215429* safezoneW;
			y = 0.194000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_pdParaCombo: MCC_RscCombo
		{
			onLBSelChanged = "[0, _this select 0, _this select 1] call MCCMK_fnc_paradropPick";
			tooltip = "Aircraft for paratrooper (static-line) drops";
			idc = 1054;
			x = 0.008000* safezoneW;
			y = 0.098000* safezoneH;
			w = 0.203429* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_pdHaloCombo: MCC_RscCombo
		{
			onLBSelChanged = "[1, _this select 0, _this select 1] call MCCMK_fnc_paradropPick";
			tooltip = "Aircraft for HALO drops (planes only)";
			idc = 1055;
			x = 0.008000* safezoneW;
			y = 0.194000* safezoneH;
			w = 0.203429* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_pdHeight: MCC_RscCombo
		{
			idc = 1058;
			tooltip = "Flight height for paratrooper drops";
			x = 0.215429* safezoneW;
			y = 0.098000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			onLBSelChanged = "if (isNil 'MCCMK_pdMem') then {MCCMK_pdMem = createHashMap}; MCCMK_pdMem set ['h', (_this select 0) lbValue (_this select 1)]; MCCMK_pdHeight = (_this select 0) lbValue (_this select 1); [0] call MCCMK_fnc_paradropOpen";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_pdParaManualText: MCC_RscText
		{
			style = 1;
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Manual";
			x = 0.008000* safezoneW;
			y = 0.124000* safezoneH;
			w = 0.024000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_pdParaManual: MCC_RscCheckbox
		{
			idc = 1060;
			tooltip = "Manual player chute deployment. AI deployment height";
			x = 0.033000* safezoneW;
			y = 0.126000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "[0, 1, _this select 1] call MCCMK_fnc_paradropOpen";
		};
		class MCC_pdParaAutoText: MCC_RscText
		{
			style = 1;
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Auto";
			x = 0.103000* safezoneW;
			y = 0.124000* safezoneH;
			w = 0.024000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_pdParaAuto: MCC_RscCheckbox
		{
			idc = 1062;
			tooltip = "Default auto chute deployment for player and AI";
			x = 0.128000* safezoneW;
			y = 0.126000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "[0, 0, _this select 1] call MCCMK_fnc_paradropOpen";
		};
		class MCC_pdParaOpen: MCC_RscCombo
		{
			idc = 1061;
			x = 0.008000* safezoneW;
			y = 0.148000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onLBSelChanged = "[0, 2, _this select 1] call MCCMK_fnc_paradropOpen";
		};
		class MCC_pdHaloManualText: MCC_RscText
		{
			style = 1;
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Manual";
			x = 0.008000* safezoneW;
			y = 0.220000* safezoneH;
			w = 0.024000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_pdHaloManual: MCC_RscCheckbox
		{
			idc = 1063;
			tooltip = "Manual player chute deployment. AI deployment height";
			x = 0.033000* safezoneW;
			y = 0.222000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "[1, 1, _this select 1] call MCCMK_fnc_paradropOpen";
		};
		class MCC_pdHaloAutoText: MCC_RscText
		{
			style = 1;
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Auto";
			x = 0.103000* safezoneW;
			y = 0.220000* safezoneH;
			w = 0.024000* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_pdHaloAuto: MCC_RscCheckbox
		{
			idc = 1065;
			tooltip = "Default auto chute deployment for player and AI";
			x = 0.128000* safezoneW;
			y = 0.222000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "[1, 0, _this select 1] call MCCMK_fnc_paradropOpen";
		};
		class MCC_pdHaloOpen: MCC_RscCombo
		{
			idc = 1064;
			x = 0.008000* safezoneW;
			y = 0.244000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			onLBSelChanged = "[1, 2, _this select 1] call MCCMK_fnc_paradropOpen";
		};
		class MCC_pdClose: MCCBTN_S
		{
			idc = -1;
			text = "Close";
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 521) ctrlShow false";

			x = 0.008000* safezoneW;
			y = 0.280000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};
