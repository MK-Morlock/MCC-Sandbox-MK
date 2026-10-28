/*================================================================== MCC_fnc_haloPlaneExit ==================================================================
	HALO aircraft after the drop (agreed): it keeps its drop height (no dive) and its fuel, turns gradually towards the
	nearest edge of the map (the in-game map area, worldSize square), flies past it into the empty area beyond and is
	then deleted with its crew. (MCC_fnc_deletePlane set flyInHeight 300 and 20% fuel: from 4 km it dived and often hit
	the ground.)
	<IN>	0: OBJECT aircraft
			1: NUMBER height to keep (m)
==============================================================================================================================================================================*/
params ["_plane", ["_height", 4000], ["_avoidZones", false]];
if (isNull _plane) exitWith {};
private _grp = group driver _plane;
for "_i" from (count waypoints _grp - 1) to 0 step -1 do {deleteWaypoint [_grp, _i]};
_plane flyInHeight _height;
_grp setBehaviour "CARELESS";
_grp setCombatMode "BLUE";
_grp setVariable ["MCC_canbecontrolled", false, true];

//Nearest map edge from where it is; aim 2 km beyond it, into the empty area
private _ws = worldSize;
(getPosATL _plane) params ["_x", "_y"];
private _exit = [
	[_x, [-2000, _y]],
	[_ws - _x, [_ws + 2000, _y]],
	[_y, [_x, -2000]],
	[_ws - _y, [_x, _ws + 2000]]
];
_exit sort true;
private _target = (_exit select 0) select 1;
private _route = [_plane getPos [2000, getDir _plane], _target];
private _isPlane = _plane isKindOf "Plane";
if (_isPlane) then {
	private _p1 = _route select 0;
	private _turn = ((((_p1 getDir _target) - (getDir _plane)) + 540) mod 360) - 180;
	if ((abs _turn) > 90) then {_route = [_p1, _p1 getPos [2500, (getDir _plane) + (if (_turn > 0) then {90} else {-90})], _target]};
};
if (_plane isKindOf "Helicopter" || {_avoidZones}) then {
	private _zones = [];
	{
		private _m = str _x;
		if !((getMarkerPos _m) isEqualTo [0,0,0]) then {
			private _sz = getMarkerSize _m;
			_zones pushBack [getMarkerPos _m, ((_sz select 0) max (_sz select 1)) + 500];
		};
	} forEach (missionNamespace getVariable ["MCC_zones_numbers", []]);
	if (count _zones > 0) then {
		private _from = getPosATL _plane;
		private _out = [];
		private _todo = +_route;
		private _n = 0;
		private _guard = 0;
		while {count _todo > 0 && {_guard < 16}} do {
			_guard = _guard + 1;
			private _to = _todo select 0;
			private _hit = [];
			private _best = 2;
			{
				_x params ["_c", "_r"];
				private _ab = [(_to select 0) - (_from select 0), (_to select 1) - (_from select 1), 0];
				private _l2 = (_ab vectorDotProduct _ab) max 1;
				private _t = (([(_c select 0) - (_from select 0), (_c select 1) - (_from select 1), 0] vectorDotProduct _ab) / _l2) max 0 min 1;
				private _q = [(_from select 0) + (_ab select 0) * _t, (_from select 1) + (_ab select 1) * _t, 0];
				if ((_q distance2D _c) < _r && {_t > 0.05} && {_t < 1} && {_t < _best} && {(_from distance2D _c) > _r}) then {_best = _t; _hit = [_c, _r, _q]};
			} forEach _zones;
			if (count _hit == 0) then {
				_out pushBack _to; _from = _to; _todo deleteAt 0;
			} else {
				_hit params ["_c", "_r", "_q"];
				private _dv = [(_q select 0) - (_c select 0), (_q select 1) - (_c select 1), 0];
				if ((vectorMagnitude _dv) < 1) then {_dv = [-((_to select 1) - (_from select 1)), (_to select 0) - (_from select 0), 0]};
				private _dt = _c vectorAdd ((vectorNormalized _dv) vectorMultiply (_r + ([300, 800] select _isPlane)));
				_dt set [2, 0];
				_todo = [_dt] + _todo;
				_n = _n + 1;
			};
		};
		_route = _out + _todo;
		if (_n > 0) then {["INFO", "haloPlaneExit", "%1 goes round %2 zone(s) on its way out (%3 waypoints)", [typeOf _plane, _n, count _route]] call MCC_fnc_log};
	};
};
//Gradual turn: first carry on straight for 2 km, then head for the edge (Arma turns the aircraft at its own rate)
{
	private _wp = _grp addWaypoint [[_x select 0, _x select 1, _height], 0];
	_wp setWaypointType "MOVE";
	_wp setWaypointSpeed (["NORMAL", "FULL"] select (_plane getVariable ["MCC_exitFull", false]));
	_wp setWaypointBehaviour "CARELESS";
	_wp setWaypointCombatMode "BLUE";
	_wp setWaypointCompletionRadius ([300, 1000] select _isPlane);
} forEach _route;
["INFO", "haloPlaneExit", "%1 leaving at %2 m towards the map edge at %3", [typeOf _plane, round _height, _target apply {round _x}]] call MCC_fnc_log;

//Deleted once it is past the edge (or after 10 minutes at most, or if it is destroyed / has no crew)
private _end = time + 600;
waitUntil {
	sleep 2;
	isNull _plane || {!alive _plane} || {time > _end} || {
		(getPosATL _plane) params ["_px", "_py"];
		_px < -500 || {_px > _ws + 500} || {_py < -500} || {_py > _ws + 500}
	}
};
if (!isNull _plane) then {
	{deleteVehicle _x} forEach (crew _plane);
	deleteVehicle _plane;
};
if (!isNull _grp) then {deleteGroup _grp};
