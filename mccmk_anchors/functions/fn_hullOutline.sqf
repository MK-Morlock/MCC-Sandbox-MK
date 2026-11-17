/*
    ANC_fnc_hullOutline  (any computer)
    The boat's hull seen from above, as a rectangle in its own coordinates: [centre x, stern y, bow y, half beam] -
    the beam taken at the real hull side amidships (not the bounding box, which can include guns or aerials sticking
    out). Worked out once and remembered on this computer.
    [boat]
*/
params [["_boat", objNull, [objNull]]];
private _c = _boat getVariable ["ANC_outline", []];
if (count _c == 4) exitWith {_c};
(_boat call ANC_fnc_boatGeometry) params ["_cx", "_sternY", "_bowY", "_halfW"];
private _midY = (_sternY + _bowY) / 2;
private _s = [_boat, _midY, 1] call ANC_fnc_hullSidePoint;
private _hw = if (count _s == 3) then {(abs ((_s select 0) - _cx) - 0.1) max 0.4} else {_halfW};
_hw = _hw min _halfW;
_c = [_cx, _sternY, _bowY, _hw];
_boat setVariable ["ANC_outline", _c];
_c
