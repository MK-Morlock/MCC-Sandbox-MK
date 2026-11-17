/*
    ANC_fnc_cargoDump  (server)
    "Overboard 1" / "Overboard all" in the Boat Cargo window: one of a thing, or the whole stack, thrown over the side
    - deleted from the boat's cargo for good. Done here on the server, all in one go, like a move (ANC_fnc_cargoMove).
    [boat, entry, player, how many] - entry as for ANC_fnc_cargoMove
*/
if (!isServer) exitWith {};
params ["_from", "_e", "_player", ["_want", 1]];
private _back = {[[], "cargoRefresh", _player] call ANC_fnc_remote};
if (isNull _from || {!alive _from} || {count _e < 2}) exitWith {call _back};
private _kind = _e select 0;
private _cls = if (_kind isEqualTo "W") then {(_e select 1) select 0} else {_e select 1};
if (_kind isEqualTo "C") then {_want = 1};
private _n = (_want max 1) min 999;
([_from] call ANC_fnc_cargoSnap) params ["_w", "_m", "_items", "_cs"];
private _gone = 0;
switch (_kind) do {
    case "W": {
        for "_k" from 1 to _n do {
            private _i = _w findIf {_x isEqualTo (_e select 1)};
            if (_i >= 0) then {_w deleteAt _i; _gone = _gone + 1};
        };
    };
    case "M": {
        for "_k" from 1 to _n do {
            private _i = _m findIf {_x isEqualTo [_e select 1, _e select 2]};
            if (_i >= 0) then {_m deleteAt _i; _gone = _gone + 1};
        };
    };
    case "I": {
        private _i = _items findIf {(_x select 0) == _cls};
        if (_i >= 0) then {
            private _have = (_items select _i) select 1;
            _gone = _n min _have;
            if (_have - _gone > 0) then {(_items select _i) set [1, _have - _gone]} else {_items deleteAt _i};
        };
    };
    case "C": {
        private _idx = [];
        {if ((_x select 0) == _cls) then {_idx pushBack _forEachIndex}} forEach _cs;
        private _i = _idx param [_e param [2, 0], -1];
        if (_i >= 0) then {_cs deleteAt _i; _gone = 1};
    };
};
if (_gone == 0) exitWith {call _back};
clearWeaponCargoGlobal _from;
clearMagazineCargoGlobal _from;
clearItemCargoGlobal _from;
clearBackpackCargoGlobal _from;
[_from, [_w, _m, _items, _cs]] call ANC_fnc_cargoFill;
call _back;
