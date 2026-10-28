//============================================================MCC_fnc_curatorVehicleSpawner======================================================================================
// Create a vhicles kiosk
//===========================================================================================================================================================================
private "_pos";
private _module = objNull;
private _resualt = [];
private _array = [];
_module = _this param [0, objNull, [objNull]];
if (isNull _module) exitWith {};

_pos = getpos _module;
_array = ["vehicle","tank","heli","jet","ship","units"];

//Not curator exit
if (!(local _module) || isnull curatorcamera) exitWith {};

_resualt = ["Vehicle Kiosk",[
							["Type",["Vehicles","Armored","Helicopters","Fixed Wing","Ships","Units"]],
							["Side Purchase",false]
							]] call MCC_fnc_initDynamicDialog;

if (count _resualt == 0) exitWith {};

_module setVariable ["type", (_array select (_resualt select 0)) ,true];
_module setVariable ["spawnFrom", if (_resualt select 1) then {1} else {0} ,true];
//The kiosk is set up on the server (see MCC_fnc_vehicleSpawnerInit)
if (isServer) then {[_module,[]] spawn MCC_fnc_vehicleSpawnerInit} else {[_module,[]] remoteExec ["MCC_fnc_vehicleSpawnerInit",2]};