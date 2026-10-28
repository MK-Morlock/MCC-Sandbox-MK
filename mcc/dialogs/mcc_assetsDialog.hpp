//Console Assets page: MCC_fnc_assetsUI (3D preview: MCC_fnc_assetsPreview)
class MCCDLG_NAME
{
	idd = 1031985;
	movingEnable = true;
	onLoad = "uiNamespace setVariable ['MCC_assetsStartFaction', missionNamespace getVariable ['MCC_faction_index', 0]]; ['init'] spawn MCC_fnc_assetsUI";
	onUnload = "['close'] call MCC_fnc_assetsPreview;";
	class controls
	{
		class Background: MCC_RscText
		{
			idc = -1;
			colorBackground[] = {0.11,0.12,0.13,0.96};
			moving = 0;	//the window moves by its title only (dragging in the preview moved the whole window)
			x = 0.1300 * safezoneW + safezoneX;
			y = 0.1200 * safezoneH + safezoneY;
			w = 0.7400 * safezoneW;
			h = 0.7000 * safezoneH;
		};
		class Title: MCC_RscText
		{
			idc = 9501;
			text = "MCC Assets";
			moving = 1;
			colorText[] = {0.89,0.90,0.91,1};
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.1400 * safezoneW + safezoneX;
			y = 0.1280 * safezoneH + safezoneY;
			w = 0.7200 * safezoneW;
			h = 0.0250 * safezoneH;
		};
		class FactionTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Enemy faction";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.1400 * safezoneW + safezoneX;
			y = 0.1580 * safezoneH + safezoneY;
			w = 0.0700 * safezoneW;
			h = 0.0250 * safezoneH;
		};
		class Faction: MCC_RscCombo
		{
			idc = 9520;
			tooltip = "The Mission Generator enemy faction: your choices below are saved for it and used for its tasks and support. The console faction (your side) is not changed.";
			onLBSelChanged = "['faction'] spawn MCC_fnc_assetsUI";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.2150 * safezoneW + safezoneX;
			y = 0.1580 * safezoneH + safezoneY;
			w = 0.3850 * safezoneW;
			h = 0.0250 * safezoneH;
		};
		class SlotsTitle: MCC_RscText
		{
			idc = -1;
			text = "Asset (Auto = chosen by faction)";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.1400 * safezoneW + safezoneX;
			y = 0.2050 * safezoneH + safezoneY;
			w = 0.2200 * safezoneW;
			h = 0.0250 * safezoneH;
		};
		class Slots: MCC_RscListbox
		{
			idc = 9502;
			onLBSelChanged = "['selectSlot'] spawn MCC_fnc_assetsUI";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.1400 * safezoneW + safezoneX;
			y = 0.2320 * safezoneH + safezoneY;
			w = 0.2200 * safezoneW;
			h = 0.4700 * safezoneH;
		};
		class Info: MCC_RscStructuredText
		{
			idc = 9503;
			colorBackground[] = {0,0,0,0};
			x = 0.3700 * safezoneW + safezoneX;
			y = 0.2050 * safezoneH + safezoneY;
			w = 0.2300 * safezoneW;
			h = 0.1500 * safezoneH;
		};
		class ListTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Your list for this asset";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.3700 * safezoneW + safezoneX;
			y = 0.3600 * safezoneH + safezoneY;
			w = 0.2300 * safezoneW;
			h = 0.0250 * safezoneH;
		};
		class List: MCC_RscListbox
		{
			idc = 9504;
			onLBSelChanged = "['previewList'] spawn MCC_fnc_assetsUI";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.3700 * safezoneW + safezoneX;
			y = 0.3870 * safezoneH + safezoneY;
			w = 0.2300 * safezoneW;
			h = 0.1500 * safezoneH;
		};
		class Remove: MCCBTN_R
		{
			idc = 9505;
			text = "Remove";
			tooltip = "Remove the selected entry from the list";
			onButtonClick = "['remove'] spawn MCC_fnc_assetsUI";
			x = 0.3700 * safezoneW + safezoneX;
			y = 0.5420 * safezoneH + safezoneY;
			w = 0.0800 * safezoneW;
			h = 0.0300 * safezoneH;
			class TextPos {left = 0; top = "((0.03 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class ResetSlot: MCCBTN_R
		{
			idc = 9509;
			text = "Auto";
			tooltip = "Clear the list: back to Auto for this asset";
			onButtonClick = "['resetSlot'] spawn MCC_fnc_assetsUI";
			x = 0.5200 * safezoneW + safezoneX;
			y = 0.5420 * safezoneH + safezoneY;
			w = 0.0800 * safezoneW;
			h = 0.0300 * safezoneH;
			class TextPos {left = 0; top = "((0.03 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class AddTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Add from";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.3700 * safezoneW + safezoneX;
			y = 0.5850 * safezoneH + safezoneY;
			w = 0.2300 * safezoneW;
			h = 0.0250 * safezoneH;
		};
		class Cands: MCC_RscCombo
		{
			idc = 9506;
			onLBSelChanged = "['previewCand'] spawn MCC_fnc_assetsUI";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.3700 * safezoneW + safezoneX;
			y = 0.6120 * safezoneH + safezoneY;
			w = 0.1700 * safezoneW;
			h = 0.0300 * safezoneH;
		};
		class Add: MCCBTN_R
		{
			idc = 9507;
			text = "Add";
			tooltip = "Add the chosen class to the list";
			onButtonClick = "['add'] spawn MCC_fnc_assetsUI";
			x = 0.5450 * safezoneW + safezoneX;
			y = 0.6120 * safezoneH + safezoneY;
			w = 0.0550 * safezoneW;
			h = 0.0300 * safezoneH;
			class TextPos {left = 0; top = "((0.03 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class ShowAll: MCCBTN_R
		{
			idc = 9508;
			text = "Show all mods: Off";
			tooltip = "Off: the enemy and your faction and their mods. On: every loaded mod";
			onButtonClick = "['showAll'] spawn MCC_fnc_assetsUI";
			x = 0.3700 * safezoneW + safezoneX;
			y = 0.6500 * safezoneH + safezoneY;
			w = 0.2300 * safezoneW;
			h = 0.0300 * safezoneH;
			class TextPos {left = 0; top = "((0.03 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class PreviewTitle: MCC_RscText
		{
			idc = 9532;
			text = "Preview";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.6100 * safezoneW + safezoneX;
			y = 0.2050 * safezoneH + safezoneY;
			w = 0.2500 * safezoneW;
			h = 0.0250 * safezoneH;
		};
		class Preview: MCC_RscPicture
		{
			idc = 9530;
			text = "#(argb,512,512,1)r2t(mccassetrt,1.0)";
			colorBackground[] = {0,0,0,1};
			x = 0.6100 * safezoneW + safezoneX;
			y = 0.2320 * safezoneH + safezoneY;
			w = 0.2500 * safezoneW;
			h = 0.4000 * safezoneH;
		};
		class PreviewHelp: MCC_RscText
		{
			idc = -1;
			text = "Left-drag: turn | Right-drag: move | Wheel: zoom";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)";
			x = 0.6100 * safezoneW + safezoneX;
			y = 0.6350 * safezoneH + safezoneY;
			w = 0.2500 * safezoneW;
			h = 0.0220 * safezoneH;
		};
		class PrevLeft: MCCBTN_S
		{
			idc = -1;
			text = "Left";
			tooltip = "Move the view left";
			onButtonClick = "['panLeft'] call MCC_fnc_assetsPreview";
			x = 0.6100 * safezoneW + safezoneX;
			y = 0.6610 * safezoneH + safezoneY;
			w = 0.0380 * safezoneW;
			h = 0.0280 * safezoneH;
			class TextPos {left = 0; top = "((0.028 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class PrevRight: MCCBTN_S
		{
			idc = -1;
			text = "Right";
			tooltip = "Move the view right";
			onButtonClick = "['panRight'] call MCC_fnc_assetsPreview";
			x = 0.6520 * safezoneW + safezoneX;
			y = 0.6610 * safezoneH + safezoneY;
			w = 0.0380 * safezoneW;
			h = 0.0280 * safezoneH;
			class TextPos {left = 0; top = "((0.028 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class PrevUp: MCCBTN_S
		{
			idc = -1;
			text = "Up";
			tooltip = "Move the view up";
			onButtonClick = "['panUp'] call MCC_fnc_assetsPreview";
			x = 0.6940 * safezoneW + safezoneX;
			y = 0.6610 * safezoneH + safezoneY;
			w = 0.0380 * safezoneW;
			h = 0.0280 * safezoneH;
			class TextPos {left = 0; top = "((0.028 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class PrevDown: MCCBTN_S
		{
			idc = -1;
			text = "Down";
			tooltip = "Move the view down";
			onButtonClick = "['panDown'] call MCC_fnc_assetsPreview";
			x = 0.7360 * safezoneW + safezoneX;
			y = 0.6610 * safezoneH + safezoneY;
			w = 0.0380 * safezoneW;
			h = 0.0280 * safezoneH;
			class TextPos {left = 0; top = "((0.028 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class PrevIn: MCCBTN_S
		{
			idc = -1;
			text = "+";
			tooltip = "Zoom in";
			onButtonClick = "['zoomIn'] call MCC_fnc_assetsPreview";
			x = 0.7780 * safezoneW + safezoneX;
			y = 0.6610 * safezoneH + safezoneY;
			w = 0.0220 * safezoneW;
			h = 0.0280 * safezoneH;
			class TextPos {left = 0; top = "((0.028 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class PrevOut: MCCBTN_S
		{
			idc = -1;
			text = "-";
			tooltip = "Zoom out";
			onButtonClick = "['zoomOut'] call MCC_fnc_assetsPreview";
			x = 0.8040 * safezoneW + safezoneX;
			y = 0.6610 * safezoneH + safezoneY;
			w = 0.0220 * safezoneW;
			h = 0.0280 * safezoneH;
			class TextPos {left = 0; top = "((0.028 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class PrevReset: MCCBTN_S
		{
			idc = -1;
			text = "Reset view";
			tooltip = "Back to the starting view";
			onButtonClick = "['reset'] call MCC_fnc_assetsPreview";
			x = 0.6100 * safezoneW + safezoneX;
			y = 0.6930 * safezoneH + safezoneY;
			w = 0.1000 * safezoneW;
			h = 0.0280 * safezoneH;
			class TextPos {left = 0; top = "((0.028 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class CopyTitle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;
			text = "Copy preset from";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
			x = 0.1400 * safezoneW + safezoneX;
			y = 0.7300 * safezoneH + safezoneY;
			w = 0.1200 * safezoneW;
			h = 0.0300 * safezoneH;
		};
		class CopyFrom: MCC_RscCombo
		{
			idc = 9511;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
			x = 0.2600 * safezoneW + safezoneX;
			y = 0.7300 * safezoneH + safezoneY;
			w = 0.2000 * safezoneW;
			h = 0.0300 * safezoneH;
		};
		class Copy: MCCBTN_R
		{
			idc = 9512;
			text = "Copy";
			tooltip = "Replace this faction preset with the chosen one";
			onButtonClick = "['copy'] spawn MCC_fnc_assetsUI";
			x = 0.4650 * safezoneW + safezoneX;
			y = 0.7300 * safezoneH + safezoneY;
			w = 0.0600 * safezoneW;
			h = 0.0300 * safezoneH;
			class TextPos {left = 0; top = "((0.03 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class ResetAll: MCCBTN_R
		{
			idc = 9510;
			text = "Reset all";
			tooltip = "Every asset of this faction back to Auto";
			onButtonClick = "['resetAll'] spawn MCC_fnc_assetsUI";
			x = 0.760000 * safezoneW + safezoneX;
			y = 0.7720 * safezoneH + safezoneY;
			w = 0.1000 * safezoneW;
			h = 0.0320 * safezoneH;
			class TextPos {left = 0; top = "((0.032 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
		class Close: MCCBTN_R
		{
			idc = -1;
			text = "Close";
			action = "closeDialog 0";
			x = 0.140000 * safezoneW + safezoneX;
			y = 0.7720 * safezoneH + safezoneY;
			w = 0.1000 * safezoneW;
			h = 0.0320 * safezoneH;
			class TextPos {left = 0; top = "((0.032 * safezoneH - (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)) / 2) max 0"; right = 0; bottom = 0;};	//text centred at this height
		};
	};
};
