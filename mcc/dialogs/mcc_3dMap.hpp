class MCC_3DMapDialog
{
	idd = 8090;
	movingEnable = false;
	enableSimulation = true;
	onLoad = "uiNamespace setVariable ['MCC_3DMapDialog', _this select 0]; private _m = (_this select 0) displayCtrl 1; _m ctrlAddEventHandler ['Draw', '_this call MCC_fnc_trackUnits;']; if (!isNil 'MCC_3D_CAM') then {_m ctrlMapAnimAdd [0, 0.1, getPosATL MCC_3D_CAM]; ctrlMapAnimCommit _m};";
	class controlsBackground
	{
		class MCC_3DMapBack: MCC_RscText
		{
			idc = -1;
			style = 48;
			text = "\mcc_sandbox_mod\data\panel_round_ca.paa";
			colorText[] = {0.08,0.10,0.12,0.94};
			colorBackground[] = {0,0,0,0};
			x = 0.2 * safezoneW + safezoneX;
			y = 0.12 * safezoneH + safezoneY;
			w = 0.6 * safezoneW;
			h = 0.76 * safezoneH;
		};
	};
	class controls
	{
		class MCC_3DMapTitle: MCC_RscText
		{
			idc = -1;
			text = "Click the map to move the camera   |   Esc to close";
			font = "RobotoCondensedBold";
			sizeEx = "(((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.9)";
			colorText[] = {0.91,0.93,0.95,1};
			x = 0.21 * safezoneW + safezoneX;
			y = 0.128 * safezoneH + safezoneY;
			w = 0.58 * safezoneW;
			h = 0.03 * safezoneH;
		};
		class MCC_3DMapMap: MCC_RscMapControl
		{
			idc = 1;
			onMouseButtonClick = "if ((_this select 1) == 0) then {[(_this select 0) ctrlMapScreenToWorld [_this select 2, _this select 3]] call MCC_3D_moveTo; closeDialog 0}; false";
			x = 0.21 * safezoneW + safezoneX;
			y = 0.162 * safezoneH + safezoneY;
			w = 0.58 * safezoneW;
			h = 0.708 * safezoneH;
		};
	};
};
class MCC_3DMiniMapDialog
{
	idd = 8091;
	movingEnable = false;
	enableSimulation = true;
	onLoad = "private _m = (_this select 0) displayCtrl 1; _m ctrlAddEventHandler ['Draw', '_this call MCC_fnc_trackUnits;']; if (!isNil 'MCC_3D_CAM') then {_m ctrlMapAnimAdd [0, uiNamespace getVariable ['MCC3D_DialogMapScale', 0.15], getPosATL MCC_3D_CAM]; ctrlMapAnimCommit _m};";
	onKeyUp = "if ((_this select 1) == 56) then {closeDialog 0}; false";
	class controls
	{
		class MCC_3DMiniMapMap: MCC_RscMapControl
		{
			idc = 1;
			onMouseButtonDblClick = __EVAL("[_this,1] execVM '"+MCCPATH+"mcc\general_scripts\3Deditor\mouseDown.sqf'");
			x = 0.78073 * safezoneW + safezoneX;
			y = 0.719914 * safezoneH + safezoneY;
			w = 0.223438 * safezoneW;
			h = 0.285889 * safezoneH;
		};
	};
};
