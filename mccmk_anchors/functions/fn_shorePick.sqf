/*
    ANC_fnc_shorePick  (server)
    Scroll action for someone on foot:
      "Pick up the line"      - a loose line end within 2.5 m: they're holding it.
      "Take hold of the line" - someone within 3 m is holding a line: they add
                                their strength to it (pulls add together).
*/
params ["_player"];
if (!alive _player || {vehicle _player != _player} || {!isNull (_player getVariable ["ANC_holdingBoat", objNull])}) exitWith {};
private _say = {[[_this], "notify", _player] call ANC_fnc_remote};

private _i = ANC_lineEnds findIf {!isNull (_x select 0) && {(_player distance (_x select 0)) <= 2.5}};
if (_i != -1) exitWith {
    (ANC_lineEnds select _i) params ["_pad", "_boat"];
    private _rope = _boat getVariable ["ANC_rope", objNull];
    if (!isNull _rope) then {ropeUnwind [_rope, 50, (ropeLength _rope) + 3]}; // slack before it's in their hand
    // The end follows their hand but isn't attached to them (ANC_fnc_shoreFollow).
    _boat setVariable ["ANC_shoreCarrier", _player, true];
    _player setVariable ["ANC_holdingBoat", _boat, true];
    [[_pad, _boat, _boat getVariable ["ANC_visual", objNull]], "shoreFollow", _player] call ANC_fnc_remote;
    _boat setVariable ["ANC_shoreHolders", [_player]];
    _player setVariable ["ANC_holdingBoat", _boat, true];
    _boat setVariable ["ANC_state", "held"];
    private _pt = _boat getVariable ["ANC_shorePoint", [0, 0, 0]];
    private _d = (_boat modelToWorldWorld _pt) distance (getPosASL _pad);
    // the line keeps the length it has - picking it up closer to the boat doesn't shorten it (the spare lies on the
    // ground); only if it's somehow shorter than where you are is it let out to reach you
    private _oldLen = (_boat getVariable ["ANC_shoreData", []]) param [2, _d + 0.5];
    [_boat, _pad, _pt, (_oldLen max (_d + 0.5)) min 30, (missionNamespace getVariable ["ANC_pullStrength", 600]), "held"] call ANC_fnc_setShore;
    call ANC_fnc_shoreLists;
    "You've got the line. Walk to pull, {haul} to haul in, {payout} to pay out." call _say;
};

private _j = ANC_heldLines findIf {!isNull (_x select 1) && {(_player distance (_x select 1)) <= 3}};
if (_j != -1) exitWith {
    private _boat = (ANC_heldLines select _j) select 0;
    private _h = _boat getVariable ["ANC_shoreHolders", []];
    _h pushBackUnique _player;
    _boat setVariable ["ANC_shoreHolders", _h];
    _player setVariable ["ANC_holdingBoat", _boat, true];
    private _d = _boat getVariable ["ANC_shoreData", []];
    if (count _d == 5) then {[_boat, _d select 0, _d select 1, _d select 2, (missionNamespace getVariable ["ANC_pullStrength", 600]) * (count _h), "held"] call ANC_fnc_setShore};
    (format ["You're helping haul (%1 on the line).", count _h]) call _say;
};
