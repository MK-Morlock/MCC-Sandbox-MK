/*
    ANC_fnc_wpScript  (where the group is simulated; Eden scripted waypoints)
    The Anchors waypoint types. The boat slows down on the approach (20 km/h within 200 m, 10 km/h within 80 m, 5 km/h
    within 30 m), stops at the waypoint, waits until it has all but stopped (under 1 km/h), then:
      Anchor           drops anchor            (done once it's set)
      Moor             moors to a dock there   (done once moored)
      Line ashore      throws a heaving line   (done once it's ashore)
      Weigh anchor /   gets under way: weighs anchor or casts off
      Cast off         (done once free; the boat carries on to its next waypoint)
      Kedge anchor     landing craft: drops the stern anchor as it passes, at any
                       speed, and carries straight on (no slowing down)
    [group, position, target, order]
*/
params ["_grp", "_pos", "_target", "_order"];
private _boat = vehicle (leader _grp);
if (_boat isEqualTo (leader _grp) || {!(_boat isKindOf "Ship")}) exitWith {true};

if (_order in ["anchor", "moor", "lineAshore"]) then {
    // Come in slowly and stop, as a real boat does before anchoring or mooring: speed limited in stages on the
    // approach (vanilla limitSpeed, km/h), then a stop at the waypoint, then wait until the boat has all but stopped.
    private _drv = driver _boat;
    _drv doMove _pos;
    private _timeout = time + 600;
    waitUntil {
        sleep 0.5;
        private _d = _boat distance2D _pos;
        _boat limitSpeed (switch (true) do {
            case (_d < 30): {5};
            case (_d < 80): {10};
            case (_d < 200): {20};
            default {1000};
        });
        !alive _boat || {time > _timeout} || {_d < 15}
    };
    doStop _drv;
    _timeout = time + 45;
    waitUntil {sleep 0.5; !alive _boat || {time > _timeout} || {(abs (speed _boat)) < 1}};
    _boat limitSpeed 1000; // speed limit lifted again
};
if (!alive _boat) exitWith {true};

// Kedge: let go as the craft passes the waypoint - no slowing down - and carry straight on to the next waypoint (the
// beach), paying out cable. The cable doesn't pull the craft back; hauling in (a Weigh anchor waypoint, or an order
// to move off) is what draws it back off the beach.
if (_order isEqualTo "kedge") exitWith {
    (driver _boat) doMove _pos;
    private _timeout = time + 600;
    waitUntil {sleep 0.5; !alive _boat || {time > _timeout} || {(_boat distance2D _pos) < 25}};
    if (alive _boat) then {[_boat, "kedge"] call ANC_fnc_doOrder};
    _boat setVariable ["ANC_aiBase", nil];
    true
};

[_boat, _order] call ANC_fnc_doOrder;
private _want = switch (_order) do {
    case "anchor":     {{(_boat getVariable ["ANC_mode", ""]) in ["anchor", "kedge"] && {(_boat getVariable ["ANC_state", ""]) in ["fixed", "hanging", "kedgePaying"]}}};
    case "moor":       {{(_boat getVariable ["ANC_state", ""]) isEqualTo "moored"}};
    case "lineAshore": {{(_boat getVariable ["ANC_state", ""]) in ["loose", "held", "tied"]}};
    default            {{(_boat getVariable ["ANC_mode", ""]) isEqualTo ""}};
};
private _timeout = time + 300;
waitUntil {sleep 1; !alive _boat || {time > _timeout} || {call _want}};
// This waypoint is done: the next one shouldn't count as "an order to get under way" for the anchor just set.
_boat setVariable ["ANC_aiBase", nil];
true
