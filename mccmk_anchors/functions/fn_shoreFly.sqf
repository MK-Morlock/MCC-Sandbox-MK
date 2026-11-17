/*
    ANC_fnc_shoreFly  (server)
    Flies a line's end in an arc from one place to another, updated every frame (smooth), with the visible rope paying
    out behind it. Waits until it has landed. [boat, end, fromASL, toASL or {code returning ASL}]
*/
params ["_boat", "_pad", "_from", "_to"];
private _target = if (_to isEqualType {}) then {call _to} else {_to};
private _span = _from distance _target;
private _flight = 0.6 + (_span * 0.06);
private _arc = 1 + (_span * 0.2);
private _done = [false];
// Let the rope out first, so it's slack all through the throw.
private _rope0 = _boat getVariable ["ANC_rope", objNull];
if (!isNull _rope0) then {
    ropeUnwind [_rope0, 100, ((_boat modelToWorldWorld (_boat getVariable ["ANC_shorePoint", [0, 0, 0]])) distance _target) + 4];
    sleep 0.3;
};
[{
    params ["_args", "_handle"];
    _args params ["_boat", "_pad", "_from", "_to", "_flight", "_arc", "_t0", "_done"];
    private _k = ((time - _t0) / _flight) min 1;
    private _target = if (_to isEqualType {}) then {call _to} else {_to};
    if (_k >= 1 || {!alive _boat} || {isNull _pad}) exitWith {
        if (!isNull _pad) then {_pad setPosASL _target};
        _done set [0, true];
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    private _p = ((_from vectorMultiply (1 - _k)) vectorAdd (_target vectorMultiply _k)) vectorAdd [0, 0, _arc * 4 * _k * (1 - _k)];
    _pad setPosASL _p;
    [_pad] call ANC_fnc_reattach; // the rope's fitting and the bag with it, every frame
    private _rope = _boat getVariable ["ANC_rope", objNull];
    private _need = ((_boat modelToWorldWorld (_boat getVariable ["ANC_shorePoint", [0, 0, 0]])) distance _p) + 1;
    if (!isNull _rope && {_need > ropeLength _rope}) then {ropeUnwind [_rope, 40, _need + 1]};
}, 0, [_boat, _pad, _from, _to, _flight, _arc, time, _done]] call CBA_fnc_addPerFrameHandler;
waitUntil {sleep 0.05; _done select 0};
