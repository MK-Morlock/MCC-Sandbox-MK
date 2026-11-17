/*
	MCCMK_fnc_cargoViVUnload - unloads an object carried with vehicle-in-vehicle, beside the vehicle; runs where the
	vehicle is local. [object]
*/
params [["_o", objNull, [objNull]]];
private _v = isVehicleCargo _o;
if (isNull _o || {isNull _v}) exitWith {};
if (!local _v) exitWith {[_o] remoteExec ["MCCMK_fnc_cargoViVUnload", _v]};
objNull setVehicleCargo _o;
