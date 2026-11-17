/*
    ANC_fnc_shoreFind  (server)
    Where a line thrown ashore lands.
      [boat, aim, from] with an aim (where the thrower was looking) and the
      thrower's position: the spot they're looking at, or as far as a 20 m throw reaches along that line, if it's dry
      land; otherwise the first dry land within 20 m in that direction (straight ahead first, then up to 30 degrees
      either side). [] if there's no shore that way.
      [boat] with no aim (to check whether a shore is in reach at all, or for
      AI and waypoints): the nearest dry land within 20 m, all round.
    Returns a position ASL, or [].
*/
params ["_boat", ["_aim", []], ["_from", []]];
if (count _from != 3) then {_from = _boat modelToWorldWorld ([_boat, "towBow"] call ANC_fnc_pointFor)};

private _landAt = {
    params ["_dirDeg"];
    private _hit = [];
    for "_r" from 2 to 20 step 1 do {
        private _p = _from vectorAdd [(sin _dirDeg) * _r, (cos _dirDeg) * _r, 0];
        if !(surfaceIsWater _p) exitWith {_hit = [_p select 0, _p select 1, getTerrainHeightASL _p]};
    };
    _hit
};

if (count _aim == 3) exitWith {
    // Where you're looking - or as far as a 20 m throw reaches along that line if it's further - as long as that's
    // dry land.
    private _look = ((_aim select 0) - (_from select 0)) atan2 ((_aim select 1) - (_from select 1));
    private _reach = (_from distance2D _aim) min 20;
    private _spot = _from vectorAdd [(sin _look) * _reach, (cos _look) * _reach, 0];
    if !(surfaceIsWater _spot) exitWith {[_spot select 0, _spot select 1, getTerrainHeightASL _spot]};
    // That spot is water: the first dry land along the look, then widening to 30 degrees either side.
    private _found = [];
    {
        _found = [_look + _x] call _landAt;
        if (count _found > 0) exitWith {};
    } forEach [0, 10, -10, 20, -20, 30, -30];
    _found
};

// No aim: nearest dry land all round.
private _best = [];
private _bestD = 1e9;
for "_a" from 0 to 350 step 10 do {
    private _h = [_a] call _landAt;
    if (count _h > 0 && {(_from distance2D _h) < _bestD}) then {_bestD = _from distance2D _h; _best = _h};
};
_best
