/*
    ANC_fnc_raftHold  (every computer, every frame - from ANC_fnc_driftInit)
    Raft-up: the boat that made the lines fast (where it's simulated) is brought to, and kept at, its place beside the
    other boat (ANC_fnc_raft: parallel, centred, 1 m between the hulls) - the invisible fender at 1 m, and free to
    drift out to 1.2 m:
      position its level speed is steered to the other boat's speed plus a gentle approach to its place (up to 0.6 m/s
      while being
                brought alongside, 0.3 m/s once there), changing by no more than 1.5 m/s each second - never a jolt;
      heading   turned towards the other boat's heading (or the opposite, if it lies the other way round) at up to 8 degrees a
                second, about its own upright - its own turning is taken off, so the waves and its rudder can't swing
                it.
    Up and down, pitch and roll are left alone: it still rises, falls and rolls on the waves by itself. Only this boat
    is moved; the other goes about as it likes. Logged every 2 seconds.
*/
private _boats = missionNamespace getVariable ["ANC_lineBoats", []];
if (count _boats == 0) exitWith {};
private _dt = (diag_deltaTime max 0.001) min 0.1;
{
    private _boat = _x;
    if (local _boat && {alive _boat}) then {
        private _link = _boat getVariable ["ANC_raftLink", []];
        private _pose = _link param [5, []];
        if (count _pose == 4 && {(_pose select 0) isEqualTo "align"}) then {
            private _o = _link select 0;
            if (!isNull _o && {alive _o}) then {
                _pose params ["", "_px", "_py", "_pyaw"];
                private _there = (_boat getVariable ["ANC_state", ""]) isEqualTo "rafted";
                // heading first (turning the boat directly resets its speed in the game, so its speed is set after)
                private _eYaw = ((((getDir _o) + _pyaw) - (getDir _boat)) + 540) mod 360 - 180; // + = turn clockwise
                private _step = ((_eYaw max (-8 * _dt)) min (8 * _dt));
                if ((abs _step) > 0.005) then {
                    private _a = -_step; // anticlockwise, as the turn below is
                    private _d0 = vectorDir _boat;
                    private _u0 = vectorUp _boat;
                    private _d1 = (_d0 vectorMultiply (cos _a)) vectorAdd ((_u0 vectorCrossProduct _d0) vectorMultiply (sin _a)) vectorAdd (_u0 vectorMultiply ((_u0 vectorDotProduct _d0) * (1 - (cos _a))));
                    _boat setVectorDirAndUp [_d1, _u0];
                };
                private _av = angularVelocityModelSpace _boat;
                _boat setAngularVelocityModelSpace [_av select 0, _av select 1, 0];
                // position: along the other boat - kept centred on it. Across - the gap between the hulls is left to
                // drift freely between 1 m and 1.2 m; only outside that band is it corrected (closer than 1 m: eased
                // out - the invisible fender; further than 1.2 m: eased back in).
                private _want = _o modelToWorldVisualWorld [_px, _py, 0];
                private _me = _boat modelToWorldVisualWorld [0, 0, 0];
                private _f = _o vectorModelToWorld [0, 1, 0];
                _f set [2, 0];
                _f = vectorNormalized _f;
                private _cap = [0.6, 0.3] select _there;
                private _vO = velocity _o;
                private _vMe = velocity _boat;
                private _eY = (_want vectorDiff _me) vectorDotProduct _f;
                private _wantY = (_vO vectorDotProduct _f) + (((_eY * 1.2) max -_cap) min _cap);
                private _dv = _f vectorMultiply (_wantY - (_vMe vectorDotProduct _f));
                ([_boat, _o] call ANC_fnc_hullGap) params ["_gap", "_n"];
                private _corrN = switch (true) do {
                    case (_gap < 1): {(((1 - _gap) * 1.2) min _cap)};
                    case (_gap > 1.2): {-(((_gap - 1.2) * 1.2) min _cap)};
                    default {0};
                };
                if (_corrN != 0) then {
                    private _wantN = (_vO vectorDotProduct _n) + _corrN;
                    _dv = _dv vectorAdd (_n vectorMultiply (_wantN - (_vMe vectorDotProduct _n)));
                };
                _dv set [2, 0];
                private _dvMax = 1.5 * _dt;
                if ((vectorMagnitude _dv) > _dvMax) then {_dv = (vectorNormalized _dv) vectorMultiply _dvMax};
                _boat setVelocity [(_vMe select 0) + (_dv select 0), (_vMe select 1) + (_dv select 1), _vMe select 2];
                private _e = _want vectorDiff _me;
                _e set [2, 0];
                _boat setVariable ["ANC_raftErr", [abs _eY, abs _eYaw, _gap]];
                if (time > (_boat getVariable ["ANC_raftLogT", 0]) + 2) then {
                    _boat setVariable ["ANC_raftLogT", time];
                    if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Raft-up hold: %1 | %2 | %3 m from its place, heading %4 deg off | hull gap %5 m | its speed %6, the other's %7 m/s",
                        typeOf _boat, ["coming alongside", "alongside"] select _there, (round ((vectorMagnitude _e) * 100)) / 100, (round (_eYaw * 10)) / 10,
                        (round (_gap * 100)) / 100, (round ((vectorMagnitude _vMe) * 100)) / 100, (round ((vectorMagnitude _vO) * 100)) / 100]};
                };
            };
        };
    };
} forEach _boats;
