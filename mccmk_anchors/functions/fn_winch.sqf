/*
    ANC_fnc_winch  (server)
    Shift+Page Down / Shift+Page Up by the driver: 3 m per press at the boat's real hauling / letting-go rate. Takes
    over from automatic weighing if it's running. Never hauls in below depth + 1 m, so it can't pull the bow under.
    Kedge: hauling in pulls a beached landing craft back off the beach.
    Moored: hauls in or eases the mooring lines 0.5 m per press.
    Tow line: shortens or lengthens it (2 m minimum, or hulls kept 2 m apart if a towing point is high -
    ANC_fnc_towMinLen). The pull acts on both vehicles by mass, so hauling in brings the lighter one to the heavier.
*/
params ["_boat", "_player", "_amount", ["_hold", []]];	// (MK) _hold: [step in metres] from the key handler (1, or 5 after a long hold)
private _mode = _boat getVariable ["ANC_mode", ""];
private _state = _boat getVariable ["ANC_state", ""];
(_boat call ANC_fnc_info) params ["", "_point", "_max", "_rode"];
private _say = {[[_this], "notify", _player] call ANC_fnc_remote};

if (time - (_boat getVariable ["ANC_lastWinch", -10]) < 0.4) exitWith {};
_boat setVariable ["ANC_lastWinch", time];
// WHICH LINE: the one chosen with the line menu (Ctrl+Page Down) or the last one thrown; otherwise the anchor /
// mooring; otherwise the only tow line. Tow lines and tethers are extra lines (the line register, ANC_fnc_xlAdd).
private _xl = _boat getVariable ["ANC_xl", []];
private _act = _boat getVariable ["ANC_activeLine", ""];
private _useX = "";
if (_act != "" && {_act != "main"} && {(_xl findIf {(_x select 0) isEqualTo _act}) >= 0}) then {_useX = _act};
private _askMenu = false;
if (_useX == "" && {_mode isEqualTo ""}) then {
    private _towsHere = _xl select {(_x select 1) isEqualTo "tow"};
    if (count _towsHere == 1) then {_useX = (_towsHere select 0) select 0};
    if (count _towsHere > 1) then {_askMenu = true};
    if (count _towsHere == 0 && {count _xl > 0}) then {_useX = (_xl select 0) select 0};
};
if (_askMenu) exitWith {"Several lines are out - choose one with {lines}." call _say};
if (_useX != "") exitWith {
    if (isNil "ANC_xLines" || {!(_useX in ANC_xLines)}) exitWith {};
    private _r = ANC_xLines get _useX;
    if ((_r get "kind") isEqualTo "tether") exitWith {"A tether line is made fast where the boats are - untether and tether again to change its length." call _say};
    private _len = _r get "len";
    private _min = _r get "min";
    // (MK) hauling in a slack line: in to the gap between its ends first, so it goes taut and pulls straight away
    // (shortening only the set length, it would sag until that is shorter than the gap)
    if (_amount < 0) then {
        private _gap0 = ((_r get "a") modelToWorldWorld (_r get "aPt")) distance ((_r get "b") modelToWorldWorld (_r get "bPt"));
        if (_len > (_gap0 + 0.3)) then {
            _len = _gap0 max _min;
            _r set ["len", _len];
            _r set ["goal", _len];
            {[_x] call ANC_fnc_xlSync} forEach [_r get "a", _r get "b"];
        };
    };
    // (MK) the step comes from the key handler: a tap is 1 m however long the key stays down (a tap's key repeat,
    // 0.4-0.7 s after the press, doesn't count as held); held for a second or more: 5 m per repeat.
    // A new press continues from the running target while the line is still moving towards it (the line follows at about
    // 1 m/s, so its length lags behind the target); a line that has stopped starts from its length.
    private _stepM = ((_hold param [0, 1]) max 1) min 5;
    _r set ["lastPress", time];
    private _goal = _r get "goal";
    if (!(_r get "moving")) then {_goal = _len};
    _goal = ((_goal + ([-1, 1] select (_amount > 0)) * _stepM) min (_max max 20)) max _min;
    _r set ["goal", _goal];
    // One mover per line, heading for the latest goal: about 1 m/s hauling in and 2 m/s paying out, up to 3 m/s while
    // more than 10 m from the goal.
    if !(_r get "moving") then {
        _r set ["moving", true];
        [_useX] spawn {
            params ["_id"];
            while {!isNil "ANC_xLines" && {_id in ANC_xLines}} do {
                private _r = ANC_xLines get _id;
                private _l = _r get "len";
                private _diff = (_r get "goal") - _l;
                private _g = ((_r get "a") modelToWorldWorld (_r get "aPt")) distance ((_r get "b") modelToWorldWorld (_r get "bPt"));
                private _closing = ((_r getOrDefault ["gapPrev", _g]) - _g) / 0.25;
                _r set ["gapPrev", _g];
                // (MK) hauled in as far as asked, but the boat still coming: the slack goes on being taken up
                private _coast = (abs _diff < 0.05) && {_r getOrDefault ["hauledIn", false]} && {_closing > 0.3} && {_l > (_g + 0.25)};
                if (abs _diff < 0.05 && {!_coast}) exitWith {_r set ["moving", false]; _r set ["hauledIn", false]};
                if (_coast) then {
                    _l = (_g + 0.2) max (_r get "min");
                    _r set ["goal", _l];
                } else {
                    private _rate = if (abs _diff > 10) then {3} else {[1, 2] select (_diff > 0)};
                    _l = _l + (((_rate * 0.25) min (abs _diff)) * ([-1, 1] select (_diff > 0)));
                    _r set ["hauledIn", _diff < 0];
                    // hauling in: the line follows the boat in - the slack taken up as it comes, so it stays taut
                    if (_diff < 0 && {_l > (_g + 0.2)}) then {_l = (_g + 0.2) max (_r get "min")};
                };
                _r set ["len", _l];
                {[_x] call ANC_fnc_xlSync} forEach [_r get "a", _r get "b"];
                sleep 0.25;
            };
        };
    };
    private _gapNow = ((_r get "a") modelToWorldWorld (_r get "aPt")) distance ((_r get "b") modelToWorldWorld (_r get "bPt"));
    if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Haul %1 (%2): line %3 m -> %4 m, minimum %5 m, gap between its ends %6 m%7.", _useX, [_useX, _boat, false] call ANC_fnc_xlLabel,
        (round (_len * 10)) / 10, (round (_goal * 10)) / 10, (round (_min * 10)) / 10, (round (_gapNow * 10)) / 10, ["", " - slack, it won't pull until shorter than the gap"] select (_goal >= _gapNow)]};
    (format ["%1: %2 m%3", [_useX, _boat, false] call ANC_fnc_xlLabel, round _goal, ["", format [" (%1 m minimum)", round _min]] select (_goal <= _min + 0.1)]) call _say;
};

if (_mode isEqualTo "moor") exitWith {
    if !(_state isEqualTo "moored") exitWith {"Still mooring." call _say};
    private _step = [-0.5, 0.5] select (_amount > 0);
    private _lens = (_boat getVariable ["ANC_moorData", []]) apply {(((_x select 2) + _step) max 0.5)};
    [_boat, _lens] call ANC_fnc_setMoorLines;
    (["Hauling in the mooring lines.", "Easing the mooring lines."] select (_amount > 0)) call _say;
};

if (_mode in ["tether", "raft"]) exitWith {
    (["A tether line is made fast where the boats are - untether and tether again to change its length.", "Rafted boats are held 0.2 - 0.5 m apart - raft off to move apart."] select (_mode isEqualTo "raft")) call _say;
};
if (_mode isEqualTo "tow") exitWith {
    if !(_state isEqualTo "towing") exitWith {"Wait a moment." call _say};
    private _link = _boat getVariable ["ANC_towLink", []];
    if (count _link != 4) exitWith {};
    _link params ["_target", "_bPt", "_tPt", "_len"];
    private _min = _boat getVariable ["ANC_towMin", 2];
    // (MK) the step comes from the key handler (a tap is 1 m; see above). Each press adds to the running target while the line
    // is still moving towards it; a line that has stopped starts from its length.
    private _stepM = ((_hold param [0, 1]) max 1) min 5;
    _boat setVariable ["ANC_towLastPress", time];
    private _goal = _boat getVariable ["ANC_towGoal", _len];
    if (!(_boat getVariable ["ANC_towMoving", false])) then {_goal = _len};
    _goal = ((_goal + ([-1, 1] select (_amount > 0)) * _stepM) min (_max max 20)) max _min;
    _boat setVariable ["ANC_towGoal", _goal];
    // One mover per boat, heading for the latest goal: about 1 m/s hauling in and 2 m/s paying out, up to 3 m/s while
    // more than 10 m from the goal.
    if !(_boat getVariable ["ANC_towMoving", false]) then {
        _boat setVariable ["ANC_towMoving", true];
        [_boat, _target, _bPt, _tPt] spawn {
            params ["_boat", "_target", "_bPt", "_tPt"];
            while {(_boat getVariable ["ANC_state", ""]) isEqualTo "towing"} do {
                private _link = _boat getVariable ["ANC_towLink", []];
                if (count _link != 4) exitWith {};
                private _l = _link select 3;
                private _goal = _boat getVariable ["ANC_towGoal", _l];
                private _diff = _goal - _l;
                if (abs _diff < 0.05) exitWith {};
                private _rate = if (abs _diff > 10) then {3} else {[1, 2] select (_diff > 0)};
                _l = _l + (((_rate * 0.25) min (abs _diff)) * ([-1, 1] select (_diff > 0)));
                [_boat, _target, _bPt, _tPt, _l] call ANC_fnc_setTowLink;
                sleep 0.25;
            };
            _boat setVariable ["ANC_towMoving", false];
        };
    };
    (format ["Tow line: %1 m%2", round _goal, ["", format [" (%1 m minimum)", round _min]] select (_goal <= _min + 0.1)]) call _say;
};

private _end = _boat getVariable ["ANC_end", objNull];
// Take over from automatic weighing / kedge pay-out.
if (_state in ["reeling", "kedgePaying"]) then {
    _state = ["fixed", "hanging"] select (!isNull _end && {((getPosATL _end) select 2) > 1});
    _boat setVariable ["ANC_state", _state];
    _boat setVariable ["ANC_base", nil];
    if (_state isEqualTo "fixed") then {
        private _d = (_boat modelToWorldWorld _point) distance (getPosASL _end);
        [_boat, ((_boat getVariable ["ANC_rodeLen", _d]) max (_d min _max)) min _max, true] call ANC_fnc_setRode;
    };
};
if !(_state in ["fixed", "hanging"]) exitWith {"Wait a moment." call _say};

private _rope = _boat getVariable ["ANC_rope", objNull];
if (isNull _rope) exitWith {};
private _len = if (_state isEqualTo "fixed") then {_boat getVariable ["ANC_rodeLen", ropeLength _rope]} else {ropeLength _rope};
private _min = 2;
if (_state isEqualTo "fixed" && {!isNull _end}) then {
    _min = ((((_boat modelToWorldWorld _point) select 2) - ((getPosASL _end) select 2)) + 1) max 2;
};

([_boat, _mode isEqualTo "kedge"] call ANC_fnc_speeds) params ["_lower", "_haul"];
// 3 m a press; presses add to the running target so quick presses add up.
private _quick = (time - (_boat getVariable ["ANC_winchLastPress", -10])) < 0.7;
_boat setVariable ["ANC_winchLastPress", time];
private _moving = (_state isEqualTo "fixed" && {_boat getVariable ["ANC_winchMoving", false]}) || {_state isEqualTo "hanging" && {!ropeUnwound _rope}};
private _base = if (_quick || {_moving}) then {_boat getVariable ["ANC_winchGoal", _len]} else {_len};
private _new = ((_base + ([-3, 3] select (_amount > 0))) min _max) max _min;
_boat setVariable ["ANC_winchGoal", _new];
private _rodeName = ["Rope", "Chain", "Cable"] select ((["rope", "chain", "wire"] find _rode) max 0);
private _msg = format ["%1 out: %2 m", _rodeName, round _new];
if (_amount < 0 && {_new <= _min + 0.1}) then {
    _msg = _msg + (["", " (can't haul in further without pulling the bow under)"] select (_state isEqualTo "fixed"));
};
if (_amount > 0 && {_new >= _max - 0.1}) then {_msg = _msg + " (all of it)"};
if (abs (_new - _len) > 0.1) then {
    if (_state isEqualTo "fixed") then {
        // Haul / pay out at the real (or multiplied) rate.
        if !(_boat getVariable ["ANC_winchMoving", false]) then {
            _boat setVariable ["ANC_winchMoving", true];
            [_boat, _lower, _haul] spawn {
                params ["_boat", "_lower", "_haul"];
                while {(_boat getVariable ["ANC_state", ""]) isEqualTo "fixed"} do {
                    private _l = _boat getVariable ["ANC_rodeLen", 0];
                    private _diff = (_boat getVariable ["ANC_winchGoal", _l]) - _l;
                    if (abs _diff < 0.05) exitWith {};
                    _l = _l + (((([_haul, _lower] select (_diff > 0)) * 0.25) min (abs _diff)) * ([-1, 1] select (_diff > 0)));
                    [_boat, _l] call ANC_fnc_setRode;
                    sleep 0.25;
                };
                _boat setVariable ["ANC_winchMoving", false];
            };
        };
    } else {
        ropeUnwind [_rope, [_lower, _haul] select (_amount < 0), _new];
    };
};
_msg call _say;
