params [["_c", [], [[]]], ["_cls", "", [""]], ["_r", 1000, [0]]];
if (count _c < 2 || {_cls == ""}) exitWith {[]};
private _roads = ((_c nearRoads _r) apply {[_x distance2D _c, _x]});
_roads sort true;
private _res = [];
{
	if (_forEachIndex >= 40) exitWith {};
	private _s = [getPosATL (_x select 1), _cls, 20] call MCC_fnc_clearVehicleSpot;
	if (count _s > 0) exitWith {_res = _s};
} forEach _roads;
_res
