/*
    ANC_fnc_raft  (server, spawned)
    RAFT-UP: two boats made fast alongside each other, with the same lines as mooring - from this boat's mooring
    points (bow and stern lines, or its side cleats if it's set to "port and starboard") on the side facing the other
    boat, to the other boat's matching points on its facing side (adjusted points are used). The lines are paired so
    neither crosses: this boat's forward line goes to whichever of the other's points is nearer. They're hauled in
    until the hulls are 0.3 m apart, then made fast; the boats can then ride between 0.2 and 0.5 m apart - never
    closer than 0.2 m, an invisible fender (ANC_fnc_rodeTick), and both boats are held to each other, whichever one
    moves. TETHER (any boat may choose it; a dinghy, which has no cleats to raft with, can only tether): one line from
    this boat's bow or stern, whichever is nearer the other boat, to the other boat's nearest point (bow, stern or
    side cleats - never its anchor point). Within 10 m. Not hauled in: the line is made fast where the boats are.
    [boat, player, other boat, "raft" / "tether"]
*/
params ["_boat", "_player", "_other", "_kind"];
private _say = {if (!isNull _player) then {[[_this], "notify", _player] call ANC_fnc_remote}};
if (isNull _other || {!alive _other}) exitWith {_boat setVariable ["ANC_mode", ""]; _boat setVariable ["ANC_state", ""]; "That boat is gone." call _say};
[_boat] call ANC_fnc_addBoatHandlers;
_boat setVariable ["ANC_drift", true, true];
_boat setVariable ["ANC_raftWith", _other];
// Which side each boat has the other on (1 = starboard, -1 = port).
private _sideMe = [-1, 1] select (((_boat worldToModel (ASLToAGL getPosASL _other)) select 0) >= 0);
private _sideThem = [-1, 1] select (((_other worldToModel (ASLToAGL getPosASL _boat)) select 0) >= 0);
private _pairs = [];
if (_kind isEqualTo "raft") then {
    private _ptsFor = {
        params ["_v", "_side"];
        if ((_v call ANC_fnc_moorLayout) isEqualTo "sides") then {
            [[_v, "moorFwd", _side] call ANC_fnc_pointFor, [_v, "moorAft", _side] call ANC_fnc_pointFor]
        } else {
            [[_v, "moorBow", _side] call ANC_fnc_pointFor, [_v, "moorStern", _side] call ANC_fnc_pointFor]
        };
    };
    ([_boat, _sideMe] call _ptsFor) params ["_myF", "_myA"];
    ([_other, _sideThem] call _ptsFor) params ["_thF", "_thA"];
    private _w = {params ["_v", "_p"]; _v modelToWorldWorld _p};
    // straight (forward to forward) or crossed over (the boats facing opposite ways): whichever is shorter in all
    private _s1 = (([_boat, _myF] call _w) distance ([_other, _thF] call _w)) + (([_boat, _myA] call _w) distance ([_other, _thA] call _w));
    private _s2 = (([_boat, _myF] call _w) distance ([_other, _thA] call _w)) + (([_boat, _myA] call _w) distance ([_other, _thF] call _w));
    _pairs = if (_s1 <= _s2) then {[[_myF, _thF], [_myA, _thA]]} else {[[_myF, _thA], [_myA, _thF]]};
} else {
    private _bowP = [_boat, "towBow"] call ANC_fnc_pointFor;
    private _sternP = [_boat, "towStern"] call ANC_fnc_pointFor;
    private _op = getPosASL _other;
    private _mine = [_sternP, _bowP] select (((_boat modelToWorldWorld _bowP) distance _op) <= ((_boat modelToWorldWorld _sternP) distance _op));
    private _from = _boat modelToWorldWorld _mine;
    // the other boat's nearest point - bow, stern or a cleat - never its anchor point (a line there doesn't look
    // right)
    private _cands = [[_other, "towBow"] call ANC_fnc_pointFor, [_other, "towStern"] call ANC_fnc_pointFor,
        [_other, "moorBow", _sideThem] call ANC_fnc_pointFor, [_other, "moorStern", _sideThem] call ANC_fnc_pointFor,
        [_other, "moorFwd", _sideThem] call ANC_fnc_pointFor, [_other, "moorAft", _sideThem] call ANC_fnc_pointFor] select {count _x == 3};
    private _theirs = _cands select 0;
    {if (((_other modelToWorldWorld _x) distance _from) < ((_other modelToWorldWorld _theirs) distance _from)) then {_theirs = _x}} forEach _cands;
    _pairs = [[_mine, _theirs]];
};

// RAFT-UP: the lines are passed across (Arma's own ropes, boat to boat, always kept slack - they're only seen, they
// never pull), then this boat is brought alongside the other: PARALLEL to it (bow by bow and stern by stern, or bow
// by stern if it lay the other way round), its middle level with the other's middle (a smaller boat sits in the
// middle of a bigger one), and exactly 1 m between the hulls along their whole length. It then stays there - an
// invisible 1 m fender, no drift (ANC_fnc_raftHold) - while the ropes hang with a little sag. Only this boat is
// moved; the other boat goes about as it likes and this one keeps station. TETHER: one line, an Arma rope, thrown
// across and made fast where the boats are, with half a metre of slack - the rope holds the boats within its length;
// nothing else.
[_boat, ["Passing a line across...", "Passing lines across..."] select (count _pairs > 1), _player] call ANC_fnc_tellBoat;
private _made = [];
{
    _x params ["_myPt", "_thPt"];
    private _d = (_boat modelToWorldWorld _myPt) distance (_other modelToWorldWorld _thPt);
    private _rope = ropeCreate [_boat, _myPt, _other, _thPt, (_d * 1.03) + 1];
    // [rope, (no fitting), (no pad), own point, other's point]
    _made pushBack [_rope, objNull, objNull, _myPt, _thPt];
    sleep 0.4;
} forEach _pairs;
_boat setVariable ["ANC_lines", _made];
if (!alive _boat || {!alive _other}) exitWith {[_boat] call ANC_fnc_cleanup};
private _ls = _pairs apply {[_x select 0, _x select 1, 0]};

if (_kind isEqualTo "raft") then {
    // Where this boat goes, in the other boat's own coordinates: beside it on the side it's on now, 1 m off, centred,
    // parallel.
    (_other call ANC_fnc_hullOutline) params ["_ocx", "_osY", "_obY", "_ohw"];
    (_boat call ANC_fnc_hullOutline) params ["_mcx", "_msY", "_mbY", "_mhw"];
    private _rel = (((getDir _boat) - (getDir _other)) + 540) mod 360 - 180;
    private _flip = (abs _rel) > 90; // lying the other way round: bow by stern
    private _side = [-1, 1] select (((_other worldToModel (ASLToAGL getPosASL _boat)) select 0) >= 0);
    private _sgn = [1, -1] select _flip;
    private _px = _ocx + (_side * (_ohw + 1 + _mhw)) - (_sgn * _mcx);
    private _py = ((_osY + _obY) / 2) - (_sgn * ((_msY + _mbY) / 2));
    private _pose = ["align", _px, _py, [0, 180] select _flip];
    [_boat, _other, _kind, _ls, 1, 1, false, _pose] call ANC_fnc_setRaftLink;
    [_boat, "Lines across - bringing her alongside.", _player] call ANC_fnc_tellBoat;
    if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Raft-up: %1 alongside %2 | %3 side, %4 | place in its coordinates x %5 y %6 | hulls: other half-beam %7, this half-beam %8",
        typeOf _boat, typeOf _other, ["port", "starboard"] select (_side > 0), ["same way round", "the other way round"] select _flip,
        (round (_px * 100)) / 100, (round (_py * 100)) / 100, (round (_ohw * 100)) / 100, (round (_mhw * 100)) / 100]};
    // wait until she's there (or a minute and a half)
    private _t0 = time;
    waitUntil {
        sleep 0.5;
        !alive _boat || {!alive _other} || {time - _t0 > 90} || {(_boat getVariable ["ANC_raftErr", [99, 99, 99]]) params ["_ep", "_ey", ["_eg", 99]]; _ep < 0.15 && {_ey < 2} && {_eg >= 0.95} && {_eg <= 1.25}}
    };
    if (!alive _boat || {!alive _other}) exitWith {[_boat] call ANC_fnc_cleanup};
    _boat setVariable ["ANC_state", "rafted"];
    [_boat, "Rafted up.", _player] call ANC_fnc_tellBoat;
} else {
    // no hauling in: the line goes across and is made fast where the boats are, with a little slack
    [_boat, _other, _kind, _ls, 0.5, -1, false, "ropes"] call ANC_fnc_setRaftLink;
    {
        _x params ["_rope", "", "", "_myPt", "_thPt"];
        if (!isNull _rope) then {ropeUnwind [_rope, 3, ((_boat modelToWorldWorld _myPt) distance (_other modelToWorldWorld _thPt)) + 0.5]};
    } forEach _made;
    _boat setVariable ["ANC_state", "rafted"];
    [_boat, "Tethered.", _player] call ANC_fnc_tellBoat;
};
[_boat] spawn ANC_fnc_raftWatchdog;
