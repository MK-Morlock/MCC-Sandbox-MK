/*
	MCCMK_fnc_crateOnTruck - the logistics crates on a vehicle: carried with vehicle-in-vehicle, and those MCC attached
	to a cargo truck's bed (in loading order). [vehicle] -> [crates]
*/
params [["_v", objNull, [objNull]]];
private _types = (missionNamespace getVariable ["MCC_logisticsCrates_TypesWest", []]) + (missionNamespace getVariable ["MCC_logisticsCrates_TypesEast", []]);
// a vehicle-in-vehicle crate is also reported as attached - each crate once
private _all = (getVehicleCargo _v) + (attachedObjects _v);
(_all arrayIntersect _all) select {(typeOf _x) in _types}
