/*
    ANC_fnc_cargoRows  (client)
    A boat's cargo as rows for the Boat Cargo window: [[label, entry, how many], ...] - identical things grouped with
    a count ("x 3"); each uniform / vest / backpack its own row (it moves with what's in it).
    [vehicle]
*/
params ["_v"];
private _name = {
    params ["_c"];
    private _n = getText (configFile >> "CfgWeapons" >> _c >> "displayName");
    if (_n isEqualTo "") then {_n = getText (configFile >> "CfgMagazines" >> _c >> "displayName")};
    if (_n isEqualTo "") then {_n = getText (configFile >> "CfgVehicles" >> _c >> "displayName")};
    if (_n isEqualTo "") then {_n = getText (configFile >> "CfgGlasses" >> _c >> "displayName")};
    [_n, _c] select (_n isEqualTo "")
};
([_v] call ANC_fnc_cargoSnap) params ["_w", "_m", "_items", "_cs"];
private _rows = [];
private _grouped = []; // [entry, count]
{
    private _e = ["W", _x];
    private _i = _grouped findIf {(_x select 0) isEqualTo _e};
    if (_i >= 0) then {(_grouped select _i) set [1, ((_grouped select _i) select 1) + 1]} else {_grouped pushBack [_e, 1]};
} forEach _w;
{
    private _e = ["M", _x select 0, _x select 1];
    private _i = _grouped findIf {(_x select 0) isEqualTo _e};
    if (_i >= 0) then {(_grouped select _i) set [1, ((_grouped select _i) select 1) + 1]} else {_grouped pushBack [_e, 1]};
} forEach _m;
{
    _x params ["_e", "_n"];
    private _label = switch (_e select 0) do {
        case "W": {
            private _wi = _e select 1;
            private _att = ({_x isEqualType "" && {_x != ""}} count [_wi select 1, _wi select 2, _wi select 3, _wi param [6, ""]]);
            format ["%1%2", [_wi select 0] call _name, ["", " (+ attachments)"] select (_att > 0)]
        };
        case "M": {
            private _max = getNumber (configFile >> "CfgMagazines" >> (_e select 1) >> "count");
            format ["%1 (%2/%3)", [_e select 1] call _name, _e select 2, _max]
        };
    };
    _rows pushBack [format ["%1%2", _label, ["", format ["  x %1", _n]] select (_n > 1)], _e, _n];
} forEach _grouped;
{
    _x params ["_c", "_n"];
    _rows pushBack [format ["%1%2", [_c] call _name, ["", format ["  x %1", _n]] select (_n > 1)], ["I", _c], _n];
} forEach _items;
private _seen = createHashMap;
{
    _x params ["_c", "_inside"];
    private _k = _seen getOrDefault [_c, 0];
    _seen set [_c, _k + 1];
    _inside params ["_iw", "_im", "_ii"];
    private _full = (count _iw) + (count _im) + (count (_ii param [0, []])) > 0;
    _rows pushBack [format ["%1%2", [_c] call _name, ["", " (with contents)"] select _full], ["C", _c, _k], 1];
} forEach _cs;
_rows
