params [["_pos", [0,0,0], [[]]], ["_radius", 6, [0]], ["_ignore", objNull, [objNull]]];
if (count _pos < 2) exitWith {false};
private _c = [_pos select 0, _pos select 1, 0];
private _pts = [_c] + ([0, 90, 180, 270] apply {_c getPos [_radius, _x]});
(_pts findIf {
	private _asl = AGLToASL [_x select 0, _x select 1, 0];
	private _hits = (lineIntersectsSurfaces [_asl vectorAdd [0, 0, 50], _asl vectorAdd [0, 0, -2], _ignore, vehicle _ignore, true, 5, "GEOM", "NONE"]) select {private _h = _x select 2; isNull _h || {!(_h isKindOf "CAManBase") && {!(_h isKindOf "ParachuteBase")}}};
	if (_hits isEqualTo []) then {false} else {
		private _o = (_hits select 0) select 2;
		!isNull _o && {(_o isKindOf "Building") || {count (_o buildingPos -1) > 0}}
	}
}) >= 0
