#define MCC_CONSOLE_UAV_MISSILE 9109

private _uav = objNull;
disableSerialization;
params ["_action", "_control"];

switch (_action) do
{
	case 0: //Flyhight
	{
		_uav = missionNamespace getVariable ["MCC_ConolseUAV",objNull];
		if (!alive _uav) exitWith {};

		(_control select 0) ctrlSetTooltip str (_control select 1);
		[_uav,sliderPosition (_control select 0)] remoteExec ["MCC_fnc_uavSetHeight",_uav];
	};

	case 1:
	{
		_uav = missionNamespace getVariable ["MCC_ConolseUAV",objNull];
		if (!alive _uav) exitWith {};


		[MCC_ConsoleUAVmissiles param [4, _uav], MCC_ConsoleUAVmissiles select 2] remoteExec ["fire",_uav];
	};

	case 2:
	{
		_uav = missionNamespace getVariable ["MCC_ACConsoleUp",objNull];
		if (!alive _uav) exitWith {};

		(_control select 0) ctrlSetTooltip str (_control select 1);
		[_uav,sliderPosition (_control select 0)] remoteExec ["flyInHeight",_uav];
	};
};