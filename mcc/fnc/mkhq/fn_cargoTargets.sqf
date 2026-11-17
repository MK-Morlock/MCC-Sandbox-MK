/*
	MCCMK_fnc_cargoTargets - vehicles within 10 m of the player that can take an object (MCC interaction, without ACE).
	Any object Arma can carry with vehicle-in-vehicle: onto those vehicles. Small objects (under 2 m and 1000 kg, not
	vehicles) also into a vehicle's cargo list, when it has the room (MCC's weight capacity) - like ACE, a large object
	never goes into hidden cargo. [object] -> [[vehicle, true = vehicle-in-vehicle], ...]
*/
params [["_o", objNull, [objNull]]];
if (isNull _o) exitWith {[]};
(boundingBoxReal _o) params ["_lo", "_hi"];
private _d = _hi vectorDiff _lo;
private _large = (_o isKindOf "AllVehicles") || {(getMass _o) > 1000} || {((_d select 0) max (_d select 1) max (_d select 2)) > 2};
private _mass = (getMass _o) max 5;
// vehicle-in-vehicle wherever Arma allows it, for any object
private _out = ([_o] call MCCMK_fnc_vivTargets) apply {[_x, true]};
// small objects can also go into a vehicle's cargo list
if (!_large) then {
	{
		if (_x != _o && {!(_x isKindOf "CAManBase")} && {alive _x} && {(_x getVariable ["MCC_logisticsObjectMass", _x call MCC_fnc_logisticsCargoGetMass]) >= _mass}) then {_out pushBack [_x, false]};
	} forEach (player nearObjects ["AllVehicles", 10]);
};
_out
