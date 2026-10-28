//=================================================================MCC_fnc_rtsOrderGetout==============================================================================
//	Stop WP
//  Parameter(s):
//     _ctrl: CONTROL
//==============================================================================================================================================================================
private "_group";
private "_vehicle";
private _groups = [];
private _vehicles = [];

if (count MCC_ConsoleGroupSelected <=0) exitWith {};

_vehicles = [];
{
	_group = _x;
	if (typeName _group == typeName grpNull) then {
		{
			if !(vehicle _x in _vehicles) then {_vehicles pushBack vehicle _x};
		} forEach units _group;
	};
} forEach MCC_ConsoleGroupSelected;

_groups = [];
player globalRadio "CuratorWaypointPlaced";
{
	_vehicle = _x;
	if (count assignedCargo _vehicle > 0) then {
		{
			if !(group _x in _groups) then {_groups pushBack group _x};
		} forEach assignedCargo _vehicle;

		{
			[[_x,_vehicle], {(_this select 0) leaveVehicle (_this select 1);}] remoteExec ["call", leader _x, false];
		} forEach _groups;
	};
} forEach _vehicles;
