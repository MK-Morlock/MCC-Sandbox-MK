/*
    ANC_fnc_bagMove  (server, every frame)
    Moves a loose line end (the bag) while the boat tows it off the land into the sea, or while it's hauled in to the
    boat. One smooth, natural model for both - only the loose end's own movement; the rope and the boat are untouched.
      [end, newPositionASL (x, y), boatLinePointASL, frameTime, moving]

      On land    It lies on the ground, settling smoothly onto the terrain and tilted
                 to the slope (the slope averaged over a metre or so, not triangle by triangle), trailing behind the
                 line.
      In water   A wet bag has weight: left alone it sinks (0.4 m/s) to the bottom.
                 Towed or hauled, the line's pull lifts it. The line runs straight from the boat to the bag, so the
                 bag trails at the depth where the line's upward pull balances the bag's weight: drag grows with speed
                 squared, so slowly it stays on the bottom, at a few m/s it trails a metre or two down, and only a
                 fast tow brings it up to just under the surface. It never comes out of the water (except where the
                 water is shallower than the bag), it follows the seabed in the shallows, and it eases up and down -
                 no stepping.
*/
params ["_pad", "_xy", "_bp", "_dt", ["_moving", true]];
private _now = getPosASL _pad;
private _bed = getTerrainHeightASL _xy;
private _wet = (surfaceIsWater _xy) && {_bed < -0.05};
if (!_wet && {!_moving}) exitWith {}; // resting on the ground

// How fast it's going (m/s), averaged over a third of a second.
private _moved = sqrt ((((_xy select 0) - (_now select 0)) ^ 2) + (((_xy select 1) - (_now select 1)) ^ 2));
private _spd = (_pad getVariable ["ANC_bagSpd", 0]) + ((((_moved / _dt) min 20) - (_pad getVariable ["ANC_bagSpd", 0])) * (1 - exp (-_dt / 0.3)));
_pad setVariable ["ANC_bagSpd", _spd];

private _z0 = _now select 2;
private _z = _z0;
if (_wet) then {
    // Where the line's upward pull balances the bag's weight (about 30 N wet; the drag on the bag is about 50 x speed
    // squared, in newtons).
    private _run = (_bp distance2D _xy) max 0.5;
    private _s = (30 / (50 * ((_spd max 0.01) ^ 2))) min 0.95;
    private _floor = _bed + 0.05;
    private _ceil = _floor max -0.3; // under the surface, unless it's shallower than that
    private _eq = (((_bp select 2) - (_run * (_s / (sqrt (1 - (_s * _s)))))) max _floor) min _ceil;
    private _dz = (_eq - _z0) * (1 - exp (-_dt / 0.6));
    // Eases towards that depth; it only ever stops at the bottom (it is never snapped down).
    _z = (_z0 + ((_dz max (-0.4 * _dt)) min (0.8 * _dt))) max _floor;
} else {
    private _dz = ((_bed + 0.05) - _z0) * (1 - exp (-_dt / 0.08));
    _z = _z0 + ((_dz max (-3 * _dt)) min (3 * _dt));
};
private _new = [_xy select 0, _xy select 1, _z];
if ((_new distance _now) < 0.0005) exitWith {};
_pad setPosASL _new;
// The end is an invisible static marker; the bag and the rope's fitting ride on it, attached. Things attached to a
// static object are only brought up to date now and then - left to the game they follow in hops, about once a second,
// though the end itself moves every frame.
[_pad] call ANC_fnc_reattach;

// Lying on what it's dragged over: tilted to the (smoothed) slope on land, upright in the water, pointing along the
// line - and turning gradually, never snapping.
private _upTo = [0, 0, 1];
if (!_wet) then {
    _upTo = [0, 0, 0];
    {_upTo = _upTo vectorAdd (surfaceNormal [(_xy select 0) + (_x select 0), (_xy select 1) + (_x select 1)])} forEach [[0.6, 0], [-0.6, 0], [0, 0.6], [0, -0.6]];
    _upTo = vectorNormalized _upTo;
};
private _k = 1 - exp (-_dt / 0.15);
private _cu = vectorUp _pad;
private _up = vectorNormalized (_cu vectorAdd ((_upTo vectorDiff _cu) vectorMultiply _k));
private _along = vectorNormalized [(_bp select 0) - (_xy select 0), (_bp select 1) - (_xy select 1), 0];
private _cd = vectorDir _pad;
private _dir = vectorNormalized (_cd vectorAdd ((_along vectorDiff _cd) vectorMultiply _k));
_dir = vectorNormalized (_dir vectorDiff (_up vectorMultiply (_dir vectorDotProduct _up)));
if (vectorMagnitude _dir > 0.1) then {_pad setVectorDirAndUp [_dir, _up]};
