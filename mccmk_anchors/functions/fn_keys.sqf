/*
    ANC_fnc_keys  (client)
    Puts the player's own keys into a message: {anchor}, {tow}, {haul}, {payout} and {adjust} become whatever those
    Anchors actions are bound to in Options > Controls > Configure Addons (Shift+R, Shift+F, Shift+Page Down,
    Shift+Page Up and Ctrl+Shift+R unless changed). Messages are written with these markers wherever they mention a
    key.
    [message]  ->  message
*/
params [["_msg", "", [""]]];
if ((_msg find "{") < 0) exitWith {_msg};
{
    _x params ["_tok", "_act", "_def"];
    if ((_msg find _tok) >= 0) then {
        private _t = _def;
        private _kb = ["Anchors", _act] call CBA_fnc_getKeybind;
        if (!isNil "_kb" && {_kb isEqualType []} && {count _kb > 5}) then {
            private _k = _kb select 5;
            if (_k isEqualType [] && {count _k == 2} && {(_k select 0) > 0} && {!isNil "CBA_fnc_localizeKey"}) then {
                private _l = _k call CBA_fnc_localizeKey;
                if (_l isEqualType "" && {_l != ""}) then {_t = _l};
            };
        };
        private _i = _msg find _tok;
        while {_i >= 0} do {
            _msg = (_msg select [0, _i]) + _t + (_msg select [_i + count _tok]);
            _i = _msg find _tok;
        };
    };
} forEach [
    ["{anchor}", "ANC_key_anchor_r", "Shift+R"],
    ["{tow}", "ANC_key_tow_f", "Shift+F"],
    ["{haul}", "ANC_key_haul_pgdn", "Shift+Page Down"],
    ["{payout}", "ANC_key_payout_pgup", "Shift+Page Up"],
    ["{adjust}", "ANC_key_adjust", "Ctrl+Shift+R"],
    ["{lines}", "ANC_key_lines", "Ctrl+Home"]
];
_msg
