/*
    ANC_fnc_raftTargets  (server)
    Boats close enough to raft up to or tether to: within 10 m (hull to hull), afloat, not already rafted or tethered,
    and with no enemies aboard (empty, civilian or friendly-crewed boats - as for tow lines). Nearest first.
    [boat, player]  ->  [[boat, gap], ...]
*/
params ["_boat", "_player"];
private _mySide = side group _player;
private _out = [];
{
    private _cand = _x;
    if (!(_x isEqualTo _boat) && {alive _x} && {_x isKindOf "Ship"} && {((_boat getVariable ["ANC_xl", []]) findIf {((_x select 2) isEqualTo _cand) && {(_x select 1) isEqualTo "tow"}}) < 0}
        && {((crew _x) findIf {alive _x && {((_mySide getFriend (side group _x)) < 0.6)}}) == -1}) then {
        private _g = ([_boat, _x] call ANC_fnc_hullGap) select 0;
        if (_g <= 10) then {_out pushBack [_x, _g]};
    };
} forEach (nearestObjects [_boat, ["Ship"], 40]);
[_out, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy
