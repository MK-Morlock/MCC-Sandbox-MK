/*
    ANC_fnc_shoreBoatEnd  (104; server)
    An attached fitting passes no force to the boat: the rope is only what you see. What the line really does to the
    boat (people hauling it, a line made fast ashore) is the mod's own pull (ANC_fnc_rodeTick).
    [boat, boat point (model)]  ->  the fitting (kept on the boat as ANC_shoreBoatHelper;
*/
params ["_boat", "_pt"];
private _old = _boat getVariable ["ANC_shoreBoatHelper", objNull];
if (!isNull _old) then {detach _old; deleteVehicle _old};
private _h = call ANC_fnc_makeHelper;
_h attachTo [_boat, _pt];
[[_h, _boat], "disableCollisionWith", 0] call ANC_fnc_remote;
_boat setVariable ["ANC_shoreBoatHelper", _h];
_h
