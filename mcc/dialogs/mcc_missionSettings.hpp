// By: Shay_gman
// Version: 1.1 (September 2011). Restyled to match the MCC console: rounded panel, orange title, rounded buttons;
// it opens over the console and its pages return to the console (mission_settings_change.sqf).
#define missionSettings_IDD 2997

class MCCDLG_NAME
{
	idd = missionSettings_IDD;
	movingEnable = true;
	controlsBackground[] = {};
	objects[] = {};
	class controls
	{
		class MCC_settingsPanel: MCC_RscText
		{
			idc = -1;
			style = 48;
			moving = 1;
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			colorText[] = {0.11,0.12,0.13,0.96};
			colorBackground[] = {0,0,0,0};
			x = 0.3800 * safezoneW + safezoneX;
			y = 0.2500 * safezoneH + safezoneY;
			w = 0.2400 * safezoneW;
			h = 0.4 * safezoneH;
		};
		class MCC_settingsTitle: MCC_RscText
		{
			idc = -1;
			text = "Mission Settings";
			colorText[] = {0.89,0.90,0.91,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			x = 0.3900 * safezoneW + safezoneX;
			y = 0.2600 * safezoneH + safezoneY;
			w = 0.2200 * safezoneW;
			h = 0.035 * safezoneH;
		};
		class MissionSettingsButton: MCCBTN_R
		{
			idc = -1;
			text = "Mission Settings";
			action = __EVAL("[0] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\mission_settings_change.sqf'");
			x = 0.3900 * safezoneW + safezoneX;
			y = 0.3050 * safezoneH + safezoneY;
			w = 0.2200 * safezoneW;
			h = 0.0329871 * safezoneH;
		};
		class UISettingsButton: MCCBTN_R
		{
			idc = -1;
			text = "UI Settings";
			action = __EVAL("[1] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\mission_settings_change.sqf'");
			x = 0.3900 * safezoneW + safezoneX;
			y = 0.3500 * safezoneH + safezoneY;
			w = 0.2200 * safezoneW;
			h = 0.0329871 * safezoneH;
		};
		class classMechanicsSettingsButton: MCCBTN_R
		{
			idc = -1;
			text = "Mechanics Settings";
			action = __EVAL("[2] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\mission_settings_change.sqf'");
			x = 0.3900 * safezoneW + safezoneX;
			y = 0.3950 * safezoneH + safezoneY;
			w = 0.2200 * safezoneW;
			h = 0.0329871 * safezoneH;
		};
		class classMedicalSettingsButton: MCCBTN_R
		{
			idc = -1;
			text = "Medical System Settings";
			action = __EVAL("[3] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\mission_settings_change.sqf'");
			x = 0.3900 * safezoneW + safezoneX;
			y = 0.4400 * safezoneH + safezoneY;
			w = 0.2200 * safezoneW;
			h = 0.0329871 * safezoneH;
		};
		class classRSSettingsButton: MCCBTN_R
		{
			idc = -1;
			text = "Role Selection Settings";
			action = __EVAL("[4] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\mission_settings_change.sqf'");
			x = 0.3900 * safezoneW + safezoneX;
			y = 0.4850 * safezoneH + safezoneY;
			w = 0.2200 * safezoneW;
			h = 0.0329871 * safezoneH;
		};
		class classGAIASettingsButton: MCCBTN_R
		{
			idc = -1;
			text = "GAIA Settings";
			action = __EVAL("[5] execVM '"+MCCPATH+"mcc\general_scripts\mission_settings\mission_settings_change.sqf'");
			x = 0.3900 * safezoneW + safezoneX;
			y = 0.5300 * safezoneH + safezoneY;
			w = 0.2200 * safezoneW;
			h = 0.0329871 * safezoneH;
		};
		class CancelButton: MCCBTN_S
		{
			idc = -1;
			text = "Close";
			action = "closeDialog 0";
			x = 0.3900 * safezoneW + safezoneX;
			y = 0.6150 * safezoneH + safezoneY;
			w = 0.0573 * safezoneW;
			h = 0.0219914 * safezoneH;
		};
	};
};
