/*
	MCCMK_fnc_sarSeat - (where the unit is local) [unit, vehicle, "in" / "out"]: into a passenger seat (else any seat), or
	out of the vehicle.
*/
params [["_u", objNull], ["_v", objNull], ["_how", "in"]];
if (isNull _u || {!local _u}) exitWith {};
if (_how == "in") then {
	if (isNull _v) exitWith {};
	_u moveInCargo _v;
	if (vehicle _u != _v) then {_u moveInAny _v};
} else {
	unassignVehicle _u;
	moveOut _u;
};
