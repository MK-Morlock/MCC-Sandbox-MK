//=================================================================MCC_fnc_rtsbuyVehicle==============================================================================
//	open vehicle spawner dialog for the commander
//  Parameter(s):
//     	_ctrl: CONTROL
//==============================================================================================================================================================================
private "_obj";
private _consType = "";
private _constLevel = 0;
private _spawnPad = objNull;
private "_spawnType";
disableSerialization;
params ["_ctrl"];

if (count MCC_ConsoleGroupSelected <=0) exitWith {};
_obj = MCC_ConsoleGroupSelected select 0;
_consType = _obj getVariable ["mcc_constructionItemType","hq"];
_constLevel = _obj getVariable ["mcc_constructionItemTypeLevel",1];

_spawnPad = objNull;

{
	if (_x getVariable ["MCC_vehicleSpawnerHelipad",false]) exitWith {_spawnPad = _x}
} forEach (nearestObjects [_obj, [], 30]);

if (isNull _spawnPad || _consType != "workshop") exitWith {};

_spawnType = switch (_constLevel) do {
    case 2: {"vehicle"};
    case 3: {"tank"};
    case 4: {"heli"};
    case 5: {"jet"};
    default {""};
};

if (_spawnType == "") exitWith {};

[player, [_spawnType,_spawnPad],true] spawn MCC_fnc_vehicleSpawnerInitDialog;
