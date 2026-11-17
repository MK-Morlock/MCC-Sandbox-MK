/*
    ANC_fnc_act - one of Anchors' actions for the player: a scroll action, or - ACE loaded and MCC MK's "MCC actions with ACE" on -
    an ACE self-interaction action, directly at the top level. Same title, code and condition either way.
    [unit, key, title, code, condition (string), priority, show on screen, hide on use, condition in ACE (optional)]
    -> the scroll action's id, or -1 in ACE
*/
params ["_u", "_key", "_title", "_code", "_cond", ["_prio", 1.5], ["_show", false], ["_hide", true], ["_condAce", ""]];
if (isNull _u) exitWith {-1};
if (call ANC_fnc_aceMenus) exitWith {
    private _c = compile ("private _this = _player; private _target = _player; " + ([_cond, _condAce] select (_condAce != "")));
    [_u, 1, ["ACE_SelfActions", _key]] call ace_interact_menu_fnc_removeActionFromObject;
    private _a = [_key, (_title splitString "<>") param [[0, 2] select ((_title find "<") == 0), _title], "",
        {params ["", "_player", "_ap"]; [_player, _player, -1, []] call (_ap select 0)},
        {params ["", "_player", "_ap"]; call (_ap select 1)},
        {}, [_code, _c]] call ace_interact_menu_fnc_createAction;
    [_u, 1, ["ACE_SelfActions"], _a] call ace_interact_menu_fnc_addActionToObject;
    -1
};
// (MK) the scroll menu is in descending order of priority. The ordinary actions here (Boat Cargo, Board Boat, throw the line...
// 1.2 to 1.5) are put 10 lower, so Arma's own seat and light actions come first, then Anchors', in the same order among
// themselves. The deliberate ones (2 or more: "Get out" at 99, the line prompts at 6) stay.
_u addAction [_title, _code, nil, _prio - ([0, 10] select (_prio < 2)), _show, _hide, "", _cond]
