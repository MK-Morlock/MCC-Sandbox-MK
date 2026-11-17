params [["_d", displayNull, [displayNull]]];
if (isNull _d) exitWith {};
private _wc = _d displayCtrl 9158;
private _fc = _d displayCtrl 9166;
private _sc = _d displayCtrl 9167;
private _bc = _d displayCtrl 9168;
private _lc = _d displayCtrl 9207;
private _cc = _d displayCtrl 9208;
private _llc = _d displayCtrl 9209;
private _lcb = _d displayCtrl 9210;
if (isNull _wc || {isNull _fc}) exitWith {};
private _mkWas = _fc getVariable ["MCCMK_wpReal", false];
_fc setVariable ["MCCMK_wpReal", false];
(ctrlPosition _bc) params ["_bx", "_by", "_bw", "_bh"];
(ctrlPosition _sc) params ["_sx", "_sy", "_sw", "_sh"];
private _full = 0.14 * safezoneW;
private _cw = 0.0105 * safezoneW;
private _chh = 0.018 * safezoneH;
private _tw = 0.036 * safezoneW;
private _wt = _wc lbValue (lbCurSel _wc);
private _isHalo = _wt == 25;
private _isPara = _wt == 26;
(_d displayCtrl 9219) ctrlShow ((uiNamespace getVariable ["MCCMK_ccFlyOn", false]) && {!(_wt in [25, 26, 27, 28, 29, 30, 31, 34])});
private _fnc_box = {
	params ["_cb", "_x0", "_y0", "_h0", "_lab", "_box"];
	_cb ctrlSetPosition [_x0, _y0, _full - _cw - _tw - 0.006 * safezoneW, _h0];
	_lab ctrlSetPosition [_x0 + _full - _cw - _tw - 0.003 * safezoneW, _y0, _tw, _h0];
	_box ctrlSetPosition [_x0 + _full - _cw, _y0 + (_h0 - _chh) / 2, _cw, _chh];
	{_x ctrlCommit 0; _x ctrlShow true} forEach [_cb, _lab, _box];
};
private _fnc_wide = {
	{
		_x params ["_cb", "_h0", "_w0"];
		if (_h0 > 0 && {_w0 < (_full - 0.001)}) then {
			(ctrlPosition _cb) params ["_x0", "_y0"];
			_cb ctrlSetPosition [_x0, _y0, _full, _h0];
			_cb ctrlCommit 0;
		};
	} forEach [[_bc, _bh, _bw], [_sc, _sh, _sw]];
};
// (MK) Pod drop / Winch drop: the drop flies itself - no formation, speed or behaviour to choose
//(MK) Fast-rope (30) too
if (_wt in [28, 29]) exitWith {{_x ctrlShow false} forEach [_fc, _sc, _bc, _lc, _cc, _llc, _lcb]};
//(MK) Fast-rope (30) and Rope extraction (31): the one thing to choose is the Hover height (the first box) - above the
// ground, or the top of whatever is on the spot; 20 m to start with, the last one chosen after that. It goes to everyone
// as MCCMK_wpHover (MCCMK_fnc_fastRopeRun, MCCMK_fnc_ropeExtract read it).
if (_wt in [30, 31]) exitWith {
	{_x ctrlShow false} forEach [_sc, _bc, _lc, _cc, _llc, _lcb];
	_fc ctrlShow true;
	lbClear _fc;
	{private _i = _fc lbAdd format ["Hover height: %1 m", _x]; _fc lbSetValue [_i, _x]} forEach [5, 10, 15, 20, 25, 30, 40, 50];
	private _sel = ((profileNamespace getVariable ["MCCMK_wpHoverSel", 3]) max 0) min 7;
	_fc lbSetCurSel _sel;
	missionNamespace setVariable ["MCCMK_wpHover", _fc lbValue _sel, true];
	if !(_fc getVariable ["MCCMK_hoverEH", false]) then {
		_fc setVariable ["MCCMK_hoverEH", true];
		_fc ctrlAddEventHandler ["LBSelChanged", {
			params ["_c", "_i"];
			private _w = (ctrlParent _c) displayCtrl 9158;
			if (_i >= 0 && {(_w lbValue (lbCurSel _w)) in [30, 31]}) then {
				profileNamespace setVariable ["MCCMK_wpHoverSel", _i];
				missionNamespace setVariable ["MCCMK_wpHover", _c lbValue _i, true];
			};
		}];
	};
};
{_x ctrlShow true} forEach [_fc, _sc, _bc];
lbClear _fc;
if (_isHalo || _isPara) then {
	private _grps = (missionNamespace getVariable ["MCC_ConsoleGroupSelected", []]) select {!isNull _x};
	private _men = 0;
	{_men = _men + count (units _x)} forEach _grps;
	private _fac = if (count _grps > 0) then {faction leader (_grps select 0)} else {faction player};
	private _key = format [["MCC_ccParaAir_%1", "MCC_ccHaloPlanes_%1"] select _isHalo, playerSide];
	private _list = uiNamespace getVariable [_key, []];
	if (_list isEqualTo []) then {
		private _sideN = [east, west, resistance, civilian] find playerSide;
		isNil {	//(MK) the side's aircraft only (it searched every class in the game), in one go
		{
			private _cl = configName _x;
			if (((_cl isKindOf "Plane") || {!_isHalo && {_cl isKindOf "Helicopter"}}) && {getNumber (_x >> "side") == _sideN} && {getNumber (_x >> "isUav") == 0} && {([_cl, "allCargo"] call MCC_fnc_crewCount) > 0}) then {
				_list pushBack [_cl, format ["%1 (%2)", getText (_x >> "displayName"), getText (configFile >> "CfgFactionClasses" >> getText (_x >> "faction") >> "displayName")], getText (_x >> "picture")];
			};
		} forEach (format ["getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'side') == %1} && {(configName _x) isKindOf 'Air'}", _sideN] configClasses (configFile >> "CfgVehicles"));
		};
		_list = [_list, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy;
		uiNamespace setVariable [_key, _list];
	};
	private _auto = if (_isHalo) then {[_fac, playerSide, [_men, 8] select (_men == 0)] call MCC_fnc_haloAutoLabel} else {
		private _pc = [_fac, playerSide, (16 min _men) max 1] call MCC_fnc_paraAutoAircraft;
		format ["%1 (Auto)", getText (configFile >> "CfgVehicles" >> _pc >> "displayName")]
	};
	private _i = _fc lbAdd _auto;
	_fc lbSetData [_i, ""];
	{
		_x params ["_cl", "_nm", "_pic"];
		_i = _fc lbAdd _nm;
		_fc lbSetData [_i, _cl];
		if (_pic != "") then {_fc lbSetPicture [_i, _pic]};
	} forEach _list;
	private _pre = ["MCC_ccPara", "MCC_ccHalo"] select _isHalo;
	[_fc, _pre + "Aircraft"] call MCC_fnc_consoleListMemory;
	lbClear _sc;
	{private _k = _sc lbAdd format ["AI open: %1 m", _x]; _sc lbSetValue [_k, _x]} forEach [75, 100, 120, 150, 175, 200];
	if ((profileNamespace getVariable [_pre + "AIHeight", ""]) == "") then {profileNamespace setVariable [_pre + "AIHeight", "AI open: 120 m"]};
	[_sc, _pre + "AIHeight"] call MCC_fnc_consoleListMemory;
	lbClear _bc;
	{_bc lbAdd _x} forEach ["Chute: Auto", "Chute: Manual"];
	[_bc, _pre + "Chute"] call MCC_fnc_consoleListMemory;
	if (_isHalo) then {
		if (_bh > 0) then {[_bc, _bx, _by, _bh, _lc, _cc] call _fnc_box};
		if (_sh > 0) then {[_sc, _sx, _sy, _sh, _llc, _lcb] call _fnc_box};
		_cc cbSetChecked (profileNamespace getVariable ["MCC_ccHaloForm", true]);
		_lcb cbSetChecked (profileNamespace getVariable ["MCC_ccHaloLead", true]);
		_lcb ctrlEnable !(cbChecked _cc);
	} else {
		{_x ctrlShow false} forEach [_lc, _cc, _llc, _lcb];
		call _fnc_wide;
	};
} else {
	if (!_mkWas) then {
		private _mkG = missionNamespace getVariable ["MCC_ConsoleGroupSelected", []];
		["fill", [_fc, "formation", _mkG]] call MCCMK_fnc_wpCombos;
		["fill", [_sc, "speed", _mkG]] call MCCMK_fnc_wpCombos;
		["fill", [_bc, "behaviour", _mkG]] call MCCMK_fnc_wpCombos;
	};
	_fc setVariable ["MCCMK_wpReal", true];
	{_x ctrlShow false} forEach [_lc, _cc, _llc, _lcb];
	call _fnc_wide;
};
