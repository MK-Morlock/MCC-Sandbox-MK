/*
	MCCMK_fnc_mapEdgeExit - a point 2 km beyond the edge of the map, straight on from a position in a direction: where a
	departing aircraft is sent, so it's removed out of sight past the edge rather than hovering where it stopped.
	[position, direction] -> position
*/
params [["_p", [0, 0, 0]], ["_dir", 0]];
private _dx = sin _dir;
private _dy = cos _dir;
private _edge = {params ["_c", "_d"]; if (_d > 0.001) exitWith {(worldSize - _c) / _d}; if (_d < -0.001) exitWith {(0 - _c) / _d}; 1e9};
private _t = ([_p select 0, _dx] call _edge) min ([_p select 1, _dy] call _edge);
[(_p select 0) + _dx * (_t + 2000), (_p select 1) + _dy * (_t + 2000), 0]
