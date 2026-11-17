params [["_p", [0, 0, 0], [[]]], ["_dir", 0, [0]], ["_beyond", 1500, [0]]];
private _ws = worldSize;
private _dx = sin _dir;
private _dy = cos _dir;
private _ts = [];
if (_dx > 0.0001) then {_ts pushBack ((_ws - (_p select 0)) / _dx)};
if (_dx < -0.0001) then {_ts pushBack (-(_p select 0) / _dx)};
if (_dy > 0.0001) then {_ts pushBack ((_ws - (_p select 1)) / _dy)};
if (_dy < -0.0001) then {_ts pushBack (-(_p select 1) / _dy)};
private _t = (selectMin (_ts select {_x > 0})) + _beyond;
[(_p select 0) + _dx * _t, (_p select 1) + _dy * _t, 0]
