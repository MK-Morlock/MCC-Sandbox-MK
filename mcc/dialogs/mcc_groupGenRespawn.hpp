class MCC_respawnDialogControls:MCC_RscControlsGroup
{
	movingEnable = true;
	idc = 503;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.297917 * safezoneW;
	h = 0.226000 * safezoneH;

	class Controls
	{

		class MCC_respawnDialogframe: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;

			w = 0.297917* safezoneW;
			h = 0.226000* safezoneH;
			colorBackground[] = {0,0,0,0};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};
		class MCC_respawnDialogTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			idc = -1;
			text = "Start Locations"; //--- ToDo: Localize;
			colorText[] = {0.89,0.90,0.91,1};

			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.281917* safezoneW;
			h = 0.030000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class MCC_respawnDialogConfirm: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[MCC_currentSide] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\mcc_start_location.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 503) ctrlShow false";	//hides the panel so the map can be clicked

			text = "Set"; //--- ToDo: Localize;
			x = 0.232617* safezoneW;
			y = 0.196000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
		class MCC_respawnSideTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Side"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.281917* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};
		class MCC_respawnSideCheck: MCC_RscToolbox
		{
			idc = -1;
			strings[]={"West","East","Resistance","Civilian"};
			rows=1;
			columns=4;
			values[] = {0, 1, 2, 3};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
			onToolBoxSelChanged = "MCC_currentSide = (_this select 1);";

			x = 0.008000* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.281917* safezoneW;
			h = 0.022000* safezoneH;
		};
		class MCC_respawnteleportTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Insertion"; //--- ToDo: Localize;

			x = 0.008000* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.281917* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";	//same text size as the Spawn panel
		};
		class MCC_respawnteleportCombo: MCC_RscCombo
		{
			idc = 201212;
			x = 0.008000* safezoneW;
			y = 0.160000* safezoneH;
			w = 0.281917* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};

		class MCC_respawnFOBTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Start"; //--- ToDo: Localize;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";

			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.281917* safezoneW;
			h = 0.018000* safezoneH;
		};
		class MCC_respawnFOBCombo: MCC_RscCombo
		{
			idc = 21;
			x = 0.008000* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.281917* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "If Role Selection is on, the position can be set as a FOB (optional respawn location)"; //--- ToDo: Localize;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};

		class MCC_respawnDialogStartRespawnMenu: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "closedialog 0;[] remoteExec ['MCC_fnc_startLocations',0]";

			text = "Activate Respawn"; //--- ToDo: Localize;
			tooltip = "Enable respawn and force dialog on all players if enabled in MCC settings";
			x = 0.171317* safezoneW;
			y = 0.196000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};

		class MCC_respawnDialogClose: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 503) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.196000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};