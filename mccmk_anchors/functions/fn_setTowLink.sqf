/*
    ANC_fnc_setTowLink  (server)
    Shares a tow line with every computer: each of the two vehicles gets
    [other vehicle, its own point, the other's point, line length], so the
    modelled pull (ANC_fnc_rodeTick) acts on both ends, wherever each one is simulated. [boat, target, boatPoint,
    targetPoint, length] - length < 0 removes the link from both.
*/
params ["_boat", "_target", "_bPt", "_tPt", "_len"];
if (_len < 0) exitWith {
    if (!isNull _boat) then {_boat setVariable ["ANC_towLink", [], true]};
    if (!isNull _target) then {_target setVariable ["ANC_towLink", [], true]};
    call ANC_fnc_lineBoats;
};
private _old = _boat getVariable ["ANC_towLink", []];
if (count _old == 4 && {abs ((_old select 3) - _len) < 0.05} && {(_old select 0) isEqualTo _target}) exitWith {};
_boat setVariable ["ANC_towLink", [_target, _bPt, _tPt, _len], true];
_target setVariable ["ANC_towLink", [_boat, _tPt, _bPt, _len], true];
if (count _old != 4) then {call ANC_fnc_lineBoats};
