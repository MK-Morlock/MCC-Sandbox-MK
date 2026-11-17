/*
    ANC_fnc_setShore  (server; or the computer simulating the boat when the line slips)
    Shares a shore line's state with every computer (used by the pull model).
    [boat, pad, boatPoint, length, strength N (0 loose, -1 made fast), state]
    Broadcast only when something actually changes.
*/
params ["_boat", "_pad", "_pt", "_len", "_strength", "_state"];
private _old = _boat getVariable ["ANC_shoreData", []];
private _new = [_pad, _pt, _len, _strength, _state];
if (count _old == 5 && {(_old select 0) isEqualTo _pad} && {abs ((_old select 2) - _len) < 0.05} && {(_old select 3) == _strength} && {(_old select 4) isEqualTo _state}) exitWith {};
_boat setVariable ["ANC_shoreData", _new, true];
if (count _old != 5) then {call ANC_fnc_lineBoats};
