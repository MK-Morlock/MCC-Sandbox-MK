//===================================================================MCC_fnc_evacSpawn======================================================================================
// Spawn a vehicle with crew and gunners, mark it as an evac vehicle
// Example:[vehicleClass, position] remoteExec ["MCC_fnc_evacSpawn", true, false];
// Params:
// 	vehicleClass: string, vehicleClass to spawn
// 	position: array, spawn position
//==============================================================================================================================================================================
private _evac_p_type = "";
private _side = configNull;
private _evac = objNull;
private _campaignEvac = false;
private _dir = 0;

params ["_heliType", "_pos"];
_campaignEvac = param [2, false, [false]];
_dir	= param [3,0,[0]];

//wait for mission start
waitUntil {time >0};

_evac_p_type = getText (configFile >> "CfgVehicles" >> _heliType >> "crew");
_side = param [4, sideUnknown, [sideUnknown, 0]];
if (_side isEqualType 0) then {_side = _side call BIS_fnc_sideType};
if (_side isEqualTo sideUnknown) then {_side = (getNumber (configFile >> "CfgVehicles" >> _heliType >> "side")) call BIS_fnc_sideType};

_evac = _heliType createVehicle [_pos select 0, _pos select 1, 500]; 				//spawn heli
if (surfaceIsWater _pos) then {
	_evac setposasl _pos;
} else {
	_evac setposatl _pos;
};

_evac setDir _dir;

[_evac, _side, true,_campaignEvac] call MCC_fnc_setEvac;