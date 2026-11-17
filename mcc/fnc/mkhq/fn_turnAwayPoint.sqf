/*
	MCCMK_fnc_turnAwayPoint - after a drop, the first point an aircraft heads for: if a mission area is near, it turns
	AWAY from it (left when the area is on its right, right when it's on its left) instead of swinging back over it.
	[aircraft, distance to the point (m), how near an area counts (m beyond its edge)]  ->  position, or [] (none near)
*/
params [["_v", objNull, [objNull]], ["_dist", 1500, [0]], ["_near", 5000, [0]]];
if (isNull _v) exitWith {[]};
private _p = getPosATL _v;
private _best = [];
private _bd = 1e9;
{
	_x params ["_c", "_r"];
	private _d = (_p distance2D _c) - _r;
	if (_d < _near && {_d < _bd}) then {_bd = _d; _best = _c};
} forEach ([0] call MCCMK_fnc_activeAOs);
if (_best isEqualTo []) exitWith {[]};
private _h = getDir _v;
private _rel = ((((_p getDir _best) - _h) + 540) mod 360) - 180;	// positive: the area is on the right
private _q = _p getPos [_dist, _h + ([90, -90] select (_rel > 0))];
_q set [2, 0];
_q
