#define MCC_AIRDROPTYPE 1031
#define MCC_airdropClass 1032
#define MCC_airdropArray 1033

class MCC_airdropDialogControls:MCC_RscControlsGroup
{
	idc = 517;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.280729 * safezoneW;
	h = 0.298000 * safezoneH;

	class Controls
	{
		class MCC_airdropDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};

			w = 0.280729* safezoneW;
			h = 0.298000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_airdropTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			idc = -1;

			text = "Supply Drop"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.264729* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};

		class MCC_airdropFilterFaction: MCC_RscCheckbox
		{
			idc = 1039;
			tooltip = "Ticked: only your faction's aircraft (and its variants). Unticked: every aircraft on your side";
			x = 0.033000* safezoneW;
			y = 0.048000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_adMem') then {MCCMK_adMem = createHashMap}; MCCMK_adMem set ['facOnly', (_this select 1) == 1]; [] call MCCMK_fnc_airdropAirList; [] call MCCMK_fnc_airdropList";
		};
		class MCC_airdropFilterFactionText: MCC_RscText
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
		class MCC_airdropFilterHeli: MCC_RscCheckbox
		{
			idc = 1041;
			tooltip = "Show helicopters in the aircraft list";
			x = 0.086500* safezoneW;
			y = 0.048000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_adMem') then {MCCMK_adMem = createHashMap}; MCCMK_adMem set ['heli', (_this select 1) == 1]; [] call MCCMK_fnc_airdropAirList; [] call MCCMK_fnc_airdropList";
		};
		class MCC_airdropFilterHeliText: MCC_RscText
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
		class MCC_airdropFilterPlane: MCC_RscCheckbox
		{
			idc = 1042;
			tooltip = "Show planes in the aircraft list";
			x = 0.128000* safezoneW;
			y = 0.048000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_adMem') then {MCCMK_adMem = createHashMap}; MCCMK_adMem set ['plane', (_this select 1) == 1]; [] call MCCMK_fnc_airdropAirList; [] call MCCMK_fnc_airdropList";
		};
		class MCC_airdropFilterPlaneText: MCC_RscText
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
		class MCC_airdropSearchClear: MCCBTN_S
		{
			idc = -1;
			text = "Clear";
			tooltip = "Clear the aircraft search";
			x = 0.215429* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 1040) ctrlSetText ''; [] call MCCMK_fnc_airdropAirList; [] call MCCMK_fnc_airdropList";
		};
		class MCC_airdropSearch: MCC_RscText
		{
			idc = 1040;
			type = 2;
			tooltip = "Search the aircraft list";
			x = 0.215429* safezoneW;
			y = 0.076000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			onKeyUp = "[] call MCCMK_fnc_airdropAirList; [] call MCCMK_fnc_airdropList";
		};
		class MCC_airdropAircraftCombo: MCC_RscCombo
		{
			idc = 1038;
			x = 0.008000* safezoneW;
			y = 0.076000* safezoneH;
			w = 0.203429* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_airdropInsertionType: MCC_RscToolbox
		{
			idc = 1037;
			strings[] = {" Parachute "," Slingload "};
			rows = 1;
			columns = 2;
			values[] = {0,1};
			onToolBoxSelChanged =  __EVAL("[3,(_this select 1)] execVM '"+MCCPATH+"mcc\general_scripts\cas\airdropReq.sqf'");

			x = 0.008000* safezoneW;
			y = 0.106000* safezoneH;
			w = 0.264729* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};

		class MCC_airdropTypeCombo: MCC_RscCombo
		{
			idc = MCC_AIRDROPTYPE;
			x = 0.008000* safezoneW;
			y = 0.136000* safezoneH;
			w = 0.099714* safezoneW;
			h = 0.022000* safezoneH;
			onLBSelChanged = "[_this select 1] call MCCMK_fnc_airdropList";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_airdropClassCombo: MCC_RscCombo
		{
			onLBSelChanged = "[] call MCCMK_fnc_airdropLive";
			idc = MCC_airdropClass;
			x = 0.111714* safezoneW;
			y = 0.136000* safezoneH;
			w = 0.099714* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_airdropArrayCombo: MCC_RscCombo
		{
			idc = MCC_airdropArray;
			x = 0.008000* safezoneW;
			y = 0.184000* safezoneH;
			w = 0.203429* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_airdropArrayTittle: MCC_RscText
		{
			idc = 1034;

			text = "Current Airdrop"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.166000* safezoneH;
			w = 0.264729* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_airdropAdd: MCCBTN_S
		{
			idc = 1035; // idc set to allow hiding button when no mcc_console available
			text = "Add"; //--- ToDo: Localize;
			x = 0.215429* safezoneW;
			y = 0.136000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Add this item to the current airdrop list"; //--- ToDo: Localize;
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\cas\airdropReq.sqf'");
		};
		class MCC_airdropClear: MCCBTN_S
		{
			idc = 1036;
			text = "Clear"; //--- ToDo: Localize;
			x = 0.215429* safezoneW;
			y = 0.184000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Clear the current airdrop list"; //--- ToDo: Localize;
			onButtonClick = __EVAL("[2] execVM '"+MCCPATH+"mcc\general_scripts\cas\airdropReq.sqf'");
		};
		class MCC_airdropCall: MCCBTN_S
		{
			idc = -1;
			text = "Call"; //--- ToDo: Localize;
			x = 0.215429* safezoneW;
			y = 0.268000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Call the current airdrop"; //--- ToDo: Localize;
			onButtonClick = "[0] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\cas\cas_request.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 517) ctrlShow false";
		};
		class MCC_airdropHeliHeightTittle: MCC_RscText
		{
			idc = -1;

			text = "Helicopters";
			x = 0.008000* safezoneW;
			y = 0.214000* safezoneH;
			w = 0.099714* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_airdropHeliHeight: MCC_RscCombo
		{
			idc = 1044;
			tooltip = "Flight height for supply drop helicopters";
			x = 0.008000* safezoneW;
			y = 0.232000* safezoneH;
			w = 0.072000* safezoneW;
			h = 0.022000* safezoneH;
			onLBSelChanged = "if (isNil 'MCCMK_adMem') then {MCCMK_adMem = createHashMap}; MCCMK_adMem set ['hHeli', (_this select 0) lbValue (_this select 1)]; MCCMK_adHeightHeli = (_this select 0) lbValue (_this select 1)";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_airdropPlaneHeightTittle: MCC_RscText
		{
			idc = -1;

			text = "Planes";
			x = 0.111714* safezoneW;
			y = 0.214000* safezoneH;
			w = 0.099714* safezoneW;
			h = 0.018000* safezoneH;
			colorText[] = {0.62,0.65,0.68,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_airdropPlaneHeight: MCC_RscCombo
		{
			idc = 1045;
			tooltip = "Flight height for supply drop planes";
			x = 0.111714* safezoneW;
			y = 0.232000* safezoneH;
			w = 0.072000* safezoneW;
			h = 0.022000* safezoneH;
			onLBSelChanged = "if (isNil 'MCCMK_adMem') then {MCCMK_adMem = createHashMap}; MCCMK_adMem set ['hPlane', (_this select 0) lbValue (_this select 1)]; MCCMK_adHeightPlane = (_this select 0) lbValue (_this select 1)";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_airdropHeliSmoke: MCC_RscCheckbox
		{
			idc = 1046;
			tooltip = "Ticked: helicopter crate drops are marked with smoke";
			x = 0.082500* safezoneW;
			y = 0.234000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_adMem') then {MCCMK_adMem = createHashMap}; MCCMK_adMem set ['smokeH', (_this select 1) == 1]; MCCMK_adSmokeHeli = (_this select 1) == 1";
		};
		class MCC_airdropPlaneSmoke: MCC_RscCheckbox
		{
			idc = 1047;
			tooltip = "Ticked: plane crate drops are marked with smoke";
			x = 0.186214* safezoneW;
			y = 0.234000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_adMem') then {MCCMK_adMem = createHashMap}; MCCMK_adMem set ['smokeP', (_this select 1) == 1]; MCCMK_adSmokePlane = (_this select 1) == 1";
		};
		class MCC_airdropHeliSmokeVeh: MCC_RscCheckbox
		{
			idc = 1048;
			tooltip = "Ticked: helicopter vehicle drops are marked with smoke";
			x = 0.095000* safezoneW;
			y = 0.234000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_adMem') then {MCCMK_adMem = createHashMap}; MCCMK_adMem set ['smokeHV', (_this select 1) == 1]; MCCMK_adSmokeHeliVeh = (_this select 1) == 1";
		};
		class MCC_airdropPlaneSmokeVeh: MCC_RscCheckbox
		{
			idc = 1049;
			tooltip = "Ticked: plane vehicle drops are marked with smoke";
			x = 0.198714* safezoneW;
			y = 0.234000* safezoneH;
			w = 0.010500* safezoneW;
			h = 0.018000* safezoneH;
			onCheckedChanged = "if (isNil 'MCCMK_adMem') then {MCCMK_adMem = createHashMap}; MCCMK_adMem set ['smokePV', (_this select 1) == 1]; MCCMK_adSmokePlaneVeh = (_this select 1) == 1";
		};
		class MCC_airdropAddConsole: MCCBTN_S
		{
			idc = -1;

			text = "Add Console"; //--- ToDo: Localize;
			x = 0.154129* safezoneW;
			y = 0.268000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			onButtonClick = __EVAL("[3] execVM '"+MCCPATH+"mcc\general_scripts\cas\cas_request.sqf'");
			tooltip = "Add the current airdrop to the player's console"; //--- ToDo: Localize;
		};
		class MCC_CSClose: MCCBTN_S
		{
			idc = -1;
			text = "Close"; //--- ToDo: Localize;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 517) ctrlShow false";

			x = 0.008000* safezoneW;
			y = 0.268000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};

