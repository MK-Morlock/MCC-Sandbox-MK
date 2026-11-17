/*
    ANC_fnc_setRaftLink  (server)
    Shares a raft-up or tether between two boats with every computer: each boat gets
      [other boat, "raft" / "tether", [[own point, other's point, length], ...], least gap, greatest gap (-1 = none), held position]
    While the lines are being hauled in, the held position is empty and the lines pull (ANC_fnc_rodeTick). Once made
    fast, the held position is where this boat is relative to the other right now - [x, y across / along the other
    boat, its heading relative to the other's] - and both boats are kept there by ANC_fnc_raftHold, every frame: held
    together side by side (or at the tether's length) as if the lines were rigid, while each still rises, falls,
    pitches and rolls on the waves by itself. The lines are then only seen.
    [boat, other, kind, lines (as seen from boat), least gap, greatest gap, hold] - no lines: removes it from both.
*/
params ["_boat", "_other", ["_kind", ""], ["_lines", []], ["_gMin", 0.5], ["_gMax", -1], ["_hold", false], ["_marker", "", ["", []]]];
if (count _lines == 0) exitWith {
    if (!isNull _boat) then {_boat setVariable ["ANC_raftLink", [], true]};
    if (!isNull _other) then {_other setVariable ["ANC_raftLink", [], true]};
    call ANC_fnc_lineBoats;
};
private _poseOf = {
    params ["_a", "_b"]; // where _a is, seen from _b
    private _l = _b worldToModel (ASLToAGL getPosASL _a);
    private _rel = (getDir _a) - (getDir _b);
    [_l select 0, _l select 1, _rel]
};
private _old = _boat getVariable ["ANC_raftLink", []];
// or a place beside the other boat (["align", x, y, heading]) that this boat is brought to and kept at
// (ANC_fnc_raftHold); the other boat's copy is marked "partner" - it isn't moved.
private _pose = switch (true) do {
    case (_marker isEqualType []): {_marker};
    case (_marker != ""): {[_marker]};
    case (_hold): {["attached"]};
    default {[]};
};
private _oPose = [_pose, ["partner"]] select (_marker isEqualType []);
_boat setVariable ["ANC_raftLink", [_other, _kind, _lines, _gMin, _gMax, _pose], true];
_other setVariable ["ANC_raftLink", [_boat, _kind, _lines apply {[_x select 1, _x select 0, _x select 2]}, _gMin, _gMax, _oPose], true];
if (_hold && {_marker isEqualTo ""}) then {[_boat, _other] call ANC_fnc_raftAttach};
if (count _old < 5) then {call ANC_fnc_lineBoats};
