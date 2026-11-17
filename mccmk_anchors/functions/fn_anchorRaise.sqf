/*
    ANC_fnc_anchorRaise  (server)
    Weighs anchor automatically (anchor key), as in real life:
      1. All the rope / chain is hauled in; its modelled pull draws the boat up
         towards the anchor, which stays dug in until only the depth's worth is out and the boat is nearly over it. If the boat is driven away instead,
         the pull exceeds what the anchor holds and it drags along the bottom - it never comes up while the rope is at
         an angle.
      2. Once the boat is nearly over it, the anchor breaks out and is lifted
         straight up under the anchor point. It stays under water until it reaches the boat.
    Hauling speed: the boat's real rate x the "Weighing anchor speed" setting. Shift+Page Down / Page Up still work at
    any time and take over by hand.

    Runs as a per-frame handler (4 times a second), not a background script, so it can't be held up when the game is
    busy with other scripts .
*/
params ["_boat", "_player", ["_quick", false]];
(_boat call ANC_fnc_info) params ["_mode", "_point", "_max", "_rode", "_kind"];
private _end = _boat getVariable ["ANC_end", objNull];
private _rope = _boat getVariable ["ANC_rope", objNull];
private _haul = ([_boat, _mode isEqualTo "kedge"] call ANC_fnc_speeds) select 1;
_boat setVariable ["ANC_state", "reeling"];
if (isNull _end || {isNull _rope}) exitWith {[_boat] call ANC_fnc_cleanup; [_boat, "Anchor up.", _player] call ANC_fnc_tellBoat};

private _l = _boat getVariable ["ANC_rodeLen", ropeLength _rope];
// Quick (AI crews, setting "AI crews weigh anchor"): done in about 6 seconds.
if (_quick) then {_haul = _haul max (_l / 6)};
private _secs = _l / _haul;
[_boat, format ["Weighing anchor - about %1 to haul in.",
    [format ["%1 seconds", round _secs], format ["%1 minutes", round (_secs / 60)]] select (_secs > 90)
], _player] call ANC_fnc_tellBoat;
[_boat, _l, true] call ANC_fnc_setRode;
_boat setVariable ["ANC_raiseStage", 1];
[_boat] call ANC_fnc_anchorVisual;
private _a0 = getPosASL _end;
private _b0 = _boat modelToWorldWorld _point;
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Weighing anchor: %1 m out, depth %2 m, %3 m from the bow to the anchor (%4 m across), hauling at %5 m/s.",
    round _l, round ((_b0 select 2) - (_a0 select 2)), round (_b0 distance _a0), round (_b0 distance2D _a0), (round (_haul * 10)) / 10]};

// [boat, player, point, haul rate, current length, stage]
[{
    params ["_args", "_handle"];
    _args params ["_boat", "_player", "_point", "_haul", "_l", "_stage"];
    private _end = _boat getVariable ["ANC_end", objNull];
    private _rope = _boat getVariable ["ANC_rope", objNull];
    // Stopped: boat gone, taken over by hand, or cleaned up.
    if (!alive _boat || {isNull _end} || {!((_boat getVariable ["ANC_state", ""]) isEqualTo "reeling")}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    private _bow = _boat modelToWorldWorld _point;
    private _a = getPosASL _end;
    private _flat = [(_bow select 0) - (_a select 0), (_bow select 1) - (_a select 1), 0];

    if (_stage == 1) exitWith {
        // 1. Haul in ALL the chain lying on the bottom: its pull draws the boat up over the anchor (which stays dug in).
        //    The anchor only breaks out once just over the depth's worth is left out AND the boat is over it - as in
        //    real life, the chain comes in first and the anchor comes up last.
        private _depth = ((_bow select 2) - (_a select 2)) max 1;
        if (_l <= (_depth + 1.05) && {vectorMagnitude _flat <= ((_depth * 0.3) + 1.5)}) exitWith {
            [_boat, false] call ANC_fnc_digIn;
            [_boat, _l, false] call ANC_fnc_setRode; // broken out: no more pull
            _args set [5, 2];
            _boat setVariable ["ANC_raiseStage", 2];
            if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Anchor broken out: %1 m of chain out, %2 m across to the anchor, depth %3 m - lifting.", round _l, round (vectorMagnitude _flat), round _depth]};
        };
        _l = (_l - (_haul * 0.25)) max (_depth + 1);
        _args set [4, _l];
        [_boat, _l] call ANC_fnc_setRode;
        // (the visible rope follows the line: ANC_fnc_anchorVisual)
    };

    // 2. Lift straight up under the anchor point.
    if ((_bow distance _a) < 1) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log "[Anchors] Anchor up."};
        [_boat] call ANC_fnc_cleanup;
        [_boat, "Anchor up."] call ANC_fnc_tellBoat;
    };
    private _step = _haul * 0.25;
    _a = _a vectorAdd ((vectorNormalized _flat) vectorMultiply ((vectorMagnitude _flat) min (_step * 2)));
    private _top = _bow select 2;
    if (vectorMagnitude _flat > 1.5) then {_top = _top min -0.5};
    _a set [2, (((_a select 2) + _step) min _top) max ((getTerrainHeightASL _a) + 0.05)];
    _end setPosASL _a;
    if (!isNull _rope) then {ropeUnwind [_rope, 20, ((_bow distance _a) + 0.5) max 0.5]};
}, 0.25, [_boat, _player, _point, _haul, _l, 1]] call CBA_fnc_addPerFrameHandler;
