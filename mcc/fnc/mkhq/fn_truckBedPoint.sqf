/*
	MCCMK_fnc_truckBedPoint - where a crate sits on a cargo truck's bed: along the rear of the bed, 1.6 m apart, resting on
	the floor (found by looking down onto the truck's own surfaces), plus the adjustment saved for that truck type and
	slot (MCCMK_fnc_crateAdjust). [truck, crate, slot, MCC point] -> [offset, direction]
*/
params ["_truck", "_crate", "_n", "_base"];
(boundingBoxReal _truck) params ["_lo", "_hi"];
private _y = (_lo select 1) + 1.1 + _n * 1.6;
private _hits = lineIntersectsSurfaces [_truck modelToWorldWorld [0, _y, 0.5], _truck modelToWorldWorld [0, _y, -2.5], _crate, objNull, true, 5, "GEOM", "NONE"];
private _z = 0;
{
	if ((_x select 2) isEqualTo _truck) exitWith {_z = (_truck worldToModel (ASLToAGL (_x select 0))) select 2};
} forEach _hits;
_z = (_z max -1.5) min 1.5;
private _ofs = [0, _y, _z - (((boundingBoxReal _crate) select 0) select 2)];
private _adj = ((profileNamespace getVariable ["MCCMK_bedAdjust", createHashMap]) getOrDefault [toLower typeOf _truck, []]) param [_n, [0, 0, 0, 0]];
[_ofs vectorAdd [_adj select 0, _adj select 1, _adj select 2], _adj select 3]
