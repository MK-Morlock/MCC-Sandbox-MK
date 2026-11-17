/*
    ANC_fnc_anchorVisual  (server)
    Keeps the visible anchor rope / chain matched to the modelled line, 20 times a second, while anchored and while
    the chain is hauled in: straight from the anchor point to the anchor when taut, hanging at the length out (with a
    natural sag) when slack. It lengthens at once whenever it's nearly tight, so it can never pull or snap (it carries
    no load - the pull is modelled, ANC_fnc_rodeTick); it shortens only once it's clearly slack (each resize rebuilds
    the rope's segments). While the anchor is lifted (weighing, stage 2) ANC_fnc_anchorRaise sizes it.
    Started (once per boat) by the watchdog and when weighing begins. [boat]
*/
params [["_boat", objNull, [objNull]]];
if (isNull _boat || {_boat getVariable ["ANC_visPFH", false]}) exitWith {};
_boat setVariable ["ANC_visPFH", true];
(_boat call ANC_fnc_info) params ["", "_point"];
[{
    params ["_args", "_h"];
    _args params ["_boat", "_point"];
    private _st = _boat getVariable ["ANC_state", ""];
    private _rope = _boat getVariable ["ANC_rope", objNull];
    private _end = _boat getVariable ["ANC_end", objNull];
    if (!alive _boat || {isNull _rope} || {isNull _end} || {!(_st in ["fixed", "reeling"])}) exitWith {
        _boat setVariable ["ANC_visPFH", false];
        [_h] call CBA_fnc_removePerFrameHandler;
    };
    if (_st isEqualTo "reeling" && {(_boat getVariable ["ANC_raiseStage", 1]) == 2}) exitWith {};
    private _dist = (_boat modelToWorldVisualWorld _point) distance (getPosASL _end);
    private _len = _boat getVariable ["ANC_rodeLen", ropeLength _rope];
    private _visual = if (_dist >= _len) then {_dist + 0.3} else {(_len min ((_dist * 1.08) + 0.5)) max (_dist + 0.3)};
    private _cur = ropeLength _rope;
    if (_cur < _dist + 0.2) then {ropeUnwind [_rope, 50, _visual]} else {
        if (_cur > _visual + 1.5) then {ropeUnwind [_rope, 8, _visual]};
    };
}, 0.05, [_boat, _point]] call CBA_fnc_addPerFrameHandler;
