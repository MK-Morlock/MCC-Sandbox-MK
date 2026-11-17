/*
    ANC_fnc_xlTether  (server, spawned)
    TETHER: one line, an Arma rope, from this boat's nearest FREE point (bow, stern, or a side cleat on the side
    facing the other boat) to the other boat's nearest free point (never its anchor point), made fast where the boats
    are with half a metre of slack - the rope holds the boats within its length. A boat can be tethered to several
    boats, one line per point, and still anchor, moor or tow. [boat, player, other boat]
*/
params ["_boat", "_player", "_other"];
if (isNull _other || {!alive _other}) exitWith {[_boat, "That boat is gone.", _player] call ANC_fnc_tellBoat};
// One type of line between any two vehicles: no tether to a boat joined to you by a tow line.
if (([_boat, _other] call ANC_fnc_xlTypeBetween) isEqualTo "tow") exitWith {[_boat, "A tow line joins you to that boat - let go of it first to tether.", _player] call ANC_fnc_tellBoat};
private _sideMe = [-1, 1] select (((_boat worldToModel (ASLToAGL getPosASL _other)) select 0) >= 0);
private _sideThem = [-1, 1] select (((_other worldToModel (ASLToAGL getPosASL _boat)) select 0) >= 0);
private _ptsOf = {
    params ["_v", "_side"];
    ([[_v, "towBow"] call ANC_fnc_pointFor, [_v, "towStern"] call ANC_fnc_pointFor,
      [_v, "moorBow", _side] call ANC_fnc_pointFor, [_v, "moorStern", _side] call ANC_fnc_pointFor,
      [_v, "moorFwd", _side] call ANC_fnc_pointFor, [_v, "moorAft", _side] call ANC_fnc_pointFor]
    select {count _x == 3}) select {[_v, _x] call ANC_fnc_xlFree}
};
private _nearest = {
    params ["_v", "_pts", "_to"];
    if (count _pts == 0) exitWith {[]};
    private _best = _pts select 0;
    {if (((_v modelToWorldWorld _x) distance _to) < ((_v modelToWorldWorld _best) distance _to)) then {_best = _x}} forEach _pts;
    _best
};
private _mine = [_boat, [_boat, _sideMe] call _ptsOf, getPosASL _other] call _nearest;
if (count _mine == 0) exitWith {[_boat, "Every attachment point on this boat already has a line on it.", _player] call ANC_fnc_tellBoat};
private _theirs = [_other, [_other, _sideThem] call _ptsOf, _boat modelToWorldWorld _mine] call _nearest;
if (count _theirs == 0) exitWith {[_boat, "Every attachment point on that boat already has a line on it.", _player] call ANC_fnc_tellBoat};
[_boat, "Passing a line across...", _player] call ANC_fnc_tellBoat;
private _d = (_boat modelToWorldWorld _mine) distance (_other modelToWorldWorld _theirs);
private _rope = ropeCreate [_boat, _mine, _other, _theirs, (_d * 1.03) + 1];
if (isNull _rope) exitWith {[_boat, "The line didn't hold.", _player] call ANC_fnc_tellBoat};
sleep 0.4;
if (!alive _boat || {!alive _other}) exitWith {ropeDestroy _rope};
if (([_boat, _other] call ANC_fnc_xlTypeBetween) isEqualTo "tow") exitWith {ropeDestroy _rope; [_boat, "A tow line joins you to that boat - let go of it first to tether.", _player] call ANC_fnc_tellBoat};
ropeUnwind [_rope, 3, ((_boat modelToWorldWorld _mine) distance (_other modelToWorldWorld _theirs)) + 0.5];
private _id = ["tether", _boat, _mine, _other, _theirs, _d + 0.5, _rope, _player] call ANC_fnc_xlAdd;
[_boat, format ["Tethered: %1.", [_id, _boat] call ANC_fnc_xlLabel], _player] call ANC_fnc_tellBoat;
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Tether %1: %2 point %3 to %4 point %5, %6 m", _id, typeOf _boat, _mine, typeOf _other, _theirs, (round (_d * 10)) / 10]};
