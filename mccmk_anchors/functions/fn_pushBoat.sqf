/*
    ANC_fnc_pushBoat  (where the boat is local)
    One push: the boat moves 2.5 m along the ground (or through the water), away from the person pushing, over about 2
    seconds. Its speed is set each frame to cover what's left of that metre in what's left of the time, so the
    ground's grip can't stop it short. Up and down is left to the game.
    [boat, the pusher's position]
*/
params [["_b", objNull, [objNull]], ["_from", [], [[]]]];
if (isNull _b || {!alive _b} || {!local _b} || {count _from != 3}) exitWith {};
if (_b getVariable ["ANC_pushing", false]) exitWith {};
private _dir = (getPosASL _b) vectorDiff _from;
_dir set [2, 0];
if ((vectorMagnitude _dir) < 0.01) exitWith {};
_dir = vectorNormalized _dir;
_b setVariable ["ANC_pushing", true];
private _start = getPosASL _b;
private _target = _start vectorAdd (_dir vectorMultiply 2.5); // 2.5 m a push
[{
    params ["_args", "_h"];
    _args params ["_b", "_target", "_t0", "_dir"];
    private _left = 2.2 - (time - _t0);
    private _here = getPosASL _b;
    private _rem = (_target vectorDiff _here) vectorDotProduct _dir;
    if (isNull _b || {!alive _b} || {_left <= 0} || {_rem <= 0.02}) exitWith {
        [_h] call CBA_fnc_removePerFrameHandler;
        if (!isNull _b) then {
            _b setVariable ["ANC_pushing", false];
            private _v = velocity _b;
            _b setVelocity [0, 0, _v select 2];
        };
    };
    private _sp = (_rem / (_left max 0.2)) min 2.5;
    private _v = velocity _b;
    _b setVelocity [(_dir select 0) * _sp, (_dir select 1) * _sp, _v select 2];
}, 0, [_b, _target, time, _dir]] call CBA_fnc_addPerFrameHandler;
