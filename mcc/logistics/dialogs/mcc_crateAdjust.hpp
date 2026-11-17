// (MK) Adjust crates: moves the crates MCC placed on a cargo truck's bed (MCCMK_fnc_crateAdjust)
class MCCMK_CRATE_ADJUST
{
	idd = 9300;
	movingEnable = 0;
	onKeyDown = "if ((_this select 1) in [42, 54]) then {uiNamespace setVariable ['MCCMK_shift', true]}; false";
	onKeyUp = "if ((_this select 1) in [42, 54]) then {uiNamespace setVariable ['MCCMK_shift', false]}; false";
	onUnload = "uiNamespace setVariable ['MCCMK_shift', false]";
	onLoad = "[_this select 0, 'MCCMK_CRATE_ADJUST'] call MCC_fnc_themeButtons";	//(MK) Buttons look: 3D buttons
	class controls
	{
		class MCCMK_adjBg: MCC_RscText
		{
			idc = -1;
			colorBackground[] = {0.11,0.12,0.13,0.95};
			x = 0.698 * safezoneW + safezoneX;
			y = 0.291 * safezoneH + safezoneY;
			w = 0.164 * safezoneW;
			h = 0.385 * safezoneH;
		};
		class MCCMK_adjTitle: MCC_RscText
		{
			idc = -1;
			text = "Adjust crates";
			x = 0.705 * safezoneW + safezoneX;
			y = 0.297 * safezoneH + safezoneY;
			w = 0.15 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCCMK_adjList: MCC_RscListbox
		{
			idc = 9301;
			x = 0.705 * safezoneW + safezoneX;
			y = 0.335 * safezoneH + safezoneY;
			w = 0.15 * safezoneW;
			h = 0.09 * safezoneH;
		};
		class MCCMK_adjFwd: MCC_RscButtonRound
		{
			idc = 9311;
			text = "Forward";
			action = "['move', [0,1,0], (uiNamespace getVariable ['MCCMK_shift', false])] call MCCMK_fnc_crateAdjust;";
			
			x = 0.745 * safezoneW + safezoneX;
			y = 0.435 * safezoneH + safezoneY;
			w = 0.07 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCCMK_adjLeft: MCC_RscButtonRound
		{
			idc = 9312;
			text = "Left";
			action = "['move', [-1,0,0], (uiNamespace getVariable ['MCCMK_shift', false])] call MCCMK_fnc_crateAdjust;";
			
			x = 0.705 * safezoneW + safezoneX;
			y = 0.475 * safezoneH + safezoneY;
			w = 0.07 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCCMK_adjRight: MCC_RscButtonRound
		{
			idc = 9313;
			text = "Right";
			action = "['move', [1,0,0], (uiNamespace getVariable ['MCCMK_shift', false])] call MCCMK_fnc_crateAdjust;";
			
			x = 0.785 * safezoneW + safezoneX;
			y = 0.475 * safezoneH + safezoneY;
			w = 0.07 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCCMK_adjBack: MCC_RscButtonRound
		{
			idc = 9314;
			text = "Back";
			action = "['move', [0,-1,0], (uiNamespace getVariable ['MCCMK_shift', false])] call MCCMK_fnc_crateAdjust;";
			
			x = 0.745 * safezoneW + safezoneX;
			y = 0.515 * safezoneH + safezoneY;
			w = 0.07 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCCMK_adjUp: MCC_RscButtonRound
		{
			idc = 9315;
			text = "Up";
			action = "['move', [0,0,1], (uiNamespace getVariable ['MCCMK_shift', false])] call MCCMK_fnc_crateAdjust;";
			
			x = 0.705 * safezoneW + safezoneX;
			y = 0.555 * safezoneH + safezoneY;
			w = 0.07 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCCMK_adjDown: MCC_RscButtonRound
		{
			idc = 9316;
			text = "Down";
			action = "['move', [0,0,-1], (uiNamespace getVariable ['MCCMK_shift', false])] call MCCMK_fnc_crateAdjust;";
			
			x = 0.785 * safezoneW + safezoneX;
			y = 0.555 * safezoneH + safezoneY;
			w = 0.07 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCCMK_adjTurn: MCC_RscButtonRound
		{
			idc = 9317;
			text = "Rotate 90";
			action = "['turn'] call MCCMK_fnc_crateAdjust;";
			tooltip = "Turn the crate a quarter turn";
			x = 0.705 * safezoneW + safezoneX;
			y = 0.595 * safezoneH + safezoneY;
			w = 0.07 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCCMK_adjReset: MCC_RscButtonRound
		{
			idc = 9318;
			text = "Reset";
			action = "['reset'] call MCCMK_fnc_crateAdjust;";
			tooltip = "Back to the automatic place";
			x = 0.785 * safezoneW + safezoneX;
			y = 0.595 * safezoneH + safezoneY;
			w = 0.07 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCCMK_adjHint: MCC_RscText
		{
			idc = -1;
			text = "10 cm a click, 1 cm with Shift";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			x = 0.705 * safezoneW + safezoneX;
			y = 0.635 * safezoneH + safezoneY;
			w = 0.085 * safezoneW;
			h = 0.033 * safezoneH;
		};
		class MCCMK_adjClose: MCC_RscButtonRound
		{
			idc = 9319;
			text = "Close";
			action = "closeDialog 0;";
			
			x = 0.785 * safezoneW + safezoneX;
			y = 0.635 * safezoneH + safezoneY;
			w = 0.07 * safezoneW;
			h = 0.033 * safezoneH;
		};
	};
};
