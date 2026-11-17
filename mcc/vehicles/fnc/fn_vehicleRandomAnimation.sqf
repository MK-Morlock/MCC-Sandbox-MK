/*=================================================================================== MCC_fnc_vehicleRandomAnimation========================================================================
spawn random animations for vehicles

Parameter(s):
	_this select 0: OBJECT vehicle

Returns:
	NOTHING

===============================================================================================================================================================================================
*/

private _veh = objNull;
private _cfgAnimationSources = "";

_veh = param [0,objNull,[objNull]];

if (isNull _veh) exitWith {if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC_fnc_vehicleRandomAnimation: Error try to change animation of null vehicle"}};

//(MK) not on aircraft: a door or ramp opened at random would stay open (cars keep their random doors)
if (_veh isKindOf "Air") exitWith {};
//(MK) nor on a class given its paint and parts in the MCC garage (MCCMK_fnc_garageApply)
if (!isNil "MCCMK_garageLooks" && {(toLower (typeOf _veh)) in MCCMK_garageLooks}) exitWith {};

_cfgAnimationSources = "getText (_x >> 'source') == 'user' && getText (_x >> 'displayName') != ''" configClasses (configFile >> "CfgVehicles" >> typeof _veh >> "AnimationSources") ;

{
	if (random 1 > 0.6) then {_veh animateSource [configName _x,1]};
} forEach _cfgAnimationSources;