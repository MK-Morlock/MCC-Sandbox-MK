params [["_road", objNull, [objNull]], ["_away", [], [[]]]];
if (isNull _road) exitWith {[]};
private _fnc_bad = {
	params ["_r"];
	private _i = getRoadInfo _r;
	((count _i > 8) && {_i select 8}) || {(((getPosATL _r) nearRoads 30) findIf {count (roadsConnectedTo _x) > 2}) >= 0}
};
private _found = objNull;
if !([_road] call _fnc_bad) then {
	_found = _road;
} else {
	private _starts = roadsConnectedTo _road;
	if (count _away > 1) then {_starts = [_starts, [_away], {_x distance2D _input0}, "DESCEND"] call BIS_fnc_sortBy};
	{
		private _prev = _road;
		private _cur = _x;
		private _walked = _road distance2D _cur;
		while {_walked <= 100} do {
			if !([_cur] call _fnc_bad) exitWith {_found = _cur};
			private _head = _prev getDir _cur;
			private _next = (roadsConnectedTo _cur) - [_prev];
			if (_next isEqualTo []) exitWith {};
			_next = [_next, [_cur, _head], {abs ((((_input0 getDir _x) - _input1) + 540) mod 360 - 180)}, "ASCEND"] call BIS_fnc_sortBy;
			_walked = _walked + (_cur distance2D (_next select 0));
			_prev = _cur;
			_cur = _next select 0;
		};
		if (!isNull _found) exitWith {};
	} forEach _starts;
};
if (isNull _found) exitWith {[]};
private _dir = -1;
private _info = getRoadInfo _found;
if (count _info > 7) then {
	private _b = _info select 6;
	private _e = _info select 7;
	if ((_b distance2D _e) > 0.5) then {_dir = _b getDir _e};
};
if (_dir < 0) then {
	private _c = roadsConnectedTo _found;
	_dir = if (count _c > 0) then {_found getDir (_c select 0)} else {getDir _found};
};
if (count _away > 1) then {
	private _out = _away getDir _found;
	if (abs ((((_dir - _out) + 540) mod 360) - 180) > 90) then {_dir = _dir + 180};
};
private _pos = getPosATL _found;
_pos set [2, 0];
[_pos, _dir mod 360]
