/*
    ANC_fnc_shoreThrowLand  (server, spawned)
    Scroll action "Throw heaving line to the boat you're looking at", for someone on foot carrying a Heaving line,
    within 20 m of a boat.

    Two bags, as a real heaving line has two ends:
      - one flies (smooth, every frame) from the thrower to the boat's nearer end
        and stays there, made fast to the boat;
      - the other is the end left at the thrower's feet, on the line.
    The Heaving line leaves the thrower's inventory. Then, at the end on the ground, the scroll menu offers:
      Pick up the line          - to pull / drag the boat
      Take back the heaving line - unties it from the boat and it goes back
                                   into your inventory
*/
params ["_player", "_boat"];
private _say = {[[_this], "notify", _player] call ANC_fnc_remote};
if (isNull _boat || {!alive _boat} || {!alive _player} || {vehicle _player != _player}) exitWith {};
if !("ANC_HeavingLine" in (items _player)) exitWith {"You don't have a Heaving line." call _say};
if !((_boat getVariable ["ANC_mode", ""]) isEqualTo "") exitWith {"That boat already has a line or anchor out." call _say};
private _bow = [_boat, "towBow"] call ANC_fnc_pointFor;
private _stern = [_boat, "towStern"] call ANC_fnc_pointFor;
private _hand = (getPosASL _player) vectorAdd [0, 0, 1.4];
private _pt = [_stern, _bow] select ((_hand distance (_boat modelToWorldWorld _bow)) <= (_hand distance (_boat modelToWorldWorld _stern)));
if ((_hand distance (_boat modelToWorldWorld _pt)) > 20.5) exitWith {"The boat's more than 20 m away." call _say};

_player removeItem "ANC_HeavingLine";
_boat setVariable ["ANC_mode", "shore"];
_boat setVariable ["ANC_state", "flying"];
_boat setVariable ["ANC_shoreFromLand", _player]; // whose Heaving line it is
_boat setVariable ["ANC_shoreFromLandPub", _player, true];

// The end at the thrower's feet (with its bag). The rope to the boat doesn't exist yet: while the bag is in the air
// the line runs from the feet to the bag itself, and only when the bag lands on the boat is the line tied to the bow.
private _feet = getPosASL _player;
_feet set [2, ((getTerrainHeightASL _feet) max 0) + 0.05];
private _pad = [_boat, _pt, _feet, true] call ANC_fnc_shoreStart;
private _endHelper = _boat getVariable ["ANC_helper", objNull];

// The thrown bag, and a hidden fitting riding on it for the line to be tied to.
call ANC_fnc_lineModel;
private _flyer = if !(ANC_lineModelClass isEqualTo "") then {createVehicle [ANC_lineModelClass, [0, 0, 1000], [], 0, "CAN_COLLIDE"]} else {createSimpleObject [ANC_lineModelPath, _hand]};
_flyer allowDamage false;
_flyer setPosASL _hand;
_boat setVariable ["ANC_flyer", _flyer];
private _flyHelper = call ANC_fnc_makeHelper;
// the hidden fitting (a hidden vehicle) never collides with this boat - it could knock and damage it unseen
[[_flyHelper, _boat], "disableCollisionWith", 0] call ANC_fnc_remote;
_flyHelper attachTo [_flyer, [0, 0, 0]];
private _flyRope = ropeCreate [_endHelper, [0, 0, 0], _flyHelper, [0, 0, 0], (_feet distance _hand) + 2];
_boat setVariable ["ANC_flyHelper", _flyHelper];
_boat setVariable ["ANC_flyRope", _flyRope];
"Throwing the line..." call _say;
private _done = [false];
private _to = _boat modelToWorldWorld _pt;
private _span = _hand distance _to;
[{
    params ["_args", "_handle"];
    _args params ["_boat", "_flyer", "_hand", "_pt", "_t0", "_flight", "_arc", "_done", "_pad", "_flyRope"];
    private _k = ((time - _t0) / _flight) min 1;
    private _target = _boat modelToWorldWorld _pt;
    if (_k >= 1 || {!alive _boat}) exitWith {
        _done set [0, true];
        [_handle] call CBA_fnc_removePerFrameHandler;
    };
    private _p = ((_hand vectorMultiply (1 - _k)) vectorAdd (_target vectorMultiply _k)) vectorAdd [0, 0, _arc * 4 * _k * (1 - _k)];
    _flyer setPosASL _p;
    [_flyer] call ANC_fnc_reattach; // the rope's fitting stays on the flying bag
    // Slack all through the flight, so the line trails behind the bag and can't snatch it.
    private _need = ((getPosASL _pad) distance _p) + 2;
    if (!isNull _flyRope && {_need > ropeLength _flyRope}) then {ropeUnwind [_flyRope, 40, _need + 1]};
}, 0, [_boat, _flyer, _hand, _pt, time, 0.6 + (_span * 0.05), 1 + (_span * 0.15), _done, _pad, _flyRope]] call CBA_fnc_addPerFrameHandler;
waitUntil {sleep 0.05; _done select 0};
if (!alive _boat) exitWith {[_boat] call ANC_fnc_cleanup};

if (!isNull _flyRope) then {ropeDestroy _flyRope};
if (!isNull _flyHelper) then {detach _flyHelper; deleteVehicle _flyHelper};
if (!isNull _flyer) then {detach _flyer; deleteVehicle _flyer};
_boat setVariable ["ANC_flyer", nil];
_boat setVariable ["ANC_flyHelper", nil];
_boat setVariable ["ANC_flyRope", nil];
private _rope = ropeCreate [[_boat, _pt] call ANC_fnc_shoreBoatEnd, [0, 0, 0], _endHelper, [0, 0, 0], ((_boat modelToWorldWorld _pt) distance (getPosASL _pad)) + 1.5]; // (from a fitting on the boat - no pull on the boat)
ropeUnwind [_rope, 100, ((_boat modelToWorldWorld _pt) distance (getPosASL _pad)) + 4];
_boat setVariable ["ANC_rope", _rope];

_boat setVariable ["ANC_state", "loose"];
[_pad, _boat getVariable ["ANC_visual", objNull]] call ANC_fnc_bagRest; // the end at your feet, flat on the ground
[_boat, _pad, _pt, ((_boat modelToWorldWorld _pt) distance (getPosASL _pad)) + 1, 0, "loose"] call ANC_fnc_setShore;
call ANC_fnc_shoreLists;
(format ["Line made fast to the %1. Pick up the line to pull, or take back the heaving line.", getText (configOf _boat >> "displayName")]) call _say;
[_boat] spawn ANC_fnc_shoreWatch;
