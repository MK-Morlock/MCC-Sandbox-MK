/*
    ANC_fnc_hullGap  (any computer)
    The gap between two boats' hulls seen from above (each its rectangle - ANC_fnc_hullOutline), and the way to push
    the first one to open it. Measured from each corner of one hull to the other hull and the other way round; the
    smallest counts. Negative if they overlap.
    [boat A, boat B]  ->  [gap (m), unit vector (world, level) pointing from B towards A]
*/
params ["_a", "_b"];
private _corners = {
    params ["_v"];
    (_v call ANC_fnc_hullOutline) params ["_cx", "_sY", "_bY", "_hw"];
    [[_cx - _hw, _sY, 0], [_cx + _hw, _sY, 0], [_cx - _hw, _bY, 0], [_cx + _hw, _bY, 0], [_cx - _hw, (_sY + _bY) / 2, 0], [_cx + _hw, (_sY + _bY) / 2, 0]] apply {_v modelToWorldVisualWorld _x}
};
// distance from a world point to a boat's rectangle (negative inside), and the nearest point on it (world)
private _toRect = {
    params ["_p", "_v"];
    (_v call ANC_fnc_hullOutline) params ["_cx", "_sY", "_bY", "_hw"];
    private _l = _v worldToModelVisual (ASLToAGL _p);
    private _qx = ((_l select 0) max (_cx - _hw)) min (_cx + _hw);
    private _qy = ((_l select 1) max _sY) min _bY;
    private _dx = (_l select 0) - _qx;
    private _dy = (_l select 1) - _qy;
    private _d = sqrt ((_dx * _dx) + (_dy * _dy));
    if (_d < 0.001) then {
        _d = -(((_l select 0) - (_cx - _hw)) min ((_cx + _hw) - (_l select 0)) min ((_l select 1) - _sY) min (_bY - (_l select 1)));
    };
    [_d, _v modelToWorldVisualWorld [_qx, _qy, _l select 2]]
};
private _best = 1e9;
private _dir = [0, 0, 0];
{
    private _r = [_x, _b] call _toRect;
    if ((_r select 0) < _best) then {_best = _r select 0; _dir = _x vectorDiff (_r select 1)};
} forEach ([_a] call _corners);
{
    private _r = [_x, _a] call _toRect;
    if ((_r select 0) < _best) then {_best = _r select 0; _dir = (_r select 1) vectorDiff _x};
} forEach ([_b] call _corners);
_dir set [2, 0];
if (_best <= 0.001 || {(vectorMagnitude _dir) < 0.001}) then {
    _dir = (getPosASLVisual _a) vectorDiff (getPosASLVisual _b);
    _dir set [2, 0];
};
if ((vectorMagnitude _dir) < 0.001) then {_dir = [1, 0, 0]};
[_best, vectorNormalized _dir]
