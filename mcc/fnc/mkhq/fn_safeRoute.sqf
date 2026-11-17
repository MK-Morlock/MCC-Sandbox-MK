/*
	MCCMK_fnc_safeRoute - a flight route from one point to another round the active mission areas (generated and campaign
	missions: each a circle of 2 km round its centre). Where a leg crosses one, a point is added beside it, on the shorter
	side, until no leg does (8 detours at most). An area the start or the end is in is ignored (it has to be flown into).
	[from, to] -> the points to fly through after "from", the last being "to"
*/
params [["_a", [0, 0, 0]], ["_b", [0, 0, 0]]];
private _r = 2000;
private _areas = ((missionNamespace getVariable ["MCC_generatedMissionsList", []]) apply {_x param [3, []]}) select {_x isEqualType [] && {count _x >= 2}};
_areas = _areas select {((_a distance2D _x) > _r) && {(_b distance2D _x) > _r}};
private _crosses = {	// does the leg p-q pass within _r of c? -> the distance along it, else -1
	params ["_p", "_q", "_c"];
	private _d = (_q vectorDiff _p); _d set [2, 0];
	private _len = vectorMagnitude _d;
	if (_len < 1) exitWith {-1};
	private _u = _d vectorMultiply (1 / _len);
	private _w = (_c vectorDiff _p); _w set [2, 0];
	private _t = ((_w vectorDotProduct _u) max 0) min _len;
	private _near = (_p vectorAdd (_u vectorMultiply _t));
	if ((_near distance2D _c) < _r) then {_t} else {-1}
};
private _pts = [[_a select 0, _a select 1, 0], [_b select 0, _b select 1, 0]];
for "_n" from 1 to 8 do {
	private _hit = [];
	for "_i" from 0 to (count _pts) - 2 do {
		if (_hit isEqualTo []) then {
			private _p = _pts select _i;
			private _q = _pts select (_i + 1);
			private _best = 1e10;
			{
				private _t = [_p, _q, _x] call _crosses;
				if (_t >= 0 && {_t < _best}) then {_best = _t; _hit = [_i, _x]};
			} forEach _areas;
		};
	};
	if (_hit isEqualTo []) exitWith {};
	_hit params ["_i", "_c"];
	private _p = _pts select _i;
	private _q = _pts select (_i + 1);
	private _dir = _p getDir _q;
	// beside the area, on the side that makes the shorter route
	private _l = _c getPos [_r * 1.25, _dir - 90];
	private _rr = _c getPos [_r * 1.25, _dir + 90];
	private _pick = if (((_p distance2D _l) + (_l distance2D _q)) <= ((_p distance2D _rr) + (_rr distance2D _q))) then {_l} else {_rr};
	_pts insert [_i + 1, [[_pick select 0, _pick select 1, 0]]];
};
_pts select [1, (count _pts) - 1]
