params [["_pos", [], [[]]], ["_center", [], [[]]], ["_maxRange", -1, [0]]];
if (count _pos < 2) exitWith {[]};
private _found = [];
{
	private _dist = _x;
	for "_a" from 0 to 315 step 45 do {
		private _p = _pos getPos [_dist, _a];
		_p set [2, 0];
		if (
			!(surfaceIsWater _p)
			&& {(count _center < 2) || {_maxRange <= 0} || {(_p distance2D _center) <= _maxRange}}
			&& {!((_p isFlatEmpty [2, -1, 100, 2, 0, false]) isEqualTo [])}
			&& {(lineIntersectsSurfaces [AGLToASL _p, (AGLToASL _p) vectorAdd [0, 0, 50], objNull, objNull, false, 1, "GEOM", "NONE"]) isEqualTo []}
			&& {!([_p] call MCC_fnc_posOnBuilding)}
		) exitWith {_found = _p};
	};
	if (count _found > 0) exitWith {};
} forEach [10, 20, 30, 40];
_found
