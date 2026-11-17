params [["_goal", [0, 0, 0], [[]]]];
private _cell = 400;
private _n = ceil (worldSize / _cell);
private _ctr = {params ["_i", "_j"]; [(_i + 0.5) * _cell, (_j + 0.5) * _cell, 0]};
private _wet = {params ["_i", "_j"]; (getTerrainHeightASL ([_i, _j] call _ctr)) < -4};
private _gi = floor ((_goal select 0) / _cell);
private _gj = floor ((_goal select 1) / _cell);
private _from = createHashMap;
_from set [[_gi, _gj], [-1, -1]];
private _q = [[_gi, _gj]];
private _head = 0;
private _end = [];
while {_head < count _q && {_end isEqualTo []} && {_head < 20000}} do {
	(_q select _head) params ["_i", "_j"];
	_head = _head + 1;
	{
		private _ni = _i + (_x select 0);
		private _nj = _j + (_x select 1);
		if (_ni < 0 || {_nj < 0} || {_ni >= _n} || {_nj >= _n}) exitWith {_end = [_i, _j]};
		if (!([_ni, _nj] in _from) && {[_ni, _nj] call _wet}) then {_from set [[_ni, _nj], [_i, _j]]; _q pushBack [_ni, _nj]};
	} forEach [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [-1, -1], [1, -1], [-1, 1]];
};
if (_end isEqualTo []) exitWith {[]};
private _path = [];
private _c = _end;
while {_c isNotEqualTo [-1, -1]} do {_path pushBack (_c call _ctr); _c = _from getOrDefault [_c, [-1, -1]]};
private _out = [];
{if ((_forEachIndex mod 3) == 0) then {_out pushBack _x}} forEach _path;
_out pushBack _goal;
_out
