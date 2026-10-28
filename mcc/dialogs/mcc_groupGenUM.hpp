#define MCC_UM_LIST 3069
#define MCC_UM_PIC 3070
#define MCC_UM_KICK 3076
#define MCC_UM_BAN 3077

class MCC_UMDialogControls:MCC_RscControlsGroup
{
	idc = 519;
	x = 0.372229 * safezoneW + safezoneX;
	y = 0.642576 * safezoneH + safezoneY;
	w = 0.464605 * safezoneW;
	h = 0.173948 * safezoneH;

	class Controls
	{
		class MCC_UMDialogControlsFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			style = 48;
			idc = 9112;
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			colorBackground[] = {0,0,0,0};
			
			w = 0.464605 * safezoneW;
			h = 0.173948 * safezoneH;
		};
		
		class MCC_gaiaBehaviorButton: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "if (!isnil 'MCC_GroupGenGroupSelected') then {if (count MCC_GroupGenGroupSelected > 0) then {{_x setVariable ['GAIA_ZONE_INTEND',[mcc_zone_markername,((MCC_spawn_behaviors select MCC_behavior_index) select 1)], true]}foreach MCC_GroupGenGroupSelected}};";

			text = "Give to Gaia"; //--- ToDo: Localize;
			x =0.006000 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.057292 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Give the selected groups to GAIA control with the selected zone and behavior"; //--- ToDo: Localize;
		};
		class MCC_giveToPlayer: MCCBTN_S
		{
			idc = 10232; // idc 10232 set to allow button disablement in mcc_groupGen_init.sqf
			onButtonClick = "if (!isnil 'MCC_GroupGenGroupSelected') then {if (count MCC_GroupGenGroupSelected > 0) then {{_x setVariable ['MCC_canbecontrolled',true,true]; _x setVariable ['GAIA_ZONE_INTEND',[],true]}foreach MCC_GroupGenGroupSelected}};";

			text = "Give to Player"; //--- ToDo: Localize;
			x =0.006000 * safezoneW;
			y = 0.033991 * safezoneH;
			w = 0.057292 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Give the selected groups to the player's control with the commander console"; //--- ToDo: Localize;
		};
		class MCC_cacheButton: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "if (!isnil 'MCC_GroupGenGroupSelected') then {if (count MCC_GroupGenGroupSelected > 0) then {{_x setVariable ['mcc_gaia_cache', !(_x getVariable ['mcc_gaia_cache',false]),true];}foreach MCC_GroupGenGroupSelected}};";
			tooltip = "Give the selected groups to the caching system";
			text = "Cache Group"; //--- ToDo: Localize;

			x = 0.006000 * safezoneW;
			y = 0.061983 * safezoneH;
			w = 0.057292 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_UMHijak: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[2] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");

			text = "Hijack"; //--- ToDo: Localize;
			x = 0.006000 * safezoneW;
			y = 0.117966 * safezoneH;
			w = 0.057292 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Hijack the selected unit (non-player units only) "; //--- ToDo: Localize;
		};
		class MCC_UMMark: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[3] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");

			text = "Track units"; //--- ToDo: Localize;
			x = 0.235167 * safezoneW;
			y = 0.089974 * safezoneH;
			w = 0.057292 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Toggle tracking of all units on the mission maker's map"; //--- ToDo: Localize;
		};
		class MCC_UMUnitsBg0: MCC_RscText
		{
			idc = -1;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_wide_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.069621 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.033175 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_UMUnitsBg1: MCC_RscText
		{
			idc = -1;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_wide_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.103996 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.033175 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_PIPviewBg0: MCC_RscText
		{
			idc = -1;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_wide_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.298788 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.043606 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_PIPviewBg1: MCC_RscText
		{
			idc = -1;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_wide_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.343594 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.043606 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_PIPviewBg2: MCC_RscText
		{
			idc = -1;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_wide_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.388399 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.043606 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_PIPfeedBg0: MCC_RscText
		{
			idc = -1;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			x = 0.435205 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.022800 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_UMList: MCC_RscListbox
		{
			idc = MCC_UM_LIST;
			rowHeight = 0.022;
			style = MCCLB_MULTI;
			colorBackground[] = {0.07,0.08,0.09,0.95};
			onSetFocus = "MCC_UMFocus = true";	
			onKillFocus = "MCC_UMFocus = false";	
			onLBSelChanged = __EVAL("[4,_this] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");
			onMouseButtonUp = __EVAL("[8,_this] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";

			x = 0.069021 * safezoneW;
			y = 0.033991 * safezoneH;
			w = 0.160417 * safezoneW;
			h = 0.133957 * safezoneH;
		};
		class MCC_UMUnitsHL: MCC_RscText
		{
			idc = 9136;	//rounded grey box under the chosen Units / Groups (MCC_fnc_umToolboxHighlight)
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_wide_n_ca.paa";
			colorText[] = {1,1,1,0};
			colorBackground[] = {0,0,0,0};
			x = 0.069021 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.034375 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_UMUnits: MCC_RscToolbox
		{
			colorText[] = {0.88,0.89,0.90,1};
			colorTextSelect[] = {0.56,0.75,0.42,1};
			style = 2;	//names centred in their boxes, like Regular / Night Vision / Thermal
			idc = 9134;
			strings[] = {"Units","Groups"};
			rows = 1;
			columns = 2;
			values[] = {0,1};
			onToolBoxSelChanged = "[_this select 1] call MCC_fnc_umModeSwitch; [9134, _this select 1] call MCC_fnc_umToolboxHighlight;";
			colorSelectedBg[] = {0,0,0,0};	//the rounded box under it (9136) marks the choice

			x = 0.069021 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.06875 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Switch display between units and groups from the given side"; //--- ToDo: Localize;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		class MCC_UMTeleport: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[0] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");

			text = "Teleport"; //--- ToDo: Localize;
			x = 0.235167 * safezoneW;
			y = 0.061983 * safezoneH;
			w = 0.057292 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Teleport selected units"; //--- ToDo: Localize;
		};
		class MCC_UMbroadcast: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[11] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");

			text = "Broadcast"; //--- ToDo: Localize;
			x = 0.235167 * safezoneW;
			y = 0.117966 * safezoneH;
			w = 0.057292 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Broadcast the live feed to all players for 25 seconds"; //--- ToDo: Localize;
		};
		class MCC_UMDelete: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[12] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");

			text = "Delete"; //--- ToDo: Localize;
			x = 0.006000 * safezoneW;
			y = 0.145957 * safezoneH;
			w = 0.057292 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Delete the selected unit or group"; //--- ToDo: Localize;
		};
		class MCC_UMJoin: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[13] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");

			text = "Join"; //--- ToDo: Localize;
			x = 0.006000 * safezoneW;
			y = 0.089974 * safezoneH;
			w = 0.057292 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Join group or unit with another group or unit"; //--- ToDo: Localize;
		};
		class MCC_UMHALO: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[9] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");

			text = "HALO"; //--- ToDo: Localize;
			x = 0.235167 * safezoneW;
			y = 0.033991 * safezoneH;
			w = 0.057292 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "HALO the current selected units"; //--- ToDo: Localize;
		};
		class MCC_UMParachute: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[10] execVM '"+MCCPATH+"mcc\general_scripts\unitManage\um.sqf'");

			text = "Airdrop"; //--- ToDo: Localize;
			x = 0.235167 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.057292 * safezoneW;
			h = 0.0219914 * safezoneH;
			tooltip = "Airdrop the currently selected units (parachutes or drop pods)"; //--- ToDo: Localize;
		};
		class MCC_UMListFrame: MCC_RscFrame
		{
			idc = -1;

			x = 0.069021 * safezoneW;
			y = 0.033991 * safezoneH;
			w = 0.160417 * safezoneW;
			h = 0.133957 * safezoneH;
		};
		class MCC_PIPUmBg: MCC_RscText
		{
			idc = -1;
			text = "";
			colorBackground[] = {0.07,0.08,0.09,0.95};
			x = 0.298188 * safezoneW;
			y = 0.033991 * safezoneH;
			w = 0.160417 * safezoneW;
			h = 0.133957 * safezoneH;
		};
		class MCC_PIPUm: MCC_RscPicture
		{
			idc = MCC_UM_PIC;
			colorBackground[] = { 0, 0, 0,1};
			
			text = "";	//blank (black background) until a unit is clicked: not the render target, which was asked for before a camera was bound to it (first feed stayed black), and not a static frame (it stayed on screen)
			x = 0.298188 * safezoneW;
			y = 0.033991 * safezoneH;
			w = 0.160417 * safezoneW;
			h = 0.133957 * safezoneH;
		};
		class MCC_PIPUmFrame: MCC_RscFrame
		{
			idc = -1;

			x = 0.298188 * safezoneW;
			y = 0.033991 * safezoneH;
			w = 0.160417 * safezoneW;
			h = 0.133957 * safezoneH;
		};
		//Right-click the feed to change the camera view
		class MCC_PIPviewHL: MCC_RscText
		{
			idc = 9137;	//rounded grey box under the chosen view (MCC_fnc_umToolboxHighlight)
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_wide_n_ca.paa";
			colorText[] = {1,1,1,0};
			colorBackground[] = {0,0,0,0};
			x = 0.298188 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.048625 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_PIPfeedHL: MCC_RscText
		{
			idc = 9138;	//rounded grey box under On (hidden when Off)
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.434605 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.024 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
		class MCC_PIPviewMod: MCC_RscToolbox
		{
			colorText[] = {0.88,0.89,0.90,1};
			colorTextSelect[] = {0.56,0.75,0.42,1};
			idc = 9133;
			strings[] = {"Regular","Night Vision","Thermal"};
			rows = 1;
			columns = 3;
			values[] = {0,1,3};
			style = 2;	//Regular where it was; the boxes spread so On / Off ends at the right edge of the camera picture
			colorSelectedBg[] = {0,0,0,0};	//the rounded box under it (9137) marks the choice
			onToolBoxSelChanged = "_this execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\general_scripts\unitManage\um_camView.sqf'); [9133, _this select 1] call MCC_fnc_umToolboxHighlight;";

			x = 0.298188 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.134417 * safezoneW;
			h = 0.0219914 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
		//Video feed On / Off (MCC_fnc_umFeedToggle): green On on the rounded box = feed running, red Off = feed switched off
		class MCC_PIPfeedToggle: MCC_RscButton
		{
			idc = 9135;
			text = "On";
			tooltip = "Switch the video feed off / on";
			style = 2;
			colorText[] = {0.56,0.75,0.42,1};
			colorBackground[] = {0,0,0,0};
			colorBackgroundActive[] = {0,0,0,0};
			colorFocused[] = {0,0,0,0};
			colorBackgroundFocused[] = {0,0,0,0};
			offsetPressedX = 0;
			offsetPressedY = 0;
			onButtonClick = "['toggle'] call MCC_fnc_umFeedToggle";

			x = 0.434605 * safezoneW;
			y = 0.006000 * safezoneH;
			w = 0.024 * safezoneW;
			h = 0.0219914 * safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
		};
			};
};
