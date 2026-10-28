#define MCC_MARKER_TEXT 3050
#define MCC_MARKER_COLOR 3051
#define MCC_MARKER_TYPE 3052
#define MCC_MARKER_SHAPE 3053
#define MCC_MARKER_BRUSH 3054
#define MCC_MARKER_AVAILABE 3049

class MCC_markersDialogControls:MCC_RscControlsGroup
{
	idc = 511;
	x = 0.196625 * safezoneW + safezoneX;
	y = 0.134000 * safezoneH + safezoneY;
	w = 0.223438 * safezoneW;
	h = 0.272000 * safezoneH;

	class Controls
	{	
		class MCC_markersDialogFrame: MCC_RscText
		{
			colorText[] = {0.11,0.12,0.13,0.96};
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			style = 48;
			idc = -1;
			colorBackground[] = {0,0,0,0};
			x = 0;
			y = 0;
			w = 0.223438* safezoneW;
			h = 0.272000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";	//same text size as the Spawn panel
		};

		class MCC_markerGeneratorTittle: MCC_RscText
		{
			font = "RobotoCondensedBold";
			style = 0;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)";
			idc = -1;

			text = "Marker Generator"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.008000* safezoneH;
			w = 0.207438* safezoneW;
			h = 0.030000* safezoneH;
			colorText[] = {0.89,0.90,0.91,1};
		};
		
		class MCC_markerColorTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Color"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.099719* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_markerTypeTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Type"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.099719* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_markerShapeTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Shape"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.142000* safezoneH;
			w = 0.099719* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_markerBrushTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Brush"; //--- ToDo: Localize;
			x = 0.008000* safezoneW;
			y = 0.190000* safezoneH;
			w = 0.099719* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_markerTextTittle: MCC_RscText
		{
			colorText[] = {0.62,0.65,0.68,1};
			idc = -1;

			text = "Name"; //--- ToDo: Localize;
			x = 0.115719* safezoneW;
			y = 0.046000* safezoneH;
			w = 0.099719* safezoneW;
			h = 0.018000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.72)";
		};
		class MCC_markerText: MCC_RscText
		{
			idc = MCC_MARKER_TEXT;
			type = 2;

			x = 0.115719* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.099719* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_markerColor: MCC_RscCombo
		{
			idc = MCC_MARKER_COLOR;

			x = 0.008000* safezoneW;
			y = 0.064000* safezoneH;
			w = 0.099719* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_markerType: MCC_RscCombo
		{
			idc = MCC_MARKER_TYPE;

			x = 0.008000* safezoneW;
			y = 0.112000* safezoneH;
			w = 0.099719* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_markerShape: MCC_RscCombo
		{
			idc = MCC_MARKER_SHAPE;

			x = 0.008000* safezoneW;
			y = 0.160000* safezoneH;
			w = 0.099719* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_markerBrush: MCC_RscCombo
		{
			idc = MCC_MARKER_BRUSH;

			x = 0.008000* safezoneW;
			y = 0.208000* safezoneH;
			w = 0.099719* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8)";
		};
		class MCC_markerSpawnMarker: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[0] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\pop_menu\markers_req.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 511) ctrlShow false";	//hides the panel so the map can be clicked

			text = "Marker"; //--- ToDo: Localize;
			x = 0.115719* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.047859* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Create a marker"; //--- ToDo: Localize;
		};
		class MCC_markerSpawnBrush: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[1] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\pop_menu\markers_req.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 511) ctrlShow false";	//hides the panel so the map can be clicked

			text = "Brush"; //--- ToDo: Localize;
			x = 0.167578* safezoneW;
			y = 0.094000* safezoneH;
			w = 0.047859* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Create a brush"; //--- ToDo: Localize;
		};
		class MCC_markerDeleteMarker: MCCBTN_S
		{
			idc = -1;
			onButtonClick = "[2] execVM ((missionNamespace getVariable ['MCC_path','\mcc_sandbox_mod\']) + 'mcc\pop_menu\markers_req.sqf'); ((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 511) ctrlShow false";	//hides the panel so the map can be clicked

			text = "Delete"; //--- ToDo: Localize;
			x = 0.175438* safezoneW;
			y = 0.124000* safezoneH;
			w = 0.040000* safezoneW;
			h = 0.022000* safezoneH;
			tooltip = "Delete the marker or brush with the given name"; //--- ToDo: Localize;
		};
		
		class MCC_markerAvailableCombo: MCC_RscCombo
		{
			idc = MCC_MARKER_AVAILABE;

			x = 0.115719* safezoneW;
			y = 0.124000* safezoneH;
			w = 0.055719* safezoneW;
			h = 0.022000* safezoneH;
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.6)";
		};
		
		class MCC_markerClose: MCCBTN_S
		{
			x = 0.008000* safezoneW;
			idc = -1;
			onButtonClick = "((uiNamespace getVariable 'MCC_groupGen_Dialog') displayCtrl 511) ctrlShow false";

			text = "Close"; //--- ToDo: Localize;
			y = 0.242000* safezoneH;
			w = 0.057300* safezoneW;
			h = 0.022000* safezoneH;
		};
	};
};

