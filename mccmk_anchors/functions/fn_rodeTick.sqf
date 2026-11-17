/*
    ANC_fnc_rodeTick  (every computer, every 0.05 s; each handles the boats it controls)

    The anchor's pull, modelled directly (Arma's rope is only the visible line, always kept slightly longer than the
    gap so it never pulls by itself).

    Each anchored boat has a rope / chain length L (ANC_rodeLen). With the anchor point (bow roller) a distance d from
    the anchor:
      Rope (nylon stretches): no pull until d > L, then pull = k x (d - L).
      Chain (heavy):           its weight hangs in a curve, so the pull starts
                               gently at 90 % of L and grows faster and faster as the curve is straightened; once
                               fully straight it is much stiffer.
      k is set from the boat's mass so a boat surges back and forth on its rope over roughly 8 seconds, as real
      anchored boats do. Damping (70 % of critical) takes the bounce out, so the boat settles.

    The pull acts AT THE ANCHOR POINT, towards the anchor. Away from the boat's centre of mass it also turns the boat
    (and dips the bow slightly if the rope leads down steeply), so the bow comes round to face the anchor - the real
    "tug". Applied as small changes to the boat's speed and turn rate, so it is ordinary physics with no snapping.

    Tow lines use the same model, applied to BOTH vehicles with their combined mass - each one moves in inverse
    proportion to its weight, so hauling in brings a dinghy to a combat boat, not the other way round.

    Shore lines (held by people ashore) use it too, limited to the combined pull of the people on the line (setting,
    default 600 N each). The line doesn't slip: the person holding the end can't walk beyond its length. On land,
    boats under 8 m can be dragged if that pull beats the ground's friction and the ground ahead isn't too steep or
    rocky; bigger boats run aground and stop.

    Mooring lines use the same model (nylon rope, can't slip), one per line, each pulling at its own point on the boat
    - so a boat rides on its bow and stern lines and hauling them in really brings it alongside.

    Holding and dragging (anchor only) use this real pull: an anchor holds the wind load on its boat in 15 m/s of wind
    at 5:1 scope or more (less with less scope; chain counts as one extra unit of scope; a kedge holds half the
    craft's weight). If the pull exceeds that, the anchor slips along the bottom just far enough to bring the pull
    back down to what it can hold - it drags.
*/
// Boats with a line out: kept by the server and shared only when it changes (ANC_fnc_lineBoats).
private _boats = missionNamespace getVariable ["ANC_lineBoats", []];
if (count _boats == 0) exitWith {ANC_rodeLastTick = diag_tickTime};
private _now = diag_tickTime;
private _dt = ((_now - ANC_rodeLastTick) max 0.01) min 0.1;
ANC_rodeLastTick = _now;

{
    private _boat = _x;
    if (local _boat && {alive _boat}) then {
        (_boat call ANC_fnc_info) params ["_mode", "_aPoint", "_max", "_rode"];
        private _m = (getMass _boat) max 50;
        private _k = _m * 0.617; // (2 pi / 8 s)^2
        private _com = getCenterOfMass _boat;

        // Every line pulling on this boat: [point on boat, end position ASL, length, "rope"/"chain", holding (-1 =
        // can't slip), end object]
        private _lines = [];
        private _end = _boat getVariable ["ANC_endObj", objNull];
        if ((_boat getVariable ["ANC_force", false]) && {!isNull _end}) then {
            _lines pushBack [_aPoint, getPosASL _end, _boat getVariable ["ANC_rodeLen", 10], _rode, 0, _end];
        };
        if (_boat getVariable ["ANC_moorOn", false]) then {
            {
                _x params ["_pad", "_bp", "_len"];
                if (!isNull _pad) then {_lines pushBack [_bp, getPosASL _pad, _len, "rope", -1, _pad]};
            } forEach (_boat getVariable ["ANC_moorData", []]);
        };

        // Tow line: [other vehicle, own point, other's point, length]. The same pull acts on both vehicles (each
        // computer applies it to the one it simulates), using their combined ("reduced") mass, so each vehicle moves
        // in inverse proportion to its own weight.
        // Every tow line on the boat (the line register, ANC_fnc_xlSync): a boat can tow from its bow and its stern, or
        // tow and be towed, at once.
        private _tows = ((_boat getVariable ["ANC_xl", []]) select {((_x select 1) isEqualTo "tow") && {!isNull (_x select 2)} && {alive (_x select 2)}}) apply {[_x select 2, _x select 3, _x select 4, _x select 5, _x param [6, ""]]};

        private _dv = [0, 0, 0];
        private _dw = [0, 0, 0];
        {
            _x params ["_point", "_a", "_L", "_type", "_holdFlag", "_endObj"];
            private _bow = _boat modelToWorldVisualWorld _point;
            private _vec = _bow vectorDiff _a;
            private _d = (vectorMagnitude _vec) max 0.01;
            private _u = _vec vectorMultiply (1 / _d);
            private _pull = 0;
            if (_type isEqualTo "chain") then {
                private _x0 = _d - (0.9 * _L);
                if (_x0 > 0) then {_pull = _k * _x0 * _x0 / ((0.1 * _L) max 0.5)};
                if (_d > _L) then {_pull = _pull + (2 * _k * (_d - _L))};
            } else {
                if (_d > _L) then {_pull = _k * (_d - _L)};
            };
            if (_pull > 0) then {
                private _rModel = _point vectorDiff _com;
                private _ptVel = (velocity _boat) vectorAdd (((angularVelocity _boat) vectorMultiply ANC_angSign) vectorCrossProduct (_boat vectorModelToWorld _rModel));
                private _vr = _ptVel vectorDotProduct _u;
                private _pullTotal = (_pull + (2 * 0.7 * sqrt (_k * _m) * _vr)) max 0;

                // Anchor only: holding and dragging.
                if (_holdFlag >= 0) then {
                    private _depth = ((_bow select 2) - (_a select 2)) max 0.5;
                    private _scope = (_L / _depth) + ([0, 1] select (_type isEqualTo "chain"));
                    private _scopeFactor = switch (true) do {
                        case (_scope >= 5): {1};
                        case (_scope >= 4): {0.75 + ((_scope - 4) * 0.25)};
                        case (_scope >= 3): {0.5 + ((_scope - 3) * 0.25)};
                        case (_scope >= 2): {0.2 + ((_scope - 2) * 0.3)};
                        default {((_scope - 1) max 0) * 0.2};
                    };
                    private _holding = if (_mode isEqualTo "kedge") then {_m * 9.81 * 0.5 * _scopeFactor} else {([_boat, 15] call ANC_fnc_windForce) * _scopeFactor};
                    if (_pullTotal > _holding && {(_boat getVariable ["ANC_state", ""]) in ["fixed", "reeling"]}) then {
                        _pullTotal = _holding;
                        private _slip = (((_d - _L) - (_holding / _k)) max 0) min 0.5;
                        if (_slip > 0.02) then {
                            private _flat = [_u select 0, _u select 1, 0];
                            if (vectorMagnitude _flat > 0.01) then {
                                private _p = _a vectorAdd ((vectorNormalized _flat) vectorMultiply _slip);
                                _p set [2, (getTerrainHeightASL _p) + 0.05];
                                _endObj setPosASL _p;
                            };
                            _boat setVariable ["ANC_dragTime", (_boat getVariable ["ANC_dragTime", 0]) + _dt];
                            if ((_boat getVariable ["ANC_dragTime", 0]) > 2 && {!(_boat getVariable ["ANC_dragWarned", false])}) then {
                                _boat setVariable ["ANC_dragWarned", true];
                                [_boat, ["The anchor is dragging - pay out more ({payout}) for a better hold.", "The anchor is dragging - it can't hold this load even with all the rope out."] select (_L >= _max - 0.5)] call ANC_fnc_tellBoat;
                            };
                        };
                    } else {
                        _boat setVariable ["ANC_dragTime", 0];
                        if (_pullTotal < _holding * 0.5) then {_boat setVariable ["ANC_dragWarned", false]};
                    };
                };

                // Add this line's effect: linear part and turning part (torque = lever arm x force).
                private _forceW = _u vectorMultiply (-_pullTotal);
                _dv = _dv vectorAdd (_u vectorMultiply (-(_pullTotal * _dt) / _m));
                (_boat call ANC_fnc_boatGeometry) params ["", "", "", "_halfW", "_bottomZ", "_topZ", "_length"];
                private _beam = _halfW * 2;
                private _height = (_topZ - _bottomZ) max 0.5;
                private _torque = _rModel vectorCrossProduct (_boat vectorWorldToModel _forceW);
                _dw = _dw vectorAdd ([
                    (_torque select 0) / (_m * ((_length ^ 2) + (_height ^ 2)) / 12), // pitch
                    (_torque select 1) / (_m * ((_beam ^ 2) + (_height ^ 2)) / 12), // roll
                    (_torque select 2) / (_m * ((_length ^ 2) + (_beam ^ 2)) / 12) // yaw
                ] vectorMultiply (_dt * ANC_angSign)); // -1: measured in game, see ANC_fnc_driftInit
            };
        } forEach _lines;

        {
            _x params ["_other", "_myPt", "_otherPt", "_tL", ["_role", ""]];
            private _mO = (getMass _other) max 50;
            private _mu = (_m * _mO) / (_m + _mO); // reduced mass of the pair
            // A tow line is stiffer than an anchor rope (about 8 times): with the anchor rope's softness and its 1 m
            // stretch limit, the pull can never beat the drag of a boat towed at speed. This holds it near the line's
            // length at speed, with a little stretch. (MK) stiffer still, and
            // no limit on the stretch counted: a line under load stretches about 10% of its length, as a real one does;
            // it still goes slack when the towed boat runs on, and snaps taut again
            private _kT = _mu * 0.617 * 8;	// (only the bow's turning uses this pull - see "A ROPE, NOT A SPRING")
            // (MK) from where the physics has the boats, not where they're drawn (drawn positions run a little ahead -
            // the rope's correction would flicker back and forth on them)
            private _me = _boat modelToWorldWorld _myPt;
            private _them = _other modelToWorldWorld _otherPt;
            private _vec = _me vectorDiff _them;
            private _d = (vectorMagnitude _vec) max 0.01;
            if (_d <= _tL && {missionNamespace getVariable ["ANC_debug", false]} && {time > (_boat getVariable ["ANC_towLogT", 0])}) then {
                _boat setVariable ["ANC_towLogT", time + 5];
                private _rp = _boat getVariable ["ANC_rope", objNull];
                diag_log format ["[Anchors] Tow %1 (%2) - %3: line %4 m | gap %5 m (slack) | rope %6 m | speeds %7 / %8 m/s",
                    typeOf _boat, [_role, "-"] select (_role isEqualTo ""), typeOf _other, _tL toFixed 1, _d toFixed 1, if (isNull _rp) then {"-"} else {(ropeLength _rp) toFixed 1},
                    (vectorMagnitude (velocity _boat)) toFixed 1, (vectorMagnitude (velocity _other)) toFixed 1];
            };
            if (_d > _tL) then {
                private _u = _vec vectorMultiply (1 / _d); // them -> me
                private _rModel = _myPt vectorDiff _com;
                private _myVel = (velocity _boat) vectorAdd (((angularVelocity _boat) vectorMultiply ANC_angSign) vectorCrossProduct (_boat vectorModelToWorld _rModel));
                private _oModel = _otherPt vectorDiff (getCenterOfMass _other);
                private _theirVel = (velocity _other) vectorAdd (((angularVelocity _other) vectorMultiply ANC_angSign) vectorCrossProduct (_other vectorModelToWorld _oModel));
                private _vr = (_myVel vectorDiff _theirVel) vectorDotProduct _u;
                // Stretch counted up to 3 m: enough to hold a boat towed at speed; a line hauled in (about 1 m/s) builds
                // its stretch gradually, so it still pulls firmly, not violently.
                private _pullT = ((_kT * (_d - _tL)) + (2 * 1.2 * sqrt (_kT * _mu) * _vr)) max 0;
                // The line can't pull harder than it takes to move the lighter vehicle: bring it up to the speed the
                // line is snapping tight at (in about half a second), accelerate it (3 m/s2), and drag it through the
                // water (about 0.05 x mass x speed squared - a floating boat keeps its full mass; the water adds drag,
                // growing with the square of its speed). A dinghy is dragged along rather than swinging a heavy boat's
                // stern round; a heavy hull at speed gets the pull it really needs.
                private _vTow = (vectorMagnitude (velocity _boat)) max (vectorMagnitude (velocity _other));
                private _pullWant = _pullT;
                private _pullCap = ((_m min _mO) * (((_vr max 0) / 0.5) + 3 + (0.05 * _vTow * _vTow))) + 600;
                _pullT = _pullT min _pullCap;
                // (MK) the tow measured with debug on, every 5 s per boat: is it held at the line's length?
                if ((missionNamespace getVariable ["ANC_debug", false]) && {time > (_boat getVariable ["ANC_towLogT", 0])}) then {
                    _boat setVariable ["ANC_towLogT", time + 5];
                    private _rp = _boat getVariable ["ANC_rope", objNull];
                    diag_log format ["[Anchors] Tow %1 (%2) - %3: line %4 m | gap %5 m (taut) | rope %6 m | speeds %7 / %8 m/s | masses %9 / %10 kg | pull %11 N (wanted %12 N, cap %13 N)",
                        typeOf _boat, [_role, "-"] select (_role isEqualTo ""), typeOf _other, _tL toFixed 1, _d toFixed 1, if (isNull _rp) then {"-"} else {(ropeLength _rp) toFixed 1},
                        (vectorMagnitude (velocity _boat)) toFixed 1, (vectorMagnitude (velocity _other)) toFixed 1, round _m, round _mO, round _pullT, round _pullWant, round _pullCap];
                };
                private _forceW = _u vectorMultiply (-_pullT);
                // (MK) a boat much heavier than the other (5 times) isn't touched at all by the line - nudged every frame,
                // the towing boat jittered against the game's own boat physics in a turn
                if (_m > (_mO * 5)) then {_forceW = [0, 0, 0]};
                // (MK) A ROPE, NOT A SPRING. A spring's pull is capped (what it takes to move the lighter boat), and a
                // dinghy towed fast has more drag than that. A taut rope simply doesn't let the boats get further apart:
                // so
                // while it's taut, each boat's speed along the line is changed by its share (the lighter boat takes nearly
                // all of it) of what's needed to stop them separating and to bring the gap back to the line's length
                // (closing at 2.5 m/s for each metre over, 6 m/s at most - it eases in, no bounce). Slack: nothing - the
                // towed boat runs on, drops back and comes taut again. The pull above still turns the bow to the line.
                private _vrWant = -(((_d - _tL) * 2.5) min 6);
                // (MK) against the jitter: the much heavier boat takes none of it and the light one all; differences under
                // 0.15 m/s are left alone; and half of what's needed is applied each frame, so it eases in over a few
                private _share = if (_m > (_mO * 5)) then {0} else {if (_mO > (_m * 5)) then {1} else {_mO / (_m + _mO)}};
                private _need = _vr - _vrWant;
                // (MK) THE STRETCH ABOVE 90 km/h, 1: half of what's needed, against a steady drag, leaves a standing gap
                // (about 1.2 m at 90 km/h). For a light boat towed by one five or more times its weight (the dinghy):
                // half up to
                // 80 km/h, rising to the whole of it by 90 km/h. Every other boat: half.
                private _strength = if (_m < 2500 && {_mO > (_m * 5)}) then {linearConversion [80, 90, _vTow * 3.6, 0.5, 1, true]} else {0.5};
                if (_need > 0.15 && {_share > 0}) then {
                    _dv = _dv vectorAdd (_u vectorMultiply (-(_need * _strength * _share)));
                };
                // (MK) with Anchors' debug on, once a second above 70 km/h: what the correction was given to work with
                if ((missionNamespace getVariable ["ANC_debug", false]) && {_role isEqualTo "towed"} && {(_vTow * 3.6) > 70} && {time > (_boat getVariable ["ANC_corrLogT", 0])}) then {
                    _boat setVariable ["ANC_corrLogT", time + 1];
                    // (the limit actually in use - the same reading as where it is applied, below)
                    private _capNow = if (_m < 2500) then {private _fx = missionNamespace getVariable ["ANC_dvCap", 3]; if (_fx > 0) then {_fx} else {3}} else {1.5};
                    diag_log format ["[Anchors] Tow correction %1: %2 km/h | stretch %3 m | needed %4 m/s, strength %5, so %6 m/s asked | limit this tick %7 m/s", typeOf _boat, round (_vTow * 3.6), (_d - _tL) toFixed 2, (_need max 0) toFixed 2, _strength toFixed 2, ((_need max 0) * _strength * _share) toFixed 2, _capNow toFixed 2];
                };
                (_boat call ANC_fnc_boatGeometry) params ["", "", "", "_halfW", "_bottomZ", "_topZ", "_length"];
                private _beam = _halfW * 2;
                private _height = (_topZ - _bottomZ) max 0.5;
                private _torque = _rModel vectorCrossProduct (_boat vectorWorldToModel _forceW);
                _dw = _dw vectorAdd ([
                    (_torque select 0) / (_m * ((_length ^ 2) + (_height ^ 2)) / 12),
                    (_torque select 1) / (_m * ((_beam ^ 2) + (_height ^ 2)) / 12),
                    (_torque select 2) / (_m * ((_length ^ 2) + (_beam ^ 2)) / 12)
                ] vectorMultiply (_dt * ANC_angSign));
                // (MK) with Anchors' debug logging on: once a second while the towed boat is going fast, what could tip its bow or stern -
                // the pull and its direction, where it acts against the boat's centre of mass and the water, and the boat's pitch
                if ((missionNamespace getVariable ["ANC_debug", false]) && {_role isEqualTo "towed"} && {(speed _boat) > 70} && {time > (_boat getVariable ["ANC_sternLogT", 0])}) then {
                    _boat setVariable ["ANC_sternLogT", time + 1];
                    private _pb = _boat call BIS_fnc_getPitchBank;
                    private _ropeUp = -(asin (((_u select 2) max -1) min 1));
                    private _pitchTwist = ((_torque select 0) * ANC_angSign) / (_m * ((_length ^ 2) + (_height ^ 2)) / 12);
                    diag_log format ["[Anchors] Stern %1: %2 km/h | pitch %3 deg, bank %4 deg | tow point %5 m above the centre of mass | rope angle %6 deg up from the boat | pull %7 N, pitch twist it gives %8 rad/s2 (+ nose up, - nose down)", typeOf _boat, round (speed _boat), (_pb select 0) toFixed 1, (_pb select 1) toFixed 1, ((_myPt select 2) - (_com select 2)) toFixed 2, _ropeUp toFixed 1, round _pullT, _pitchTwist toFixed 2];
                };
                // FOLLOWING THE LINE: a floating boat towed by its bow with nobody driving it turns its bow to the line
                // (a man on a riverbank could do it by hand) - in a turn it follows round on the inside. Here its
                // turning is steered towards the line: faster the more it's angled off (up to about 34 degrees a
                // second), easing off as it comes into line so it doesn't swing past, and only as firmly as the line is
                // pulling. Stern-first tows (unstable, as in real life) and crewed boats (their driver steers) are left
                // alone. (MK) any boat without its engine running - a man at the wheel of a powerless boat steers
                // nothing
                if (_role isEqualTo "towed" && {(_myPt select 1) > 0} && {!isEngineOn _boat || {isNull (driver _boat)} || {!alive (driver _boat)}}) then {
                    private _toLine = vectorNormalized [-(_u select 0), -(_u select 1), 0];
                    private _fwd = vectorNormalized [(vectorDir _boat) select 0, (vectorDir _boat) select 1, 0];
                    private _ang = (((_fwd select 0) * (_toLine select 1)) - ((_fwd select 1) * (_toLine select 0))) atan2 (_fwd vectorDotProduct _toLine);
                    private _wNow = ((angularVelocityModelSpace _boat) select 2) * ANC_angSign;
                    private _wWant = (((rad _ang) * 1.2) max -0.6) min 0.6;
                    // (MK) hauled in, the dinghy is CLOSING on the tow boat, and the pull number comes out at zero (its
                    // closing speed is taken off the line's stretch as damping) While closing, the nose-turning strength
                    // comes from the stretch alone. 
                    // This number does NOT move the boat - only how firmly its nose is turned.
                    private _pullFirm = if (_vr < 0) then {(_kT * (_d - _tL)) max 0} else {_pullT};
                    private _firm = ((_pullFirm / (_m * 0.3)) min 1) max 0;
                    _dw = _dw vectorAdd [0, 0, ((_wWant - _wNow) * (((4 * _dt) min 1) * _firm)) * ANC_angSign];
                };
            };
        } forEach _tows;

        // ---- Raft-up / tether: lines to another boat (both boats held, each by the computer simulating it), and an ----
        // invisible fender - the hulls can't come closer than the least gap (0.5 m), and rafted boats can't drift
        // further apart than the greatest (1.5 m). Each boat takes its share of the correction by weight: the lighter
        // one moves more.
        private _raft = _boat getVariable ["ANC_raftLink", []];
        // only while the lines are being hauled in - once made fast the boats are held together by ANC_fnc_raftHold
        if (count _raft >= 5 && {count (_raft param [5, []]) == 0}) then {
            _raft params ["_rO", "_rKind", "_rLines", "_gMin", "_gMax"];
            if (!isNull _rO && {alive _rO}) then {
                private _mO = (getMass _rO) max 50;
                private _mu = (_m * _mO) / (_m + _mO);
                private _kT = _mu * 0.617;
                (_boat call ANC_fnc_boatGeometry) params ["", "", "", "_halfW", "_bottomZ", "_topZ", "_length"];
                private _beam = _halfW * 2;
                private _height = (_topZ - _bottomZ) max 0.5;
                {
                    _x params ["_myPt", "_thPt", "_L"];
                    private _me = _boat modelToWorldVisualWorld _myPt;
                    private _them = _rO modelToWorldVisualWorld _thPt;
                    private _vec = _me vectorDiff _them;
                    private _d = (vectorMagnitude _vec) max 0.01;
                    if (_d > _L) then {
                        private _u = _vec vectorMultiply (1 / _d);
                        private _rModel = _myPt vectorDiff _com;
                        private _myVel = (velocity _boat) vectorAdd (((angularVelocity _boat) vectorMultiply ANC_angSign) vectorCrossProduct (_boat vectorModelToWorld _rModel));
                        private _oModel = _thPt vectorDiff (getCenterOfMass _rO);
                        private _theirVel = (velocity _rO) vectorAdd (((angularVelocity _rO) vectorMultiply ANC_angSign) vectorCrossProduct (_rO vectorModelToWorld _oModel));
                        private _vr = (_myVel vectorDiff _theirVel) vectorDotProduct _u;
                        private _pullT = ((_kT * ((_d - _L) min 1)) + (2 * 1.2 * sqrt (_kT * _mu) * _vr)) max 0;
                        private _forceW = _u vectorMultiply (-_pullT);
                        _dv = _dv vectorAdd (_forceW vectorMultiply (_dt / _m));
                        private _torque = _rModel vectorCrossProduct (_boat vectorWorldToModel _forceW);
                        _dw = _dw vectorAdd ([
                            (_torque select 0) / (_m * ((_length ^ 2) + (_height ^ 2)) / 12),
                            (_torque select 1) / (_m * ((_beam ^ 2) + (_height ^ 2)) / 12),
                            (_torque select 2) / (_m * ((_length ^ 2) + (_beam ^ 2)) / 12)
                        ] vectorMultiply (_dt * ANC_angSign));
                    };
                } forEach _rLines;
                ([_boat, _rO] call ANC_fnc_hullGap) params ["_gap", "_n"];
                private _vRel = ((velocity _boat) vectorDiff (velocity _rO)) vectorDotProduct _n; // + = opening
                private _share = _mO / (_m + _mO);
                if (_gap < _gMin) then {
                    private _want = ((_gMin - _gap) * 2) min 1;
                    if (_vRel < _want) then {_dv = _dv vectorAdd (_n vectorMultiply ((_want - _vRel) * _share))};
                };
                if (_gMax > 0 && {_gap > _gMax}) then {
                    private _want = -(((_gap - _gMax) * 2) min 1);
                    if (_vRel > _want) then {_dv = _dv vectorAdd (_n vectorMultiply ((_want - _vRel) * _share))};
                };
            };
        };

        // ---- Shore line (held by people ashore, or made fast to something) ----
        private _shore = _boat getVariable ["ANC_shoreData", []];
        if (count _shore == 5 && {(_shore select 4) in ["held", "tied"]} && {!isNull (_shore select 0)}) then {
            _shore params ["_sPad", "_sPt", "_sL", "_sStr", "_sState"];
            // Paddle Mod's Zodiacs ("One person can pull them ashore"): no per-person strength limit, as in Paddle
            // Mod - only its Zodiacs carry the rope bag that can be pulled. Steep or rocky shores still stop the
            // boat. Any other boat can have it too, from the line in its Eden Init box:
            if (_sStr >= 0 && {missionNamespace getVariable ["ANC_paddlePull", false]}
                && {(_boat getVariable ["PaddleRopeBag", false]) || {_boat isKindOf "Rubber_duck_base_F" && {_boat call ANC_fnc_isPaddleBoat}}}) then {_sStr = 1e6};
            private _me = _boat modelToWorldVisualWorld _sPt;
            private _end = getPosASL _sPad;
            private _vec = _me vectorDiff _end;
            private _d = (vectorMagnitude _vec) max 0.01;
            private _tell = {
                params ["_key", "_msg"];
                if (time > (_boat getVariable [_key, -100]) + 8) then {_boat setVariable [_key, time]; [_boat, _msg] call ANC_fnc_tellBoat};
            };
            // or someone leaning back on it at its end - then it's taut, whatever the few centimetres say
            if (_d > _sL - 0.25 || {_sStr >= 0 && {_d > _sL - 0.5} && {(serverTime - (_boat getVariable ["ANC_pullT", -10])) < 0.8}}) then {
                private _u = _vec vectorMultiply (1 / _d); // end -> boat
                private _rModel = _sPt vectorDiff _com;
                private _ptVel = (velocity _boat) vectorAdd (((angularVelocity _boat) vectorMultiply ANC_angSign) vectorCrossProduct (_boat vectorModelToWorld _rModel));
                private _pull = if (_sStr >= 0) then {
                    // People leaning on a taut line pull with their full strength (ramping up over the last 25 cm of
                    // slack), eased off if the boat is already coming in fast.
                    private _ramp = (((_d - (_sL - 0.25)) / 0.25) min 1) max 0;
                    ((_sStr * _ramp) + (2 * 0.7 * sqrt (_k * _m) * ((_ptVel vectorDotProduct _u) min 0))) max 0
                } else {
                    // Made fast to something: a mooring-type line.
                    if (_d > _sL) then {((_k * (_d - _sL)) + (2 * 0.7 * sqrt (_k * _m) * (_ptVel vectorDotProduct _u))) max 0} else {0}
                };
                // Made fast ashore and hauled in from aboard (the line shortened from the boat): that's the crew
                // pulling themselves in hand over hand - one person's strength (350 N), not a winch. No lurch.
                if (_sStr < 0 && {(_d - _sL) > 0.3} && {surfaceIsWater (getPosASL _boat)} && {!(_boat call ANC_fnc_isAground)}) then {_pull = _pull min 350};

                // People can only pull so hard: the force on the boat is capped at their combined strength. The line
                // doesn't slip - whoever holds the end is stopped at the end of it instead (ANC_fnc_shoreFollow).
                if (_sStr >= 0 && {_pull > _sStr}) then {_pull = _sStr};

                // "Afloat" for pulling: in water with the hull floating - not aground, OR still in more than 30 cm of
                // water at its middle. Touching bottom in water, it gets that friction too, but only on the little
                // weight the water doesn't carry (below).
                private _bAground = _boat call ANC_fnc_isAground;
                private _depthMid = 0 - (getTerrainHeightASL (getPosASL _boat));
                // Someone LEANING BACK on the line at its end (ANC_fnc_shoreFollow holds them there and flags it):
                // the line is taut and they pull with their full strength. ...but only when the line really is
                // (nearly) taut: within half a metre of its length. A slack line never pulls - with 10 m of slack it
                // does nothing, however the holder is flagged.
                private _leaning = ((serverTime - (_boat getVariable ["ANC_pullT", -10])) < 0.8) && {_d > _sL - 0.5};
                if ((surfaceIsWater (getPosASL _boat)) && {!_bAground || {_depthMid > 0.3}} && {_sStr >= 0} && {(_d > _sL - 0.1) || _leaning}) then {
                    // AFLOAT, HELD BY PEOPLE: a boat on the water pulled by a rope follows whoever pulls it with
                    // hardly any resistance - at the pace that keeps the line only slightly stretched (4 m/s for each
                    // metre past the line's length, up to 8 m/s), slowed only by the "Water drag" setting (0 % =
                    // none). Pulled at an angle, it swings round behind its line as it comes (like anything towed by
                    // one end). Applied by the drag handler, smoothly.
                    private _sp = _boat getVariable ["ANC_pullStretch", [0, -10]];
                    private _st = if ((serverTime - (_sp select 1)) < 0.6) then {_sp select 0} else {0};
                    private _vF = [_boat, _st, _dt, false] call ANC_fnc_pullSpeed; // from forces: the pull against the water's drag
                    private _dirH = [-(_u select 0), -(_u select 1), 0];
                    if ((vectorMagnitude _dirH) > 0.01) then {_dirH = vectorNormalized _dirH};
                    private _lever = _boat vectorModelToWorld (_sPt vectorDiff _com);
                    _lever set [2, 0];
                    private _leverLen = (vectorMagnitude _lever) max 0.5;
                    private _sinA = (((_lever select 0) * (_dirH select 1)) - ((_lever select 1) * (_dirH select 0))) / _leverLen;
                    private _vNowH = velocity _boat;
                    _vNowH set [2, 0];
                    private _wF = ((((vectorMagnitude _vNowH) max (_vF * 0.5)) * _sinA) / _leverLen) max -0.8 min 0.8;
                    private _e = [_boat, _dirH vectorMultiply _vF, _wF, time + 0.15];
                    private _i = ANC_dragList findIf {(_x select 0) isEqualTo _boat};
                    if (_i < 0) then {ANC_dragList pushBack _e} else {ANC_dragList set [_i, _e]};
                    if (time > (_boat getVariable ["ANC_waterLogT", 0]) + 2) then {
                        _boat setVariable ["ANC_waterLogT", time];
                        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Pulling afloat: %1 | %2 m past the line's length | asked %3 m/s, moving %4 m/s | turning %5 rad/s | water drag %6 percent", typeOf _boat, _st toFixed 2, _vF toFixed 2, (vectorMagnitude _vNowH) toFixed 2, _wF toFixed 2, missionNamespace getVariable ["ANC_waterDrag", 100]]};
                    };
                } else {
                if ((surfaceIsWater (getPosASL _boat)) && {!(_boat call ANC_fnc_isAground)}) then {
                    // A HELD line that isn't taut yet (between 25 and 10 cm short) pulls nothing: its pull is the
                    // force model above, and only once it's taut.
                    if (_sStr >= 0) then {_pull = 0};
                    // Afloat: the pull acts at the line's point on the boat (moves and turns it).
                    private _forceW = _u vectorMultiply (-_pull);
                    _dv = _dv vectorAdd (_forceW vectorMultiply (_dt / _m));
                    (_boat call ANC_fnc_boatGeometry) params ["", "", "", "_halfW", "_bottomZ", "_topZ", "_length"];
                    private _beam = _halfW * 2;
                    private _height = (_topZ - _bottomZ) max 0.5;
                    private _torque = _rModel vectorCrossProduct (_boat vectorWorldToModel _forceW);
                    _dw = _dw vectorAdd ([
                        (_torque select 0) / (_m * ((_length ^ 2) + (_height ^ 2)) / 12),
                        (_torque select 1) / (_m * ((_beam ^ 2) + (_height ^ 2)) / 12),
                        (_torque select 2) / (_m * ((_length ^ 2) + (_beam ^ 2)) / 12)
                    ] vectorMultiply (_dt * ANC_angSign));
                } else {
                    // Aground (resting on the bottom, even in the shallows) or on land: only boats under 8 m can be
                    // dragged, and only if the people on the line can beat the ground's friction - and the ground
                    // ahead isn't too steep (over the "Steepest shore" setting, 30 degrees by default) or rocky. Held
                    // lines only (a line made fast to a post doesn't drag the boat up the beach).
                    (_boat call ANC_fnc_boatGeometry) params ["", "", "", "", "", "", "_length"];
                    private _dirH = [-(_u select 0), -(_u select 1), 0];
                    if (vectorMagnitude _dirH > 0.01) then {_dirH = vectorNormalized _dirH};
                    private _ahead = (getPosASL _boat) vectorAdd (_dirH vectorMultiply ((_length / 2) + 1));
                    private _surf = toLower surfaceType _ahead;
                    private _steep = ((surfaceNormal _ahead) select 2) < cos (missionNamespace getVariable ["ANC_maxSlope", 30]);
                    private _rocky = (["rock", "stony", "stone", "concrete", "gravel"] findIf {(_surf find _x) != -1}) != -1;
                    private _mass = _m + (90 * ({alive _x} count crew _boat));
                    private _mu = [0.5, 0.3] select (_boat call ANC_fnc_isDinghy); // inflatables slide well on sand
                    private _needed = _mu * _mass * 9.81;
                    // THE PULL OVER THE GROUND: the "Pulling force over ground" setting (newtons per person on the
                    // line), only while the line is taut (or someone leans back on it).
                    private _people = (count (_boat getVariable ["ANC_shoreHolders", []])) max 1;
                    private _Fg = if (_leaning || {_d > _sL - 0.1}) then {_people * (missionNamespace getVariable ["ANC_groundPull", 3000])} else {0};
                    if !(_boat getVariable ["ANC_massLogged", false]) then {
                        _boat setVariable ["ANC_massLogged", true];
                        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Dragging %1 ashore: mass %2 kg (+%3 kg crew), needs %4 N to slide along its length; pull %5 N per person.", typeOf _boat, round _m, round (_mass - _m), round _needed, missionNamespace getVariable ["ANC_groundPull", 3000]]};
                    };
                    // A hull slides along its length far more easily than sideways (keel and chines dig in): sideways
                    // grip is 2.5 times the lengthwise grip; A hull already sliding turns more easily (half the
                    // grip); - the more spare pull over the grip, the faster: 0.2 m/s plus 0.8 m/s for each "grip's
                    // worth" of spare pull, up to 3 m/s - so the setting really changes how easily and how fast it
                    // comes. So "along" is always towards the line's end: a line on the bow, pulled from ahead,
                    // slides it bow first and swings the bow to the pull; on the stern, stern first.
                    private _fwd = _boat vectorModelToWorld (_sPt vectorDiff _com);
                    _fwd set [2, 0];
                    if ((vectorMagnitude _fwd) < 0.3) then {_fwd = vectorDir _boat; _fwd set [2, 0]};
                    _fwd = if ((vectorMagnitude _fwd) > 0.01) then {vectorNormalized _fwd} else {_dirH};
                    private _side = [_fwd select 1, -(_fwd select 0), 0];
                    private _fLong = _Fg * (_dirH vectorDotProduct _fwd);
                    private _fLat = _Fg * (_dirH vectorDotProduct _side);
                    private _gripLong = _needed;
                    private _gripLat = _needed * 2.5;
                    // THE PULLER'S OWN PACE: how fast the person on the line is trying to move away (walking, jogging
                    // or running backwards, or turned away and running - worked out on his computer while he's held
                    // at the line's end, ANC_fnc_shoreFollow).
                    private _pace = if ((serverTime - (_boat getVariable ["ANC_pullT", -10])) < 0.8) then {(((velocity _boat) vectorDotProduct _dirH) max 0) + ((_boat getVariable ["ANC_pullPace", 0]) * 1.5) + 0.1} else {0};    // (the boat's own speed towards him + how much faster than that he's trying to go)
                    private _spd = {
                        params ["_f", "_grip"];
                        if ((abs _f) <= _grip) exitWith {0};
                        // times the "Drag speed" setting - the top speed too
                        private _mul = missionNamespace getVariable ["ANC_dragSpeedMul", 1];
                        ((((0.2 + ((((abs _f) - _grip) / _grip) * 0.8)) * _mul) min ((3 * _mul) max _pace)) * ([-1, 1] select (_f > 0)))
                    };
                    private _vLong = [_fLong, _gripLong] call _spd;
                    private _vLat = ([_fLat, _gripLat] call _spd) * 0.25;
                    // THE SPEED, SIMPLY: the boat follows whoever is pulling at the pace that keeps the line only
                    // slightly stretched - 4 m/s for each metre he is past the line's length (x the Drag speed
                    // setting), up to 8 m/s - straight towards him. No ground grip, no newtons: he walks, it comes;
                    // he runs, it comes faster; he stops, it eases to a stop.
                    private _sp = _boat getVariable ["ANC_pullStretch", [0, -10]];
                    private _st = if ((serverTime - (_sp select 1)) < 0.6) then {_sp select 0} else {0};
                    private _vF = [_boat, _st, _dt, true] call ANC_fnc_pullSpeed;   /*
 from forces: the pull against the ground's drag
*/
                    _vLong = _vF * (_dirH vectorDotProduct _fwd);
                    _vLat = _vF * (_dirH vectorDotProduct _side);
                    private _lever = _boat vectorModelToWorld (_sPt vectorDiff _com);
                    _lever set [2, 0];
                    private _torque = _Fg * (((_lever select 0) * (_dirH select 1)) - ((_lever select 1) * (_dirH select 0)));
                    private _tGrip = _gripLat * (_length / 4) * ([1, 0.5] select (_vLong != 0));
                    private _w = if ((abs _torque) > _tGrip) then {((((((abs _torque) - _tGrip) / _tGrip) min 1) * 0.5) + 0.05) * ([-1, 1] select (_torque > 0))} else {0};
                    // TURNING WHILE IT MOVES: a hull dragged by one end swings round behind it, like a trailer or a
                    // sledge on a rope - its turn rate is its own speed x sin(angle between its end and the line) /
                    // the end's distance from the middle. Worked out from how fast the boat is ACTUALLY moving (not
                    // what's asked for), so it can't stall the drag: standing still it turns only if the pull beats
                    // the ground's grip (above); moving, the bow comes round to the pull.
                    private _leverLen = (vectorMagnitude _lever) max 0.5;
                    private _sinA = (((_lever select 0) * (_dirH select 1)) - ((_lever select 1) * (_dirH select 0))) / _leverLen;
                    private _vNowH = velocity _boat;
                    _vNowH set [2, 0];
                    private _wTow = ((vectorMagnitude _vNowH) * _sinA) / _leverLen;
                    if ((abs _wTow) > (abs _w)) then {_w = _wTow};
                    _w = (_w max -0.8) min 0.8;
                    // The turn's direction checked against the logs: with the line on the bow and the puller ahead of
                    // it, the turn as worked out above brings the bow round towards the pull. (Reversing it, as
                    // tried, swung the boat right round until its stern faced the puller.) It can only be seen
                    // working once the boat really moves - standing still, the ground holds it. SPEED: no faster than
                    // a person can walk back with the line (1.6 m/s, times the Drag speed setting), so the boat
                    // doesn't shoot past the walker, go slack and stop, again and again. The pull still decides
                    // whether it moves at all and how quickly it gets up to that.
                    private _cap = 1e6;
                    private _vMag = sqrt ((_vLong ^ 2) + (_vLat ^ 2));
                    if (_vMag > _cap) then {_vLong = _vLong * (_cap / _vMag); _vLat = _vLat * (_cap / _vMag)};
                    switch (true) do {
                        case (_sStr < 0): {};
                        case (_Fg <= 0): {
                            private _i = ANC_dragList findIf {(_x select 0) isEqualTo _boat};
                            if (_i >= 0) then {ANC_dragList set [_i, [_boat, [0, 0, 0], 0, time + 0.15]]};
                        };
                        case (_length >= 8): {["ANC_toldBig", "This boat is too big to drag out of the water - it has run aground."] call _tell};
                        case (_vF <= 0): {
                            private _i = ANC_dragList findIf {(_x select 0) isEqualTo _boat};
                            if (_i >= 0) then {ANC_dragList set [_i, [_boat, [0, 0, 0], 0, time + 0.15]]};
                        };
                        default {
                            // applied every frame, eased in, by the drag handler - smooth, not in 20 steps a second
                            private _e = [_boat, (_fwd vectorMultiply _vLong) vectorAdd (_side vectorMultiply _vLat), _w, time + 0.15];
                            private _i = ANC_dragList findIf {(_x select 0) isEqualTo _boat};
                            if (_i < 0) then {ANC_dragList pushBack _e} else {ANC_dragList set [_i, _e]};
                            if (isDamageAllowed _boat) then {_boat allowDamage false; _boat setVariable ["ANC_dmgOff", true]};
                            _boat setVariable ["ANC_dragUntil", time + 3];
                            if (time > (_boat getVariable ["ANC_groundLogT", 0]) + 2) then {
                                _boat setVariable ["ANC_groundLogT", time];
                                if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Pulling over ground: %1 | pull %2 N (%3 on the line) | along %4 N, across %5 N, grip %6 / %7 N | speed along %8, across %9 m/s | turning %10 rad/s (turn force %11 N.m, grip %12 N.m) | really moving %13 m/s | line point %14 (model y %15, the model's front is +y) | pull %16 deg off the line's end", typeOf _boat, round _Fg, _people, round _fLong, round _fLat, round _gripLong, round _gripLat, _vLong toFixed 2, _vLat toFixed 2, _w toFixed 2, round _torque, round _tGrip, (vectorMagnitude _vNowH) toFixed 2, _sPt, (_sPt select 1) toFixed 2, round (acos (((_fwd vectorDotProduct _dirH) max -1) min 1))]};
                            };
                        };
                    };
                };
                };
            };
        };
        // Damage back on once the boat has stopped being dragged over land.
        if ((_boat getVariable ["ANC_dmgOff", false]) && {time > (_boat getVariable ["ANC_dragUntil", 0])}) then {
            _boat allowDamage true;
            _boat setVariable ["ANC_dmgOff", false];
        };

        if ((vectorMagnitude _dv) > 0) then {
            // (MK) no big jump in a single frame (a light boat would jitter - a double image): at most 0.8 m/s a frame
            // (MK) THE STRETCH ABOVE 90 km/h, 2: the most a boat's speed is changed in a tick. The water's drag on a
            // dinghy passes 1.5 m/s a tick at about 88 km/h, so for a light boat (under 2.5 t - the towed dinghy) the
            // limit is 3 m/s a tick AT EVERY SPEED. Heavier boats: 1.5. From the debug console, ANC_dvCap = 2; (any
            // number above 0) sets another limit for light boats.
            private _dvCap = 1.5;
            if (_m < 2500) then {
                private _fix = missionNamespace getVariable ["ANC_dvCap", 3];
                _dvCap = if (_fix > 0) then {_fix} else {3};
            };
            if ((vectorMagnitude _dv) > _dvCap) then {_dv = (vectorNormalized _dv) vectorMultiply _dvCap};
            _boat setVelocity ((velocity _boat) vectorAdd _dv);
            _boat setAngularVelocityModelSpace ((angularVelocityModelSpace _boat) vectorAdd _dw);
        };
    };
} forEach _boats;
