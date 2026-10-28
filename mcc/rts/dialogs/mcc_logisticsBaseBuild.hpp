// By: Shay_gman
// Version: 1 (September 2014)

//-----------------------------------------------------------------------------
// Main dialog
//-----------------------------------------------------------------------------
class MCC_LOGISTICS_BASE_BUILD
{
	idd = -1;
	movingEnable = 1;
	onLoad = __EVAL("_this execVM '"+MCCPATH+"mcc\rts\scripts\mcc_logisticsBaseBuild.sqf'");

	class controlsBackground
	{
		class mouseArea: MCC_RscListBox
		{
			idc = 2;
			colorBackground[] = {0,0,0,0};
			shadow = false;
			x = -0.000156274 * safezoneW + safezoneX;
			y = -0.00599999 * safezoneH + safezoneY;
			w = 1.00547 * safezoneW;
			h = 0.759 * safezoneH;

			onMouseMoving = "MCC_mousePos = [ _this select 1,_this select 2 ];";
			onMouseExit = "MCC_mousePos = nil;";
			onMouseZChanged = "if (!isNil 'MCC_CONST_PLACEHOLDER' && {!isNull MCC_CONST_PLACEHOLDER}) then {MCC_CONST_PLACEHOLDER setDir ((getDir MCC_CONST_PLACEHOLDER) + (([-1, 1] select ((_this select 1) > 0)) * ([2, 15] select (uiNamespace getVariable ['MCC_LOGISTICS_BASE_BUILD_SHIFT', false])))); missionNamespace setVariable ['MCC_rtsFortDir', getDir MCC_CONST_PLACEHOLDER]; [true] call MCC_fnc_rtsPreviewMove};";
		};

		class bottomData: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};
			x = -0.0207813 * safezoneW + safezoneX;
			y = 0.753 * safezoneH + safezoneY;
			w = 1.02094 * safezoneW;
			h = 0.253 * safezoneH;
		};

		class mapSkirt: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};
			x = -0.000156274 * safezoneW + safezoneX;
			y = 0.665 * safezoneH + safezoneY;
			w = 0.225 * safezoneW;
			h = 0.088 * safezoneH;
		};

		class frameMiddle: MCC_RscText
		{
			idc = -1;

			x = 0.226719 * safezoneW + safezoneX;
			y = 0.764 * safezoneH + safezoneY;
			w = 0.417656 * safezoneW;
			h = 0.242 * safezoneH;
			style = 48;
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			colorText[] = {0.17,0.19,0.21,0.92};
			colorBackground[] = {0,0,0,0};
		};
		class frameLeft: MCC_RscText
		{
			idc = -1;

			x = 0.649531 * safezoneW + safezoneX;
			y = 0.764 * safezoneH + safezoneY;
			w = 0.345469 * safezoneW;
			h = 0.253 * safezoneH;
			style = 48;
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			colorText[] = {0.17,0.19,0.21,0.92};
			colorBackground[] = {0,0,0,0};
		};
		class frameRight: MCC_RscText
		{
			idc = -1;

			x = -0.000156274 * safezoneW + safezoneX;
			y = 0.665 * safezoneH + safezoneY;
			w = 0.225 * safezoneW;
			h = 0.352 * safezoneH;
			style = 48;
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			colorText[] = {0.17,0.19,0.21,0.92};
			colorBackground[] = {0,0,0,0};
		};
	};


	//---------------------------------------------
	objects[] =
	{
	};

	class controls
	{
		class side1Icon: MCC_RscPicture
		{
			idc = 23;
			style = 2096;
			colorText[] = {1,1,1,0.9};
			x = 0.5 * safezoneW + safezoneX;
			y = 0.008 * safezoneH + safezoneY;
			w = 0.03 * safezoneW;
			h = 0.05 * safezoneH;
		};
		class side2Icon: MCC_RscPicture
		{
			idc = 24;
			style = 2096;
			colorText[] = {1,1,1,0.9};
			x = 0.5 * safezoneW + safezoneX;
			y = 0.008 * safezoneH + safezoneY;
			w = 0.03 * safezoneW;
			h = 0.05 * safezoneH;
		};
		class side3Icon: MCC_RscPicture
		{
			idc = 25;
			style = 2096;
			colorText[] = {1,1,1,0.9};
			x = 0.5 * safezoneW + safezoneX;
			y = 0.008 * safezoneH + safezoneY;
			w = 0.03 * safezoneW;
			h = 0.05 * safezoneH;
		};
		class side1Score: MCC_RscText
		{
			idc = 20;
			font = "RobotoCondensedBold";
			shadow = 2;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};

			style = 0x02;
			x = 0.412344 * safezoneW + safezoneX;
			y = 0.00500001 * safezoneH + safezoneY;
			w = 0.0567187 * safezoneW;
			h = 0.033 * safezoneH;
		};

		class side2Score: MCC_RscText
		{
			idc = 21;
			font = "RobotoCondensedBold";
			shadow = 2;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};

			style = 0x02;
			x = 0.474219 * safezoneW + safezoneX;
			y = 0.00500001 * safezoneH + safezoneY;
			w = 0.0567187 * safezoneW;
			h = 0.033 * safezoneH;
		};

		class side3Score: MCC_RscText
		{
			idc = 22;
			font = "RobotoCondensedBold";
			shadow = 2;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};

			style = 0x02;
			x = 0.536094 * safezoneW + safezoneX;
			y = 0.00500001 * safezoneH + safezoneY;
			w = 0.0567187 * safezoneW;
			h = 0.033 * safezoneH;
		};

		class selectedTile: MCC_RscText
		{
			idc = 9140;
			style = 48;
			text = "\mcc_sandbox_mod\data\btn_round_sq_n_ca.paa";
			colorText[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0};
			x = 0.474219 * safezoneW + safezoneX;
			y = 0.79 * safezoneH + safezoneY;
			w = 0.036 * safezoneW;
			h = 0.064 * safezoneH;
		};
		class selectedPic: MCC_RscPicture
		{
			idc = 9141;
			x = 0.474219 * safezoneW + safezoneX;
			y = 0.79 * safezoneH + safezoneY;
			w = 0.036 * safezoneW;
			h = 0.064 * safezoneH;
		};
		class infoText: MCC_RscStructuredText
		{
			idc = 9999;
			size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.75)";
			colorBackground[] = {0,0,0,0};
			x = 0.516 * safezoneW + safezoneX;
			y = 0.786 * safezoneH + safezoneY;
			w = 0.128 * safezoneW;
			h = 0.209 * safezoneH;
		};

		class feedBackText: MCC_RscText
		{
			idc = 9989;
			style = 2;
			//colorText[] = {1,0,0,0.8};
			x = 0.29375 * safezoneW + safezoneX;
			y = 0.698 * safezoneH + safezoneY;
			w = 0.4125 * safezoneW;
			h = 0.066 * safezoneH;
		};

		class mouseFeedBackText: MCC_RscText
		{
			idc = 9191;
			style = 2;
			//colorText[] = {1,0,0,0.8};
			x = 0 * safezoneW + safezoneX;
			y = 0 * safezoneH + safezoneY;
			w = 0 * safezoneW;
			h = 0 * safezoneH;
		};

		class selectBox: MCC_RscFrame
		{
			idc = 9929;
			x = 0;
			y = 0;
			w = 0;
			h = 0;
		};
		#include "rscRtsResources.hpp"
		#include "rscRtsManageSelected.hpp"

		class placePrompt: MCC_RscStructuredText
		{
			idc = 9137;
			colorBackground[] = {0.05,0.07,0.10,0.82};
			size = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
			x = 0.32 * safezoneW + safezoneX;
			y = 0.055 * safezoneH + safezoneY;
			w = 0.36 * safezoneW;
			h = 0.058 * safezoneH;
		};
		class mapLocation: MCC_RscText
		{
			idc = 9136;
			font = "RobotoCondensedBold";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85)";
			colorText[] = {0.88,0.90,0.92,1};
			x = 0.008 * safezoneW + safezoneX;
			y = 0.669 * safezoneH + safezoneY;
			w = 0.21 * safezoneW;
			h = 0.025 * safezoneH;
		};
		class map: MCC_RscMapControl
		{
			idc = 9120;
			x = 0.005 * safezoneW + safezoneX;
			y = 0.696 * safezoneH + safezoneY;
			w = 0.216563 * safezoneW;
			h = 0.299 * safezoneH;

			onMouseButtonDown = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\console\mouseDown.sqf'");
			onMouseButtonUp = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\console\mouseUp.sqf'");
			onMouseButtonDblClick = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\console\mouseDblClick.sqf'");
			onMouseMoving = __EVAL("[_this] execVM '"+MCCPATH+"mcc\general_scripts\console\mouseMoving.sqf'");
		};
	};
};
