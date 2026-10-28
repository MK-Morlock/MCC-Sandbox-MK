#define MCC_JUKEBOX_VOLUME 3059
#define MCC_JUKEBOX_TRACK 3060
#define MCC_JUKEBOX_ACTIVATE 3061
#define MCC_JUKEBOX_CONDITION 3062
#define MCC_JUKEBOX_ZONE 3063

class MCC_jukeboxDialogControls: MCC_RscControlsGroup
{
	idc = 514;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.171875 * safezoneW;
	h = 0.350000 * safezoneH;

	class Controls
	{			
		class MCC_jukeboxDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};
			
			w = 0.171875* safezoneW;
			h = 0.350000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};

		class MCC_JukeboxTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			idc = -1;

			text = "Juke Box"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.155875* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
		};
		class MCC_JukeboxMusic: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[6] execVM '"+MCCPATH+"mcc\general_scripts\jukebox\jukebox.sqf'");

			text = "Music"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.075937* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Switch to music tracks"; //--- ToDo: Localize;
		};
		class MCC_JukeboxSound: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[7] execVM '"+MCCPATH+"mcc\general_scripts\jukebox\jukebox.sqf'");

			text = "Sound"; //--- ToDo: Localize;
			x = 0.087938* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.075937* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Switch to sound tracks"; //--- ToDo: Localize;
		};
		class MCC_JukeboxTrackTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Track"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.076000* safezoneH;
			w = 0.155875* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_JukeboxVolumeTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Volume"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.124000* safezoneH;
			w = 0.155875* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_JukeboxActivateTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Activate"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.172000* safezoneH;
			w = 0.155875* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_JukeboxConditionTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Condition"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.220000* safezoneH;
			w = 0.155875* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_JukeboxZoneTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Zone"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.268000* safezoneH;
			w = 0.155875* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_JukeboxLink: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[5] execVM '"+MCCPATH+"mcc\general_scripts\jukebox\jukebox.sqf'");

			text = "Link"; //--- ToDo: Localize;
			x = 0.123875* safezoneW;
			y = 0.286000* safezoneH;
			w = 0.040000* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Link the sound or music to the selected zone"; //--- ToDo: Localize;
		};
		class MCC_JukeboxVolume: MCC_RscXSliderH
		{
			idc = MCC_JUKEBOX_VOLUME;
			tooltip = "Volume: left = silent, right = full";
			onLoad = "(_this select 0) sliderSetRange [0, 1]; (_this select 0) sliderSetSpeed [0.05, 0.1]";
			onSliderPosChanged = __EVAL("[4] execVM '"+MCCPATH+"mcc\general_scripts\jukebox\jukebox.sqf'");

			x = 0.008000* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.107875* safezoneW;
			h = 0.022000* safezoneH;
		};
		class MCC_JukeboxTrack: MCC_RscCombo
		{
			idc = MCC_JUKEBOX_TRACK;

			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.155875* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_JukeboxActivate: MCC_RscCombo
		{
			idc = MCC_JUKEBOX_ACTIVATE;

			x = 0.008000* safezoneW;
			y = 0.190000* safezoneH;
			w = 0.155875* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_JukeboxCondition: MCC_RscCombo
		{
			idc = MCC_JUKEBOX_CONDITION;

			x = 0.008000* safezoneW;
			y = 0.238000* safezoneH;
			w = 0.155875* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_JukeboxZone: MCC_RscCombo
		{
			idc = MCC_JUKEBOX_ZONE;

			x = 0.008000* safezoneW;
			y = 0.286000* safezoneH;
			w = 0.111875* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_JukeboxPlay: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\jukebox\jukebox.sqf'");

			text = ">"; //--- ToDo: Localize;
			x = 0.119875* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.020000* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Play track"; //--- ToDo: Localize;
		};
		class MCC_JukeboxStop: MCCBTN_S
		{
			idc = -1;
			onButtonClick = __EVAL("[3] execVM '"+MCCPATH+"mcc\general_scripts\jukebox\jukebox.sqf'");

			text = "[]"; //--- ToDo: Localize;
			x = 0.143875* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.020000* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Stop track"; //--- ToDo: Localize;
		};
		
		class MCC_jukeboxClose: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 514) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.320000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Link the sound or music to the selected zone"; //--- ToDo: Localize;
		};
	};
};

