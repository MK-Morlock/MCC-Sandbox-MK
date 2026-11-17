/*
    ANC_fnc_cargoRefresh  (client)
    After a move: adds it to the tally ([how many, class, from, to] from ANC_fnc_cargoMove), then - a moment later, so
    the boats' cargo has caught up - refills both lists and their headings (name, distance, cargo load) and the tally
    text, if the Boat Cargo window is open.
    [how many, class, from, to] (optional)
*/
params [["_n", 0], ["_cls", ""], ["_from", objNull], ["_to", objNull]];
if (isNull (findDisplay 47101)) exitWith {};
if (_n > 0 && {_cls != ""} && {!isNil "ANC_cargoTally"}) then {
    private _sign = [-1, 1] select (_from isEqualTo ANC_cargoA);
    ANC_cargoTally set [_cls, (ANC_cargoTally getOrDefault [_cls, 0]) + (_sign * _n)];
};
[{
    private _d = findDisplay 47101;
    if (isNull _d) exitWith {};
    ([ANC_cargoA] call ANC_fnc_cargoLoad) params ["_uA", "_mA"];
    ([ANC_cargoB] call ANC_fnc_cargoLoad) params ["_uB", "_mB"];
    // in kilograms: Arma's inventory "mass" units are a tenth of a pound each (10 = 1 lb = 0.4536 kg)
    private _kg = {
        params ["_m"];
        private _k = _m * 0.04536;
        if (_k < 10) then {(round (_k * 10)) / 10} else {round _k}
    };
    // a boat loaded beyond its capacity (Arma spawns some boats like that) is marked "over full", in red - nothing
    // more fits
    (_d displayCtrl 47120) ctrlSetText format ["Your boat: %1  -  Cargo %2 kg / %3 kg%4", getText (configOf ANC_cargoA >> "displayName"), [_uA] call _kg, [_mA] call _kg, ["", "  (over full)"] select (_uA > _mA)];
    (_d displayCtrl 47121) ctrlSetText format ["%1  -  Cargo %2 kg / %3 kg%4", [ANC_cargoA, ANC_cargoB] call ANC_fnc_boatLabel, [_uB] call _kg, [_mB] call _kg, ["", "  (over full)"] select (_uB > _mB)];
    (_d displayCtrl 47120) ctrlSetTextColor ([[1, 1, 1, 1], [1, 0.45, 0.4, 1]] select (_uA > _mA));
    (_d displayCtrl 47121) ctrlSetTextColor ([[1, 1, 1, 1], [1, 0.45, 0.4, 1]] select (_uB > _mB));
    ANC_cargoRowsA = [ANC_cargoA] call ANC_fnc_cargoRows;
    ANC_cargoRowsB = [ANC_cargoB] call ANC_fnc_cargoRows;
    {
        _x params ["_idc", "_rows"];
        private _l = _d displayCtrl _idc;
        private _sel = lbCurSel _l;
        lbClear _l;
        {
            private _i = _l lbAdd (_x select 0);
            _l lbSetData [_i, str _forEachIndex];
        } forEach _rows;
        if (count _rows == 0) then {_l lbAdd "(empty)"};
        if (_sel >= 0) then {_l lbSetCurSel (_sel min ((lbSize _l) - 1))};
    } forEach [[47110, ANC_cargoRowsA], [47111, ANC_cargoRowsB]];
    // the tally: what has gone each way while the window has been open
    private _sent = [];
    private _taken = [];
    {
        if (_y > 0) then {_sent pushBack format ["%1 x %2", _y, [_x] call ANC_fnc_itemName]};
        if (_y < 0) then {_taken pushBack format ["%1 x %2", -_y, [_x] call ANC_fnc_itemName]};
    } forEach ANC_cargoTally;
    // under your list: what you've sent to / taken from the other boat; under its list: the same seen from that boat
    private _nameA = getText (configOf ANC_cargoA >> "displayName");
    private _nameB = getText (configOf ANC_cargoB >> "displayName");
    private _line = {
        params ["_label", "_list"];
        format ["%1 %2", _label, [_list joinString ", ", "nothing yet"] select (count _list == 0)]
    };
    (_d displayCtrl 47130) ctrlSetStructuredText parseText format ["<t color='#99ff99'>%1</t><br/><t color='#ffcc66'>%2</t>",
        ["Sent to " + _nameB + ":", _sent] call _line, ["Taken from " + _nameB + ":", _taken] call _line];
    (_d displayCtrl 47131) ctrlSetStructuredText parseText format ["<t color='#99ff99'>%1</t><br/><t color='#ffcc66'>%2</t>",
        ["Received from " + _nameA + ":", _sent] call _line, ["Given to " + _nameA + ":", _taken] call _line];
}, [], 0.3] call CBA_fnc_waitAndExecute;
