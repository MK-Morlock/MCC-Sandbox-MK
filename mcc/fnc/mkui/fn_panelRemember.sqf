disableSerialization;
params [["_mode", "restore", [""]]];
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
private _skip = [25, 26, 40, 41, 42, 43, 44, 45, 1038, 1044, 1045, 1054, 1055, 1058, 1061, 1064];
private _mem = uiNamespace getVariable ["MCCMK_panelMem", createHashMap];
uiNamespace setVariable ["MCCMK_panelMem", _mem];
private _inSpawn = {
	params ["_c"];
	private _p = ctrlParentControlsGroup _c;
	private _in = false;
	while {!_in && {!isNull _p}} do {if (ctrlIDC _p == 506) then {_in = true}; _p = ctrlParentControlsGroup _p};
	_in
};
private _combos = (allControls _d) select {ctrlType _x == 4 && {!isNull (ctrlParentControlsGroup _x)} && {!((ctrlIDC _x) in _skip)} && {(ctrlIDC _x) >= 0} && {!([_x] call _inSpawn)}};
if (_mode == "init") exitWith {
	{
		if !(_x getVariable ["MCCMK_remember", false]) then {
			_x setVariable ["MCCMK_remember", true];
			_x ctrlAddEventHandler ["MouseButtonDown", {uiNamespace setVariable ["MCCMK_userCombo", [ctrlIDC (_this select 0), diag_tickTime]]}];
			_x ctrlAddEventHandler ["LBSelChanged", {
				params ["_c", "_i"];
				(uiNamespace getVariable ["MCCMK_userCombo", [-1, -100]]) params ["_ui", "_ut"];
				if (_i >= 0 && {((focusedCtrl (ctrlParent _c)) isEqualTo _c) || {_ui == ctrlIDC _c && {diag_tickTime - _ut < 10}}}) then {(uiNamespace getVariable ["MCCMK_panelMem", createHashMap]) set [ctrlIDC _c, _c lbText _i]};
			}];
		};
	} forEach _combos;
};
sleep 0.5;
private _shown = {
	params ["_c"];
	private _v = ctrlShown _c;
	private _p = ctrlParentControlsGroup _c;
	while {_v && {!isNull _p}} do {_v = ctrlShown _p; _p = ctrlParentControlsGroup _p};
	_v
};
private _list = _combos select {([_x] call _shown) && {!(_x getVariable ["MCC_comboRemember", false])}};
_list = [_list, [], {(ctrlPosition _x) select 1}, "ASCEND"] call BIS_fnc_sortBy;
{
	private _want = if (isNull _x) then {""} else {_mem getOrDefault [ctrlIDC _x, ""]};
	if (_want != "" && {(_x lbText (lbCurSel _x)) != _want}) then {
		private _i = -1;
		for "_k" from 0 to ((lbSize _x) - 1) do {if ((_x lbText _k) == _want) exitWith {_i = _k}};
		if (_i >= 0) then {_x lbSetCurSel _i; sleep 0.15};
	};
} forEach _list;
