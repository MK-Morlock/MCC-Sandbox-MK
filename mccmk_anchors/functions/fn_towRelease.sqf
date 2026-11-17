/*
    ANC_fnc_towRelease  (server, spawned)
    Tow line key (Shift+F) while towing: the line is let go and hauled back aboard.
*/
params ["_boat", "_player"];
(_boat call ANC_fnc_info) params ["", "_point"];
_point = _boat getVariable ["ANC_towOwnPoint", _point];
private _rope = _boat getVariable ["ANC_rope", objNull];
private _target = _boat getVariable ["ANC_towVeh", objNull];
// Stop the modelled pull on both vehicles.
[_boat, _target, [], [], -1] call ANC_fnc_setTowLink;
private _pad = objNull;
if (!isNull _target) then {
    _pad = createVehicle ["Land_HelipadEmpty_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _pad setPosASL (_target modelToWorldWorld (_boat getVariable ["ANC_towTheirPoint", [0, 0, 0]]));
    _boat setVariable ["ANC_end", _pad];
};
_boat setVariable ["ANC_state", "reeling"];
[_boat, "Releasing the tow - hauling the line in.", _player] call ANC_fnc_tellBoat;
if (!isNull _rope) then {ropeDestroy _rope};
_boat setVariable ["ANC_rope", objNull];
if (!isNull _pad) then {
    // A visible line from the boat to the loose end while it's hauled back.
    private _helper = call ANC_fnc_makeHelper;
    // the hidden fitting (a hidden vehicle) never collides with this boat - it could knock and damage it unseen
    [[_helper, _boat], "disableCollisionWith", 0] call ANC_fnc_remote;
    _helper attachTo [_pad, [0, 0, 0]];
    _boat setVariable ["ANC_helper", _helper];
    private _back = ropeCreate [_boat, _point, _helper, [0, 0, 0], ((_boat modelToWorldWorld _point) distance (getPosASL _pad)) + 1];
    _boat setVariable ["ANC_rope", _back];
    private _haul = ([_boat] call ANC_fnc_speeds) select 1;
    private _timeout = time + 60;
    while {alive _boat && {time < _timeout}} do {
        private _bow = _boat modelToWorldWorld _point;
        private _gap = _bow vectorDiff (getPosASL _pad);
        if (vectorMagnitude _gap < 1) exitWith {};
        _pad setPosASL ((getPosASL _pad) vectorAdd ((vectorNormalized _gap) vectorMultiply (((_haul * 2) * 0.25) min (vectorMagnitude _gap))));
        if (!isNull _back && {(ropeLength _back) > (vectorMagnitude _gap) + 1.5}) then {ropeUnwind [_back, 6, (vectorMagnitude _gap) + 0.5]};
        sleep 0.25;
    };
};
[_boat] call ANC_fnc_cleanup;
[_boat, "Tow line aboard."] call ANC_fnc_tellBoat;
