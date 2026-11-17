/*
    ANC_fnc_logTurning  (client, diagnostic)

    Use: drive the boat, open the debug console and run
    then for 60 seconds hold FULL LOCK (either way) and circle at a few steady speeds - e.g. slow, half throttle, full
    throttle, full with turbo. Keep each speed for 10 seconds or so. The Assault Boat handling (boost, speed caps,
    trim) is paused while it measures, so it's Arma's own turning.

    For each 5 km/h speed band it logs the average turning circle (diameter) and radius, and the 40 degree equivalent:
    x sin 15 / sin 40 (about 0.40) - an outboard's sideways push grows with the sine of its swivel angle.
*/
private _boat = vehicle player;
if (_boat isEqualTo player || {driver _boat != player}) exitWith {hintSilent "Drive the boat first."};
ANC_measureTurn = true; // pauses the Assault Boat handling while measuring
hintSilent "Turning log: 60 seconds. Hold FULL LOCK and circle at a few steady speeds (10 s each).";
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Turning log: %1", typeOf _boat]};

private _bins = []; // [speed band, [radius samples]]
for "_i" from 0 to 11 do {_bins pushBack [_i * 5, []]};
private _end = time + 60;
while {time < _end && {alive _boat} && {driver _boat == player}} do {
    private _phase = _boat animationPhase "drivingwheel";
    private _v = velocity _boat;
    private _speed = vectorMagnitude [_v select 0, _v select 1, 0]; // m/s
    private _yaw = abs ((angularVelocity _boat) select 2); // rad/s
    // Full lock (the animation reaches +/-0.5), moving, and actually turning.
    if (abs _phase >= 0.45 && {_speed > 0.8} && {_yaw > 0.02} && {surfaceIsWater getPosASL _boat}) then {
        private _band = (floor ((_speed * 3.6) / 5)) min 11;
        ((_bins select _band) select 1) pushBack (_speed / _yaw);
    };
    sleep 0.1;
};
ANC_measureTurn = nil;

private _k = (sin 15) / (sin 40);
private _any = false;
{
    _x params ["_from", "_r"];
    if (count _r >= 10) then {
        _any = true;
        private _avg = 0;
        {_avg = _avg + _x} forEach _r;
        _avg = _avg / (count _r);
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Turning log: %1-%2 km/h: Arma turning circle %3 m (radius %4 m, %5 readings) | with a 40 deg outboard: circle %6 m (radius %7 m)",
            _from, _from + 5, (_avg * 2) toFixed 1, _avg toFixed 1, count _r, (_avg * 2 * _k) toFixed 1, (_avg * _k) toFixed 1]};
    };
} forEach _bins;
if (!_any) then {if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log "[Anchors] Turning log: not enough full-lock readings - hold full lock longer at each speed."}};
hintSilent "Turning log done - see the RPT lines starting [Anchors] Turning log.";
