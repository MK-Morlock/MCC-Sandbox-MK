/*
    ANC_fnc_bagStow  (server)
    [player]
*/
params ["_player"];
private _boat = _player getVariable ["ANC_holdingBoat", objNull];
if (isNull _boat || {!alive _player}) exitWith {};
(_boat call ANC_fnc_hullOutline) params ["_cx", "_sY", "_bY", "_hw"];
private _l = _boat worldToModel (ASLToAGL getPosASL _player);
private _dx = (_l select 0) - (((_l select 0) max (_cx - _hw)) min (_cx + _hw));
private _dy = (_l select 1) - (((_l select 1) max _sY) min _bY);
if ((sqrt ((_dx * _dx) + (_dy * _dy))) > 4.5) exitWith {[["Get within 4 m of the boat to put the bag in it."], "notify", _player] call ANC_fnc_remote};
[_boat] call ANC_fnc_cleanup;
[_boat, "The rope bag is back in the boat.", _player] call ANC_fnc_tellBoat;
