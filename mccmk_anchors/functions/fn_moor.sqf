/*
    ANC_fnc_moor  (server, spawned)
    Mooring, as in real life:
      1. Lines are thrown ashore: each flies in an arc from the boat to the dock
         and is made fast there (on top of the dock, just in from the edge).
      2. They're hauled in by hand (about 0.5 m a second; 0.3 on boats 12 m and
         over). Fenders go out as the boat comes within about 2.5 m. Each line stops when the hull beside it is on the
         fenders (0.3 m off the dock face), or 0.5 m off without fenders - measured as the boat comes in - or if the
         boat stops coming closer on it. A dinghy on a single painter is brought in to 2.5 m.
      3. Made fast with a little slack - 0.3 m (under 12 m) or 0.6 m.
    The pull of the lines is modelled (ANC_fnc_rodeTick), like the anchor's, so hauling really moves the boat and it
    rides on its lines; Arma's ropes are the visible lines only, tied from the boat so they're always drawn.
*/
params ["_boat", "_player", ["_preset", []], ["_inPlace", false]];
// _inPlace (mission start): the lines go ashore and are made fast at their current length with a little slack - the
// boat isn't hauled in, so it stays where the mission maker placed it. Lines given by the caller, or found
// automatically.
private _found = if (count _preset > 0) then {_preset} else {[_boat] call ANC_fnc_findDock};
private _say = {if (!isNull _player) then {[[_this], "notify", _player] call ANC_fnc_remote}};
if (count _found == 0) exitWith {
    _boat setVariable ["ANC_mode", ""];
    _boat setVariable ["ANC_state", ""];
    "There's nothing within 20 m to moor to." call _say;
};

[_boat] call ANC_fnc_addBoatHandlers;
_boat setVariable ["ANC_drift", true, true];
_boat setVariable ["ANC_owner", _player];
private _large = ((_boat call ANC_fnc_boatGeometry) select 6) >= 12;
private _slack = 0.5; // made fast with 0.5 m of slack: pulled in to 0.5 m off the dock, it can drift out to about 1 m
private _haulRate = [0.5, 0.3] select _large;
private _shipCleats = _boat getVariable ["ANC_shipCleats", []];
private _anyShip = (_found findIf {private _c = _x select 1; (_shipCleats findIf {(_x distance _c) < 0.5}) >= 0}) >= 0;
[_boat, [["Throwing a line ashore...", "Throwing lines ashore..."] select (count _found > 1), "Lines coming down from the ship..."] select _anyShip, _player] call ANC_fnc_tellBoat;

// 1. Throw each line ashore.
private _made = [];
{
    _x params ["_boatPoint", "_cleatPos", "_gap", "_side", ["_target", -1]];
    private _from = _boat modelToWorldWorld _boatPoint;
    private _pad = createVehicle ["Land_HelipadEmpty_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _pad setPosASL _from;
    private _helper = call ANC_fnc_makeHelper;
    _helper attachTo [_pad, [0, 0, 0]];
    // the hidden fitting the line is tied to (a hidden vehicle) never collides with this boat - it could knock and
    // damage it unseen
    [[_helper, _boat], "disableCollisionWith", 0] call ANC_fnc_remote;
    private _rope = objNull;
    if ((_shipCleats findIf {(_x distance _cleatPos) < 0.5}) >= 0) then {
        // Alongside a ship: its crew throw the line DOWN from the deck edge to the boat, whatever the height; the
        // boat's crew make it fast on their cleat.
        _pad setPosASL _cleatPos;
        private _fly = createVehicle ["Land_HelipadEmpty_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
        _fly setPosASL _cleatPos;
        private _end = call ANC_fnc_makeHelper;
        _end attachTo [_fly, [0, 0, 0]];
        [[_end, _boat], "disableCollisionWith", 0] call ANC_fnc_remote;
        private _toss = ropeCreate [_helper, [0, 0, 0], _end, [0, 0, 0], 1.5];
        private _span = _from distance _cleatPos;
        private _flight = 0.5 + (_span * 0.05);
        private _arc = 0.5 + (_span * 0.05);
        private _t0 = time;
        while {time - _t0 < _flight && {alive _boat}} do {
            private _k = (time - _t0) / _flight;
            private _to = _boat modelToWorldWorld _boatPoint;
            private _p = ((_cleatPos vectorMultiply (1 - _k)) vectorAdd (_to vectorMultiply _k)) vectorAdd [0, 0, _arc * 4 * _k * (1 - _k)];
            _fly setPosASL _p;
            if (!isNull _toss && {((_cleatPos distance _p) + 1) > ropeLength _toss}) then {ropeUnwind [_toss, 30, (_cleatPos distance _p) + 2]};
            sleep 0.05;
        };
        if (!isNull _toss) then {ropeDestroy _toss};
        detach _end;
        deleteVehicle _end;
        deleteVehicle _fly;
        _rope = ropeCreate [_boat, _boatPoint, _helper, [0, 0, 0], ((_boat modelToWorldWorld _boatPoint) distance _cleatPos) + 1];
    } else {
        _rope = ropeCreate [_boat, _boatPoint, _helper, [0, 0, 0], 1.5];
        private _span = _from distance _cleatPos;
        private _flight = 0.6 + (_span * 0.06);
        private _arc = 1 + (_span * 0.2);
        private _t0 = time;
        while {time - _t0 < _flight && {alive _boat}} do {
            private _k = (time - _t0) / _flight;
            private _start = _boat modelToWorldWorld _boatPoint;
            private _p = ((_start vectorMultiply (1 - _k)) vectorAdd (_cleatPos vectorMultiply _k)) vectorAdd [0, 0, _arc * 4 * _k * (1 - _k)];
            _pad setPosASL _p;
            if (!isNull _rope && {((_start distance _p) + 1) > ropeLength _rope}) then {ropeUnwind [_rope, 30, (_start distance _p) + 2]};
            sleep 0.05;
        };
    };
    _pad setPosASL _cleatPos;
    // [rope, helper, pad, boatPoint, gap, made-fast length (set below), side]
    _made pushBack [_rope, _helper, _pad, _boatPoint, _gap, 0, _side, _target];
    sleep 0.4;
} forEach _found;
_boat setVariable ["ANC_lines", _made];
if (!alive _boat) exitWith {[_boat] call ANC_fnc_cleanup};

// 2. Haul in. Each line is hauled until the hull beside it is 0.5 m off the dock face, measured as the boat comes in
// - it stops there rather than pulling the boat into the dock. A line also stops if the boat isn't coming any closer
// on it (something's in the way). A dinghy on a single painter is brought in to 2.5 m.
[_boat, ["Line ashore - hauling in.", "Lines ashore - hauling in."] select (count _made > 1)] call ANC_fnc_tellBoat;
private _painter = (count _made == 1) && {_boat call ANC_fnc_isDinghy};
(_boat call ANC_fnc_boatGeometry) params ["_cx", "", "", "_halfW", "", "", "", "_zWater"];

// Clearance between the hull and whatever is beside it, on the line's side, at the line's position along the boat.
private _clearance = {
    params ["_y", "_side"];
    private _rail = [_boat, _y, _side] call ANC_fnc_hullSidePoint;
    private _best = 99;
    // At several heights - waterline, half freeboard, the rail and up to 1 m above it - so a pier on stilts (deck up
    // high, open beneath) is still found.
    {
        private _z = _x;
        private _from = _boat modelToWorldWorld [(_rail select 0) - (_side * 0.1), _y, _z];
        private _to = _boat modelToWorldWorld [(_rail select 0) + (_side * 4), _y, _z];
        private _hits = (lineIntersectsSurfaces [_from, _to, _boat, objNull, true, 1, "GEOM", "FIRE"]);
        if (count _hits > 0) then {_best = _best min (_from distance ((_hits select 0) select 0))};
    } forEach [_zWater + 0.3, ((_zWater + (_rail select 2)) / 2), _rail select 2, (_rail select 2) + 0.5, (_rail select 2) + 1];
    _best
};

private _lens = [];
private _stopped = [];
private _history = [];
{
    _x params ["_rope", "_helper", "_pad", "_boatPoint"];
    private _d = (_boat modelToWorldWorld _boatPoint) distance (getPosASL _pad);
    _lens pushBack (_d + 0.3);
    _stopped pushBack false;
    _history pushBack [_d];
} forEach _made;
[_boat, _lens] call ANC_fnc_setMoorLines;

private _timeout = time + ([120, 0] select _inPlace);
private _tick = 0;
// No tyre fenders: the hull is hauled in to 0.5 m off the dock face.
private _stopAt = 0.55;
while {alive _boat && {time < _timeout} && {(_stopped findIf {!_x}) != -1}} do {
    _tick = _tick + 1;
    {
        _x params ["_rope", "_helper", "_pad", "_boatPoint", "_gap", "", "_side", ["_target", -1]];
        if !(_stopped select _forEachIndex) then {
            private _d = (_boat modelToWorldWorld _boatPoint) distance (getPosASL _pad);
            private _l = _lens select _forEachIndex;
            private _stop = false;
            if (_painter) then {
                _stop = _l <= 2.5;
            } else {
                private _clear = [_boatPoint select 1, _side] call _clearance;
                // Close enough: 0.5 m off the dock. Lines given a target length: hauled to it - only touching the
                // dock / fenders stops them sooner.
                if (_target > 0) then {
                    if (_l <= _target || {_clear <= (_stopAt - 0.15)}) then {_stop = true};
                } else {
                    if (_clear <= _stopAt) then {_stop = true};
                };
                // Not coming closer on this line for 1.5 s while it's being hauled: stop.
                private _h = _history select _forEachIndex;
                _h pushBack _d;
                if (count _h > 6) then {
                    if (((_h select ((count _h) - 7)) - _d) < 0.05 && {_d > _l}) then {_stop = true};
                };
            };
            if (_stop) then {
                _stopped set [_forEachIndex, true];
                _lens set [_forEachIndex, (_d max 0.5)];
            } else {
                _lens set [_forEachIndex, ((_l - (_haulRate * 0.25)) max 0.5)];
            };
        };
    } forEach _made;
    [_boat, _lens] call ANC_fnc_setMoorLines;
    sleep 0.25;
};
if (!alive _boat) exitWith {[_boat] call ANC_fnc_cleanup};
private _targets = +_lens;

// 3. Make fast with a little slack; remember each line's mooring length.
{
    private _final = (_targets select _forEachIndex) + _slack;
    _x set [5, _final];
    _lens set [_forEachIndex, _final];
} forEach _made;
_boat setVariable ["ANC_lines", _made];
[_boat, _lens] call ANC_fnc_setMoorLines;
_boat setVariable ["ANC_state", "moored"];
// no invisible fender at docks - the boat rides on its lines.
[_boat, ["Moored on a single line.", "Moored with bow and stern lines."] select (count _made > 1)] call ANC_fnc_tellBoat;
[_boat] spawn ANC_fnc_moorWatchdog;
