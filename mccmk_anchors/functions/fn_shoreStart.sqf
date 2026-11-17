/*
    ANC_fnc_shoreStart  (server)
    Creates the pieces of a shore line: the end (an invisible marker carrying the visible line-end model and the
    hidden fitting the rope is tied to) and the visible rope from the boat. Returns the end.
    [boat, boatPoint, startPosASL]
*/
params ["_boat", "_pt", "_startPos", ["_noRope", false]];
private _pad = createVehicle ["Land_HelipadEmpty_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_pad setPosASL _startPos;
// The bag at the end.
call ANC_fnc_lineModel;
private _visual = if !(ANC_lineModelClass isEqualTo "") then {
    private _v = createVehicle [ANC_lineModelClass, [0, 0, 1000], [], 0, "CAN_COLLIDE"];
    _v allowDamage false; // simulation stays on: an attached object needs it to move with its parent
    _v
} else {
    createSimpleObject [ANC_lineModelPath, _startPos]
};
_visual attachTo [_pad, [0, 0, 0.1]];
private _helper = call ANC_fnc_makeHelper;
// the hidden fitting (a hidden vehicle) never collides with this boat - it could knock and damage it unseen
[[_helper, _boat], "disableCollisionWith", 0] call ANC_fnc_remote;
_helper attachTo [_pad, [0, 0, 0]];
// (A line thrown from the shore has no rope to the boat until the bag lands - ANC_fnc_shoreThrowLand.)
private _rope = if (_noRope) then {objNull} else {ropeCreate [[_boat, _pt] call ANC_fnc_shoreBoatEnd, [0, 0, 0], _helper, [0, 0, 0], ((_boat modelToWorldWorld _pt) distance _startPos) + 1.5]   /*
 (from a fitting on the boat - no pull on the boat)
*/};
{_boat setVariable [_x select 0, _x select 1]} forEach [["ANC_end", _pad], ["ANC_visual", _visual], ["ANC_helper", _helper], ["ANC_rope", _rope], ["ANC_shorePoint", _pt]];
_boat setVariable ["ANC_mode", "shore"];
_boat setVariable ["ANC_shoreHolders", []];
[_boat] call ANC_fnc_addBoatHandlers;
_pad
