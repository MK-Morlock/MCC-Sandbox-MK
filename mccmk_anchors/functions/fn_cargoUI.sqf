/*
    ANC_fnc_cargoUI  (client)
    "Boat Cargo": your boat's cargo and the other boat's side by side, each headed with its name and how full it is
    ("Your boat: Combat Boat (HMG) - Cargo 15 kg / 91 kg" - Arma measures cargo by weight; shown in kilograms). Click
    a row to select it, then use the buttons between the lists:
        Move 1  >      Move all  >>     one / the whole stack from your boat to the other
        <  Move 1      <<  Move all     one / the whole stack from the other boat to yours
    (Dragging a row across, or double-clicking it, moves one.) Underneath, a running tally of everything moved while
    the window is open - "Sent to Combat Boat (Unarmed): 2 x 6.5 mm 30Rnd STANAG Mag" / "Taken from it: 1 x First Aid
    Kit" - so you can see what's gone where; moving something back takes it off the tally. The server does each move
    (ANC_fnc_cargoMove). Closes if the boats drift more than 10 m apart ("Boats must be within ten metres to
    transfer").
    [other boat]
*/
params [["_b", objNull, [objNull]]];
private _mine = vehicle player;
if (isNull _b || {!alive _b} || {_mine isEqualTo player}) exitWith {};
ANC_cargoA = _mine;
ANC_cargoB = _b;
ANC_cargoTally = createHashMap; // class -> net number moved (+ sent to the other boat, - taken from it)
ANC_cargoLastIdc = -1;
if (!createDialog "ANC_CargoDialog") exitWith {};
private _d = findDisplay 47101;
private _mk = {
    params ["_cls", "_pos", ["_idc", -1]];
    private _c = _d ctrlCreate [_cls, _idc];
    _c ctrlSetPosition _pos;
    _c ctrlCommit 0;
    _c
};
private _w = safeZoneW * 0.55;
private _h = safeZoneH * 0.58;
private _x0 = safeZoneX + ((safeZoneW - _w) / 2);
private _y0 = safeZoneY + ((safeZoneH - _h) / 2);
private _lineH = 0.035;
private _fH = _lineH * 0.72;
private _acc = ["GUI", "BCG_RGB"] call BIS_fnc_displayColorGet;
// (MK) built into MCC Sandbox MK: styled as MCC MK's own panels (MCCMK_fnc_navalPanel and the others) - a dark panel
// with a plain title, RobotoCondensed text, and MCC's buttons, FLAT or BUTTONS as chosen with the console's cog
// (profileNamespace MCC_consoleButtons: MCC_RscButtonRound / MCC_RscButtonRound3D). 
private _mccUI = isClass (configFile >> "MCC_RscButtonRound");
private _font = ["PuristaMedium", "RobotoCondensed"] select _mccUI;
private _btnCls = if (_mccUI) then {["MCC_RscButtonRound", "MCC_RscButtonRound3D"] select (profileNamespace getVariable ["MCC_consoleButtons", false])} else {"RscButton"};
private _bar = ["RscText", [_x0, _y0, _w, _lineH]] call _mk;
_bar ctrlSetBackgroundColor ([_acc, [0.08, 0.09, 0.1, 0.95]] select _mccUI);
_bar ctrlSetText "  Boat Cargo";
_bar ctrlSetFont "PuristaMedium";	// (MCC MK's panels title in PuristaMedium too)
// (MK) at MCC's own text size (its buttons' size), and never taller than its bar 
_bar ctrlSetFontHeight ((((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8) min (_lineH * 0.9));
private _bg = ["RscText", [_x0, _y0 + _lineH, _w, _h - _lineH]] call _mk;
_bg ctrlSetBackgroundColor ([[0, 0, 0, 0.85], [0.08, 0.09, 0.1, 0.95]] select _mccUI);
private _hint = ["RscText", [_x0 + 0.005, _y0 + _lineH + 0.002, _w - 0.01, _lineH * 0.85]] call _mk;
_hint ctrlSetText "Click an item, then Move 1 or Move all. (Drag or double-click moves one.)";
_hint ctrlSetTextColor [1, 1, 1, 0.6];
_hint ctrlSetFontHeight _fH;
if (_mccUI) then {_hint ctrlSetFont _font};
private _midW = _w * 0.16;
private _colW = (_w - _midW - 0.02) / 2;
private _xA = _x0 + 0.005;
private _xM = _xA + _colW + 0.005;
private _xB = _xM + _midW + 0.005;
private _yT = _y0 + (_lineH * 1.9);
private _tA = ["RscText", [_xA, _yT, _colW, _lineH], 47120] call _mk;
private _tB = ["RscText", [_xB, _yT, _colW, _lineH], 47121] call _mk;
{
	_x ctrlSetBackgroundColor ([[(_acc select 0), (_acc select 1), (_acc select 2), 0.35], [0.22, 0.24, 0.26, 1]] select _mccUI);
	_x ctrlSetFontHeight _fH;
	if (_mccUI) then {_x ctrlSetFont _font};
} forEach [_tA, _tB];
private _yL = _yT + _lineH + 0.004;
private _tallyH = _lineH * 2.3;
private _lH = (_y0 + _h) - _yL - _tallyH - (_lineH * 1.5);
private _lA = ["ANC_RscListBoxDrag", [_xA, _yL, _colW, _lH], 47110] call _mk;
private _lB = ["ANC_RscListBoxDrag", [_xB, _yL, _colW, _lH], 47111] call _mk;
{_x ctrlSetBackgroundColor [0.05, 0.05, 0.05, 0.7]; _x ctrlSetFontHeight _fH; if (_mccUI) then {_x ctrlSetFont _font}} forEach [_lA, _lB];

// the buttons, between the lists: Move 1 / Move all each way; a button's space; Overboard 1 / Overboard all, with a
// note
private _bH = _lineH * 0.95;
private _gap = _lineH * 0.25;
private _colH = (_bH * 7) + (_gap * 5) + (_lineH * 0.6);
private _yB = _yL + (((_lH - _colH) / 2) max 0);
// (MK) MCC's button draws its label low and can't be centred by a setting. In MCC style the label is drawn here instead: a static
// text laid over the button (the click goes through to the button), centred left-right by its alignment and up-down by working out
// the text's height and placing it in the middle. Not MCC style: the button's own text.
private _label = {
    params ["_btn", "_txt"];
    if (!_mccUI) exitWith {_btn ctrlSetText _txt};
    _btn ctrlSetText "";
    (ctrlPosition _btn) params ["_bx", "_by", "_bw", "_bh"];
    private _t = ["RscStructuredText", [_bx, _by, _bw, _bh]] call _mk;
    _t ctrlSetFontHeight _fH;
    // (MK) "<" and ">" written as text, not tags (read as tags, "< Move 1" and "<< Move all" show nothing)
    private _safe = ((_txt regexReplace ["&", "&amp;"]) regexReplace ["<", "&lt;"]) regexReplace [">", "&gt;"];
    _t ctrlSetStructuredText parseText format ["<t align='center' font='RobotoCondensed'>%1</t>", _safe];
    private _th = (ctrlTextHeight _t) min _bh;
    _t ctrlSetPosition [_bx, _by + (((_bh - _th) / 2) max 0), _bw, _th];
    _t ctrlCommit 0;
    _t ctrlEnable false;
    _btn setVariable ["ANC_label", _t];
    _t
};
private _mkBtn = {
    params ["_txt", "_y", "_args", "_code"];
    private _btn = [_btnCls, [_xM, _y, _midW, _bH]] call _mk;
    [_btn, _txt] call _label;
    _btn ctrlSetFontHeight _fH;
    if (!_mccUI) then {_btn ctrlSetBackgroundColor [(_acc select 0), (_acc select 1), (_acc select 2), 0.6]};	// (MCC's button has its own colours)
    _btn setVariable ["ANC_args", _args];
    _btn ctrlAddEventHandler ["ButtonClick", _code];
    _btn
};
private _moveCode = {
    params ["_btn"];
    (_btn getVariable ["ANC_args", [47110, false]]) params ["_fromIdc", "_all"];
    private _l = (ctrlParent _btn) displayCtrl _fromIdc;
    private _sel = lbCurSel _l;
    if (_sel < 0) exitWith {["Click an item in that list first."] call ANC_fnc_notice};
    [_fromIdc, parseNumber (_l lbData _sel), _all] call ANC_cargoSend;
};
private _y = _yB;
{
    _x params ["_txt", "_fromIdc", "_all"];
    [_txt, _y, [_fromIdc, _all], _moveCode] call _mkBtn;
    _y = _y + _bH + _gap + ([0, _gap] select (_forEachIndex == 1));
} forEach [["Move 1  >", 47110, false], ["Move all  >>", 47110, true], ["<  Move 1", 47111, false], ["<<  Move all", 47111, true]];
_y = _y + _bH; // a button's space
// Overboard: the item selected in whichever list you last clicked
private _dumpCode = {
    params ["_btn"];
    (_btn getVariable ["ANC_args", [false]]) params ["_all"];
    private _idc = missionNamespace getVariable ["ANC_cargoLastIdc", -1];
    if !(_idc in [47110, 47111]) exitWith {["Click an item in a list first."] call ANC_fnc_notice};
    private _l = (ctrlParent _btn) displayCtrl _idc;
    private _sel = lbCurSel _l;
    if (_sel < 0) exitWith {["Click an item in a list first."] call ANC_fnc_notice};
    private _rows = [ANC_cargoRowsA, ANC_cargoRowsB] select (_idc == 47111);
    ((_rows param [parseNumber (_l lbData _sel), []])) params [["_label", ""], ["_e", []], ["_n", 1]];
    if (count _e == 0) exitWith {};
    private _boat = [ANC_cargoA, ANC_cargoB] select (_idc == 47111);
    [[_boat, _e, player, [1, _n] select _all], "cargoDump", 2] call ANC_fnc_remote;
};
["Overboard 1", _y, [false], _dumpCode] call _mkBtn;
_y = _y + _bH + _gap;
["Overboard all", _y, [true], _dumpCode] call _mkBtn;
_y = _y + _bH + (_gap * 0.5);
private _irr = ["RscText", [_xM, _y, _midW, _lineH * 0.6]] call _mk;
_irr ctrlSetText "Irretrievable";
_irr ctrlSetTextColor [1, 0.45, 0.4, 0.9];
_irr ctrlSetFontHeight (_fH * 0.8);
if (_mccUI) then {_irr ctrlSetFont _font};

// the tallies of what has gone each way
private _tY = (_y0 + _h) - _tallyH - (_lineH * 1.35);
{
    _x params ["_idc", "_xx"];
    private _tal = ["RscStructuredText", [_xx, _tY, _colW, _tallyH], _idc] call _mk;
    _tal ctrlSetBackgroundColor [0.05, 0.05, 0.05, 0.5];
    _tal ctrlSetFontHeight _fH;
} forEach [[47130, _xA], [47131, _xB]];
// (MK) in from the corner 
private _close = [_btnCls, [_x0 + _w - 0.1 - 0.012, _y0 + _h - _lineH - 0.012, 0.1, _lineH]] call _mk;
[_close, "Close"] call _label;
if (_mccUI) then {_close ctrlSetFontHeight _fH} else {_close ctrlSetBackgroundColor _acc};
_close ctrlAddEventHandler ["ButtonClick", {closeDialog 2}];

// one row (or its whole stack) moved: [from list idc, row index, whole stack]
ANC_cargoSend = {
    params ["_fromIdc", "_row", ["_all", false]];
    private _rows = [ANC_cargoRowsA, ANC_cargoRowsB] select (_fromIdc == 47111);
    (_rows param [_row, []]) params [["_label", ""], ["_e", []], ["_n", 1]];
    if (count _e == 0) exitWith {};
    private _from = [ANC_cargoA, ANC_cargoB] select (_fromIdc == 47111);
    private _to = [ANC_cargoB, ANC_cargoA] select (_fromIdc == 47111);
    [[_from, _to, _e, player, [1, _n] select _all], "cargoMove", 2] call ANC_fnc_remote;
};
{
    _x ctrlAddEventHandler ["LBSelChanged", {params ["_ctrl"]; ANC_cargoLastIdc = ctrlIDC _ctrl}];
    _x ctrlAddEventHandler ["LBDrop", {
        params ["_ctrl", "", "", "_srcIdc", "_info"];
        if (_srcIdc == ctrlIDC _ctrl || {!(_srcIdc in [47110, 47111])}) exitWith {false};
        {[_srcIdc, parseNumber (_x param [2, "-1"])] call ANC_cargoSend} forEach _info;
        true
    }];
    _x ctrlAddEventHandler ["LBDblClick", {
        params ["_ctrl", "_sel"];
        [ctrlIDC _ctrl, parseNumber (_ctrl lbData _sel)] call ANC_cargoSend;
    }];
} forEach [_lA, _lB];
[] call ANC_fnc_cargoRefresh;

// closes if the boats drift apart
[{
    params ["_args", "_h"];
    private _d = findDisplay 47101;
    if (isNull _d) exitWith {[_h] call CBA_fnc_removePerFrameHandler};
    if (isNull ANC_cargoB || {!alive ANC_cargoB} || {!alive ANC_cargoA} || {(([ANC_cargoA, ANC_cargoB] call ANC_fnc_hullGap) select 0) > 20}) then {
        closeDialog 2;
        [_h] call CBA_fnc_removePerFrameHandler;
        ["Boats must be within ten metres to transfer."] call ANC_fnc_notice;
    };
}, 0.5] call CBA_fnc_addPerFrameHandler;
