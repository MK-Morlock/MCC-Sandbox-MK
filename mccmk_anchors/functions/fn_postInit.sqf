/*
    ANC_fnc_postInit  (client)
    Registers the keys (Options > Controls > Configure Addons > Anchors):
      Shift+R     - anchor / moor / weigh anchor / cast off (anyone aboard)
      Shift+F     - tow line: pick a nearby vehicle, then Tow / Towed (anyone aboard)
      Shift+Page Down - haul in (hold to repeat)
      Shift+Page Up    - pay out (hold to repeat)
    Keys can be changed in Options > Controls > Configure Addons > Anchors. If Paddle Mod is loaded WITHOUT the Paddle
    Mod fix, Paddle Mod's own rope keys would also handle boats, so they are switched off here. With the fix, its rope
    bag is offered through these keys instead.
*/
if (call ANC_fnc_builtIn) exitWith {if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log "[Anchors] The mission has Anchors built in - this mod stands aside (the mission's is used)."}};
if (!hasInterface) exitWith {};

// Anyone aboard (driver, crew or passenger) can use these.
private _aboard = {
    private _boat = vehicle player;
    if (_boat isEqualTo player || {!alive _boat}) exitWith {objNull};
    if (!(_boat isKindOf "Ship") && {!(_boat call ANC_fnc_isSubmersible)}) exitWith {objNull};
    _boat
};
// What the player is looking at (up to 40 m): the vehicle to throw a tow line to.
private _aim = {
    private _boat = vehicle player;
    private _from = AGLToASL positionCameraToWorld [0, 0, 0];
    private _to = AGLToASL positionCameraToWorld [0, 0, 40];
    private _hits = lineIntersectsSurfaces [_from, _to, player, _boat, true, 1, "GEOM", "FIRE"];
    if (count _hits == 0) exitWith {[_to, objNull]};
    (_hits select 0) params ["_pos", "", "_obj", "_parent"];
    [_pos, [_parent, _obj] select (isNull _parent)]
};
ANC_aboard = _aboard;
// The haul in / pay out keys only act aboard a boat, or on foot while holding a line (a shore line / rope bag) -
// anywhere else they do nothing at all, leaving the keys free for other uses.
ANC_lineHand = {
    !isNull (call ANC_aboard) || {((missionNamespace getVariable ["ANC_heldLines", []]) findIf {(_x param [1, objNull]) isEqualTo player}) >= 0}
};
ANC_aim = _aim;

[missionNamespace getVariable ["ANC_keyCat", "Anchors"], "ANC_key_anchor_r", ["Anchor / moor", "Drop anchor, moor to a dock, weigh anchor or cast off. Anyone aboard can use it."], {
    private _boat = call ANC_aboard;
    if (isNull _boat) exitWith {};
    // Aim is passed on for options that are thrown where you look (e.g. the Paddle Mod rope bag).
    (call ANC_aim) params ["_aimPos", "_target"];
    [["toggle", _boat, player, 0, _aimPos, _target], "server", 2] call ANC_fnc_remote;
}, {}, [19, [true, false, false]], false] call CBA_fnc_addKeybind;

[missionNamespace getVariable ["ANC_keyCat", "Anchors"], "ANC_key_tow_f", ["Tow line / rope bag", "Throw a tow line (lists the vehicles within 20 m - pick one, then Tow or Towed; press again to release) or throw the rope bag from the bow or the stern (where you look; press again to bring it back). Anyone aboard can use it."], {
    private _boat = call ANC_aboard;
    if (isNull _boat) exitWith {};
    (call ANC_aim) params ["_aimPos", "_target"]; // the rope bag is thrown from this key too - where you look
    [["towKey", _boat, player, 0, _aimPos, _target], "server", 2] call ANC_fnc_remote;
}, {}, [33, [true, false, false]], false] call CBA_fnc_addKeybind;

[missionNamespace getVariable ["ANC_keyCat", "Anchors"], "ANC_key_adjust", ["Adjust attachment points", "Opens an edit screen (own camera, free mouse) to drag where the anchor, tow lines and mooring lines attach to this type of boat, then save them. Anyone aboard."], {
    private _boat = call ANC_aboard;
    if (isNull _boat) exitWith {};
    [_boat] call ANC_fnc_adjustPoints;
}, {}, [19, [true, true, false]], false] call CBA_fnc_addKeybind;

// (MK) the haul in / pay out keys. A TAP is exactly 1 m, however long the key stays down: the game repeats a held key
// from 0.4-0.7 s after the press, so the repeats in the first second of a press are ignored; held for a second or more:
// 5 m for each repeat.
ANC_haulKeyState = [[false, 0, 0], [false, 0, 0]];	// per key: [down, pressed at, last event]
ANC_haulKey = {
    params ["_i", "_amount"];
    if !(call ANC_lineHand) exitWith {};
    private _s = ANC_haulKeyState select _i;
    // (a key whose release was missed, e.g. focus lost: no event for 1.2 s counts as a new press)
    private _repeat = (_s select 0) && {(time - (_s select 2)) < 1.2};
    if (!_repeat) then {_s set [1, time]};
    _s set [0, true];
    _s set [2, time];
    private _heldFor = time - (_s select 1);
    if (_repeat && {_heldFor < 1}) exitWith {};
    // (MK) held for a second: 5 m steps
    [["winch", vehicle player, player, _amount, [[1, 5] select (_heldFor >= 1)]], "server", 2] call ANC_fnc_remote;
};
[missionNamespace getVariable ["ANC_keyCat", "Anchors"], "ANC_key_haul_pgdn", ["Haul in", "Shorten the anchor rope / chain, tow line or mooring lines."], {
    [0, -3] call ANC_haulKey;
}, {(ANC_haulKeyState select 0) set [0, false]}, [209, [true, false, false]], true] call CBA_fnc_addKeybind;

[missionNamespace getVariable ["ANC_keyCat", "Anchors"], "ANC_key_payout_pgup", ["Pay out", "Let out more anchor rope / chain, tow line, or ease the mooring lines."], {
    [1, 3] call ANC_haulKey;
}, {(ANC_haulKeyState select 1) set [0, false]}, [201, [true, false, false]], true] call CBA_fnc_addKeybind;

[missionNamespace getVariable ["ANC_keyCat", "Anchors"], "ANC_key_lines", ["Choose line", "With several lines out: choose which one the haul in / pay out keys work on."], {
    if (isNull (call ANC_aboard)) exitWith {};
    [["lineMenu", vehicle player, player, 0], "server", 2] call ANC_fnc_remote;
}, {}, [199, [false, true, false]], false] call CBA_fnc_addKeybind;

// Getting into a boat that somehow has no Heaving line yet: the server adds one.
player addEventHandler ["GetInMan", {
    params ["", "", "_veh"];
    if (_veh isKindOf "Ship" && {!(_veh getVariable ["ANC_lineAdded", false])}) then {[[_veh], "boatInitLine", 2] call ANC_fnc_remote};
}];
addMissionEventHandler ["EntityRespawned", {
    params ["_new"];
    if (_new isEqualTo player) then {
        _new addEventHandler ["GetInMan", {
            params ["", "", "_veh"];
            if (_veh isKindOf "Ship" && {!(_veh getVariable ["ANC_lineAdded", false])}) then {[[_veh], "boatInitLine", 2] call ANC_fnc_remote};
        }];
    };
}];

// 0-8 Communication menu: Anchor, Weigh anchor, Moor, Cast off, Throw line ashore. Checked once a second.
if (missionNamespace getVariable ["ANC_commMenu", true]) then {
    ANC_commIDs = [];
    [] spawn {
        while {true} do {
            private _boats = [player] call ANC_fnc_commBoats;
            private _shown = count ANC_commIDs > 0;
            if (count _boats > 0 && {!_shown}) then {
                ANC_commIDs = ["ANC_cmAnchor", "ANC_cmWeigh", "ANC_cmMoor", "ANC_cmCastOff", "ANC_cmLineAshore"] apply {[player, _x, nil, nil, ""] call BIS_fnc_addCommMenuItem};
            };
            if (count _boats == 0 && {_shown}) then {
                {[player, _x] call BIS_fnc_removeCommMenuItem} forEach ANC_commIDs;
                ANC_commIDs = [];
            };
            sleep 1;
        };
    };
    addMissionEventHandler ["EntityRespawned", {params ["_new"]; if (_new isEqualTo player) then {ANC_commIDs = []}}];
};

// Once per game version: the full list of script commands this game accepts, to the RPT.
if (missionNamespace getVariable ["ANC_debug", false]) then {[] spawn {sleep 5; call ANC_fnc_dumpCommands}};

// Shore line scroll actions (and again after respawning).
ANC_actBoat = objNull; ANC_actPick = ""; ANC_actPost = false; ANC_actTakeBack = false;
call ANC_fnc_shoreActions;
addMissionEventHandler ["EntityRespawned", {params ["_new"]; if (_new isEqualTo player) then {call ANC_fnc_shoreActions}}];

if (isClass (configFile >> "CfgPatches" >> "PaddleMod") && {!isClass (configFile >> "CfgPatches" >> "PaddleMod_CompatFix")}) then {
    [{
        PADDLE_fnc_ropeOnOff = {};
        PADDLE_fnc_ropeShorten = {};
        PADDLE_fnc_ropeLengthen = {};
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log "[Anchors] Paddle Mod found without the Paddle Mod fix: its rope keys are switched off (Anchors uses the same keys). Load the fix to get the rope bag back."};
    }, [], 1] call CBA_fnc_waitAndExecute;
};

// Board Boat / Boat Cargo / Boat Inventory: the boats within 10 m while the player is aboard one, and the scroll menu
// actions.
// call ANC_fnc_boatNear; - started with the first boat (ANC_fnc_wake)

// "Push boat": on foot within 20 m of the shoreline with a boat in reach.
// call ANC_fnc_pushNear; - started with the first boat (ANC_fnc_wake)

// "Get Bag" / "Bag in Boat": the rope bag by hand within 4 m of a boat.
// call ANC_fnc_bagNear; - started with the first boat (ANC_fnc_wake)
