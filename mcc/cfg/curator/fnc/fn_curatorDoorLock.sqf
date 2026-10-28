//==========================================================MCC_fnc_curatorDoorLock========================================================================================
// Manage doors status
//===========================================================================================================================================================================
private "_pos";
private _module = objNull;
private _resualt = [];
_module = _this param [0, objNull, [objNull]];
if (isNull _module) exitWith {};

//Not curator exit
if (!(local _module) || isnull curatorcamera) exitWith {};

_pos = getpos _module;

_resualt = ["Lock/Unlock Doors",[
 						["Radius",500],
 						["Lock Doors",["Lock All","Lock Random","Unlock All"]]
 					  ],format ["<t align='center'> %1</t>",localize "STR_Module__lockDoors_description"]] call MCC_fnc_initDynamicDialog;

if (count _resualt == 0) exitWith {deleteVehicle _module};

private _radius = _resualt select 0;

[_pos, _radius, (_resualt select 1)+10] remoteExec ["MCC_fnc_deleteBrush", 2, false];

deleteVehicle _module;