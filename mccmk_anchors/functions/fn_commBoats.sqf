/*
    ANC_fnc_commBoats  (client)
    The boats a player can order from the 0-8 menu right now: boats holding units they've selected (F-keys), and boats
    of High Command groups they've selected. Not just their own boat (they have Shift+R for that).
*/
params ["_player"];
private _boats = [];
private _isBoat = {params ["_v"]; _v isKindOf "Ship" || {_v call ANC_fnc_isSubmersible}};
{
    private _v = vehicle _x;
    if (_x != _player && {_v != _x} && {[_v] call _isBoat}) then {_boats pushBackUnique _v};
} forEach (groupSelectedUnits _player);
{
    private _v = vehicle (leader _x);
    if (_v != (leader _x) && {[_v] call _isBoat}) then {_boats pushBackUnique _v};
} forEach (hcSelected _player);
_boats
