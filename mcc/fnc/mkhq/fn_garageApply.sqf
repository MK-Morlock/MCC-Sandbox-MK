/*
	MCCMK_fnc_garageApply - (server) a vehicle spawned from the MCC console's Spawn or Evac panel (or the 3D Editor) given
	the paint and parts its class was given in the garage (MCCMK_fnc_garageOpen), if any: [vehicle]. MCC's random doors
	are then not used on it (MCC_fnc_vehicleRandomAnimation).
*/
params [["_v", objNull]];
if (isNull _v || {isNil "MCCMK_garageLooks"}) exitWith {};
private _look = MCCMK_garageLooks getOrDefault [toLower (typeOf _v), []];
if (_look isEqualTo []) exitWith {};
_v setVariable ["MCCMK_garageLook", true];
[_v, _look select 0, _look select 1] call BIS_fnc_initVehicle;
