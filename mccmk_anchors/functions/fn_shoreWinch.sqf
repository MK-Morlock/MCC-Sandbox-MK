/*
    ANC_fnc_shoreWinch  (server)
    Shift+Page Down / Page Up on a shore line - by someone holding it ashore, or by anyone aboard. Hauls in or pays
    out 0.5 m per press (down to 0.5 m, up to the line's 30 m). Hauling only works as far as the people holding it can
    pull (ANC_fnc_rodeTick): beyond that the line slips through their hands.
*/
params ["_boat", "_player", "_amount"];
private _d = _boat getVariable ["ANC_shoreData", []];
if (count _d != 5) exitWith {};
_d params ["_pad", "_pt", "_len", "_strength", "_state"];
// A guide rope lying loose in the water can be paid out / hauled in from the boat (from Paddle Mod Fix).
private _guide = (_state isEqualTo "loose") && {surfaceIsWater (getPosASL _pad)};
if !(_state in ["held", "tied"] || _guide) exitWith {[["Nobody is holding the line ashore."], "notify", _player] call ANC_fnc_remote};
if (time - (_boat getVariable ["ANC_lastWinch", -10]) < 0.4) exitWith {};
_boat setVariable ["ANC_lastWinch", time];
// Paying out with the key held down: the first three steps are half a metre each, then 2 m a step. Hauling in stays
// at half a metre a step (it moves the boat).
private _step = 0.5;
if (_amount > 0) then {
    private _run = if (time - (_boat getVariable ["ANC_payoutLastT", -10]) < 0.7) then {(_boat getVariable ["ANC_payoutRun", 0]) + 1} else {1};
    _boat setVariable ["ANC_payoutRun", _run];
    _boat setVariable ["ANC_payoutLastT", time];
    if (_run > 3) then {_step = 2};
} else {
    _boat setVariable ["ANC_payoutRun", 0];
    _step = 1; // hauling in: a metre a press (eased in smoothly while the boat's afloat)
};
private _afloat = (surfaceIsWater (getPosASL _boat)) && {!(_boat call ANC_fnc_isAground) || {(0 - (getTerrainHeightASL (getPosASL _boat))) > 0.3}};
// The boat comes to you as you haul - afloat, or held ashore when your pull can drag it over the ground
// (ANC_fnc_groundCanMove). Only when it can't come (too heavy for the pull, too steep or rocky, too big, or a line
// made fast) do you have to move closer.
private _comes = _afloat || {_state isEqualTo "held" && {[_boat, _pad] call ANC_fnc_groundCanMove}};
// hauling in counts from where it's already being hauled to (a press while it's still easing in adds to it)
private _from = if (_amount < 0) then {_boat getVariable ["ANC_lenTarget", _len]} else {_len};
private _new = ((_from + ([-_step, _step] select (_amount > 0))) max 0.5) min 30;
// You can only take in line as far as the boat comes: not shorter than the distance between you and the boat, apart
// from half a metre to pull with.
private _gap = (_boat modelToWorldWorld _pt) distance (getPosASL _pad);
private _msg = format ["Line: %1 m%2", _new toFixed 1, ["", " (shortest)"] select (_new <= 0.55)];
// Afloat, the boat comes to you as you haul - there's no need to move closer. Only when it's aground or on land
// (where it doesn't come) can't you take in more line than reaches it. (afloat, the line can be taken in up to 2.5 m
// inside where the boat is - it keeps coming as you haul - without a message)
if (_amount < 0 && {!_guide} && {_comes} && {_new < _gap - 2.5}) then {_new = ((_gap - 2.5) max 0.5) min _len};
if (_amount < 0 && {!_guide} && {!_comes} && {_new < _gap - 0.5}) then {
    _new = (_gap - 0.5) max 0.5;
    _msg = "The boat can't be pulled any further from here - move closer to take in more line.";
};
// Hauled in, the line doesn't jump half a metre shorter at once - the length eases down to the new one at 0.6 m/s
// (ANC_fnc_shoreWatch), so each press is a smooth pull, never a jerk. Paid out, it's let go at once (slack can't
// jerk).
if (_new < _len && {_comes} && {!_guide}) then {
    _boat setVariable ["ANC_lenTarget", _new];
} else {
    if (_new >= _len) then {_boat setVariable ["ANC_lenTarget", nil]};
    if (abs (_new - _len) > 0.01) then {[_boat, _pad, _pt, _new, _strength, _state] call ANC_fnc_setShore};
};
[[_msg], "notify", _player] call ANC_fnc_remote;
