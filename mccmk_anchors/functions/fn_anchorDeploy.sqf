/*
    ANC_fnc_anchorDeploy  (server, spawned)
    "anchor" - lowered from the anchor point (never thrown) at a real-life rate
               for the boat's size - dinghies too. Rope / chain is paid out until the anchor is on the bottom; then it
               digs in and the scope from the settings is let out (ANC_fnc_anchorSet). Deeper than everything the boat
               carries: it hangs and doesn't hold.
    "kedge" - landing craft: dropped off the stern, usually on the run in to a
               beach. Cable pays out as the craft moves away; the brake goes on when it stops or beaches. Hauling in
               then pulls it off the beach.
    The anchor is moved by script (straight down, stays where it lands).
*/
params ["_boat", "_player", ["_aim", []], ["_anySpeed", false]];
(_boat call ANC_fnc_info) params ["_mode", "_point", "_max", "_rode", "_kind"];
private _isKedge = _mode isEqualTo "kedge";
private _fail = {
    params ["_msg"];
    _boat setVariable ["ANC_mode", ""];
    _boat setVariable ["ANC_state", ""];
    if (!isNull _player) then {[[_msg], "notify", _player] call ANC_fnc_remote};
};
if (_mode isEqualTo "") exitWith {"This boat has no anchor." call _fail};
if (!_isKedge && {abs (speed _boat) > 10}) exitWith {"Slow down to drop the anchor." call _fail};
// The Kedge waypoint drops it at any speed (landing craft let go on the run in).
if (_isKedge && {!_anySpeed} && {abs (speed _boat) > 20}) exitWith {"Too fast to drop the kedge anchor." call _fail};
if !(surfaceIsWater (_boat modelToWorldWorld _point)) exitWith {"The anchor point isn't over water." call _fail};

[_boat] call ANC_fnc_addBoatHandlers;
_boat setVariable ["ANC_state", "lowering"];
_boat setVariable ["ANC_drift", true, true]; // wind drift on (ANC_fnc_driftInit)
_boat setVariable ["ANC_owner", _player];

private _start = (_boat modelToWorldWorld _point) vectorAdd [0, 0, -0.5];
private _end = createVehicle ["Land_HelipadEmpty_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_end setPosASL _start;
_end setDir getDir _boat;
private _visual = createSimpleObject [call ANC_fnc_anchorModel, _start];
_visual attachTo [_end, [0, 0, 0]];
private _helper = call ANC_fnc_makeHelper;
// the hidden fitting (a hidden vehicle) never collides with this boat - it could knock and damage it unseen
[[_helper, _boat], "disableCollisionWith", 0] call ANC_fnc_remote;
_helper attachTo [_end, [0, 0, 0]];
// The rope runs FROM the boat (always drawn) to the hidden fitting at the anchor. Tied the other way round, Arma
// sometimes skipped drawing it.
private _rope = ropeCreate [_boat, _point, _helper, [0, 0, 0], 1.5];

_boat setVariable ["ANC_end", _end];
_boat setVariable ["ANC_visual", _visual];
_boat setVariable ["ANC_helper", _helper];
_boat setVariable ["ANC_rope", _rope];
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Rope created: %1 | boat %2 | from point %3 (%4 m above the water) | segments %5 | anchor model %6",
    !isNull _rope, typeOf _boat, _point, ((_boat modelToWorldVisual _point) select 2) toFixed 2,
    count (ropeSegments _rope), call ANC_fnc_anchorModel]};
if (isNull _rope) exitWith {[_boat] call ANC_fnc_cleanup};

private _rodeName = ["rope", "chain", "cable"] select ((["rope", "chain", "wire"] find _rode) max 0);
[_boat, [format ["Lowering anchor on %1 m of %2...", _max, _rodeName], "Dropping kedge anchor off the stern..."] select _isKedge, _player] call ANC_fnc_tellBoat;

private _speed = ([_boat, _isKedge] call ANC_fnc_speeds) select 0;
private _pos = _start;
private _onBottom = false;

_boat setVariable ["ANC_stopLower", nil];
while {alive _boat && {!isNull _end}} do {
    // (MK) Shift+R again while it's going down: it stops here and is weighed from where it's got to
    if (!isNil {_boat getVariable "ANC_stopLower"}) exitWith {};
    private _seabed = getTerrainHeightASL _pos;
    private _next = (_pos select 2) - (_speed * 0.25);
    private _bow = _boat modelToWorldWorld _point;
    if (_next <= _seabed + 0.2) exitWith {
        _pos set [2, _seabed + 0.2];
        _end setPosASL _pos;
        _onBottom = true;
    };
    if (((_bow select 2) - _next) >= _max - 0.5) exitWith {};
    _pos set [2, _next];
    // A lowered anchor hangs under the anchor point; a dropped kedge falls where let go.
    if (!_isKedge) then {_pos set [0, _bow select 0]; _pos set [1, _bow select 1]};
    _end setPosASL _pos;
    // Resize the visible rope only in 1 m steps (each resize rebuilds its segments).
    private _want = ((_bow distance _pos) + 1) min _max;
    if ((_want - (ropeLength _rope)) > 0) then {ropeUnwind [_rope, 6, (_want + 1) min _max]};
    sleep 0.25;
};
if (!alive _boat || {isNull _end}) exitWith {[_boat] call ANC_fnc_cleanup};
if (!isNil {_boat getVariable "ANC_stopLower"}) exitWith {
    private _by = _boat getVariable ["ANC_stopLower", _player];
    _boat setVariable ["ANC_stopLower", nil];
    _boat setVariable ["ANC_state", "hanging"];
    if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] %1: anchor stopped on its way down (%2 m out) - weighing it", typeOf _boat, (ropeLength (_boat getVariable ["ANC_rope", objNull])) toFixed 1]};
    [_boat, _by] call ANC_fnc_anchorRaise;
};

if (!_onBottom) exitWith {
    _boat setVariable ["ANC_state", "hanging"];
    [_boat, format ["Too deep - the anchor can't reach the bottom on %1 m of %2. It's hanging and won't hold.", _max, _rodeName], _player] call ANC_fnc_tellBoat;
    [_boat] spawn ANC_fnc_watchdog;
};

if (_isKedge) exitWith {
    [_boat] call ANC_fnc_digIn;
    _boat setVariable ["ANC_state", "kedgePaying"];
    [_boat, "Kedge anchor down - paying out cable. Stop or beach the craft and the brake goes on.", _player] call ANC_fnc_tellBoat;
    [_boat] spawn ANC_fnc_watchdog;
};

[_boat, _player] call ANC_fnc_anchorSet;
[_boat] spawn ANC_fnc_watchdog;
