/*
	MCCMK_fnc_vivTargets - vehicles within 10 m of the player that can carry an object with Arma's vehicle-in-vehicle
	(Arma's own check: the object is transportable and fits). [object] -> [vehicles]
*/
params [["_o", objNull, [objNull]]];
if (isNull _o || {!isNull isVehicleCargo _o} || {!isNull attachedTo _o}) exitWith {[]};
(player nearObjects ["AllVehicles", 10]) select {
	_x != _o && {!(_x isKindOf "CAManBase")} && {alive _x} && {(_x canVehicleCargo _o) param [0, false]}
}
