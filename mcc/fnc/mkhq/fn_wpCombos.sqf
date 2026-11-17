params ["_mode", "_a"];
if (_mode == "read") exitWith {
	_a params ["_c", "_same"];
	private _i = lbCurSel _c;
	private _d = _c lbData _i;
	if (_i < 0 || {_i == (_c getVariable ["MCCMK_wpOpen", -1])} || {_d == ""}) exitWith {_same};
	_d
};
if (_mode == "readFly") exitWith {
	_a params ["_c"];
	private _i = lbCurSel _c;
	if (_i < 0 || {_i == (_c getVariable ["MCCMK_wpOpen", -1])}) exitWith {0};
	_c lbValue _i
};
_a params ["_c", "_kind", ["_groups", []], ["_pre", ""]];
private _mkCase = {(_this select [0, 1]) + (toLower (_this select [1]))};
if (isNull _c) exitWith {};
_groups = _groups select {!isNull _x && {!isNull (leader _x)}};
lbClear _c;
private _sel = -1;
if (_kind == "fly") exitWith {
	private _air = _groups select {(vehicle (leader _x)) isKindOf "Air"};
	private _cur = _air apply {(vehicle (leader _x)) getVariable ["MCCMK_flyH", 100]};
	_cur = _cur arrayIntersect _cur;
	if (_cur isEqualTo []) then {_cur = [100]};
	private _list = +(missionNamespace getVariable ["MCC_evacFlyInHight_array", []]);
	if ((count _cur) == 1 && {(_list findIf {(_x select 1) == (_cur select 0)}) < 0}) then {_list pushBack [format ["%1m", _cur select 0], _cur select 0]};
	if ((count _cur) > 1) then {
		private _i = _c lbAdd (_pre + "Mixed");
		_c lbSetValue [_i, 0];
		_sel = _i;
	};
	{
		_x params ["_n", "_v"];
		private _i = _c lbAdd (_pre + _n + (["", " (D)"] select (_v == 100)));
		_c lbSetValue [_i, _v];
		if ((count _cur) == 1 && {(_cur select 0) == _v}) then {_sel = _i};
	} forEach _list;
	_c lbSetCurSel (_sel max 0);
	_c setVariable ["MCCMK_wpOpen", _sel max 0];
};
private _vals = [];
private _def = "";
private _cur = [];
switch (_kind) do {
	case "formation": {
		_vals = ["COLUMN", "STAG COLUMN", "WEDGE", "ECH LEFT", "ECH RIGHT", "VEE", "LINE", "FILE", "DIAMOND"];
		_def = "WEDGE";
		_cur = _groups apply {formation _x};
	};
	case "speed": {
		_vals = ["LIMITED", "NORMAL", "FULL"];
		_def = "NORMAL";
		_cur = _groups apply {speedMode _x};
	};
	default {
		_vals = ["CARELESS", "SAFE", "AWARE", "COMBAT", "STEALTH"];
		_def = "AWARE";
		_cur = _groups apply {behaviour (leader _x)};
	};
};
_cur = (_cur apply {toUpper _x}) select {_x in _vals};
_cur = _cur arrayIntersect _cur;
if (_cur isEqualTo []) then {_cur = [_def]};
if ((count _cur) > 1) then {
	private _i = _c lbAdd "Mixed";
	_c lbSetData [_i, ""];
	_sel = _i;
};
{
	private _i = _c lbAdd ((_x call _mkCase) + (["", " (D)"] select (_x == _def)));
	_c lbSetData [_i, _x];
	if ((count _cur) == 1 && {(_cur select 0) == _x}) then {_sel = _i};
} forEach _vals;
_c lbSetCurSel (_sel max 0);
_c setVariable ["MCCMK_wpOpen", _sel max 0];
