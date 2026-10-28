//============================================================MCC_fnc_curatorSetArmedCivilian====================================================================================
// Make unit armed civilian
//===========================================================================================================================================================================
private "_pos";
private _module = objNull;
private _object = [];
private _resualt = [];
private _iedside = [];
private _static = false;
_module = _this param [0, objNull, [objNull]];
if (isNull _module) exitWith {};

_pos = getpos _module;
//did we get here from the 2d editor?
if (typeName (_module getVariable ["side",true]) == typeName 0) exitWith {

	_iedside =  [(_module getVariable ["side",1])] call BIS_fnc_sideType;
	// "Random Patrol" = Yes means the unit moves around, so it is NOT static (this was inverted and never applied)
	_static = (_module getVariable ["patrol",1]) == 0;
	private _weapon = _module getVariable ["weapon",""];

	{
		if (_x isKindOf "Man" && {!isPlayer _x}) then {
			_x setVariable ["MCC_IEDtype","ac",true];
			_x setVariable ["static",_static,true];
			if (_weapon != "") then {_x setVariable ["MCC_armedCivWeapon",_weapon,true]};
			[_x, _iedside, 25] spawn MCC_fnc_manageAC;
		};
	} forEach (synchronizedObjects _module);
};

//Not curator exit
if (!(local _module) || isnull curatorcamera) exitWith {};

_object = missionNamespace getVariable ["MCC_curatorMouseOver",[]];

//if no object selected or not a vehicle
if (count _object <2) exitWith {
	[objNull, localize "STR_GENERAL_ERROR_NOUNITSELECTED"] call bis_fnc_showCuratorFeedbackMessage;
	deleteVehicle _module;
};
_object = _object select 1;

//if nis player
if (isPlayer _object || !(_object isKindOf "Man")) exitWith {deleteVehicle _module};

//Weapon choices: random from pool, then the pools weapons
private _pool = (missionNamespace getVariable ["MCC_armedCivilansWeapons",[]]) select {_x isEqualType "" && {isClass (configFile >> "CfgWeapons" >> _x)}};
private _poolNames = ["Random from pool"] + (_pool apply {getText (configFile >> "CfgWeapons" >> _x >> "displayName") + " (" + _x + ")"});

//Already an armed civilian: only change its weapon
if ((_object getVariable ["MCC_IEDtype",""])=="ac") exitWith {
	_resualt = ["Armed Civilian - change weapon",[
		["Weapon",_poolNames],
		["Or weapon class","","Any CfgWeapons class, overrides the list above"]
	]] call MCC_fnc_initDynamicDialog;
	deleteVehicle _module;
	if (count _resualt == 0) exitWith {};
	private _class = [_resualt select 1] call BIS_fnc_trimString;
	if (_class == "" && {(_resualt select 0) > 0}) then {_class = _pool select ((_resualt select 0) - 1)};
	if (_class != "" && {!isClass (configFile >> "CfgWeapons" >> _class)}) exitWith {[objNull, format ["No weapon class %1", _class]] call bis_fnc_showCuratorFeedbackMessage};
	_object setVariable ["MCC_armedCivWeapon",_class,true];
	[objNull, format ["Weapon set: %1", ["random from pool", _class] select (_class != "")]] call bis_fnc_showCuratorFeedbackMessage;
};

_resualt = ["Make unit an Armed Civilian",[
 						["Attack Side",["East","West","Resistance"],"",1],
 						["Patrol",false],
 						["Weapon",_poolNames],
 						["Or weapon class","","Any CfgWeapons class, overrides the list above"]
 					  ]] call MCC_fnc_initDynamicDialog;

if (count _resualt == 0) exitWith {deleteVehicle _module};

private _class = [_resualt select 3] call BIS_fnc_trimString;
if (_class == "" && {(_resualt select 2) > 0}) then {_class = _pool select ((_resualt select 2) - 1)};
if (_class != "" && {!isClass (configFile >> "CfgWeapons" >> _class)}) exitWith {
	[objNull, format ["No weapon class %1", _class]] call bis_fnc_showCuratorFeedbackMessage;
	deleteVehicle _module;
};

_object setVariable ["MCC_IEDtype","ac",true];
if (_class != "") then {_object setVariable ["MCC_armedCivWeapon",_class,true]};

_iedside = (_resualt select 0) call BIS_fnc_sideType;
_static = !(_resualt select 1);
_object setVariable ["static",_static,true];
[_object, _iedside, 25] remoteExec ["MCC_fnc_manageAC", _object, false];

deleteVehicle _module;