class MCC_sidebarControls: MCC_RscControlsGroup
{
	idc = -1;
	x = 0.105 * safezoneW + safezoneX;
	y = 0.0711672 * safezoneH + safezoneY;
	w = 0.080208 * safezoneW;
	h = 0.759000 * safezoneH;
	class Controls
	{
		class MCC_sidebarFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			style = 48;
			idc = 9110;
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			colorBackground[] = {0,0,0,0};
			x = 0;
			y = 0;
			w = 0.080208 * safezoneW;
			h = 0.759000 * safezoneH;
		};
		class MCC_sideHeadFORCES: MCC_RscText
		{
			idc = -1;
			text = "FORCES";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.6)";
			colorText[] = {0.55,0.58,0.62,1};
			font = "RobotoCondensed";
			x = 0.006 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.068208 * safezoneW;
			h = 0.019000 * safezoneH;
		};
		class MCC_groupGenSpawnButton: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Spawn units or groups";
			onButtonClick = __EVAL("[6] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			text = "Spawn";
			x = 0.003 * safezoneW;
			y = 0.025000 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_callConvoyButton: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Open Convoy Menu";
			onButtonClick = __EVAL("[9] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			text = "Convoy";
			x = 0.003 * safezoneW;
			y = 0.048600 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_callIEDButton: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Open IEDs Menu";
			onButtonClick = __EVAL("[8] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			text = "IED";
			x = 0.003 * safezoneW;
			y = 0.072200 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_sideHeadSUPPORT: MCC_RscText
		{
			idc = -1;
			text = "SUPPORT";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.6)";
			colorText[] = {0.55,0.58,0.62,1};
			font = "RobotoCondensed";
			x = 0.006 * safezoneW;
			y = 0.099700 * safezoneH;
			w = 0.068208 * safezoneW;
			h = 0.019000 * safezoneH;
		};
		class MCC_callCASButton: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Open Close Air Support Menu";
			onButtonClick = __EVAL("[4] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			text = "CAS";
			x = 0.003 * safezoneW;
			y = 0.118700 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_callArtilleryButton: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Open artillery Menu";
			onButtonClick = __EVAL("[5] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			text = "Artillery";
			x = 0.003 * safezoneW;
			y = 0.142300 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_AC130Button: MCCBTN_SIDE
		{
			idc = 620; // idc set to allow hiding button when no mcc_console available
			tooltip = "Call a gunship (your faction gunship if it has one, otherwise the Blackfish): then click and drag on the map to set the area and approach direction. Control its guns from the MCC Commander Console";
			onButtonClick = "if !(call MCC_fnc_supportFactionOK) exitWith {}; MCC_CASrequestMarker = true;MCC_spawnkind = ['ac-130'];MCC_planeType = [call MCC_fnc_gunshipClass];[parseText '<t size=''1.1'' color=''#33CC00''>Gunship</t><br/>Click and drag on the map to draw an arrow. It circles over the middle of the arrow and flies in from the direction the arrow points from.<br/><br/>Its guns are controlled from the MCC Commander Console (Live Feed / AC-130). Press Gunship again and drag to send it away.'] call MCC_fnc_hintBrief";
			text = "Gunship";
			x = 0.003 * safezoneW;
			y = 0.165900 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_airdropButton: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Open Supply Drop Menu";
			onButtonClick = __EVAL("[16] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			text = "Supply Drop";
			x = 0.003 * safezoneW;
			y = 0.189500 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_paradropButton: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Paradrop settings: aircraft and height for paratrooper and HALO drops";
			onButtonClick = __EVAL("[18] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			text = "Paradrop";
			x = 0.003 * safezoneW;
			y = 0.213100 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_callEvacButton: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Open Evac Menu";
			onButtonClick = __EVAL("[7] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			text = "Evac";
			x = 0.003 * safezoneW;
			y = 0.236700 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_sideHeadMISSION: MCC_RscText
		{
			idc = -1;
			text = "MISSION";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.6)";
			colorText[] = {0.55,0.58,0.62,1};
			font = "RobotoCondensed";
			x = 0.006 * safezoneW;
			y = 0.264200 * safezoneH;
			w = 0.068208 * safezoneW;
			h = 0.019000 * safezoneH;
		};
		class MCC_openMWButton: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = "createDialog ('MCCMWDialog' + (['', 'Buttons'] select (profileNamespace getVariable ['MCC_consoleButtons', false])))";
			tooltip = "Open mission Generator";
			text = "Mission Generator";
			x = 0.003 * safezoneW;
			y = 0.283200 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_deleteMissionsButton: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = "[] spawn MCC_fnc_deleteMissionDialog";
			tooltip = "Delete a generated mission (Mission Generator, campaign or Front Lines) with its tasks, AI, objects, mines and map markers";
			text = "Delete Missions";
			x = 0.003 * safezoneW;
			y = 0.306800 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_briefingCallButton: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = __EVAL("[11] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			tooltip = "Open Briefing Menu"; //--- ToDo: Localize;
			text = "Briefing";
			x = 0.003 * safezoneW;
			y = 0.330400 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_tasksCallButton: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = __EVAL("[12] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			tooltip = "Open Tasks Menu"; //--- ToDo: Localize;
			text = "Tasks";
			x = 0.003 * safezoneW;
			y = 0.354000 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_triggersCallButton: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = __EVAL("[14] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			tooltip = "Open Triggers Menu"; //--- ToDo: Localize;
			text = "Triggers";
			x = 0.003 * safezoneW;
			y = 0.377600 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_markersCallButton: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = __EVAL("[10] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			tooltip = "Open Markers Menu"; //--- ToDo: Localize;
			text = "Markers";
			x = 0.003 * safezoneW;
			y = 0.401200 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_StartLocation: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = __EVAL("[2] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			tooltip = "Open Locations Menu"; //--- ToDo: Localize;
			text = "Start Locations";
			x = 0.003 * safezoneW;
			y = 0.424800 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_MissionSettings: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Open Mission Settings Menu"; //--- ToDo: Localize;
			onButtonClick = "if (mcc_missionmaker == (name player)) then {createDialog ('missionSettings' + (['', 'Buttons'] select (profileNamespace getVariable ['MCC_consoleButtons', false])));} else {player globalchat 'Access Denied'};";
			text = "Mission Settings";
			x = 0.003 * safezoneW;
			y = 0.448400 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_sideHeadWORLD: MCC_RscText
		{
			idc = -1;
			text = "WORLD";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.6)";
			colorText[] = {0.55,0.58,0.62,1};
			font = "RobotoCondensed";
			x = 0.006 * safezoneW;
			y = 0.475900 * safezoneH;
			w = 0.068208 * safezoneW;
			h = 0.019000 * safezoneH;
		};
		class MCC_setWeatherButton: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			tooltip = "Open Weather Menu"; //--- ToDo: Localize;
			text = "Weather";
			x = 0.003 * safezoneW;
			y = 0.494900 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_setTimeButton: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			tooltip = "Open Time Menu"; //--- ToDo: Localize;
			text = "Time";
			x = 0.003 * safezoneW;
			y = 0.518500 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_DeleteButton: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Brushes Menu";
			onButtonClick = __EVAL("[17] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			text = "Brushes";
			x = 0.003 * safezoneW;
			y = 0.542100 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_jukeBoxCallButton: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = __EVAL("[13] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			tooltip = "Open Jukebox Menu"; //--- ToDo: Localize;
			text = "Jukebox";
			x = 0.003 * safezoneW;
			y = 0.565700 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_sideHeadADMIN: MCC_RscText
		{
			idc = -1;
			text = "ADMIN";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.6)";
			colorText[] = {0.55,0.58,0.62,1};
			font = "RobotoCondensed";
			x = 0.006 * safezoneW;
			y = 0.593200 * safezoneH;
			w = 0.068208 * safezoneW;
			h = 0.019000 * safezoneH;
		};
		class MCC_curatorButton: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Click on map to open BIS Zeus";
			onButtonClick = "uiNameSpace setVariable ['MCC_ZeusOpen',true]";
			text = "Zeus";
			x = 0.003 * safezoneW;
			y = 0.612200 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_arsenalButton: MCCBTN_SIDE
		{
			idc = -1;
			tooltip = "Click to open BIS arsenal";
			onButtonClick = "closeDialog 0; ['Open',true] call BIS_fnc_arsenal;";
			text = "Arsenal";
			x = 0.003 * safezoneW;
			y = 0.635800 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_roleSelectionButton: MCCBTN_SIDE
		{
			idc = 520;
			tooltip = "Enable/Disable Role Selection";
			onButtonClick =  __EVAL("[6] execVM '"+MCCPATH+"mcc\general_scripts\mcc_start_location.sqf'");
			text = "";
			x = 0.003 * safezoneW;
			y = 0.659400 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_StartDisableRespawn: MCCBTN_SIDE
		{
			idc = 9140;
			tooltip = "Disable respawn to all players";
			action = "[] spawn MCC_fnc_toggleRespawn";	//toggles: Disable Respawn / Enable Respawn (MCC_fnc_respawnButton)
			text = "Disable Respawn";
			x = 0.003 * safezoneW;
			y = 0.683000 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_debugButton: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = __EVAL("[3] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			tooltip = "Open Debug Menu"; //--- ToDo: Localize;
			text = "Debug";
			x = 0.003 * safezoneW;
			y = 0.706600 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
		class MCC_clientSideCallButton: MCCBTN_SIDE
		{
			idc = -1;
			onButtonClick = __EVAL("[15] execVM '"+MCCPATH+"mcc\general_scripts\groupGen\controlsHandle.sqf'");
			tooltip = "Open Client Side Menu"; //--- ToDo: Localize;
			text = "Client Side";
			x = 0.003 * safezoneW;
			y = 0.730200 * safezoneH;
			w = 0.074208 * safezoneW;
			h = 0.022000 * safezoneH;
		};
	};
};
