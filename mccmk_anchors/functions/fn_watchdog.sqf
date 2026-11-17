/*
    ANC_fnc_watchdog  (server, spawned)
    Runs while a boat has an anchor out. Twice a second it:
      - cleans up if the boat is destroyed or deleted;
      - hanging anchor: keeps it under the anchor point; sets it if it reaches
        the bottom (boat drifted shallower, or more was let out);
      - kedge: pays out cable as the landing craft moves away; brake on when
        it stops or beaches;
      - keeps at least depth + 1 m out, so nothing can hold the bow down;
      - keeps the visible rope matching the modelled rope / chain (the pull
        itself, and holding / dragging, are in ANC_fnc_rodeTick);
      - bow held under: eases 2 m of rope (never drags the anchor);
      - keeps the chain texture on chain;
      - grapnel tow: drops the line if the other vehicle is destroyed or gone.
    Within the slack the boat moves on Arma's own wave and drift physics.
*/
params ["_boat"];
private _id = (_boat getVariable ["ANC_watchId", 0]) + 1;
_boat setVariable ["ANC_watchId", _id];

(_boat call ANC_fnc_info) params ["_mode", "_point", "_max", "_rode"];
private _end = objNull;
private _helper = objNull;
private _rope = objNull;
private _visual = objNull;
private _strikes = 0;
private _stillTime = 0;
private _samples = [];
private _dragWarned = false;
private _tick = 0;

// Messages go to whoever is aboard (and anyone holding its shore line) - not to the player who dropped the anchor if
// they've since left the boat.
private _tell = {params ["_msg"]; [_boat, _msg] call ANC_fnc_tellBoat};
private _dragToward = {
    params ["_bowPos", "_step"];
    private _p = getPosASL _end;
    private _toBoat = _bowPos vectorDiff _p;
    _toBoat set [2, 0];
    if (vectorMagnitude _toBoat < 0.5) exitWith {};
    _p = _p vectorAdd ((vectorNormalized _toBoat) vectorMultiply _step);
    _p set [2, (getTerrainHeightASL _p) + 0.05];
    _end setPosASL _p;
};

while {true} do {
    sleep 0.25;
    _tick = _tick + 1;

    if (isNull _boat) exitWith {[objNull, _end, _helper, _rope, _visual] call ANC_fnc_cleanup};
    if ((_boat getVariable ["ANC_watchId", 0]) != _id) exitWith {};
    if (!alive _boat) exitWith {[_boat] call ANC_fnc_cleanup};
    if !((_boat getVariable ["ANC_mode", ""]) in ["anchor", "kedge", "tow"]) exitWith {};

    private _state = _boat getVariable ["ANC_state", ""];
    _end = _boat getVariable ["ANC_end", objNull];
    _helper = _boat getVariable ["ANC_helper", objNull];
    _rope = _boat getVariable ["ANC_rope", objNull];
    _visual = _boat getVariable ["ANC_visual", objNull];
    if ((isNull _end && {!(_state isEqualTo "towing")}) || {isNull _rope}) exitWith {
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Rope or anchor disappeared (rope %1, anchor %2, state %3).", !isNull _rope, !isNull _end, _state]};
        if !(_state in ["reeling", "throwing"]) then {[_boat] call ANC_fnc_cleanup};
    };
    private _bowPos = _boat modelToWorldWorld _point;

    switch (_state) do {
        case "towing": {
            private _tow = _boat getVariable ["ANC_towVeh", objNull];
            if (isNull _tow || {!alive _tow}) exitWith {
                [_boat] call ANC_fnc_cleanup;
                ["Tow line lost."] call _tell;
            };
            // Enemies have boarded the other vehicle: the line is let go.
            private _mySide = side group ([_boat getVariable ["ANC_owner", objNull], effectiveCommander _boat] select (isNull (_boat getVariable ["ANC_owner", objNull])));
            if (((crew _tow) findIf {alive _x && {(_mySide getFriend (side group _x)) < 0.6}}) != -1) exitWith {
                [_boat] call ANC_fnc_cleanup;
                ["Enemies aboard the other vehicle - tow line let go."] call _tell;
            };
            // The visible line: just longer than the gap when taut; when slack, its full length, sagging between the
            // boats (it isn't reeled in as they come together - the line stays the length it was set to).
            private _link = _boat getVariable ["ANC_towLink", []];
            if (count _link == 4) then {
                _link params ["", "_bPt", "_tPt", "_tL"];
                private _gap = (_boat modelToWorldWorld _bPt) distance (_tow modelToWorldWorld _tPt);
                private _visual = if (_gap >= _tL - 0.5) then {_gap + 0.2} else {_tL max (_gap + 0.2)};
                private _cur = ropeLength _rope;
                if ((_cur < _gap + 0.1) || {_cur > _visual + 0.6}) then {ropeUnwind [_rope, 6, _visual]};
            };
        };
        case "hanging": {
            private _len = ropeLength _rope;
            private _p = _bowPos vectorAdd [0, 0, -(_len - 0.5)];
            private _seabed = getTerrainHeightASL _p;
            if ((_p select 2) <= _seabed + 0.2) then {
                _p set [2, _seabed + 0.2];
                _end setPosASL _p;
                if (_mode isEqualTo "kedge") then {
                    [_boat] call ANC_fnc_digIn;
                    _boat setVariable ["ANC_state", "kedgePaying"];
                    ["Kedge anchor on the bottom - paying out cable."] call _tell;
                } else {
                    [_boat, _boat getVariable ["ANC_owner", objNull]] call ANC_fnc_anchorSet;
                };
            } else {
                _end setPosASL _p;
            };
        };

        case "kedgePaying": {
            // Cable runs out freely as the craft moves away (no pull yet).
            private _dist = _bowPos distance (getPosASL _end);
            private _len = ropeLength _rope;
            if (_dist > _len - 2) then {
                if (_len >= _max - 0.1) then {
                    _boat setVariable ["ANC_state", "fixed"];
                    _boat setVariable ["ANC_base", nil];
                    [_boat, _max, true] call ANC_fnc_setRode;
                    [format ["Kedge cable all out (%1 m) - brake on.", round _max]] call _tell;
                } else {
                    ropeUnwind [_rope, 30, (_dist + 6) min _max]; // keeps up even at full speed
                };
            };
            if (abs (speed _boat) < 1) then {_stillTime = _stillTime + 0.25} else {_stillTime = 0};
            if (_stillTime >= 2 && {(_boat getVariable ["ANC_state", ""]) isEqualTo "kedgePaying"}) then {
                _stillTime = 0;
                _boat setVariable ["ANC_state", "fixed"];
                _boat setVariable ["ANC_base", nil];
                [_boat, (_dist + 0.5) min _max, true] call ANC_fnc_setRode;
                [format ["Kedge brake on: %1 m of cable out. Haul in ({haul}) to pull the craft off the beach.", round _dist]] call _tell;
            };
        };

        case "fixed": {
            private _len = _boat getVariable ["ANC_rodeLen", ropeLength _rope];
            private _endPos = getPosASL _end;
            private _depth = ((_bowPos select 2) - (_endPos select 2)) max 0;
            private _dist = _bowPos distance _endPos;

            // Never less than depth + 1 m out.
            private _min = ((_depth + 1) max 2) min _max;
            if (_len < _min - 0.2) then {_len = _min; [_boat, _len] call ANC_fnc_setRode};

            // The visible rope runs from the anchor point down to the anchor with a natural sag (8 % of the gap + 0.5
            // m), never more than the rope / chain actually out; just longer than the gap once taut. The pull itself
            // is modelled (ANC_fnc_rodeTick), so Arma's rope never needs to carry any load.
            private _visual = if (_dist >= _len) then {_dist + 0.3} else {(_len min ((_dist * 1.08) + 0.5)) max (_dist + 0.3)};
            // Resize only when it's clearly off (each resize rebuilds the rope's segments, which made it jump), and
            // slowly so it doesn't whip: lengthen once it's nearly tight; shorten only if over 1.5 m slack.
            // (sized 20 times a second by ANC_fnc_anchorVisual, so it never falls behind)
            [_boat] call ANC_fnc_anchorVisual;

            // Make sure no part of the visible rope is hidden (a hidden fitting must not take its rope with it), and
            // log its state now and then.
            if (_tick % 20 == 0) then {
                private _segs = ropeSegments _rope;
                {if (isObjectHidden _x) then {_x hideObjectGlobal false}} forEach _segs;
                if (true) then { if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Rope check %1: segments %2 | hidden %3 | visible length %4 | modelled %5 | gap %6",
                    typeOf _boat, count _segs, {isObjectHidden _x} count _segs, (ropeLength _rope) toFixed 1, _len toFixed 1, _dist toFixed 1]}; };
            };

            // Bow held well under the waves for 2 s while taut: ease 2 m (never drags).
            private _taut = _dist > _len;
            if (surfaceIsWater _bowPos && {_len < _max - 0.5}) then {
                private _bowH = (_boat modelToWorldVisual _point) select 2;
                private _base = _boat getVariable ["ANC_base", nil];
                if (isNil "_base") then {
                    _samples pushBack _bowH;
                    if (count _samples >= 4) then {
                        private _sum = 0;
                        {_sum = _sum + _x} forEach _samples;
                        _boat setVariable ["ANC_base", _sum / (count _samples)];
                        _samples = [];
                    };
                } else {
                    if (_taut && {_bowH < _base - 1}) then {_strikes = _strikes + 1} else {_strikes = 0};
                    if (_strikes >= 4) then {
                        _strikes = 0;
                        [_boat, (_len + 2) min _max] call ANC_fnc_setRode;
                    };
                };
            } else {
                _strikes = 0;
            };
        };
    };
};
