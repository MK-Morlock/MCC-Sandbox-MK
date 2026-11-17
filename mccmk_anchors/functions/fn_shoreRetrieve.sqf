/*
    ANC_fnc_shoreRetrieve  (server, spawned)
*/
params ["_boat", "_player"];
private _d = _boat getVariable ["ANC_shoreData", []];
{_x setVariable ["ANC_holdingBoat", objNull, true]; [["The boat is taking the line back."], "notify", _x] call ANC_fnc_remote} forEach (_boat getVariable ["ANC_shoreHolders", []]);
_boat setVariable ["ANC_shoreHolders", []];
_boat setVariable ["ANC_state", "reeling"];
[_boat, "Bringing the line aboard...", _player] call ANC_fnc_tellBoat;
if (count _d == 5) then {
    _d params ["_pad", "_pt"];
    [_boat, _pad, _pt, 30, 0, "reeling"] call ANC_fnc_setShore;
    _boat setVariable ["ANC_shoreCarrier", objNull, true];
    if (!isNull (attachedTo _pad)) then {detach _pad};
    private _bagBack = _boat getVariable ["ANC_visual", objNull];
    if (!isNull _bagBack) then {_bagBack attachTo [_pad, [0, 0, 0.1]]};
    // Every computer.
    {
        if (!isNull _x) then {[[_x, _boat], "disableCollisionWith", 0] call ANC_fnc_remote};
    } forEach [_boat getVariable ["ANC_visual", objNull], _boat getVariable ["ANC_helper", objNull]];
    private _rope = _boat getVariable ["ANC_rope", objNull];
    private _timeout = time + 60;
    // The end is hauled in at 2 m/s every frame (not in 25 cm jumps four times a second): along the ground and the
    // bottom, never straight through the water to the bow - see ANC_fnc_bagMove.
    private _done = [false];
    [{
        params ["_args", "_handle"];
        _args params ["_boat", "_pad", "_pt", "_done"];
        if (isNull _boat || {!alive _boat} || {isNull _pad} || {_done select 0}) exitWith {
            _done set [0, true];
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        private _dt = (diag_deltaTime max 0.001) min 0.1;
        private _bp = _boat modelToWorldVisualWorld _pt;
        private _now = getPosASL _pad;
        private _to = [(_bp select 0) - (_now select 0), (_bp select 1) - (_now select 1), 0];
        private _flat = vectorMagnitude _to;
        // THE BAG ON THE END OF THE LINE, as it really comes in: - further out, the line's pull is mostly along: the
        // bag is dragged along the bottom (or trails just above it at speed) - its depth from its weight against the
        // line's lift (ANC_fnc_bagMove); - the last 3 m, the line is steep and short: it lifts the bag straight up
        // the line to the bow, out of the water, and over the side - it stays on the end of the line all the way.
        private _dist3 = _bp distance _now;
        if (_dist3 < 0.6) exitWith {
            _done set [0, true];
            [_handle] call CBA_fnc_removePerFrameHandler;
        };
        if (_flat < 3) then {
            private _p3 = _now vectorAdd ((vectorNormalized (_bp vectorDiff _now)) vectorMultiply ((2 * _dt) min _dist3));
            _pad setPosASL _p3;
            [_pad] call ANC_fnc_reattach;
        } else {
            // reeled in at the same speed as this boat's anchor is weighed (ANC_fnc_speeds - the "Weighing anchor
            // speed" setting)
            private _reel = ([_boat] call ANC_fnc_speeds) select 1;
            private _xy = _now vectorAdd ((vectorNormalized _to) vectorMultiply ((_reel * _dt) min _flat));
            [_pad, _xy, _bp, _dt, true] call ANC_fnc_bagMove;
        };
        // Being reeled in, the line is under tension: kept a little shorter than the gap, so it runs straight from
        // the bow to the bag and the bag is always at its end - never above a sagging rope. (The rope runs from a
        // fitting attached to the boat - ANC_fnc_shoreBoatEnd - so its tension can't pull the boat; the bag is what
        // comes in.)
        [_boat] call ANC_fnc_shoreRopeKeep; // never without its rope - tied again at once if it broke
        private _rope = _boat getVariable ["ANC_rope", objNull];
        if (!isNull _rope && {time > (_boat getVariable ["ANC_ropeT", 0]) + 0.05}) then {
            _boat setVariable ["ANC_ropeT", time];
            private _want = ((_bp distance (getPosASL _pad)) - 0.03) max 0.3; // (only just shorter - tight, but not so tight it breaks)
            if (abs ((ropeLength _rope) - _want) > 0.03) then {ropeUnwind [_rope, 10, _want]};
        };
    }, 0, [_boat, _pad, _pt, _done]] call CBA_fnc_addPerFrameHandler;
    while {alive _boat && {time < _timeout} && {!(_done select 0)}} do {
        private _gap = (_boat modelToWorldWorld _pt) vectorDiff (getPosASL _pad);
        if (!isNull _rope && {(ropeLength _rope) > (vectorMagnitude _gap) + 1.5}) then {ropeUnwind [_rope, 6, (vectorMagnitude _gap) + 0.5]};
        sleep 0.25;
    };
    _done set [0, true];
};
[_boat] call ANC_fnc_cleanup;
call ANC_fnc_shoreLists;
[_boat, "Line aboard."] call ANC_fnc_tellBoat;
