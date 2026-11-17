params [["_ship", objNull, [objNull]]];
if (isNull _ship) exitWith {[]};
private _half = (([_ship getVariable ["MCC_ShipType", 0]] call MCCMK_fnc_shipCfg) select 3);
private _boats = (nearestObjects [_ship, ["Ship"], 300]) select {
	private _m = _ship worldToModel (getPos _x);
	alive _x && {canMove _x} && {!(_x getVariable ["MCC_isLHD", false])} && {(abs (_m select 0)) <= (_half select 0) + 60} && {(abs (_m select 1)) <= (_half select 1) + 60}
	&& {((crew _x) select {alive _x}) isEqualTo [] || {(side group ((crew _x) select 0)) isEqualTo (side group player)}}
	&& {(count ((fullCrew [_x, "", true]) select {isNull (_x select 0)})) > 0}
};
[_boats, [], {_x distance2D player}, "ASCEND"] call BIS_fnc_sortBy
