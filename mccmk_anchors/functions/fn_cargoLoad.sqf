/*
    ANC_fnc_cargoLoad  (any computer)
    How full a vehicle's cargo is: [used, maximum] - Arma measures cargo space by weight ("mass" units, the same
    numbers as the load bar in the inventory screen), not by slots. Uses the game's own figures where it has them,
    otherwise adds up the weight of everything aboard from the config.
    [vehicle]  ->  [used, maximum]
*/
params ["_v"];
private _max = getNumber (configOf _v >> "maximumLoad");
private _used = 0;
private _mass = {
    params ["_c"];
    private _m = getNumber (configFile >> "CfgWeapons" >> _c >> "WeaponSlotsInfo" >> "mass");
    if (_m == 0) then {_m = getNumber (configFile >> "CfgWeapons" >> _c >> "ItemInfo" >> "mass")};
    if (_m == 0) then {_m = getNumber (configFile >> "CfgMagazines" >> _c >> "mass")};
    if (_m == 0) then {_m = getNumber (configFile >> "CfgVehicles" >> _c >> "mass")};
    if (_m == 0) then {_m = getNumber (configFile >> "CfgGlasses" >> _c >> "mass")};
    _m
};
private _sum = {
    params ["_w", "_m", "_ic"];
    private _t = 0;
    {
        {if (_x isEqualType "" && {_x != ""}) then {_t = _t + ([_x] call _mass)}} forEach [_x select 0, _x select 1, _x select 2, _x select 3, _x param [6, ""]];
        {if (_x isEqualType [] && {count _x > 0}) then {_t = _t + ([_x select 0] call _mass)}} forEach [_x param [4, []], _x param [5, []]];
    } forEach _w;
    {_t = _t + ([_x select 0] call _mass)} forEach _m;
    _ic params [["_cl", []], ["_cn", []]];
    {_t = _t + (([_x] call _mass) * (_cn select _forEachIndex))} forEach _cl;
    _t
};
([_v] call ANC_fnc_cargoSnap) params ["_w", "_m", "_items", "_cs"];
_used = [_w, _m, [_items apply {_x select 0}, _items apply {_x select 1}]] call _sum;
{
    _x params ["_c", "_inside"];
    _used = _used + ([_c] call _mass) + (_inside call _sum);
} forEach _cs;
[round _used, round _max]
