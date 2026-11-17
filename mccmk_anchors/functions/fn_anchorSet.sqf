/*
    ANC_fnc_anchorSet  (server)
    The anchor is on the bottom: it digs in, then the amount from "Anchor rope / chain length" is let out (scope =
    length / depth).
      Rope: 3, 5 or 7 x depth. Chain: 3, 3 or 5 x depth.
    If the boat doesn't carry enough, everything is let out and the player is warned it may drag (it will under load
    below 3:1 - ANC_fnc_watchdog).
*/
params ["_boat", ["_player", objNull]];
(_boat call ANC_fnc_info) params ["_mode", "_point", "_max", "_rode", "_kind"];
private _end = _boat getVariable ["ANC_end", objNull];
private _rope = _boat getVariable ["ANC_rope", objNull];
if (isNull _end || {isNull _rope}) exitWith {};

[_boat] call ANC_fnc_digIn;

private _bow = _boat modelToWorldWorld _point;
private _depth = ((_bow select 2) - ((getPosASL _end) select 2)) max 0.5;
private _dist = _bow distance (getPosASL _end);
private _index = ((missionNamespace getVariable ["ANC_anchorScope", 2]) min 3) max 0;
private _ratio = ([[0, 3, 5, 7], [0, 3, 3, 5]] select (_rode isEqualTo "chain")) select _index;
private _want = if (_ratio == 0) then {_dist + 4} else {(_depth * _ratio) max (_dist + 2)};
private _len = (_want min _max) max 2;
// The pull is modelled (ANC_fnc_rodeTick); the visible rope follows it (ANC_fnc_watchdog).
[_boat, _len, true] call ANC_fnc_setRode;
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Anchor set: rope exists %1 | rope length %2 | modelled length %3 | depth %4 | anchor %5 m from the bow | segments %6",
    !isNull _rope, (ropeLength _rope) toFixed 1, _len toFixed 1, _depth toFixed 1, _dist toFixed 1, count (ropeSegments _rope)]};

_boat setVariable ["ANC_base", nil];
_boat setVariable ["ANC_state", "fixed"];

if (true) then {
    private _rodeName = ["rope", "chain", "cable"] select ((["rope", "chain", "wire"] find _rode) max 0);
    private _msg = format ["%1 set: %2 m of %3 out in %4 m of water.", "Anchor", round _len, _rodeName, round _depth];
    if (_ratio > 0 && {_len / _depth < 3}) then {_msg = _msg + " Not enough for a good hold - it may drag."};
    [_boat, _msg, _player] call ANC_fnc_tellBoat;
};
