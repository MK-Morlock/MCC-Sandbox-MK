/*
	MCCMK_fnc_cargoViV - loads an object into a vehicle with Arma's vehicle-in-vehicle (visible on or in it); runs where
	the vehicle is local. Arma's own Unload actions take it off again. [object, vehicle]
*/
params [["_o", objNull, [objNull]], ["_v", objNull, [objNull]]];
if (isNull _o || {isNull _v}) exitWith {};
if (!local _v) exitWith {[_o, _v] remoteExec ["MCCMK_fnc_cargoViV", _v]};
if !(_v setVehicleCargo _o) then {
	["WARN", "MCCMK_fnc_cargoViV", "%1 could not be loaded into %2", [typeOf _o, typeOf _v]] call MCC_fnc_log;
};
