/*
    ANC_fnc_editorBoats  (server, once, after the settling time)
    What happens to boats already placed when the mission starts (setting "Boats placed in the mission"):

    0 Drift from the start (realistic) - nothing special. 1 Stay put until boarded (mission-friendly) - each boat is
    held
      (no wind drift) until someone gets in. A boat that starts with crew is held until it moves under power, is given
      waypoints or its crew go into combat.
    2 Anchor or moor (default) - friendly boats that are stopped and have no waypoints
      drop anchor, or moor if within 20 m of a dock - AI-crewed ones too if "Anchor / moor AI-crewed boats at start"
      is on (they weigh anchor / cast off by themselves when ordered to move: ANC_fnc_aiWatch). Enemy boats (and
      moving or waypointed ones) are held as in 1.

    Each boat's own Eden attribute "Anchors - at mission start" overrides this: Drift, Stay put, Anchor, or Moor
    (anchors if there's no dock within 20 m).

    "Friendly" = friendly to the players' side. Boats that are aground are never drifted anyway (ANC_fnc_isAground).
*/
if (!isServer) exitWith {};
private _mode = missionNamespace getVariable ["ANC_editorBoats", 2];

// The players' side(s): from playable / switchable units (works on a dedicated server too).
private _sides = [];
{_sides pushBackUnique (side group _x)} forEach (playableUnits + switchableUnits + allPlayers);
if (count _sides == 0) then {_sides = [west]};
private _friendly = {
    params ["_boat"];
    private _crew = (crew _boat) select {alive _x};
    private _side = if (count _crew > 0) then {side group (_crew select 0)} else {
        [east, west, independent, civilian] select (((getNumber (configOf _boat >> "side")) max 0) min 3)
    };
    (_sides findIf {(_x getFriend _side) >= 0.6}) != -1
};
private _hasWaypoints = {
    params ["_boat"];
    private _crew = (crew _boat) select {alive _x};
    (count _crew > 0) && {count (waypoints (group (_crew select 0))) > 1}
};

private _held = [];
private _anchorOrMoor = {
    params ["_boat", ["_preferMoor", true]];
    if ((_boat getVariable ["ANC_mode", ""]) isEqualTo "" && {!([_boat] call ANC_fnc_isAground)}) then {
        if (_preferMoor && {missionNamespace getVariable ["ANC_tieUp", true]} && {count ([_boat] call ANC_fnc_findDock) > 0}) then {
            _boat setVariable ["ANC_mode", "moor"];
            _boat setVariable ["ANC_state", "mooring"];
            [_boat, objNull, [], true] spawn ANC_fnc_moor; // tied up where placed, not hauled in
            true
        } else {
            private _info = _boat call ANC_fnc_info;
            if ((_info select 0) in ["anchor", "kedge"]) then {
                _boat setVariable ["ANC_mode", _info select 0];
                [_boat, objNull] spawn ANC_fnc_anchorDeploy;
                true
            } else {false};
        };
    } else {false};
};
{
    private _boat = _x;
    if (alive _boat && {!(_boat getVariable ["ANC_editorDone", false])}) then {
        _boat setVariable ["ANC_editorDone", true];
        private _stopped = (abs (speed _boat)) < 1 && {!isEngineOn _boat};
        private _crewed = ({alive _x} count (crew _boat)) > 0;
        // The boat's own Eden attribute: 0 = global setting, 1 drift, 2 stay put, 3 anchor, 4 moor.
        private _own = _boat getVariable ["ANC_startMode", 0];
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Mission start: %1 | own attribute %2 | stopped %3 | crewed %4 | friendly %5 | waypoints %6 | aground %7 | dock within 20 m %8",
            typeOf _boat, _own, _stopped, _crewed, [_boat] call _friendly, [_boat] call _hasWaypoints, [_boat] call ANC_fnc_isAground, count ([_boat] call ANC_fnc_findDock) > 0]};
        switch (true) do {
            case (_own == 1): {};
            case (_own == 2): {_held pushBack _boat};
            case (_own in [3, 4]): {if !([_boat, _own == 4] call _anchorOrMoor) then {_held pushBack _boat}};
            case (_mode == 0): {};
            case (_mode == 2 && {_stopped} && {!([_boat] call _hasWaypoints)} && {[_boat] call _friendly}
                && {!_crewed || {missionNamespace getVariable ["ANC_aiCrewedStart", true]}}): {
                if !([_boat] call _anchorOrMoor) then {_held pushBack _boat};
            };
            default {_held pushBack _boat};
        };
    };
} forEach (vehicles select {_x isKindOf "Ship"});

// Hold the rest: no wind drift until released.
{
    _x setVariable ["ANC_held", true, true];
    // Released by someone getting in.
    _x addEventHandler ["GetIn", {
        params ["_boat"];
        if (_boat getVariable ["ANC_held", false]) then {_boat setVariable ["ANC_held", false, true]};
    }];
} forEach _held;

// Boats that started with crew: released by any order - waypoints, a command (currentCommand / expectedDestination),
// moving under power, or combat. Checked every 5 s, only for those few boats, and stops once they're all released.
private _crewedHeld = _held select {({alive _x} count (crew _x)) > 0};
if (count _crewedHeld > 0) then {
    [{
        params ["_args", "_handle"];
        _args params ["_boats"];
        {
            private _boat = _x;
            if (isNull _boat || {!alive _boat} || {!(_boat getVariable ["ANC_held", false])}) then {_boats set [_forEachIndex, objNull]} else {
                private _crew = (crew _boat) select {alive _x};
                private _grp = if (count _crew > 0) then {group (_crew select 0)} else {grpNull};
                private _drv = driver _boat;
                if ((isEngineOn _boat && {(abs (speed _boat)) > 2})
                    || {!isNull _grp && {count (waypoints _grp) > 1}}
                    || {!isNull _drv && {!((currentCommand _drv) in ["", "WAIT", "STOP"])}}
                    || {!isNull _drv && {!(((expectedDestination _drv) select 1) in ["DoNotPlan", "DoNotPlanFormation"])}}
                    || {!isNull _grp && {(behaviour (leader _grp)) isEqualTo "COMBAT"}}) then {
                    _boat setVariable ["ANC_held", false, true];
                    _boats set [_forEachIndex, objNull];
                };
            };
        } forEach _boats;
        _boats = _boats - [objNull];
        _args set [0, _boats];
        if (count _boats == 0) then {[_handle] call CBA_fnc_removePerFrameHandler};
    }, 5, [_crewedHeld]] call CBA_fnc_addPerFrameHandler;
};
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Boats placed in the mission: %1 held until boarded / under way, others anchored or moored (setting %2).", count _held, _mode]};
