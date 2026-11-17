/*
    ANC_fnc_cleanup  (server)
    Removes a boat's anchor (rope / chain, anchor model, hidden fittings) or mooring lines, and clears its state. Also
    tells a provider (e.g. the Paddle Mod rope bag) to clean up its own. Safe to call more than once.
*/
params [["_boat", objNull, [objNull]], ["_end", objNull], ["_helper", objNull], ["_rope", objNull], ["_visual", objNull]];

if (!isNull _boat) then {
    private _mode = _boat getVariable ["ANC_mode", ""];
    if (!isNil "ANC_providers" && {_mode in ANC_providers}) then {[_boat] call ((ANC_providers get _mode) select 6)};
    if (isNull _end)    then {_end    = _boat getVariable ["ANC_end", objNull]};
    if (isNull _helper) then {_helper = _boat getVariable ["ANC_helper", objNull]};
    if (isNull _rope)   then {_rope   = _boat getVariable ["ANC_rope", objNull]};
    if (isNull _visual) then {_visual = _boat getVariable ["ANC_visual", objNull]};
    {
        _x params ["_lRope", "_lHelper", "_lPad"];
        if (!isNull _lRope) then {ropeDestroy _lRope};
        if (!isNull _lHelper) then {detach _lHelper; deleteVehicle _lHelper};
        if (!isNull _lPad) then {deleteVehicle _lPad};
    } forEach (_boat getVariable ["ANC_lines", []]);
    // remove any left over.)
    {
        _x params ["_tyre", "_line"];
        if (!isNull _line) then {ropeDestroy _line};
        if (!isNull _tyre) then {deleteVehicle _tyre};
    } forEach (_boat getVariable ["ANC_fenders", []]);
    _boat setVariable ["ANC_fenders", nil];
    if (_boat getVariable ["ANC_moorOn", false]) then {_boat setVariable ["ANC_moorOn", false, true]};
    if (count (_boat getVariable ["ANC_moorData", []]) > 0) then {_boat setVariable ["ANC_moorData", [], true]};
    if (count (_boat getVariable ["ANC_fenderPlanes", []]) > 0) then {_boat setVariable ["ANC_fenderPlanes", [], true]}; // the invisible fender
    // Rafted up / tethered: this boat made the lines fast (its mode is raft / tether) - the link goes from both
    // boats. The other boat's own anchor or mooring coming in doesn't touch it. If this boat is the other end and is
    // destroyed or deleted, the boat that made the lines fast lets go too.
    private _raftL = _boat getVariable ["ANC_raftLink", []];
    if (count _raftL >= 5) then {
        private _o = _raftL select 0;
        if (_mode in ["raft", "tether"]) then {
            // let go of the other boat, carrying on at its speed
            if (!isNull _o && {(attachedTo _boat) isEqualTo _o}) then {
                detach _boat;
                [[_boat, velocity _o], "setVelocity", _boat] call ANC_fnc_remote;
            };
            [_boat, _o] call ANC_fnc_setRaftLink;
        } else {
            if (!alive _boat && {!isNull _o} && {(_o getVariable ["ANC_mode", ""]) in ["raft", "tether"]}) then {[_o] call ANC_fnc_cleanup};
        };
    };
    _boat setVariable ["ANC_raftWith", nil];
    _boat setVariable ["ANC_raftErr", nil];
    // the shore line's fitting on the boat
    private _sbh = _boat getVariable ["ANC_shoreBoatHelper", objNull];
    if (!isNull _sbh) then {detach _sbh; deleteVehicle _sbh};
    _boat setVariable ["ANC_shoreBoatHelper", nil];
    // Shore line: whoever holds it lets go; its pull stops.
    {_x setVariable ["ANC_holdingBoat", objNull, true]} forEach (_boat getVariable ["ANC_shoreHolders", []]);
    _boat setVariable ["ANC_shoreHolders", nil];
    if (!isNull (_boat getVariable ["ANC_shoreCarrier", objNull])) then {_boat setVariable ["ANC_shoreCarrier", objNull, true]};
    if (count (_boat getVariable ["ANC_shoreData", []]) > 0) then {
        _boat setVariable ["ANC_shoreData", [], true];
        [] spawn {sleep 0.1; call ANC_fnc_shoreLists};
    };
    // A heaving line thrown from the shore: the bag on the boat goes too.
    private _flyer = _boat getVariable ["ANC_flyer", objNull];
    private _flyRope = _boat getVariable ["ANC_flyRope", objNull];
    private _flyHelper = _boat getVariable ["ANC_flyHelper", objNull];
    if (!isNull _flyRope) then {ropeDestroy _flyRope};
    if (!isNull _flyHelper) then {detach _flyHelper; deleteVehicle _flyHelper};
    if (!isNull _flyer) then {detach _flyer; deleteVehicle _flyer};
    {_boat setVariable [_x, nil]} forEach ["ANC_flyer", "ANC_flyRope", "ANC_flyHelper"];
    // A Heaving line thrown from the shore and not taken back (the boat reels it in, or the throw is cut short): it
    // goes into the boat's cargo, and is never lost.
    private _thrower = _boat getVariable ["ANC_shoreFromLand", objNull];
    if (!isNull _thrower) then {
        private _stored = false;
        if (alive _boat) then {
            _boat addItemCargoGlobal ["ANC_HeavingLine", 1];
            _stored = "ANC_HeavingLine" in (itemCargo _boat);
        };
        if (!_stored) then {
            private _at = [getPosATL _boat, getPosATL _thrower] select (!alive _boat && {alive _thrower});
            private _holder = createVehicle ["GroundWeaponHolder", _at, [], 0, "CAN_COLLIDE"];
            _holder addItemCargoGlobal ["ANC_HeavingLine", 1];
        };
    };
    _boat setVariable ["ANC_shoreFromLand", nil];
    if (!isNull (_boat getVariable ["ANC_shoreFromLandPub", objNull])) then {_boat setVariable ["ANC_shoreFromLandPub", objNull, true]};
    // Pier fenders put out for this boat: left on the pier for 2 minutes after casting off, then taken away.
    private _left = (_boat getVariable ["ANC_fenderObjs", []]) select {!isNull _x};
    _boat setVariable ["ANC_fenderObjs", nil];
    if (count _left > 0) then {
        {_x setVariable ["ANC_fenderLeft", true]} forEach _left;
        [_left] spawn {
            params ["_left"];
            sleep 120;
            {if (!isNull _x && {_x getVariable ["ANC_fenderLeft", false]}) then {deleteVehicle _x}} forEach _left;
        };
    };
    // Tow line: stop its pull on both vehicles.
    if (count (_boat getVariable ["ANC_towLink", []]) > 0) then {
        [_boat, _boat getVariable ["ANC_towVeh", objNull], [], [], -1] call ANC_fnc_setTowLink;
    };
    {_boat setVariable [_x, nil]} forEach ["ANC_end", "ANC_helper", "ANC_rope", "ANC_visual", "ANC_lines", "ANC_base", "ANC_towVeh", "ANC_pending", "ANC_towOwnPoint", "ANC_towMin", "ANC_towHow", "ANC_towTheirPoint"];
    _boat setVariable ["ANC_state", ""];
    [] spawn {sleep 0.1; call ANC_fnc_lineBoats};
    if (_boat getVariable ["ANC_force", false]) then {_boat setVariable ["ANC_force", false, true]};
    if (!isNull (_boat getVariable ["ANC_endObj", objNull])) then {_boat setVariable ["ANC_endObj", objNull, true]};
    if (_boat getVariable ["ANC_drift", false]) then {_boat setVariable ["ANC_drift", false, true]};
    _boat setVariable ["ANC_mode", ""];
};
if (!isNull _rope)   then {ropeDestroy _rope};
if (!isNull _helper) then {detach _helper; deleteVehicle _helper};
if (!isNull _visual) then {detach _visual; deleteVehicle _visual};
if (!isNull _end)    then {detach _end; deleteVehicle _end};
