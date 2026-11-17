disableSerialization;
params [["_title", "", [""]], ["_body", "", [""]], ["_rows", [], [[]]], ["_buttons", [], [[]]], ["_parent", displayNull, [displayNull]]];
if (isNull _parent) then {_parent = findDisplay 46};
private _d = _parent createDisplay "RscDisplayEmpty";
uiNamespace setVariable ["MCCMK_confirmButtons", _buttons];
private _btn = ["MCC_RscButtonRound", "MCC_RscButtonRound3D"] select (profileNamespace getVariable ["MCC_consoleButtons", false]);
private _panW = 0.28 * safezoneW;
private _rowsH = (count _rows) * 0.042 * safezoneH;
private _panH = (0.17 * safezoneH) + _rowsH;
private _panX = safezoneX + (safezoneW - _panW) / 2;
private _panY = safezoneY + (safezoneH - _panH) / 2;
private _pad = 0.012 * safezoneW;
private _mk = {
	params ["_cls", "_cx", "_cy", "_cw", "_ch"];
	private _c = _d ctrlCreate [_cls, -1];
	_c ctrlSetPosition [_panX + _cx, _panY + _cy, _cw, _ch];
	_c ctrlCommit 0;
	_c
};
private _bg = ["RscText", 0, 0, _panW, _panH] call _mk;
_bg ctrlSetBackgroundColor [0.08, 0.09, 0.1, 0.95];
private _ti = ["RscStructuredText", _pad, 0.012 * safezoneH, _panW - 2 * _pad, 0.04 * safezoneH] call _mk;
_ti ctrlSetStructuredText parseText format ["<t size='1.25' font='PuristaMedium'>%1</t>", _title];
private _tx = ["RscStructuredText", _pad, 0.055 * safezoneH, _panW - 2 * _pad, 0.06 * safezoneH] call _mk;
_tx ctrlSetStructuredText parseText format ["<t size='0.95'>%1</t>", _body];
{
	_x params ["_icon", "_colour", "_label", "_cost", "_have"];
	private _ry = (0.122 + _forEachIndex * 0.042) * safezoneH;
	private _pic = ["RscPictureKeepAspect", _pad, _ry, 0.034 * safezoneH * 3 / 4, 0.034 * safezoneH] call _mk;
	_pic ctrlSetText _icon;
	_pic ctrlSetTextColor _colour;
	private _v = ["RscStructuredText", _pad + 0.032 * safezoneH, _ry + 0.002 * safezoneH, _panW - 2 * _pad - 0.032 * safezoneH, 0.034 * safezoneH] call _mk;
	_v ctrlSetStructuredText parseText (if (_have >= 0 && {call MCCMK_fnc_resFree}) then {
		format ["<t size='0.95'>%1: <t color='#ffffff'>%2</t></t>", _label, toString [8734]]
	} else {if (_have < 0) then {
		format ["<t size='0.95'>%1: <t color='#99ff66'>+%2</t></t>", _label, _cost]
	} else {
		format ["<t size='0.95'>%1: <t color='%2'>%3</t>  <t color='#aaaaaa' size='0.85'>(you have %4)</t></t>", _label, ["#ff5555", "#ffffff"] select (_have >= _cost), _cost, _have]
	}});
} forEach _rows;
private _n = (count _buttons) max 1;
private _bw = (_panW - (_n + 1) * _pad) / _n;
{
	_x params ["_label", "_code", ["_enabled", true], ["_tip", ""]];
	private _b = [_btn, _pad + _forEachIndex * (_bw + _pad), _panH - 0.048 * safezoneH, _bw, 0.034 * safezoneH] call _mk;
	_b ctrlSetText _label;
	_b ctrlEnable _enabled;
	if (_tip != "") then {_b ctrlSetTooltip _tip};
	_b setVariable ["MCCMK_btnIndex", _forEachIndex];
	_b ctrlAddEventHandler ["ButtonClick", {
		params ["_c"];
		private _i = _c getVariable ["MCCMK_btnIndex", -1];
		private _code = ((uiNamespace getVariable ["MCCMK_confirmButtons", []]) param [_i, ["", {}]]) param [1, {}];
		(ctrlParent _c) closeDisplay 1;
		[] call _code;
	}];
} forEach _buttons;
_d
