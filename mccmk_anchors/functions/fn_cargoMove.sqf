/*
    ANC_fnc_cargoMove  (server)
    "Boat Cargo": moves things from one boat's cargo to the other's - weapons (with their attachments and loaded
    magazines), magazines (with their ammo counts), items, or a uniform / vest / backpack with everything in it. Done
    here on the server, all in one go, so two players moving things at once can't lose or double anything. As many of
    a stack as asked for and as there's room for go across; if there's no room for even one, nothing moves and the
    player is told ("Not enough cargo space on the ..."). Arma can't take single things out of a vehicle's cargo, so
    the first boat's cargo is emptied and refilled without them. The player is then told what went where, for the
    window's tally.
    [from, to, entry, player, how many (default 1)]
      entry: ["W", weapon entry] / ["M", class, ammo] / ["I", class] / ["C", class, which one of that class]
*/
if (!isServer) exitWith {};
params ["_from", "_to", "_e", "_player", ["_want", 1]];
private _back = {[[], "cargoRefresh", _player] call ANC_fnc_remote};
if (isNull _from || {isNull _to} || {!alive _from} || {!alive _to} || {count _e < 2}) exitWith {call _back};
if ((([_from, _to] call ANC_fnc_hullGap) select 0) > 10) exitWith {[["Boats must be within ten metres to transfer."], "notice", _player] call ANC_fnc_remote};
private _kind = _e select 0;
private _cls = if (_kind isEqualTo "W") then {(_e select 1) select 0} else {_e select 1};
// as many as there's room for (at least one, or nothing moves)
if (_kind isEqualTo "C") then {_want = 1};
private _n = (_want max 1) min 999;
while {_n > 0 && {!(_to canAdd [_cls, _n])}} do {_n = _n - 1};
if (_n == 0) exitWith {
    ([_to] call ANC_fnc_cargoLoad) params ["_u", "_mx"];
    [[format ["Not enough cargo space on the %1%2.", getText (configOf _to >> "displayName"),
        ["", format [" - it's already over full (%1 kg of %2 kg)", round (_u * 0.04536), round (_mx * 0.04536)]] select (_u > _mx)]], "notice", _player] call ANC_fnc_remote;
    call _back;
};
private _s = [_from] call ANC_fnc_cargoSnap;
_s params ["_w", "_m", "_items", "_cs"];
private _add = [[], [], [], []];
private _moved = 0;
switch (_kind) do {
    case "W": {
        private _taken = [];
        for "_k" from 1 to _n do {
            private _i = _w findIf {_x isEqualTo (_e select 1)};
            if (_i >= 0) then {_taken pushBack (_w deleteAt _i)};
        };
        _add set [0, _taken];
        _moved = count _taken;
    };
    case "M": {
        private _taken = [];
        for "_k" from 1 to _n do {
            private _i = _m findIf {_x isEqualTo [_e select 1, _e select 2]};
            if (_i >= 0) then {_taken pushBack (_m deleteAt _i)};
        };
        _add set [1, _taken];
        _moved = count _taken;
    };
    case "I": {
        private _i = _items findIf {(_x select 0) == _cls};
        if (_i >= 0) then {
            private _have = (_items select _i) select 1;
            _moved = _n min _have;
            if (_have - _moved > 0) then {(_items select _i) set [1, _have - _moved]} else {_items deleteAt _i};
            _add set [2, [[_cls, _moved]]];
        };
    };
    case "C": {
        private _idx = [];
        {if ((_x select 0) == _cls) then {_idx pushBack _forEachIndex}} forEach _cs;
        private _i = _idx param [_e param [2, 0], -1];
        if (_i >= 0) then {_add set [3, [_cs deleteAt _i]]; _moved = 1};
    };
};
if (_moved == 0) exitWith {call _back};
[_to, _add] call ANC_fnc_cargoFill;
clearWeaponCargoGlobal _from;
clearMagazineCargoGlobal _from;
clearItemCargoGlobal _from;
clearBackpackCargoGlobal _from;
[_from, [_w, _m, _items, _cs]] call ANC_fnc_cargoFill;
[[_moved, _cls, _from, _to], "cargoRefresh", _player] call ANC_fnc_remote;
