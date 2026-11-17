/*
    ANC_fnc_cargoSnap  (any computer)
    Everything in a vehicle's cargo, in a form that can be put back exactly:
      [weapons with their attachments and loaded magazines, magazines with their ammo counts, other items [[class, count], ...],
       containers (uniforms, vests, backpacks) [[class, [weapons, magazines, [item classes, counts]]], ...]]
    Uniforms and vests are counted once, as containers (Arma lists them as items too).
    [vehicle]
*/
params ["_v"];
private _conts = everyContainer _v;
private _contClasses = _conts apply {_x select 0};
(getItemCargo _v) params [["_ic", []], ["_in", []]];
private _items = [];
{
    private _c = _x;
    private _n = (_in select _forEachIndex) - ({_x == _c} count _contClasses);
    if (_n > 0) then {_items pushBack [_c, _n]};
} forEach _ic;
private _cs = _conts apply {
    private _o = _x select 1;
    [_x select 0, [weaponsItemsCargo _o, magazinesAmmoCargo _o, getItemCargo _o]]
};
[weaponsItemsCargo _v, magazinesAmmoCargo _v, _items, _cs]
