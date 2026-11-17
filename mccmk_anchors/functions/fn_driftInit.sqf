/*
    ANC_fnc_driftInit  (every computer, postInit)
    Arma 3 has no water current, and its wind never moves boats. This makes boats react to the Arma 3 wind and
    weather: see ANC_fnc_driftTick for the physics (wind pressure on the boat's sides against water resistance on its
    hull - no drift speed is set). Runs on every computer; each one only handles the boats it controls.

    The boat only ever gets the wind's push; anchor ropes and mooring lines (Arma rope physics) do the rest. Anchored
    by the bow, the rope pulls the bow back, so the boat swings until it lies downwind of the anchor, bow into the
    wind - as in real life. On a stern anchor it lies stern to wind.

    Setting "Wind drift": all boats with the engine off (default), anchored / moored boats only, or off.
*/
// The list of boats the wind can act on: built once now, then each new boat is added as it's created. A slow safety
// rebuild (every 60 s) catches any boat that arrived from another computer without the event firing here.
if (call ANC_fnc_builtIn) exitWith {if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log "[Anchors] The mission has Anchors built in - this mod stands aside (the mission's is used)."}};
// a boat whose driver is killed: engine off, so it drifts instead of carrying on (ANC_fnc_deadHelm)
if (isServer) then {call ANC_fnc_deadHelm};
// no helicopter sling loads a boat that is anchored, moored or has a line out
call ANC_fnc_slingGuard;
ANC_driftShips = vehicles select {(_x isKindOf "Ship" || {_x call ANC_fnc_isSubmersible}) && {!(_x isKindOf "sab_Boat_01_base_F")}};
ANC_driftNextScan = time + 60;
addMissionEventHandler ["EntityCreated", {
    params ["_e"];
    if ((_e isKindOf "Ship" || {_e call ANC_fnc_isSubmersible}) && {!(_e isKindOf "sab_Boat_01_base_F")}) then {ANC_driftShips pushBackUnique _e};
}];
// (the drift timer: started with the first boat - ANC_fnc_wake)

// The anchor's pull (ANC_fnc_rodeTick), 20 times a second. Boats with a line out (anchor, mooring, tow, shore): a
// list the server keeps and shares only when a line goes out or comes in (ANC_fnc_lineBoats).
if (isNil "ANC_lineBoats") then {ANC_lineBoats = []};
ANC_rodeLastTick = diag_tickTime;
// Which way Arma's spin turns a vehicle: measured in game (a positive spin about the boat's up axis turns it
// clockwise), so the turning part of the anchor pull is reversed to match.
ANC_angSign = -1;
// Find the grappling hook model once, in the background (server only).
if (isNil "ANC_lineEnds") then {ANC_lineEnds = []};
if (isNil "ANC_heldLines") then {ANC_heldLines = []};
if (isNil "ANC_seaLines") then {ANC_seaLines = []}; // heaving lines thrown into the sea: [[end, bag pad, rope, end bag, bag, end fitting, bag fitting, state]]
if (isServer) then {
    call ANC_fnc_loadPoints; // adjusted attachment points saved in the server's profile
    [] spawn {
        call ANC_fnc_anchorModel;
        call ANC_fnc_lineModel;
        // Log every rope / coil model in the game, so a better Heaving line model can be picked.
        private _ropes = [];
        {
            {if (((toLower _x) find "rope") != -1 || {((toLower _x) find "coil") != -1}) then {_ropes pushBack _x}} forEach (addonFiles [_x, ".p3d"]);
        } forEach ((allAddonsInfo apply {_x select 0}) select {(toLower _x) find "a3\" == 0});
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Rope / coil models in the game (%1): %2", count _ropes, _ropes select [0, 40]]};
        private _r = "Land_Rope_01_F" createVehicleLocal [0, 0, 1000];
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Land_Rope_01_F: retexturable parts %1 (textures %2) | editor preview '%3' (exists %4)",
            selectionNames _r, getObjectTextures _r, getText (configFile >> "CfgVehicles" >> "Land_Rope_01_F" >> "editorPreview"),
            fileExists (getText (configFile >> "CfgVehicles" >> "Land_Rope_01_F" >> "editorPreview"))]};
        deleteVehicle _r;
        private _ropeTex = [];
        {
            {if (((toLower _x) find "rope") != -1) then {_ropeTex pushBack _x}} forEach (addonFiles [_x, ".paa"]);
        } forEach ((allAddonsInfo apply {_x select 0}) select {((toLower _x) find "a3\data_f") == 0});
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Arma rope textures: %1", _ropeTex select [0, 20]]};
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Arma rope class: model '%1' | hidden textures %2",
            getText (configFile >> "CfgVehicles" >> "Rope" >> "model"), getArray (configFile >> "CfgVehicles" >> "Rope" >> "hiddenSelectionsTextures")]};
    };
    // Heaving lines: every boat already in the mission now, then each new boat as it's created (no repeated checks).
    // The CBA hook also does this, but some boats don't run CBA's hooks (e.g. Paddle Mod's Zodiacs without the Paddle
    // Mod fix); and a player getting into a boat asks for one too (ANC_fnc_postInit), in case a boat slipped through
    // both.
    {[_x] call ANC_fnc_boatInitLine} forEach (vehicles select {_x isKindOf "Ship"});
    addMissionEventHandler ["EntityCreated", {
        params ["_e"];
        if (_e isKindOf "Ship") then {[_e] call ANC_fnc_boatInitLine};
    }];
    // AI-crewed boats that are anchored / moored: weigh anchor / cast off when ordered to move.
    ANC_aiPaused = [];
    // (the AI watch: started with the first boat - ANC_fnc_wake)
    // Boats placed in the mission: held / anchored / moored per setting, once the settling time is up.
    [{call ANC_fnc_editorBoats}, [], ((missionNamespace getVariable ["ANC_settleTime", 10]) max 1)] call CBA_fnc_waitAndExecute;
};
// (the rope physics: started with the first boat - ANC_fnc_wake)
ANC_dragList = [];
// (pulling a boat by hand, every frame: started with the first boat - ANC_fnc_wake)
ANC_dragTick = {
    if (ANC_dragList isEqualTo []) exitWith {};
    private _dt = (diag_deltaTime max 0.001) min 0.1;
    private _k = 1 - (exp (-_dt / 0.3));
    private _now = time;
    ANC_dragList = ANC_dragList select {
        _x params ["_b", "_vel", "_w", "_until"];
        // only ever a boat being pulled ashore by people holding its shore line (rope bag line) - never an anchored,
        // moored or towed boat, or any other rope, whatever the drag settings are
        if (isNull _b || {!alive _b} || {!local _b} || {_now > _until} || {!(((_b getVariable ["ANC_shoreData", []]) param [4, ""]) isEqualTo "held")} || {!((_b getVariable ["ANC_mode", ""]) isEqualTo "shore")}) then {if (!isNull _b) then {_b setVariable ["ANC_dragCmd", nil]; _b setVariable ["ANC_dragExtra", nil]; _b setVariable ["ANC_dragWExtra", nil]}; false} else {
            // The speed the forces call for is set IN FULL every frame. The command itself is eased (about half a
            // second) so the boat still starts, turns and stops smoothly.
            (_b getVariable ["ANC_dragCmd", [[0, 0, 0], 0]]) params ["_cv", "_cw"];
            _cv = _cv vectorAdd ((_vel vectorDiff _cv) vectorMultiply _k);
            _cw = _cw + ((_w - _cw) * _k);
            _b setVariable ["ANC_dragCmd", [_cv, _cw]];
            // back to way (the one that brought boats out of the water): the speed set in full every frame, the
            // command eased in. For more speed: the "Drag speed" setting multiplies what the pull calls for
            // (ANC_fnc_rodeTick). MAKING UP WHAT THE GROUND TAKES: a beached hull loses part of the speed it's given
            // to the ground's friction every physics step (logs: 3 m/s given, 0.8-1.5 m/s moved). So the shortfall -
            // the speed asked for minus the speed it really has - is added on, building up over about a third of a
            // second and kept (up to 2 m/s extra) while it lasts. The boat then really moves at the speed asked for,
            // smoothly, without being moved bodily. It fades away when no speed is asked for (the line slack), so the
            // boat eases to a stop.
            private _act = velocity _b;
            _act set [2, 0];
            private _extra = _b getVariable ["ANC_dragExtra", [0, 0, 0]];
            if ((vectorMagnitude _cv) > 0.05) then {
                private _short = _cv vectorDiff _act;
                // along the way it should go only (never pushing it sideways or backwards): up while it's slower than
                // asked, down again if it's faster - between 0 and 2 m/s
                private _dirC = vectorNormalized _cv;
                private _cs = vectorMagnitude _cv;
                private _actAlong = _act vectorDotProduct _dirC;
                // NO LURCHING: the make-up can never be more than the speed asked for (at most doubling it), and it's
                // let go at once the moment the boat is moving as fast as asked, so it can't build up while the ground holds
                // the boat still and release all at once. While the boat is moving it may cancel the game's ground friction
                // fully (up to 4 times the speed asked for, on dry land). While it's held still (or in the water) it stays at no
                // more than the speed asked for - so it can still get a boat going from rest, but can't store up a
                // lurch while it's stuck, or surge when it slides off the sand into the water.
                private _movingNow = (vectorMagnitude _act) > 0.3;
                private _onDry = !(surfaceIsWater (getPosASL _b));
                private _eMax = if (_movingNow && {_onDry}) then {_cs * 3} else {_cs};
                private _eAlong = (((_extra vectorDotProduct _dirC) + ((_short vectorDotProduct _dirC) * _dt * 6)) max 0) min (_eMax min 10);
                if (_actAlong >= _cs) then {_eAlong = _eAlong * 0.5};
                _extra = _dirC vectorMultiply _eAlong;
            } else {
                _extra = _extra vectorMultiply (exp (-_dt / 0.3));
            };
            _b setVariable ["ANC_dragExtra", _extra];
            private _give = _cv vectorAdd _extra;
            // a boat held off the ground - let go in mid-air after being dug up or uncamouflaged, where the game's
            // physics left it hanging - is let fall while it's dragged, so it slides ON the ground, not just above it
            private _vz = ((velocity _b) select 2) min 0;
            if (!(isTouchingGround _b) && {!(surfaceIsWater (getPosASL _b))}) then {_vz = _vz min -1.5};
            // THE TURN, MADE UP THE SAME WAY: the ground holds a beached hull against turning just as it holds it
            // against sliding, so most of the turn asked for never happened (the log: turning asked for all the time,
            // the boat not coming round). The shortfall in its turn rate is added on, building up over about a third
            // of a second (up to 1 rad/s more), and fades when no turn is asked for.
            private _av = angularVelocityModelSpace _b;
            private _wAct = ANC_angSign * (_av select 2);
            private _wExtra = _b getVariable ["ANC_dragWExtra", 0];
            if ((abs _cw) > 0.02) then {
                _wExtra = _wExtra + ((_cw - _wAct) * _dt * 3);
                // only ever helping the way it should turn, never against it
                _wExtra = if (_cw > 0) then {(_wExtra max 0) min 1} else {(_wExtra min 0) max -1};
            } else {
                _wExtra = _wExtra * (exp (-_dt / 0.3));
            };
            _b setVariable ["ANC_dragWExtra", _wExtra];
            if (surfaceIsWater (getPosASL _b)) then {
                _b setAngularVelocityModelSpace [_av select 0, _av select 1, ANC_angSign * (_cw + _wExtra)];
            } else {
                // ON THE GROUND THE TURN IS MADE DIRECTLY: the boat is turned about its middle, this frame's share of
                // the turn asked for (anticlockwise seen from above when positive), its position and tilt left alone.
                // A turn rate handed to the game is simply held by the ground.
                private _a = _cw * _dt;
                private _d0 = vectorDir _b;
                private _u0 = vectorUp _b;
                // turned about the boat's own up direction (it may be lying on a slope)
                private _d1 = (_d0 vectorMultiply (cos (deg _a))) vectorAdd ((_u0 vectorCrossProduct _d0) vectorMultiply (sin (deg _a))) vectorAdd (_u0 vectorMultiply ((_u0 vectorDotProduct _d0) * (1 - (cos (deg _a)))));
                if ((abs _a) > 0.0002) then {_b setVectorDirAndUp [_d1, _u0]};
                _b setAngularVelocityModelSpace [_av select 0, _av select 1, 0];
            };
            // the speed is set AFTER the turn: turning the boat (setVectorDirAndUp) takes away its speed in the game,
            // so with the speed set first the boat would stand still on the ground. And the boat is only turned when
            // there's a turn to make. ONE WAY EVERYWHERE - water,
            // water's edge and beach: the boat is given the speed it should go, and the game carries it up onto the
            // beach on its own, as it does a boat coasting ashore.
            _b setVelocity [_give select 0, _give select 1, _vz];
            true
        };
    };
};

// The timers above run only while there are boats: started by the first boat (at mission start, or when one is created
// - on this computer or another), stopped when the last one is gone (ANC_fnc_driftTick -> ANC_fnc_sleep).
addMissionEventHandler ["EntityCreated", {
    params ["_e"];
    if ((_e isKindOf "Ship") || {_e call ANC_fnc_isSubmersible}) then {call ANC_fnc_wake};
}];
["Ship", "init", {
    params ["_e"];
    if !(_e isKindOf "sab_Boat_01_base_F") then {ANC_driftShips pushBackUnique _e; call ANC_fnc_wake};
}, true, [], true] call CBA_fnc_addClassEventHandler;
if (count ANC_driftShips > 0) then {call ANC_fnc_wake};
