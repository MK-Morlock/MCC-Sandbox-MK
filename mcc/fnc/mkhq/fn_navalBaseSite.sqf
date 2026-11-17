params [["_ship", objNull, [objNull]], ["_zones", [], [[]]]];
private _cands = [];
{
	_x params ["_key", "_tp", ["_zr", 300]];
	private _sr = (_zr + 200) min 1500;
	private _d = _tp distance2D _ship;
	if (_d > 3000 && {(_d - _zr) < 8000}) then {
		{_cands pushBack [3, getPos _x]} forEach (nearestTerrainObjects [_tp, ["QUAY"], _sr, false, true]);
		{_cands pushBack [2, getPos _x]} forEach (nearestTerrainObjects [_tp, ["LIGHTHOUSE"], _sr, false, true]);
		{
			private _m = toLower ((getModelInfo _x) select 0);
			if ((["pier", "dock", "quay"] findIf {_m find _x >= 0}) >= 0) then {_cands pushBack [3, getPos _x]} else {
				if ((["cargo_tower", "cargo_patrol", "cargo_hq"] findIf {_m find _x >= 0}) >= 0) then {_cands pushBack [2, getPos _x]};
			};
		} forEach (nearestTerrainObjects [_tp, ["HOUSE", "BUILDING", "BUNKER", "VIEW-TOWER"], _sr, false, true]);
		for "_k" from 1 to 10 do {_cands pushBack [1, _tp getPos [random (_sr - 50), random 360]]};
	};
} forEach _zones;
_cands = _cands call BIS_fnc_arrayShuffle;
_cands sort false;
private _best = [];
{
	_x params ["_score", "_c"];
	private _moor = [];
	for "_r" from 40 to 160 step 40 do {
		for "_a" from 0 to 330 step 30 do {
			private _w = _c getPos [_r, _a];
			if ((getTerrainHeightASL _w) < -3) exitWith {_moor = _w};
		};
		if (_moor isNotEqualTo []) exitWith {};
	};
	if (_moor isNotEqualTo []) then {
		private _lz = [];
		for "_k" from 0 to 15 do {
			private _p = _c getPos [20 + random 90, random 360];
			if (!surfaceIsWater _p && {(_p isFlatEmpty [11, -1, 0.35, 12, 0, false, objNull]) isNotEqualTo []}) exitWith {_lz = _p};
		};
		if (_lz isNotEqualTo [] && {(allPlayers findIf {(_x distance2D _lz) < 1000}) < 0}) exitWith {_best = [_lz, _moor, _score]};
	};
	if (_forEachIndex > 60) exitWith {};
} forEach _cands;
_best
