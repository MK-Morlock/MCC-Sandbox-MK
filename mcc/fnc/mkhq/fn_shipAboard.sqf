// Who and what is on a ship's deck: [people on foot, parked vehicles / aircraft / boats / statics] - leaving out the
// ship's own parts and weapons (and their AI crews). [ship]
params [["_ship", objNull, [objNull]]];
if (isNull _ship) exitWith {[[], []]};
private _half = (([_ship getVariable ["MCC_ShipType", 0]] call MCCMK_fnc_shipCfg) select 3);
private _skip = (_ship getVariable ["MCCMK_weapons", []]) + ([_ship] call MCCMK_fnc_hullParts) + (_ship getVariable ["MCCMK_shipObjects", []]) + (attachedObjects _ship) + (missionNamespace getVariable ["MCC_staticShips", []]);
private _in = {
	params ["_o"];
	private _m = _ship worldToModel (ASLToAGL (getPosASL _o));
	(abs (_m select 0)) <= (_half select 0) && {(abs (_m select 1)) <= (_half select 1)} && {((getPosASL _o) select 2) > 2}
};
private _r = ((_half select 0) max (_half select 1)) + 10;
private _veh = (_ship nearEntities [["LandVehicle", "Air", "Ship", "StaticWeapon"], _r]) select {!(_x in _skip) && {alive _x} && {[_x] call _in}};
private _men = (_ship nearEntities [["CAManBase"], _r]) select {alive _x && {(vehicle _x) isEqualTo _x} && {[_x] call _in}};
[_men, _veh]
