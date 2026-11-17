/*
    ANC_fnc_cargoFill  (server)
    Adds the contents of a cargo snapshot (ANC_fnc_cargoSnap) to a vehicle - containers with what was inside them.
    [vehicle, snapshot]
*/
params ["_v", "_snap"];
_snap params [["_w", []], ["_m", []], ["_items", []], ["_cs", []]];
{_v addWeaponWithAttachmentsCargoGlobal [_x, 1]} forEach _w;
{_v addMagazineAmmoCargo [_x select 0, 1, _x select 1]} forEach _m;
{_v addItemCargoGlobal [_x select 0, _x select 1]} forEach _items;
{
    _x params ["_cls", "_inside"];
    private _before = (everyContainer _v) apply {_x select 1};
    private _isBag = isClass (configFile >> "CfgVehicles" >> _cls);
    // a backpack's plain version, so it doesn't come with the kit some backpacks are issued with on top of what was
    // in it
    private _add = if (_isBag) then {[_cls] call BIS_fnc_basicBackpack} else {_cls};
    if (_isBag) then {_v addBackpackCargoGlobal [_add, 1]} else {_v addItemCargoGlobal [_add, 1]};
    private _new = ((everyContainer _v) select {(_x select 0) == _add && {!((_x select 1) in _before)}}) param [0, []];
    if (count _new == 2) then {
        private _o = _new select 1;
        _inside params [["_iw", []], ["_im", []], ["_ii", [[], []]]];
        {_o addWeaponWithAttachmentsCargoGlobal [_x, 1]} forEach _iw;
        {_o addMagazineAmmoCargo [_x select 0, 1, _x select 1]} forEach _im;
        _ii params [["_icl", []], ["_icn", []]];
        {_o addItemCargoGlobal [_x, _icn select _forEachIndex]} forEach _icl;
    };
} forEach _cs;
