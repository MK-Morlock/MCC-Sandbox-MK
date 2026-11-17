/*
    ANC_fnc_aiWatch  (server, every 2 s)
    AI-crewed boats that are anchored, moored or have a shore line out.

    The driver is held still (vanilla disableAI "MOVE") from the moment the boat is anchored or moored, so it can't
    drive off with the anchor down. When the crew are given an order to move, they weigh anchor / cast off - still
    held - and only then is the driver let go to carry out the order.

    "An order" is any of: a new waypoint or moving on to the next one (Eden, Zeus, High Command - including mods that
    issue normal waypoints); a direct order from the command menu (currentCommand); somewhere to go
    (expectedDestination); the crew going into combat.

    Only looks at boats with something out, plus held drivers - next to nothing when no AI boats are anchored.
*/
if (isNil "ANC_aiPaused") then {ANC_aiPaused = []};

// Let drivers go once their boat is free - or a player has taken the wheel.
{
    private _b = _x;
    if (isNull _b || {(_b getVariable ["ANC_mode", ""]) isEqualTo ""} || {isPlayer (driver _b)}) then {[_b, false] call ANC_fnc_aiPause};
} forEach +ANC_aiPaused;

{
    private _boat = _x;
    private _mode = _boat getVariable ["ANC_mode", ""];
    // A kedge being dropped or paying out on the run in to a beach: the craft must keep going, so it isn't held and
    // new waypoints don't weigh it.
    private _running = _mode isEqualTo "kedge" && {(_boat getVariable ["ANC_state", ""]) in ["lowering", "kedgePaying"]};
    if (_running) then {_boat setVariable ["ANC_aiBase", nil]};
    if (alive _boat && {_mode in ["anchor", "kedge", "moor", "shore"]} && {!_running}) then {
        private _crew = (crew _boat) select {alive _x};
        if (count _crew > 0 && {(_crew findIf {isPlayer _x}) == -1}) then {
            // Hold the driver while anything is out.
            if !(_boat in ANC_aiPaused) then {[_boat, true] call ANC_fnc_aiPause};

            if !(_boat getVariable ["ANC_aiWeighing", false]) then {
                private _grp = group (effectiveCommander _boat);
                private _drv = driver _boat;
                private _now = [count (waypoints _grp), currentWaypoint _grp];
                private _base = _boat getVariable ["ANC_aiBase", []];
                if (count _base == 0) exitWith {_boat setVariable ["ANC_aiBase", _now]};
                private _ordered = !(_now isEqualTo _base)
                    || {!isNull _drv && {!((currentCommand _drv) in ["", "WAIT", "STOP"])}}
                    || {!isNull _drv && {!(((expectedDestination _drv) select 1) in ["DoNotPlan", "DoNotPlanFormation"])}}
                    || {(behaviour (leader _grp)) isEqualTo "COMBAT"};
                if (_ordered && {(_boat getVariable ["ANC_state", ""]) in ["fixed", "hanging", "kedgePaying", "moored", "loose", "held", "tied"]}) then {
                    _boat setVariable ["ANC_aiWeighing", true];
                    _boat setVariable ["ANC_aiBase", nil];
                    [_boat, "weigh", objNull] call ANC_fnc_aiOrder;
                };
            };
        };
    };
} forEach (missionNamespace getVariable ["ANC_lineBoats", []]);
