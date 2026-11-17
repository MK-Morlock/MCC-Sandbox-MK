/*
    ANC_fnc_shoreHaulSea  (97; server)
    Scroll action "Haul in the heaving line", at the end of a heaving line thrown into the sea (or onto the ground) -
    ANC_fnc_shoreThrowSea. The bag is hauled back hand over hand (0.8 m/s) the same way a bag is towed off the beach
    (ANC_fnc_bagMove): along the seabed in the water, rising only as much as the line's pull lifts it, then over the
    ground, the line coming in as it does. At your feet the line is coiled up and the Heaving line goes back into your
    inventory (on the ground if there's no room).
    [player]
*/
params ["_player"];
private _say = {[[_this], "notify", _player] call ANC_fnc_remote};
if (isNil "ANC_seaLines") exitWith {};
private _i = ANC_seaLines findIf {!isNull (_x select 0) && {(_x select 7) isEqualTo "out"} && {(_player distance (_x select 0)) <= 2.5}};
if (_i == -1) exitWith {"There's no heaving line end here to haul in." call _say};
private _rec = ANC_seaLines select _i;
_rec set [7, "hauling"];
publicVariable "ANC_seaLines";
"Hauling in the line..." call _say;
[{
    params ["_args", "_handle"];
    _args params ["_rec", "_player", "_t"];
    _rec params ["_endPad", "_bagPad", "_rope", "_endVis", "_bagVis", "_endHelper", "_bagHelper"];
    private _dt = ((time - (_args select 2)) max 0.001) min 0.1;
    _args set [2, time];
    private _endAt = (getPosASL _endPad) vectorAdd [0, 0, 1];
    private _p = getPosASL _bagPad;
    private _gap = _p distance2D _endAt;
    if (_gap < 1.2 || {isNull _bagPad}) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        { if (!isNull _x) then {detach _x; deleteVehicle _x}; } forEach [_bagVis, _bagHelper, _endVis, _endHelper];
        if (!isNull _rope) then {ropeDestroy _rope};
        { if (!isNull _x) then {deleteVehicle _x}; } forEach [_bagPad, _endPad];
        ANC_seaLines = ANC_seaLines - [_rec];
        publicVariable "ANC_seaLines";
        private _say = {[[_this], "notify", _player] call ANC_fnc_remote};
        if (alive _player && {_player canAdd "ANC_HeavingLine"}) then {_player addItem "ANC_HeavingLine"; "Heaving line hauled in and coiled - it's back in your inventory." call _say} else {
            private _holder = createVehicle ["GroundWeaponHolder", ASLToATL (getPosASL _endPad), [], 0, "CAN_COLLIDE"];
            _holder addItemCargoGlobal ["ANC_HeavingLine", 1];
            "Heaving line hauled in - no room for it, it's on the ground." call _say;
        };
    };
    private _d = vectorNormalized [(_endAt select 0) - (_p select 0), (_endAt select 1) - (_p select 1), 0];
    private _xy = _p vectorAdd (_d vectorMultiply ((2 * _dt) min _gap));
    [_bagPad, _xy, _endAt, _dt, true] call ANC_fnc_bagMove;
    // hauled, the line is taut - straight from your hands to the bag, never sagging below it
    if (!isNull _rope) then {ropeUnwind [_rope, 3, (((getPosASL _bagPad) distance _endAt) + 0.05) max 1]};
}, 0, [_rec, _player, time]] call CBA_fnc_addPerFrameHandler;
