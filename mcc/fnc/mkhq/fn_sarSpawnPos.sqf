/*
	MCCMK_fnc_sarSpawnPos - (server) where a rescue appears when no ship is near: [target position, distance, by water?]
	-> a position out of sight (no player within 1.5 km), on the map; by water: on open water (2 m deep or more) with a
	straight water route to the target (checked every 50 m). [] if none found.
*/
params [["_pos", [0, 0, 0]], ["_dist", 4500], ["_water", false]];
private _players = allPlayers - (entities "HeadlessClient_F");
private _best = [];
for "_try" from 0 to 47 do {
	private _d = if (_water) then {_dist + (random 1000) - 500} else {_dist};
	private _p = _pos getPos [_d, random 360];
	if ((_p select 0) < 100 || {(_p select 1) < 100} || {(_p select 0) > (worldSize - 100)} || {(_p select 1) > (worldSize - 100)}) then {continue};
	if ((_players findIf {(_x distance2D _p) < 1500}) >= 0) then {continue};
	if (_water) then {
		if (!(surfaceIsWater _p) || {(getTerrainHeightASL _p) > -2}) then {continue};
		private _ok = true;
		private _n = (floor ((_p distance2D _pos) / 50)) max 1;
		for "_k" from 1 to _n do {
			private _q = _p vectorAdd (((_pos vectorDiff _p)) vectorMultiply (_k / _n));
			if !(surfaceIsWater _q) exitWith {_ok = false};
		};
		if (!_ok) then {continue};
	};
	_best = [_p select 0, _p select 1, 0];
	if (true) exitWith {};
};
_best
