/*
    ANC_fnc_driftTick  (every computer, every 0.1 s)
    - see ANC_fnc_driftInit.

    For each boat this computer controls, using Arma 3's current wind (the weather system, including gusts):
      wind force = 1/2 x air density x (wind speed relative to the boat)^2
                    x the boat's above-water area facing the wind
      water force = 1/2 x water density x (boat's speed through the water)^2
                    x the hull's underwater area facing that way
    The difference accelerates the boat downwind (force / the boat's mass). Areas depend on how the boat lies to the
    wind: broadside-on catches more wind but also has more hull in the water than end-on. No drift speed is set
    anywhere - the boat speeds up until the water's resistance matches the wind's push, as a real one does. If the
    boat is already moving downwind faster than that (e.g. coasting after the engine was cut), this does nothing and
    Arma's own water resistance slows it.
*/
// Every 5 s: no boats left (and no lines out) - every Anchors timer stops until a boat appears again (ANC_fnc_wake).
if (time > (missionNamespace getVariable ["ANC_sleepCheck", 0])) then {
    ANC_sleepCheck = time + 5;
    ANC_driftShips = ANC_driftShips select {!isNull _x && {alive _x}};
    if (ANC_driftShips isEqualTo [] && {(missionNamespace getVariable ["ANC_lineBoats", []]) isEqualTo []}) then {call ANC_fnc_sleep};
};
if !(missionNamespace getVariable ["ANC_boatsOn", false]) exitWith {};
private _mode = missionNamespace getVariable ["ANC_windDrift", 2];
if (_mode == 0) exitWith {};
// Settling time at mission start before any drift.
if (time < (missionNamespace getVariable ["ANC_settleTime", 10])) exitWith {};

// Safety rebuild of the list every 60 s; deleted boats are dropped from it.
if (time > ANC_driftNextScan) then {
    ANC_driftNextScan = time + 60;
    ANC_driftShips = vehicles select {(_x isKindOf "Ship" || {_x call ANC_fnc_isSubmersible}) && {!(_x isKindOf "sab_Boat_01_base_F")}};
};
if (count ANC_driftShips == 0) exitWith {};

private _w = wind;
private _wH = [_w select 0, _w select 1, 0];
private _windSpeed = vectorMagnitude _wH;
if (_windSpeed < 0.3) exitWith {};
private _wDir = vectorNormalized _wH;
private _dt = 0.1;

{
    private _boat = _x;
    if (local _boat && {alive _boat} && {
        (_boat getVariable ["ANC_drift", false]) || {_mode == 2 && {!isEngineOn _boat} && {!(_boat getVariable ["ANC_held", false])}}
    } && {surfaceIsWater getPosASL _boat} && {_boat call ANC_fnc_isSurfaced} && {!(_boat call ANC_fnc_isAground)}) then {
        (_boat call ANC_fnc_boatGeometry) params ["_cx", "", "", "_halfW", "_bottomZ", "_topZ", "_length", "_zWater"];
        private _beam = _halfW * 2;
        private _freeboard = ((_topZ - _zWater) max 0.2) min (_length * 0.3);
        private _draft = ((_zWater - _bottomZ) max 0.15) min (_length * 0.2);

        // How the boat lies to the wind: 1 = broadside-on, 0 = end-on.
        private _heading = vectorDir _boat;
        _heading set [2, 0];
        private _broad = abs (((vectorNormalized _heading) vectorCrossProduct _wDir) select 2);
        private _airArea = ((_length * _broad) + (_beam * (1 - _broad))) * _freeboard * 0.8;
        private _waterArea = ((_length * _broad) + (_beam * (1 - _broad))) * _draft * 0.8;

        private _v = velocity _boat;
        private _along = _v vectorDotProduct _wDir; // speed downwind through the water
        private _relWind = (_windSpeed - _along) max 0;
        private _windForce = 0.5 * 1.225 * _relWind * _relWind * _airArea;
        private _waterForce = 0.5 * 1025 * (_along max 0) * (_along max 0) * _waterArea;
        private _net = _windForce - _waterForce;
        if (_net > 0) then {
            private _dv = (_net / ((getMass _boat) max 50)) * _dt;
            _boat setVelocity (_v vectorAdd (_wDir vectorMultiply _dv));
        };
    };
} forEach ANC_driftShips;
