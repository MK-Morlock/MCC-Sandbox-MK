/*
    ANC_fnc_aiOrder  (server)
    Carries out an order for a boat, whoever or whatever gave it: the 0-8 Communication menu, an Anchors waypoint, or
    a script (ANC_fnc_doAnchor etc.).
      "anchor"     drop anchor (kedge on landing craft)
      "kedge"      landing craft: drop the kedge at any speed, keep going
      "weigh"      weigh anchor
      "moor"       moor to the nearest dock within 20 m
      "castoff"    cast off (also lets go a shore line or tow line)
      "lineAshore" throw a heaving line to the nearest shore within 20 m
    [boat, order, player who gave it (or objNull)]. A player may only order a
    boat they're aboard, or whose crew is in a group they lead. Weighing for an AI crew follows "AI crews weigh
    anchor" (Realistic / Quick), and the driver waits until it's done (ANC_fnc_aiWatch).
*/
if (!isServer) exitWith {};
params [["_boat", objNull, [objNull]], ["_order", "", [""]], ["_player", objNull, [objNull]]];
if (isNull _boat || {!alive _boat}) exitWith {};
private _say = {if (!isNull _player) then {[[_this], "notify", _player] call ANC_fnc_remote}};

if (!isNull _player && {!(_player in crew _boat)}) then {
    private _crew = (crew _boat) select {alive _x};
    // Their group leader, or their High Command commander.
    if ((_crew findIf {((leader group _x) isEqualTo _player) || {(hcLeader (group _x)) isEqualTo _player}}) == -1) then {_order = "notYours"};
};
if (_order isEqualTo "notYours") exitWith {(format ["You don't command the %1's crew.", getText (configOf _boat >> "displayName")]) call _say};

private _mode = _boat getVariable ["ANC_mode", ""];
private _state = _boat getVariable ["ANC_state", ""];
private _aiCrewed = (({alive _x && {!isPlayer _x}} count (crew _boat)) > 0) && {({isPlayer _x} count (crew _boat)) == 0};
private _quick = _aiCrewed && {(missionNamespace getVariable ["ANC_aiWeigh", 0]) == 1};

switch (_order) do {
    case "anchor": {
        if !(_mode isEqualTo "") exitWith {"That boat already has an anchor or line out." call _say};
        private _info = _boat call ANC_fnc_info;
        if !((_info select 0) in ["anchor", "kedge"]) exitWith {"That boat has no anchor." call _say};
        _boat setVariable ["ANC_mode", _info select 0];
        _boat setVariable ["ANC_aiBase", nil];
        [_boat, _player] spawn ANC_fnc_anchorDeploy;
    };
    case "kedge": {
        if !(_mode isEqualTo "") exitWith {"That boat already has an anchor or line out." call _say};
        if !(((_boat call ANC_fnc_info) select 0) isEqualTo "kedge") exitWith {"That boat isn't a landing craft (no kedge anchor)." call _say};
        _boat setVariable ["ANC_mode", "kedge"];
        _boat setVariable ["ANC_aiBase", nil];
        [_boat, _player, [], true] spawn ANC_fnc_anchorDeploy;
    };
    case "moor": {
        if !(_mode isEqualTo "") exitWith {"That boat already has an anchor or line out." call _say};
        if (count ([_boat] call ANC_fnc_findDock) == 0) exitWith {"No dock within 20 m of that boat." call _say};
        _boat setVariable ["ANC_mode", "moor"];
        _boat setVariable ["ANC_state", "mooring"];
        _boat setVariable ["ANC_aiBase", nil];
        [_boat, _player] spawn ANC_fnc_moor;
    };
    case "lineAshore": {
        if !(_mode isEqualTo "") exitWith {"That boat already has an anchor or line out." call _say};
        _boat setVariable ["ANC_mode", "shore"];
        _boat setVariable ["ANC_state", "flying"];
        [_boat, _player, []] spawn ANC_fnc_shoreThrow;
    };
    case "weigh";
    case "castoff": {
        switch (true) do {
            case (_mode in ["anchor", "kedge"] && {_state in ["fixed", "hanging", "kedgePaying"]}): {
                if (_aiCrewed) then {[_boat, true] call ANC_fnc_aiPause};
                [_boat, _player, _quick] call ANC_fnc_anchorRaise;
            };
            case (_mode isEqualTo "moor" && {_state isEqualTo "moored"}): {
                if (_aiCrewed) then {[_boat, true] call ANC_fnc_aiPause};
                // Letting go the lines takes a few seconds; Quick lets them go at once.
                [_boat, [4, 0] select _quick] spawn {
                    params ["_boat", "_delay"];
                    [_boat, "Casting off..."] call ANC_fnc_tellBoat;
                    sleep _delay;
                    [_boat] call ANC_fnc_cleanup;
                    [_boat, "Cast off."] call ANC_fnc_tellBoat;
                };
            };
            case (_mode isEqualTo "shore" && {_state in ["loose", "held", "tied"]}): {[_boat, _player] spawn ANC_fnc_shoreRetrieve};
            case (_mode isEqualTo "tow" && {_state isEqualTo "towing"}): {[_boat, _player] spawn ANC_fnc_towRelease};
            default {"Nothing to weigh or cast off." call _say};
        };
    };
};
