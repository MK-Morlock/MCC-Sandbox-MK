/*
    ANC_fnc_shoreThrowBag  (server)
    The rope's end rides on the bag. Lands at (or very near) the target; waits until it's down.
    [boat, end, bag, fromASL, targetASL]
*/
params ["_boat", "_pad", "_bag", "_from", "_target"];
if (isNull _bag) exitWith {[_boat, _pad, _from, _target] call ANC_fnc_shoreFly};

// Ballistic velocity to reach the target: flight time grows with distance.
private _flat = [(_target select 0) - (_from select 0), (_target select 1) - (_from select 1), 0];
private _d = (vectorMagnitude _flat) max 0.5;
private _t = 0.6 + (_d * 0.04);
private _vz = (((_target select 2) - (_from select 2)) + (0.5 * 9.81 * _t * _t)) / _t;
private _v = ((vectorNormalized _flat) vectorMultiply (_d / _t)) vectorAdd [0, 0, _vz];

// Let the rope out first, so it's slack all through the throw and can't snatch the boat mid-flight.
private _rope = _boat getVariable ["ANC_rope", objNull];
private _pt = _boat getVariable ["ANC_shorePoint", [0, 0, 0]];
if (!isNull _rope) then {
    ropeUnwind [_rope, 100, ((_boat modelToWorldWorld _pt) distance _target) + 4];
    sleep 0.3;
};
detach _bag;
_bag setPosASL _from;
_bag setVelocity _v;
_pad attachTo [_bag, [0, 0, 0]]; // the rope's end rides on the bag
// the rope's fitting on the bag ITSELF while it flies (through the end, attached to the bag, it lagged behind)
private _ropeFit = _boat getVariable ["ANC_helper", objNull];
if (!isNull _ropeFit) then {_ropeFit attachTo [_bag, [0, 0, 0]]};

// Until it's down (or 6 s); if it flies further than expected, more rope goes out.
private _timeout = time + 6;
sleep 0.2;
waitUntil {
    sleep 0.03;
    private _p = getPosASL _bag;
    private _need = ((_boat modelToWorldWorld _pt) distance _p) + 1.5;
    if (!isNull _rope && {_need > ropeLength _rope}) then {ropeUnwind [_rope, 40, _need + 1]};
    if (!isNull _ropeFit) then {_ropeFit attachTo [_bag, [0, 0, 0]]}; // kept on the bag every step
    isNull _bag || {time > _timeout} || {(vectorMagnitude velocity _bag) < 0.3}
        || {if (surfaceIsWater _p) then {((getPosASLW _bag) select 2) < 0.2} else {((getPosATL _bag) select 2) < 0.25}}
};
private _at = getPosASL _bag;
// INTO THE WATER (from Paddle Mod Fix): no stop at the surface. The bag carries its speed into the water - slowed by
// the water at once - and eases into its steady sink (0.4 m/s), all in one smooth movement, every frame;
// ANC_fnc_shoreWatch then carries on sinking it at that rate, to the bottom or to the end of the line (a guide rope
// in deep water).
if (surfaceIsWater _at && {(getTerrainHeightASL _at) < -0.3}) exitWith {
    private _v = velocity _bag;
    detach _pad;
    _pad setPosASL _at;
    _pad setVectorDirAndUp [vectorNormalized [(_v select 0) + 0.001, _v select 1, 0], [0, 0, 1]];
    private _bottom = ((boundingBoxReal _bag) select 0) select 2;
    _bag attachTo [_pad, [0, 0, (-_bottom) max 0.05]];
    _bag setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];
    _bag setVariable ["ANC_attOff", [0, 0, (-_bottom) max 0.05]];
    _bag setVariable ["ANC_attVD", [[0, 1, 0], [0, 0, 1]]];
    if (!isNull _ropeFit) then {_ropeFit attachTo [_pad, [0, 0, 0]]; _ropeFit setVariable ["ANC_attOff", [0, 0, 0]]};
    private _vz = ((_v select 2) min -1) max -8;
    private _done = [false];
    [{
        params ["_args", "_handle"];
        _args params ["_pad", "_p", "_vh", "_vz", "_t0", "_done"];
        if (isNull _pad || {time > _t0 + 1.5}) exitWith {_done set [0, true]; [_handle] call CBA_fnc_removePerFrameHandler};
        private _dt = (diag_deltaTime max 0.001) min 0.1;
        _vh = _vh vectorMultiply (exp (-_dt / 0.2)); // the water stops it going sideways
        _vz = -0.4 + ((_vz + 0.4) * (exp (-_dt / 0.25))); // and eases the plunge into a steady sink
        _p = _p vectorAdd ((_vh vectorAdd [0, 0, _vz]) vectorMultiply _dt);
        _p set [2, (_p select 2) max ((getTerrainHeightASL _p) + 0.05)];
        _pad setPosASL _p;
        [_pad] call ANC_fnc_reattach; // the bag and the rope's end with it
        _args set [1, _p]; _args set [2, _vh]; _args set [3, _vz];
    }, 0, [_pad, +_at, [_v select 0, _v select 1, 0], _vz, time, _done]] call CBA_fnc_addPerFrameHandler;
    waitUntil {sleep 0.05; _done select 0};
};
// Down: the end of the line sits where the bag landed, with the bag on it.
detach _pad;
_pad setPosASL _at;
if (!isNull _ropeFit) then {_ropeFit attachTo [_pad, [0, 0, 0]]; _ropeFit setVariable ["ANC_attOff", [0, 0, 0]]}; // back on the end
[_pad, _bag] call ANC_fnc_bagRest; // down on the ground beneath it, flat
