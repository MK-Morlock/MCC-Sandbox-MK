/*
    ANC_fnc_reattach
    Brings whatever is attached to a moving object up to date at once: the bag on a line's end, and the hidden fitting
    the rope is tied to. Things attached to an object moved by script (an invisible static marker, or the bag itself)
    are only refreshed by the game now and then - left to the game, the rope's end and the bag lag behind and seem to
    come off each other.
    [parent]
*/
params ["_p"];
if (isNull _p) exitWith {};
{
    private _off = _x getVariable "ANC_attOff";
    if (isNil "_off") then {
        _off = _p worldToModel (ASLToAGL (getPosASL _x));
        if ((vectorMagnitude _off) > 2) then {_off = [0, 0, 0]}; // (never a stale offset from a lagging moment)
        _x setVariable ["ANC_attOff", _off];
        _x setVariable ["ANC_attVD", [_p vectorWorldToModel (vectorDir _x), _p vectorWorldToModel (vectorUp _x)]];
    };
    _x attachTo [_p, _off];
    _x setVectorDirAndUp (_x getVariable ["ANC_attVD", [[0, 1, 0], [0, 0, 1]]]);
} forEach (attachedObjects _p);
