/*
    ANC_fnc_towDeploy  (server, spawned)
    Tow line key (Shift+F): anyone aboard picks a vehicle from the list (within 20 m), then chooses which ends the
    line joins (bow or stern, see below) and
      "Tow"   - you tow it: the line runs from your boat to it, and it is
                simulated on your computer if nobody is aboard it;
      "Towed" - it tows you: the line runs from it to your boat, and your boat
                is simulated on its computer if nobody is aboard yours.
    The line's end flies in an arc to the other vehicle (just the rope - no hook object is shown) and the line is made
    fast with 2 m of slack. Shift+Page Down / Page Up shorten / lengthen it; the tow line key's menu releases it.
    Tow lines are extra lines (the line register, ANC_fnc_xlAdd): a boat can tow from its bow and its stern, be
    tethered, and anchor or moor, all at once - one line per attachment point.
*/
params ["_boat", "_player", "_target", ["_aim", []], ["_choice", "tow_bow"]];
// tow_bow / tow_stern: we tow it, from our stern to its bow / stern. towed_bow / towed_stern: it tows us, from its
// stern to our bow / stern.
private _how = ["tow", "towed"] select ((_choice find "towed") == 0);
(_boat call ANC_fnc_info) params ["", "_point", "_max"];
private _say = {[[_this], "notify", _player] call ANC_fnc_remote};
if (_max <= 0) then {_max = 60};

// Attachment points follow the tow: the vehicle doing the towing takes the line at its stern, the vehicle being towed
// at its bow.
private _weTow = !(_how isEqualTo "towed");
_point = [_boat, if (_weTow) then {true} else {_choice isEqualTo "towed_stern"}] call ANC_fnc_towPoint;
private _hookPoint = [_target, if (_weTow) then {_choice isEqualTo "tow_stern"} else {true}] call ANC_fnc_towPoint;
// (MK) in reach: boat to boat, 20 m between the hulls (the line still runs between the two tow points, so it can be longer);
// to anything else, 20 m between the tow points
private _reach = if (_boat isKindOf "Ship" && {_target isKindOf "Ship"}) then {(([_boat, _target] call ANC_fnc_hullGap) select 0) max 0} else {(_boat modelToWorldWorld _point) distance (_target modelToWorldWorld _hookPoint)};
if (isNull _target || {!alive _target} || {_reach > 20.5}) exitWith {
    "That's more than 20 m away - the line won't reach." call _say;
};
// One type of line between any two vehicles: no tow line to a boat you're tethered to.
if (([_boat, _target] call ANC_fnc_xlTypeBetween) isEqualTo "tether") exitWith {"You're tethered to that boat - untether first to tow it." call _say};
// Each attachment point carries one line.
if !([_boat, _point] call ANC_fnc_xlFree) exitWith {"That end of your boat already has a line on it." call _say};
if !([_target, _hookPoint] call ANC_fnc_xlFree) exitWith {"That end of the other vehicle already has a line on it." call _say};
[_boat] call ANC_fnc_addBoatHandlers;

private _start = _boat modelToWorldWorld _point;
private _pad = createVehicle ["Land_HelipadEmpty_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_pad setPosASL _start;
private _helper = call ANC_fnc_makeHelper;
// the hidden fitting (a hidden vehicle) never collides with this boat - it could knock and damage it unseen
[[_helper, _boat], "disableCollisionWith", 0] call ANC_fnc_remote;
_helper attachTo [_pad, [0, 0, 0]];
private _rope = ropeCreate [_boat, _point, _helper, [0, 0, 0], 1.5];
[_boat, "Throwing the tow line...", _player] call ANC_fnc_tellBoat;

// Flight: the line's end flies in an arc to the other vehicle (which may be moving).
private _dist = _start distance (_target modelToWorldWorld _hookPoint);
private _flight = 0.6 + (_dist * 0.06);
private _arc = 1 + (_dist * 0.2);
private _t0 = time;
while {time - _t0 < _flight && {alive _boat} && {alive _target}} do {
    private _k = (time - _t0) / _flight;
    private _from = _boat modelToWorldWorld _point;
    private _p = ((_from vectorMultiply (1 - _k)) vectorAdd ((_target modelToWorldWorld _hookPoint) vectorMultiply _k)) vectorAdd [0, 0, _arc * 4 * _k * (1 - _k)];
    _pad setPosASL _p;
    if (!isNull _rope && {((_from distance _p) + 1) > ropeLength _rope}) then {ropeUnwind [_rope, 30, (_from distance _p) + 2]};
    sleep 0.05;
};
if (!isNull _rope) then {ropeDestroy _rope};
detach _helper;
deleteVehicle _helper;
deleteVehicle _pad;
if (!alive _boat || {!alive _target}) exitWith {};
// in the meantime another line may have been made fast to either point
if (!([_boat, _point] call ANC_fnc_xlFree) || {!([_target, _hookPoint] call ANC_fnc_xlFree)}) exitWith {"Another line was made fast there first." call _say};
if (([_boat, _target] call ANC_fnc_xlTypeBetween) isEqualTo "tether") exitWith {"You've been tethered to that boat - untether first to tow it." call _say};

// Made fast. The visible line runs from the tower to the towed vehicle; its pull is modelled and acts on BOTH
// vehicles, each according to its own mass (ANC_fnc_rodeTick) - hauling in moves a light dinghy much more than a
// heavy combat boat, as in real life.
private _gap = (_target modelToWorldWorld _hookPoint) distance (_boat modelToWorldWorld _point);
private _tower = [_target, _boat] select _weTow;
private _towed = [_boat, _target] select _weTow;
private _minLen = if (_weTow) then {[_boat, _point, _target, _hookPoint] call ANC_fnc_towMinLen} else {[_target, _hookPoint, _boat, _point] call ANC_fnc_towMinLen};
private _len = ((_gap + 2) min (_max max 20)) max _minLen;
_rope = if (_weTow) then {
    ropeCreate [_boat, _point, _target, _hookPoint, _len + 0.5]
} else {
    ropeCreate [_target, _hookPoint, _boat, _point, _len + 0.5]
};
if (isNull _rope) exitWith {"The tow line didn't hold." call _say};
// the line register: a = the tower, b = the towed vehicle
private _id = if (_weTow) then {
    ["tow", _boat, _point, _target, _hookPoint, _len, _rope, _player, _minLen] call ANC_fnc_xlAdd
} else {
    ["tow", _target, _hookPoint, _boat, _point, _len, _rope, _player, _minLen] call ANC_fnc_xlAdd
};
_boat setVariable ["ANC_activeLine", _id, true];

// The vehicle being towed is simulated on the tower's computer when nobody is aboard it, so the tow is smooth.
if ((count crew _towed) == 0) then {_towed setOwner (owner _tower)};
[_boat, format ["Tow line made fast to the %1 (%2 m). %3", getText (configOf _target >> "displayName"), round _len,
    ["It's towing you.", "You're towing it."] select _weTow]] call ANC_fnc_tellBoat;
// (MK) the towed boat's anchor stays down (a tow line is an extra line) - and it holds the boat back
if (((_towed getVariable ["ANC_mode", ""]) in ["anchor", "kedge"]) && {(_towed getVariable ["ANC_state", ""]) in ["lowering", "hanging", "fixed", "kedgePaying", "reeling"]}) then {
    [_boat, "Towed boat is anchored."] call ANC_fnc_tellBoat;
};
