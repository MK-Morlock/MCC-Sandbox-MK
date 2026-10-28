//=================================================================MCC_fnc_rtsFncMountGuns==============================================================================
//	Mount turrets on civilian vehicles
//  Parameter(s):
//     _ctrl: CONTROL
//==============================================================================================================================================================================
private "_obj";
private "_pos";
private "_dir";
private "_damage";
private _res = [];
private _BuildTime = 0;
disableSerialization;
params ["_ctrl"];
_res = param [1, [], [[]]];


if (count MCC_ConsoleGroupSelected <=0) exitWith {};
_obj = MCC_ConsoleGroupSelected select 0;
if !(alive _obj) exitWith {};

_pos = getPos _obj;
_dir = getdir _obj;
_damage = getDammage _obj;

//remove resources
[_res] spawn MCC_fnc_baseResourceReduce;

//get time
_BuildTime = 0;
{
	if ((_x select 0)=="time") exitWith {_BuildTime = (_x select 1)};
} foreach _res;

//eject units
{
	_x action ["EJECT",_obj];
} forEach crew _obj;

deleteVehicle _obj;

_obj = "B_G_Offroad_01_armed_F" createVehicle _pos;
_obj setpos _pos;
_obj setdir _dir;
_obj setDamage _damage;

