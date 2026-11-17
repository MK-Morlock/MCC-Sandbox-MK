/*
    ANC_fnc_raftAttach  (server)
    Raft-up / tether made fast: the boat that made the lines fast is attached to the other boat (Arma's attachTo)
    exactly where it is now - beside it (Raft-Up) or at the tether's distance - level, at the same heading relative to
    it. From then on the pair moves as one: whoever drives, whatever the wind, they can't drift, bounce, fight the
    physics or fling each other. (The attached boat rises, falls and rolls with the other one rather than by itself.)
    The lines stay for show, with a sag. Logged to the RPT.
    [boat, other]
*/
params ["_boat", "_o"];
if (isNull _boat || {isNull _o} || {!alive _boat} || {!alive _o}) exitWith {};
private _before = getPosASL _boat;
private _dirW = vectorDir _boat;
_dirW set [2, 0];
private _off = _o worldToModel (ASLToAGL _before);
_boat attachTo [_o, _off];
// level relative to the other boat, same heading relative to it
private _dirM = _o vectorWorldToModel _dirW;
_dirM set [2, 0];
_boat setVectorDirAndUp [vectorNormalized _dirM, [0, 0, 1]];
// correct for where Arma actually put it
private _after = getPosASL _boat;
private _diff = _before vectorDiff _after;
if ((vectorMagnitude _diff) > 0.02) then {
    _off = _off vectorAdd (_o vectorWorldToModel _diff);
    _boat attachTo [_o, _off];
    _boat setVectorDirAndUp [vectorNormalized _dirM, [0, 0, 1]];
};
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Raft-up / tether: %1 attached to %2 at %3 (in its coordinates) | first placed %4 m out, corrected | now %5 m from where it was",
    typeOf _boat, typeOf _o, _off apply {(round (_x * 100)) / 100}, ((round ((vectorMagnitude _diff) * 100)) / 100), ((round (((getPosASL _boat) distance _before) * 100)) / 100)]};
