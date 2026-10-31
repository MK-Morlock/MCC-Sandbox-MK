//============================================================MCC_fnc_curatorDamagePart===================================================================================
// Damage part of object/Unit
//===========================================================================================================================================================================
private "_pos";
private _module = objNull;
private _object = [];
private _resualt = [];
_module = _this param [0, objNull, [objNull]];
if (isNull _module) exitWith {};

//Not curator exit
if (!(local _module) || isnull curatorcamera) exitWith {};

_pos = getpos _module;
_object = missionNamespace getVariable ["MCC_curatorMouseOver",[]];

//if no object selected or not a vehicle
if (count _object <2) exitWith {
	[objNull, localize "STR_GENERAL_ERROR_NOVEHICLESELECTED"] call bis_fnc_showCuratorFeedbackMessage;
	deleteVehicle _module
};
_object = _object select 1;

private _selectionsNames = [];
private _hitPoints = configNull;
private "_point";
private _displayNames = [];
private _displayArray = [];
private "_resualtCount";
private _null = [];
_selectionsNames = [];
_displayNames = [];

_hitPoints = configFile >> "CfgVehicles" >> typeof _object >> "HitPoints";
for "_i" from 0 to (count _hitPoints - 1) do {
 _point = _hitPoints select _i;
 if (isClass _point) then {
 	_displayNames pushBack (configName _point);
 	_selectionsNames pushBack (getText (_point >> "name"));
 };
};

if (count _selectionsNames == 0) exitWith {deleteVehicle _module;};

//Build hit parts
_displayArray = [];
{
	_displayArray pushBack [_x,false]
} forEach _displayNames;

_displayArray pushBack ["Explosion Effect",false];

_resualt = ["Hit Specific Part",_displayArray] call MCC_fnc_initDynamicDialog;


if (count _resualt == 0) exitWith {deleteVehicle _module};

//Do we want explosion effect
_resualtCount = count _resualt;
if (_resualt select (_resualtCount - 1)) then {
	_pos = [getpos _object, 5, random 360] call bis_fnc_relPos;
	_null = [_pos,"small"] spawn MCC_fnc_IedFakeExplosion;
	_resualt resize (_resualtCount-1);
};

//Set Damage
{
	if (_x) then {
		["call", [[_object, _selectionsNames select _foreachIndex], {(_this select 0) setHit [(_this select 1), 1];}], _object, false] call MCC_fnc_secRemote;
	}
} forEach _resualt;

deleteVehicle _module;