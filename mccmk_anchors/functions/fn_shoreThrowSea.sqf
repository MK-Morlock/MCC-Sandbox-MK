/*
    ANC_fnc_shoreThrowSea  (97; server, spawned)
    Scroll action "Throw the bag", for someone on foot carrying a Heaving line (beside "Throw heaving line to the boat
    you're looking at" when a boat is in reach): the bag is just thrown the way they're looking - into the sea, as
    Paddle Mod's rope bag was, or onto the ground if that's where it comes down.

    One end stays at the thrower's feet (the line's end, with its own bag); the other flies:
      In the air   A real throw: about 15 m/s, up at the angle you're looking (15 to 45 deg), under
                   gravity with a little air drag. The line pays out behind it as it goes - never more than it needs -
                   and at 30 m (the whole line) it brings the bag up short. Hitting a wall, a tree or a rock: it drops
                   straight down from there.
      Into water   No floating: it goes straight in. The splash takes most of its speed (a quarter of
                   the speed along, a sixth of the speed down is left), then the wet bag sinks under its own weight
                   while the water slows it - the same model as a bag towed off the beach (ANC_fnc_bagMove): it eases
                   down to the seabed and stops there. The line only pays out as far as the bag actually goes, so it
                   stops where the bag reaches the bottom - the full 30 m never comes out unless the bag really goes
                   that far.
      On land      It drops onto the ground and lies flat on the slope.
    Then, at the end at your feet: "Haul in the heaving line" (ANC_fnc_shoreHaulSea) drags the bag back along the
    seabed and the shore, and the Heaving line goes back into your inventory.
    [player, aim direction (the player's camera direction, from his computer)]
*/
params ["_player", ["_aim", [], [[]]]];
private _say = {[[_this], "notify", _player] call ANC_fnc_remote};
if (!alive _player || {vehicle _player != _player}) exitWith {};
if !("ANC_HeavingLine" in (items _player)) exitWith {"You don't have a Heaving line." call _say};
if (!isNull (_player getVariable ["ANC_holdingBoat", objNull])) exitWith {};
if (count _aim < 3) then {_aim = getCameraViewDirection _player};
private _maxLen = 30; // (the heaving line is 30 m, as a shore line to a boat)

_player removeItem "ANC_HeavingLine";
[[_player, "ThrowGrenade"], "playActionNow", _player] call ANC_fnc_remote;

// The end at the thrower's feet: an invisible marker carrying a bag and the hidden fitting the rope is tied to.
call ANC_fnc_lineModel;
private _mkEnd = {
    params ["_posASL"];
    private _pad = createVehicle ["Land_HelipadEmpty_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
    _pad setPosASL _posASL;
    private _vis = if !(ANC_lineModelClass isEqualTo "") then {
        private _v = createVehicle [ANC_lineModelClass, [0, 0, 1000], [], 0, "CAN_COLLIDE"];
        _v allowDamage false;
        _v
    } else {createSimpleObject [ANC_lineModelPath, _posASL]};
    _vis attachTo [_pad, [0, 0, 0.1]];
    private _h = call ANC_fnc_makeHelper;
    _h attachTo [_pad, [0, 0, 0]];
    [_pad, _vis, _h]
};
private _feet = getPosASL _player;
_feet set [2, ((getTerrainHeightASL _feet) max 0) + 0.05];
([_feet] call _mkEnd) params ["_endPad", "_endVis", "_endHelper"];
[_endPad, _endVis] call ANC_fnc_bagRest;

// The thrown bag, from the hand.
private _hand = (getPosASL _player) vectorAdd [0, 0, 1.5];
([_hand] call _mkEnd) params ["_bagPad", "_bagVis", "_bagHelper"];
private _rope = ropeCreate [_endHelper, [0, 0, 0], _bagHelper, [0, 0, 0], (_feet distance _hand) + 1];

// The launch: 15 m/s, along the look direction, up at the look angle kept between 15 and 45 degrees.
private _flat = vectorNormalized [_aim select 0, _aim select 1, 0];
if (vectorMagnitude _flat < 0.1) then {_flat = vectorDir _player};
private _el = (((asin (((_aim select 2) max -1) min 1)) + 20) max 15) min 45;
private _v = (_flat vectorMultiply (15 * cos _el)) vectorAdd [0, 0, 15 * sin _el];

private _rec = [_endPad, _bagPad, _rope, _endVis, _bagVis, _endHelper, _bagHelper, "flying"];
if (isNil "ANC_seaLines") then {ANC_seaLines = []};
ANC_seaLines pushBack _rec;
"Throwing the line..." call _say;

private _state = [_v, "air", time]; // velocity, phase, last time
[{
    params ["_args", "_handle"];
    _args params ["_rec", "_state", "_feet", "_maxLen", "_player"];
    _rec params ["_endPad", "_bagPad", "_rope"];
    _state params ["_v", "_phase", "_t"];
    if (isNull _bagPad) exitWith {[_handle] call CBA_fnc_removePerFrameHandler};
    private _dt = ((time - _t) max 0.001) min 0.1;
    _state set [2, time];
    private _p = getPosASL _bagPad;
    private _bed = getTerrainHeightASL _p;
    private _endAt = (getPosASL _endPad) vectorAdd [0, 0, 0.1];
    private _stop = false;

    switch (_phase) do {
        case "air": {
            // gravity and a little air drag (0.01 per m - a bag with a tail of line)
            private _sp = vectorMagnitude _v;
            _v = (_v vectorAdd [0, 0, -9.81 * _dt]) vectorDiff (_v vectorMultiply (0.01 * _sp * _dt));
            private _n = _p vectorAdd (_v vectorMultiply _dt);
            // something in the way (a wall, a tree, a rock): it drops straight down from there
            private _hit = lineIntersectsSurfaces [_p, _n, _rec select 4, _player, true, 1, "GEOM", "FIRE"]; // (its own bag left out)
            if (_hit isNotEqualTo [] && {!(((_hit select 0) select 2) in [_endPad, _rec select 3, _rec select 5, _rec select 6])}) then {
                _n = ((_hit select 0) select 0) vectorAdd ((vectorNormalized (_p vectorDiff _n)) vectorMultiply 0.2);
                _v = [0, 0, (_v select 2) min 0];
            };
            // the whole line out: it brings the bag up short
            if ((_n distance _endAt) > _maxLen) then {
                private _dir = vectorNormalized (_n vectorDiff _endAt);
                _n = _endAt vectorAdd (_dir vectorMultiply _maxLen);
                _v = _v vectorDiff (_dir vectorMultiply ((_v vectorDotProduct _dir) max 0));
            };
            private _bedN = getTerrainHeightASL _n;
            if (surfaceIsWater _n && {_bedN < -0.05} && {(_n select 2) <= 0}) then {
                // in: the splash takes most of its speed
                _n set [2, 0 min ((_n select 2))];
                _v = [(_v select 0) * 0.25, (_v select 1) * 0.25, (_v select 2) / 6];
                _phase = "water";
                [[_n], "splash", 0] call ANC_fnc_remote;
            } else {
                if ((_n select 2) <= (_bedN + 0.05)) then {
                    _n set [2, _bedN + 0.05];
                    _phase = "land";
                };
            };
            _bagPad setPosASL _n;
            [_bagPad] call ANC_fnc_reattach; // the bag and the rope's fitting with it, every frame
        };
        case "water": {
            // carried on by what speed it kept, the water slowing it (a time constant of half a second); its depth
            // from the towed-bag model: sinking under its own weight, eased by the line's pull
            private _h = [_v select 0, _v select 1, 0];
            _h = _h vectorMultiply (exp (-_dt / 0.5));
            _v = [_h select 0, _h select 1, 0];
            private _xy = (getPosASL _bagPad) vectorAdd (_h vectorMultiply _dt);
            if ((_xy distance2D _endAt) > _maxLen) then {
                private _d = vectorNormalized [(_xy select 0) - (_endAt select 0), (_xy select 1) - (_endAt select 1), 0];
                _xy = _endAt vectorAdd (_d vectorMultiply _maxLen);
                _v = [0, 0, 0];
            };
            [_bagPad, _xy, _endAt vectorAdd [0, 0, 1], _dt, (vectorMagnitude _h) > 0.05] call ANC_fnc_bagMove;
            private _q = getPosASL _bagPad;
            // on the bottom and still: it stays there
            if ((vectorMagnitude _h) < 0.05 && {(_q select 2) <= ((getTerrainHeightASL _q) + 0.1)}) then {_phase = "bottom"};
            // washed into the shallows / onto the shore
            if !(surfaceIsWater _q && {(getTerrainHeightASL _q) < -0.05}) then {_phase = "land"};
        };
        case "land": {
            [_bagPad, _rec select 4] call ANC_fnc_bagRest;
            _stop = true;
        };
        case "bottom": {
            _stop = true;
        };
    };
    _state set [0, _v];
    _state set [1, _phase];
    // the line pays out behind the bag - only as much as it needs, never more than 30 m
    if (!isNull _rope) then {
        private _need = (((getPosASL _bagPad) distance _endAt) + 1) min _maxLen;
        if (_need > ropeLength _rope) then {ropeUnwind [_rope, 40, _need]};
    };
    if (_stop) then {
        _rec set [7, "out"];
        publicVariable "ANC_seaLines";
        [_handle] call CBA_fnc_removePerFrameHandler;
        private _where = if (surfaceIsWater (getPosASL _bagPad) && {(getTerrainHeightASL (getPosASL _bagPad)) < -0.05}) then {
            format ["on the bottom, %1 m down", round (0 - ((getPosASL _bagPad) select 2))]
        } else {"on the ground"};
        [[format ["The bag's %1, %2 m out. Haul in the heaving line at your feet to bring it back.", _where, round ((getPosASL _bagPad) distance2D _endAt)]], "notify", _player] call ANC_fnc_remote;
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Heaving line thrown: %1 m out, %2 | line %3 m", round ((getPosASL _bagPad) distance2D _endAt), _where, (ropeLength _rope) toFixed 1]};
    };
}, 0, [_rec, _state, _feet, _maxLen, _player]] call CBA_fnc_addPerFrameHandler;
publicVariable "ANC_seaLines";
