/*
    ANC_fnc_shoreWatch  (server, spawned)
    Runs while a boat has a shore line out:
      - cleans up if the boat is destroyed or deleted;
      - lets go for anyone holding it who dies, disconnects or gets into a
        vehicle; a helper who moves more than 3 m from whoever has the end lets go;
      - a loose end: if the boat drifts beyond the line's 30 m it drags the end;
      - keeps the visible rope from the boat to the end with a natural sag.
*/
params ["_boat"];
private _pad = objNull;

// A loose end: dragged along if the boat goes beyond 30 m of line, moved every frame - smooth, along the ground and
// out into the sea (see ANC_fnc_bagMove for how it lies, sinks and trails). The boat's line point is smoothed a
// little (a tenth of a second) so the boat's pitching and the network's update steps don't show up as jerks in the
// bag. It stays until the line is brought back.
if !(_boat getVariable ["ANC_dragOn", false]) then {
    _boat setVariable ["ANC_dragOn", true];
    [{
        params ["_args", "_handle"];
        _args params ["_boat"];
        if (isNull _boat || {!alive _boat} || {!((_boat getVariable ["ANC_mode", ""]) isEqualTo "shore")}) exitWith {
            if (!isNull _boat) then {_boat setVariable ["ANC_dragOn", false]; _boat setVariable ["ANC_dragBp", nil]};
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        if !((_boat getVariable ["ANC_state", ""]) isEqualTo "loose") exitWith {_boat setVariable ["ANC_dragBp", nil]};
        private _d = _boat getVariable ["ANC_shoreData", []];
        if (count _d != 5) exitWith {};
        _d params ["_pad", "_pt", ["_len", 30]];
        if (isNull _pad) exitWith {};
        // Beyond that the boat drags the end.
        private _lineLen = ((_len max 1) min 30);
        private _dt = (diag_deltaTime max 0.001) min 0.1;
        private _bp = _boat modelToWorldVisualWorld _pt;
        private _bs = _boat getVariable ["ANC_dragBp", _bp];
        _bs = _bs vectorAdd ((_bp vectorDiff _bs) vectorMultiply (1 - exp (-_dt / 0.1)));
        _boat setVariable ["ANC_dragBp", _bs];
        private _now = getPosASL _pad;
        // The line is 30 m long: the bag can lie that far from the boat's line point, measured along the line (so a
        // bag lying deeper than the bow is a little nearer, horizontally).
        private _dz = ((_bs select 2) - (_now select 2)) min (_lineLen * 0.85); // (as deep as the line allows - a guide rope)
        private _reach = sqrt (((_lineLen ^ 2) - (_dz ^ 2)) max 1);
        private _flat = _bs distance2D _now;
        private _xy = +_now;
        private _moving = false;
        if (_flat > _reach) then {
            // SMOOTH: the bag doesn't jump to where the line would put it each frame - it follows it with a fifth of
            // a second's lag (its weight and the ground's grip), so the boat's surges and bobbing are taken up by the
            // line and the bag slides along steadily, without jerks.
            private _tgt = _now vectorAdd ((vectorNormalized [(_bs select 0) - (_now select 0), (_bs select 1) - (_now select 1), 0]) vectorMultiply (_flat - _reach));
            _xy = _now vectorAdd ((_tgt vectorDiff _now) vectorMultiply (1 - exp (-_dt / 0.2)));
            _moving = true;
            _boat setVariable ["ANC_dragT", time];
        };
        [_pad, _xy, _bs, _dt, _moving] call ANC_fnc_bagMove;
        // Deeper than the line reaches (a guide rope in deep water - from Paddle Mod Fix): it hangs at the end of the
        // line.
        private _pp = getPosASL _pad;
        if ((_pp distance _bs) > _lineLen + 0.05) then {
            private _hang = (_bs select 2) - sqrt (((_lineLen ^ 2) - ((_pp distance2D _bs) ^ 2)) max 0);
            if (_hang > (_pp select 2)) then {_pad setPosASL [_pp select 0, _pp select 1, _hang]; [_pad] call ANC_fnc_reattach};
        };
        [_boat] call ANC_fnc_shoreRopeKeep; // never without its rope
        // Dragged, the line is kept just the length of the gap: straight from the boat to the bag, not sagging below
        // it - but never shorter, so it doesn't pull the boat: the bag is light; it's the bag that moves.
        if (_moving) then {
            private _rope = _boat getVariable ["ANC_rope", objNull];
            if (!isNull _rope && {time > (_boat getVariable ["ANC_ropeT", 0]) + 0.1}) then {
                _boat setVariable ["ANC_ropeT", time];
                private _want = ((_bs distance (getPosASL _pad)) - 0.03) max 0.5;   /*
 (only just shorter)
*/ // (taut while dragging - straight to the bag; the rope runs from a fitting attached to the boat, so it cannot pull the boat)
                if (abs ((ropeLength _rope) - _want) > 0.05) then {ropeUnwind [_rope, 10, _want]};
            };
        };
    }, 0, [_boat]] call CBA_fnc_addPerFrameHandler;
};
while {true} do {
    sleep 0.25;
    if (isNull _boat) exitWith {
        if (!isNull _pad) then {{detach _x; deleteVehicle _x} forEach (attachedObjects _pad); deleteVehicle _pad};
        call ANC_fnc_shoreLists;
    };
    if (!alive _boat) exitWith {[_boat] call ANC_fnc_cleanup};
    if !((_boat getVariable ["ANC_mode", ""]) isEqualTo "shore") exitWith {};
    private _state = _boat getVariable ["ANC_state", ""];
    private _d = _boat getVariable ["ANC_shoreData", []];
    if (count _d == 5) then {
        _d params ["_p", "_pt", "_len"];
        _pad = _p;
        private _rope = _boat getVariable ["ANC_rope", objNull];
        private _gap = (_boat modelToWorldWorld _pt) distance (getPosASL _pad);

        private _tgt = _boat getVariable "ANC_lenTarget";
        if (!isNil "_tgt") then {
            if (_tgt >= _len - 0.01 || {!(_state in ["held", "tied"])}) then {_boat setVariable ["ANC_lenTarget", nil]} else {
                private _newL = (_len - 0.15) max _tgt;
                [_boat, _pad, _pt, _newL, _d select 3, _state] call ANC_fnc_setShore;
                _len = _newL;
            };
        };
        // People holding the line.
        if (_state isEqualTo "held") then {
            private _h = _boat getVariable ["ANC_shoreHolders", []];
            private _carrier = _boat getVariable ["ANC_shoreCarrier", objNull];
            {
                if (isNull _x || {!alive _x} || {vehicle _x != _x} || {_x != _carrier && {(_x distance _carrier) > 3}}) then {[_x, _boat] call ANC_fnc_shoreDrop};
            } forEach +_h;
            if ((count (_boat getVariable ["ANC_shoreHolders", []])) == 0 && {(_boat getVariable ["ANC_state", ""]) isEqualTo "held"}) then {[objNull, _boat] call ANC_fnc_shoreDrop};
        };

        // (A loose end dragged along beyond 30 m of line is moved every frame - see the handler started at the top of
        // this function.)

        // Visible rope. A real Arma rope only looks straight when it's under tension (a touch shorter than the gap) -
        // even at exactly the gap length it sags. Slack = line length - gap. The rope's length follows it smoothly: -
        // being pulled (the holder is held at the end of the line, still leaning on it, or the gap has reached the
        // line's length): 10 cm shorter than the gap, so it's taut and stays taut for as long as they pull; - they
        // let off, but haven't moved: only a few cm of slack (4 cm), not a drop; - they walk back towards the boat:
        // the slack grows and the rope eases out to the line's full length over the first 60 cm of slack - never
        // shorter than the gap, so it can't pull on the boat - and with 60 cm or more it's the full paid-out length,
        // so line paid out near the boat piles up on the ground. The rope's end stays on the pad in the holder's
        // hand. The boat's own pull is the mod's (ANC_fnc_rodeTick).
        if (!isNull _rope) then {
            private _cur = ropeLength _rope;
            switch (_state) do {
                case "held": {
                    private _slack = _len - _gap;
                    // The rope is sized from where its two ends really are (the engine reports them), not from where
                    // the script thinks they are - the end tied to the hidden fitting need not be exactly on the pad.
                    // Used only if it's close.
                    private _ends = ropeEndPosition _rope;
                    private _real = if (count _ends == 2) then {((_ends select 0) distance (_ends select 1))} else {_gap};
                    private _g = if (abs (_real - _gap) < 2) then {_real} else {_gap};
                    private _pulling = (serverTime - (_boat getVariable ["ANC_pullT", -10])) < 0.8 || {_slack <= 0};
                    private _want = if (_pulling) then {
                        (_g - 0.1) max 0.5
                    } else {
                        if (_slack >= 0.6) then {_len max (_g + 0.5)} else {_g + 0.04 + (((_slack - 0.1) max 0) * 1.12)}
                    };
                    // Resized whenever it's off by more than a few cm - in either direction. Going slack, the rope is
                    // let out GRADUALLY - at about a walking step's pace (1.2 m/s) - so as you step towards the boat
                    // (or it comes towards you) the line sags a little more with each step until it lies on the
                    // ground: no snap from taut to lying flat. (A little extra length makes a big sag over a long
                    // line - real, but only as fast as the slack really comes.) Taken up (pulled tight), it tightens
                    // at once, as a line does when it's yanked.
                    if (abs (_cur - _want) > ([0.2, 0.06] select (_slack < 0.6))) then {
                        ropeUnwind [_rope, ([20, 1.2] select (_want > _cur)), _want];
                    };
                    // For the log, every 2 s while the line is (nearly) tight: what the rope is doing.
                    if ((_pulling || _slack < 0.6) && {time > (_boat getVariable ["ANC_ropeLogT", 0]) + 2}) then {
                        _boat setVariable ["ANC_ropeLogT", time];
                        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Held line: gap %1 m | rope ends %2 m | line %3 m | slack %4 | rope %5 m -> %6 m | pulled %7 (flag age %8 s) | aground %9 | on water %10 | boat speed %11 m/s", _gap toFixed 2, _real toFixed 2, _len toFixed 2, _slack toFixed 2, _cur toFixed 2, _want toFixed 2, _pulling, (serverTime - (_boat getVariable ["ANC_pullT", -10])) toFixed 1, _boat call ANC_fnc_isAground, surfaceIsWater (getPosASL _boat), ((speed _boat) / 3.6) toFixed 2]};
                    };
                };
                case "tied": {
                    private _want = if (_gap >= _len) then {_gap + 0.3} else {(_gap * 1.05) + 0.5};
                    if ((_cur < _gap + 0.2) || {_cur > _want + 1.5}) then {ropeUnwind [_rope, 10, _want]};
                };
                case "loose": {
                    // While the boat is dragging the end, the drag handler keeps it taut.
                    if (time > (_boat getVariable ["ANC_dragT", -10]) + 0.5) then {
                        private _want = ((_len min 30) max 1) max ((_gap * 1.02) + 0.3);
                        if (abs (_cur - _want) > 0.3) then {ropeUnwind [_rope, ([20, 1.2] select (_want > _cur)), _want]}; // (slackens gradually - it sags, it doesn't drop)
                    };
                };
                default {
                    private _want = (_gap * 1.05) + 0.5;
                    if ((_cur < _gap + 0.1) || {_cur > _want + 1.5}) then {ropeUnwind [_rope, 10, _want]};
                };
            };
        };
    };
};
