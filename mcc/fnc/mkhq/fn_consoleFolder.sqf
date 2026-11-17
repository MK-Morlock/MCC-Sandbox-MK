/*
	MCCMK_fnc_consoleFolder - the commander console's side panels (CAS 2010, Supply Drop 2020, Evac 2030), one open at a
	time. Opening slides it out to the right and, for CAS and Supply Drop, down as well - CAS to the bottom of the Supply
	Drop slot, Supply Drop to the bottom of the Evac slot - with its background, list and grey arrow bar stretched to the
	new height (anything that reaches its bottom); the slot tabs it covers are hidden while it's open. Closing puts it
	back in its slot at its own size.
	["open" / "close", panel idc]
*/
disableSerialization;
params [["_mode", "close", [""]], ["_idc", 2010, [0]]];
private _d = findDisplay 2993;
if (isNull _d) exitWith {};
private _grp = _d displayCtrl _idc;
if (isNull _grp) exitWith {};
private _tab = _d displayCtrl (_idc - 999);
private _full = createHashMapFromArray [[2010, 0.293 * safezoneH], [2020, 0.324 * safezoneH]];
private _covers = createHashMapFromArray [[2010, [1021]], [2020, [1031]]];	// the slot tabs it covers when open
private _h0 = _grp getVariable ["MCCMK_h0", (ctrlPosition _grp) select 3];
_grp setVariable ["MCCMK_h0", _h0];
private _kids = (allControls _d) select {(ctrlParentControlsGroup _x) isEqualTo _grp};
private _setH = {	// the panel and what reaches its bottom, to height _h
	params ["_h", "_t"];
	{
		private _kp = ctrlPosition _x;
		private _k0 = _x getVariable ["MCCMK_k0", [_kp select 1, _kp select 3]];
		_x setVariable ["MCCMK_k0", _k0];
		if (abs (((_k0 select 0) + (_k0 select 1)) - _h0) < 0.02 * safezoneH) then {
			_kp set [3, (_k0 select 1) + (_h - _h0)];
			_x ctrlSetPosition _kp;
			_x ctrlCommit _t;
		};
	} forEach _kids;
};
if (_mode == "open") then {
	{if (_x != _idc) then {["close", _x] call MCCMK_fnc_consoleFolder}} forEach [2010, 2020, 2030];
	private _h = _full getOrDefault [_idc, _h0];
	[_h, 0.1] call _setH;
	private _gp = ctrlPosition _grp;
	_gp set [2, 0.257813 * safezoneW];
	_gp set [3, _h];
	_grp ctrlSetPosition _gp;
	_grp ctrlCommit 0.1;
	private _tp = ctrlPosition _tab;
	_tp set [2, 0];
	_tab ctrlSetPosition _tp;
	_tab ctrlCommit 0;
	{(_d displayCtrl _x) ctrlShow false} forEach (_covers getOrDefault [_idc, []]);
} else {
	[_h0, 0.1] call _setH;
	private _gp = ctrlPosition _grp;
	_gp set [2, 0];
	_gp set [3, _h0];
	_grp ctrlSetPosition _gp;
	_grp ctrlCommit 0.1;
	private _tp = ctrlPosition _tab;
	_tp set [2, 0.02 * safezoneW];
	_tab ctrlSetPosition _tp;
	_tab ctrlCommit 0;
	{(_d displayCtrl _x) ctrlShow true} forEach (_covers getOrDefault [_idc, []]);
};
