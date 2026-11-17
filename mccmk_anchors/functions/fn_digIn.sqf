/*
    ANC_fnc_digIn  (server)
    Makes a landed anchor look set: it is dragged a short way along the bottom towards the boat as the first strain
    comes on, buries its points in the sea bed and tilts so the shank leans up towards the boat - not just a hook
    lying on the bottom.
    [boat, false] reverses it when the anchor breaks out (weighing anchor).
*/
params ["_boat", ["_set", true]];
private _end = _boat getVariable ["ANC_end", objNull];
private _visual = _boat getVariable ["ANC_visual", objNull];
if (isNull _end) exitWith {};

if (_set) then {
    // Face the boat, drag 0.6 m towards it over a second while sinking in.
    private _pos = getPosASL _end;
    private _boatPos = getPosASL _boat;
    private _dir = [_pos, _boatPos] call BIS_fnc_dirTo;
    _end setDir _dir;
    for "_i" from 1 to 6 do {
        _pos = _pos vectorAdd [sin _dir * 0.1, cos _dir * 0.1, 0];
        _pos set [2, (getTerrainHeightASL _pos) + 0.2 - (_i * 0.06)];
        _end setPosASL _pos;
        sleep 0.15;
    };
    if (!isNull _visual) then {
        // Points down into the bottom, shank tilted ~35 degrees up towards the boat.
        _visual attachTo [_end, [0, 0, -0.15]];
        _visual setVectorDirAndUp [[0, cos 35, -sin 35], [0, sin 35, cos 35]];
    };
} else {
    private _pos = getPosASL _end;
    _pos set [2, (getTerrainHeightASL _pos) + 0.3];
    _end setPosASL _pos;
    if (!isNull _visual) then {
        _visual attachTo [_end, [0, 0, 0]];
        _visual setVectorDirAndUp [[0, 1, 0], [0, 0, 1]];
    };
};
