/*
	MCCMK_fnc_crateLoadOn - loads a logistics crate onto a vehicle: with Arma's vehicle-in-vehicle when the vehicle can
	take it (placed by Arma, as many as fit), otherwise onto a cargo truck's bed (as many as it's long, at MCC's points plus any
	adjustment made for that truck type). [vehicle, crate, MCC point] -> true when loaded
*/
params ["_v", "_crate", "_base"];
if ((_v canVehicleCargo _crate) param [0, false]) exitWith {_v setVehicleCargo _crate};
if (isClass (configFile >> "CfgVehicles" >> typeOf _v >> "VehicleTransport" >> "Carrier")) exitWith {false};	// a carrier that's full: no room
if !([_v] call MCCMK_fnc_isCargoTruck) exitWith {false};
private _used = (attachedObjects _v) apply {_x getVariable ["MCCMK_bedSlot", -1]};
private _slots = [_v] call MCCMK_fnc_crateSlots;	// as many as the bed is long
private _n = -1;
for "_i" from 0 to (_slots - 1) do {if (_n < 0 && {!(_i in _used)}) then {_n = _i}};	// the first free place on the bed
if (_n < 0) exitWith {false};
private _p = [_v, _crate, _n, _base] call MCCMK_fnc_truckBedPoint;
_p params ["_ofs", "_rot"];
_crate attachTo [_v, _ofs];
[_crate, _rot] remoteExec ["setDir", _crate];
_crate setVariable ["MCCMK_bedSlot", _n, true];
true
