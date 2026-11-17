/*
	MCCMK_fnc_rtsGroupPanel  (client) - the RTS groups panel, top left of the RTS screen.
	Tabs: All, Infantry, Vehicles, Air, Naval; the arrow on the right folds the whole panel to its tab bar (a tab opens
	it again). Sections: Infantry, Vehicles, Support, Air, Boats, Ships - each ship a row of its own (single click: the
	camera views the ship; the red icon: sell it) with its weapons beneath. Group rows: symbol, name, health (green) and
	fuel (white, vehicles) or ammunition (amber, ship weapons); single click selects the group and flies the camera to
	it. Double click a heading or a ship to fold it (or click its arrow). Every click redraws at once; the bars refresh
	every second. Tab, folded panel and folds are remembered per player.
*/
disableSerialization;
private _d = uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", displayNull];
if (isNull _d) exitWith {};
{ctrlDelete _x} forEach (uiNamespace getVariable ["MCCMK_gpAll", []]);
MCCMK_gpRun = (missionNamespace getVariable ["MCCMK_gpRun", 0]) + 1;
private _run = MCCMK_gpRun;
MCCMK_gpW = 0.18 * safezoneW;
MCCMK_gpRowH = 0.022 * safezoneH;
MCCMK_gpTabH = 0.028 * safezoneH;
MCCMK_gpMaxH = 0.56 * safezoneH;
MCCMK_gpFs = ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.8;
MCCMK_gpLastKey = "";
MCCMK_gpLastT = 0;
private _grp = _d ctrlCreate ["RscControlsGroupNoScrollbars", -1];
_grp ctrlSetPosition [safezoneX + 0.008 * safezoneW, safezoneY + 0.0083 * safezoneH, MCCMK_gpW, MCCMK_gpTabH];
_grp ctrlCommit 0;
private _bg = _d ctrlCreate ["RscText", -1, _grp];
_bg ctrlSetBackgroundColor [0.055, 0.063, 0.07, 0.86];
_bg ctrlSetPosition [0, 0, MCCMK_gpW, MCCMK_gpTabH];
_bg ctrlCommit 0;
private _line = _d ctrlCreate ["RscText", -1, _grp];
_line ctrlSetPosition [0, MCCMK_gpTabH - pixelH, MCCMK_gpW, pixelH];
_line ctrlSetBackgroundColor [1, 1, 1, 0.12];
_line ctrlCommit 0;
private _tabs = [];
{
	private _t = _d ctrlCreate ["MCCMK_RscRowItem", -1, _grp];
	_t ctrlSetPosition [0.003 * safezoneW + _forEachIndex * 0.031 * safezoneW, 0.002 * safezoneH, 0.031 * safezoneW, MCCMK_gpTabH - 0.004 * safezoneH];
	_t ctrlSetFontHeight MCCMK_gpFs;
	_t ctrlSetText _x;
	_t setVariable ["MCCMK_tab", _forEachIndex];
	_t ctrlAddEventHandler ["ButtonClick", {
		params ["_c"];
		profileNamespace setVariable ["MCCMK_rtsGrpTab", _c getVariable ["MCCMK_tab", 0]];
		profileNamespace setVariable ["MCCMK_rtsGrpCollapsed", false];
		[] call MCCMK_gpRebuild;
	}];
	_t ctrlCommit 0;
	_tabs pushBack _t;
} forEach ["All", "Infantry", "Vehicles", "Air", "Naval"];
private _arrow = _d ctrlCreate ["RscActivePicture", -1, _grp];
_arrow ctrlSetPosition [MCCMK_gpW - 0.016 * safezoneW, 0.007 * safezoneH, 0.010 * safezoneW, 0.014 * safezoneH];
_arrow ctrlSetText "\a3\ui_f\data\gui\rsccommon\rsccombo\arrow_combo_ca.paa";
_arrow ctrlSetTextColor [0.78, 0.8, 0.82, 1];
_arrow ctrlSetActiveColor [1, 1, 1, 1];
_arrow ctrlSetTooltip "Fold / unfold the groups list";
_arrow ctrlAddEventHandler ["ButtonClick", {
	profileNamespace setVariable ["MCCMK_rtsGrpCollapsed", !(profileNamespace getVariable ["MCCMK_rtsGrpCollapsed", false])];
	[] call MCCMK_gpRebuild;
}];
_arrow ctrlCommit 0;
private _body = _d ctrlCreate ["RscControlsGroup", -1, _grp];
_body ctrlSetPosition [0, MCCMK_gpTabH, MCCMK_gpW, 0];
_body ctrlCommit 0;
uiNamespace setVariable ["MCCMK_gpAll", [_grp]];
uiNamespace setVariable ["MCCMK_gpCtrls", [_grp, _bg, _body, _arrow, _tabs]];

// every group of the player's side, with its section (ship weapons: under their ship)
MCCMK_gpScan = {
	private _weap = createHashMap;
	{private _s = _x; {if (!isNull _x) then {_weap set [hashValue _x, _s]}} forEach (_s getVariable ["MCCMK_weapons", []])} forEach (missionNamespace getVariable ["MCC_staticShips", []]);
	private _items = [];
	{
		_x params ["_ic", "_g"];
		if (!isNull _g && {(count units _g) > 0} && {alive leader _g}) then {
			private _ship = _weap getOrDefault [hashValue (vehicle (leader _g)), objNull];
			private _sec = "ships";
			if (isNull _ship) then {
				_g setVariable ["MCCMK_shipWpn", false];
				// [infantry, mechanised, armour, air, naval, recon, support, autonomous] - as the group icons use
				private _c = [_g] call MCC_fnc_countGroupHC;
				if (isNil "_c" || {!(_c isEqualType [])} || {count _c < 8}) then {_c = [0, 0, 0, 0, 0, 0, 0, 0]};
				_sec = switch (true) do {
					case ((_c select 3) > 0): {"air"};
					case ((_c select 4) > 0): {"boats"};
					case ((_c select 6) > 0 || {(_c select 7) > 0}): {"support"};
					case ((_c select 1) > 0 || {(_c select 2) > 0}): {"vehicles"};
					default {"infantry"};
				};
			} else {_g setVariable ["MCCMK_shipWpn", true]};
			_items pushBack [_g, _sec, _ship, _ic];
		};
	} forEach (missionNamespace getVariable ["MCC_rtsUIGroupsIcons", []]);
	// ships with no weapon groups still get a row (to view or sell them)
	{
		private _s = _x;
		if (!isNull _s && {(_s getVariable ["MCC_side", sideUnknown]) isEqualTo playerSide} && {(_items findIf {(_x select 2) isEqualTo _s}) < 0}) then {_items pushBack [grpNull, "ships", _s, controlNull]};
	} forEach (missionNamespace getVariable ["MCC_staticShips", []]);
	MCCMK_gpItems = _items;
	_items
};

MCCMK_gpFly = {
	params ["_o", ["_dist", 60], ["_h", -1]];
	private _cam = missionNamespace getVariable ["MCC_CONST_CAM", objNull];
	if (isNull _cam || {isNull _o}) exitWith {};
	private _height = if (_h < 0) then {((getPos _cam) select 2) max 40} else {_h};
	private _p = _o getPos [_dist, (getDir _o) + 180];
	_p set [2, _height];
	_cam setPos _p;
	_cam camSetTarget _o;
	_cam camCommit 0;
	_cam camSetTarget objNull;
	_cam camCommit 0;
};

MCCMK_gpFold = {
	params ["_key"];
	private _f = +(profileNamespace getVariable ["MCCMK_rtsGrpFold", []]);
	if (_key in _f) then {_f deleteAt (_f find _key)} else {_f pushBack _key};
	profileNamespace setVariable ["MCCMK_rtsGrpFold", _f];
	[] call MCCMK_gpRebuild;
};

MCCMK_gpClick = {
	params ["_c"];
	(_c getVariable ["MCCMK_row", []]) params [["_kind", ""], ["_key", ""], ["_obj", objNull], ["_ic", controlNull]];
	private _now = diag_tickTime;
	private _dbl = (MCCMK_gpLastKey isEqualTo _key) && {(_now - MCCMK_gpLastT) < 0.4};
	MCCMK_gpLastKey = _key;
	MCCMK_gpLastT = [_now, 0] select _dbl;
	switch (_kind) do {
		case "head": {if (_dbl) then {[_key] call MCCMK_gpFold}};
		case "ship": {
			if (_dbl) exitWith {[_key] call MCCMK_gpFold};
			MCCMK_gpShipSel = _obj;
			private _half = (([_obj getVariable ["MCC_ShipType", 0]] call MCCMK_fnc_shipCfg) select 3);
			[_obj, ((_half select 1) * 1.6) + 40, ((_half select 1) * 0.8) + 40] call MCCMK_gpFly;
			[] call MCCMK_gpBars;
		};
		case "group": {
			MCCMK_gpShipSel = objNull;
			if (!isNull _ic) then {[_ic, 0] call MCC_fnc_rtsSelectGroup};
			if (!isNull _obj) then {[vehicle (leader _obj), 60] call MCCMK_gpFly};
			[] call MCCMK_gpBars;
		};
	};
};

MCCMK_gpRebuild = {
	disableSerialization;
	private _d = uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", displayNull];
	(uiNamespace getVariable ["MCCMK_gpCtrls", []]) params [["_grp", controlNull], ["_bg", controlNull], ["_body", controlNull], ["_arrow", controlNull], ["_tabs", []]];
	if (isNull _d || {isNull _body}) exitWith {};
	private _items = missionNamespace getVariable ["MCCMK_gpItems", []];
	private _tab = ((profileNamespace getVariable ["MCCMK_rtsGrpTab", 0]) max 0) min 4;
	private _coll = profileNamespace getVariable ["MCCMK_rtsGrpCollapsed", false];
	private _folds = profileNamespace getVariable ["MCCMK_rtsGrpFold", []];
	// tabs: each sized to its own text, evenly spaced
	private _tx = 0.004 * safezoneW;
	{
		private _lbl = if (_forEachIndex == 0) then {format ["All %1", {!isNull (_x select 0)} count _items]} else {["", "Infantry", "Vehicles", "Air", "Naval"] select _forEachIndex};
		_x ctrlSetText _lbl;
		_x ctrlSetTextColor ([[0.6, 0.63, 0.66, 1], [0.81, 0.9, 0.74, 1]] select (_forEachIndex == _tab));
		private _tw = (ctrlTextWidth _x) + 0.006 * safezoneW;
		_x ctrlSetPosition [_tx, 0.002 * safezoneH, _tw, MCCMK_gpTabH - 0.004 * safezoneH];
		_x ctrlCommit 0;
		_tx = _tx + _tw + 0.004 * safezoneW;
	} forEach _tabs;
	_arrow ctrlSetAngle [[180, 0] select _coll, 0.5, 0.5];
	{ctrlDelete _x} forEach ((allControls _d) select {(ctrlParentControlsGroup _x) isEqualTo _body});
	private _W = MCCMK_gpW;
	private _rh = MCCMK_gpRowH;
	private _y = 0;
	private _rows = [];
	private _arrowCtl = {
		params ["_ind", "_key", "_folded"];
		private _a = _d ctrlCreate ["RscActivePicture", -1, _body];
		_a ctrlSetPosition [_ind, _y + 0.005 * safezoneH, 0.008 * safezoneW, 0.012 * safezoneH];
		_a ctrlSetText "\a3\ui_f\data\gui\rsccommon\rsccombo\arrow_combo_ca.paa";
		_a ctrlSetTextColor [0.6, 0.63, 0.66, 1];
		_a ctrlSetActiveColor [1, 1, 1, 1];
		_a ctrlSetAngle [[0, 270] select _folded, 0.5, 0.5];
		_a setVariable ["MCCMK_key", _key];
		_a ctrlAddEventHandler ["ButtonClick", {[(_this select 0) getVariable ["MCCMK_key", ""]] call MCCMK_gpFold}];
		_a ctrlCommit 0;
	};
	private _rowCtl = {
		params ["_ind", "_txt", "_pic", "_picCol", "_txtCol", "_data", ["_textW", -1]];
		private _hl = _d ctrlCreate ["RscText", -1, _body];
		_hl ctrlSetPosition [0, _y, _W, _rh];
		_hl ctrlSetBackgroundColor [0, 0, 0, 0];
		_hl ctrlCommit 0;
		private _tx = _ind;
		if (_pic != "") then {
			private _p = _d ctrlCreate ["RscPicture", -1, _body];
			_p ctrlSetPosition [_ind, _y + 0.003 * safezoneH, 0.011 * safezoneW, _rh - 0.006 * safezoneH];
			_p ctrlSetText _pic;
			_p ctrlSetTextColor _picCol;
			_p ctrlCommit 0;
			_tx = _ind + 0.013 * safezoneW;
		};
		private _b = _d ctrlCreate ["MCCMK_RscRowItem", -1, _body];
		_b ctrlSetPosition [_tx, _y, [_W - _tx - 0.004 * safezoneW, _textW] select (_textW > 0), _rh];
		_b ctrlSetFontHeight MCCMK_gpFs;
		_b ctrlSetText _txt;
		_b ctrlSetTextColor _txtCol;
		_b setVariable ["MCCMK_row", _data];
		_b ctrlAddEventHandler ["ButtonClick", {_this call MCCMK_gpClick}];
		_b ctrlCommit 0;
		_hl
	};
	private _iconOf = {params ["_g"]; getText (configFile >> "CfgMarkers" >> (([_g] call MCC_fnc_getGroupIconData) param [2, "b_inf"]) >> "icon")};
	private _labels = [["infantry", "INFANTRY"], ["vehicles", "VEHICLES"], ["support", "SUPPORT"], ["air", "AIR"], ["boats", "BOATS"], ["ships", "SHIPS"]];
	private _tabSecs = [["infantry", "vehicles", "support", "air", "boats", "ships"], ["infantry"], ["vehicles", "support"], ["air"], ["boats", "ships"]] select _tab;
	if (!_coll) then {
		{
			_x params ["_key", "_lbl"];
			private _in = _items select {(_x select 1) == _key};
			if (_key in _tabSecs && {count _in > 0}) then {
				private _fold = _key in _folds;
				private _cnt = if (_key == "ships") then {count ((_in apply {_x select 2}) arrayIntersect (_in apply {_x select 2}))} else {count _in};
				[0.004 * safezoneW, _key, _fold] call _arrowCtl;
				[0.014 * safezoneW, format ["%1   %2", _lbl, _cnt], "", [], [0.6, 0.63, 0.66, 1], ["head", _key]] call _rowCtl;
				_y = _y + _rh;
				if (!_fold) then {
					if (_key == "ships") then {
						private _ships = (_in apply {_x select 2}) arrayIntersect (_in apply {_x select 2});
						{
							private _s = _x;
							private _sk = format ["ship:%1", (missionNamespace getVariable ["MCC_staticShips", []]) find _s];
							private _sf = _sk in _folds;
							private _wl = _in select {((_x select 2) isEqualTo _s) && {!isNull (_x select 0)}};
							private _nm = _s getVariable ["MCC_LHDDisplayName", ["Destroyer", "Aircraft carrier", "Submarine", "LHD"] param [_s getVariable ["MCC_ShipType", 0], "Ship"]];
							if (count _wl > 0) then {[0.012 * safezoneW, _sk, _sf] call _arrowCtl};
							private _hl = [0.022 * safezoneW, format ["%1  (%2 weapons)", _nm, count _wl], "\a3\ui_f\data\igui\cfg\simpleTasks\types\boat_ca.paa", [0.42, 0.66, 1, 1], [0.86, 0.87, 0.89, 1], ["ship", _sk, _s], _W - 0.022 * safezoneW - 0.034 * safezoneW] call _rowCtl;
							private _sell = _d ctrlCreate ["RscActivePicture", -1, _body];
							_sell ctrlSetPosition [_W - 0.02 * safezoneW, _y + 0.002 * safezoneH, 0.014 * safezoneW, _rh - 0.004 * safezoneH];
							_sell ctrlSetText ((missionNamespace getVariable ["MCC_path", "\mcc_sandbox_mod\"]) + "mcc\rts\data\shipSell.paa");
							_sell ctrlSetTextColor [1, 1, 1, 0.9];
							_sell ctrlSetActiveColor [1, 1, 1, 1];
							_sell ctrlSetTooltip format ["Sell the %1", _nm];
							_sell setVariable ["MCCMK_ship", _s];
							_sell ctrlAddEventHandler ["ButtonClick", {[(_this select 0) getVariable ["MCCMK_ship", objNull]] call MCCMK_fnc_shipSellConfirm}];
							_sell ctrlCommit 0;
							_rows pushBack [grpNull, "shiprow", _hl, _y, controlNull, controlNull, _s];
							_y = _y + _rh;
							if (!_sf) then {
								{
									_x params ["_g", "_sec", "", "_ic"];
									private _hl2 = [0.032 * safezoneW, groupId _g, [_g] call _iconOf, (side _g) call BIS_fnc_sideColor, [0.80, 0.81, 0.83, 1], ["group", str _g, _g, _ic], _W - 0.032 * safezoneW - 0.056 * safezoneW] call _rowCtl;
									_rows pushBack [_g, _sec, _hl2, _y];
									_y = _y + _rh;
								} forEach _wl;
							};
						} forEach _ships;
					} else {
						{
							_x params ["_g", "_sec", "", "_ic"];
							private _hl = [0.016 * safezoneW, groupId _g, [_g] call _iconOf, (side _g) call BIS_fnc_sideColor, [0.80, 0.81, 0.83, 1], ["group", str _g, _g, _ic], _W - 0.016 * safezoneW - 0.056 * safezoneW] call _rowCtl;
							_rows pushBack [_g, _sec, _hl, _y];
							_y = _y + _rh;
						} forEach _in;
					};
				};
			};
		} forEach _labels;
	};
	{
		_x params ["_g", "_sec", "_hl", "_ry"];
		if (!isNull _g) then {
			private _b1 = _d ctrlCreate ["RscProgress", -1, _body];
			_b1 ctrlSetPosition [_W - 0.05 * safezoneW, _ry + 0.007 * safezoneH, 0.044 * safezoneW, 0.004 * safezoneH];
			_b1 ctrlSetTextColor [0.25, 0.85, 0.4, 0.95];
			_b1 ctrlCommit 0;
			private _b2 = _d ctrlCreate ["RscProgress", -1, _body];
			_b2 ctrlSetPosition [_W - 0.05 * safezoneW, _ry + 0.013 * safezoneH, 0.044 * safezoneW, 0.003 * safezoneH];
			_b2 ctrlCommit 0;
			_x set [4, _b1];
			_x set [5, _b2];
		};
	} forEach _rows;
	uiNamespace setVariable ["MCCMK_gpRows", _rows];
	private _h = if (_coll) then {0} else {_y min MCCMK_gpMaxH};
	_bg ctrlSetPosition [0, 0, _W, MCCMK_gpTabH + _h];
	_bg ctrlCommit 0;
	_body ctrlSetPosition [0, MCCMK_gpTabH, _W, _h];
	_body ctrlCommit 0;
	_grp ctrlSetPosition [safezoneX + 0.008 * safezoneW, safezoneY + 0.0083 * safezoneH, _W, MCCMK_gpTabH + _h];
	_grp ctrlCommit 0;
	[] call MCCMK_gpBars;
};

MCCMK_gpBars = {
	disableSerialization;
	private _sel = missionNamespace getVariable ["MCC_ConsoleGroupSelected", []];
	{
		_x params ["_g", "_sec", "_hl", "_ry", ["_b1", controlNull], ["_b2", controlNull], ["_s", objNull]];
		if (_sec == "shiprow") then {
			_hl ctrlSetBackgroundColor ([[0, 0, 0, 0], [0.56, 0.75, 0.42, 0.16]] select (!isNull _s && {_s isEqualTo (missionNamespace getVariable ["MCCMK_gpShipSel", objNull])}));
		} else {
			if (!isNull _g && {!isNull _b1}) then {
				private _u = units _g;
				private _dm = 0;
				{_dm = _dm + damage (vehicle _x)} forEach _u;
				_b1 progressSetPosition (1 - (_dm / ((count _u) max 1)));
				private _v = vehicle (leader _g);
				private _two = -1;
				if (_sec == "ships") then {
					private _have = 0;
					private _max = 0;
					{_have = _have + (_x select 2); _max = _max + getNumber (configFile >> "CfgMagazines" >> (_x select 0) >> "count")} forEach (magazinesAllTurrets _v);
					_two = if (_max > 0) then {_have / _max} else {0};
					_b2 ctrlSetTextColor [0.95, 0.7, 0.25, 0.9];
				} else {
					if (_v != leader _g) then {_two = fuel _v; _b2 ctrlSetTextColor [1, 1, 1, 0.8]};
				};
				_b2 ctrlShow (_two >= 0);
				if (_two >= 0) then {_b2 progressSetPosition _two};
				_hl ctrlSetBackgroundColor ([[0, 0, 0, 0], [0.56, 0.75, 0.42, 0.16]] select ((_g in _sel) || {_g getVariable ["MCC_rtsHighlightedGroup", false]}));
			};
		};
	} forEach (uiNamespace getVariable ["MCCMK_gpRows", []]);
};

// keep it current: the list when groups change (at once), the bars every second
private _sig = [];
private _tick = 0;
while {!isNull _d && {!isNull _grp} && {MCCMK_gpRun == _run}} do {
	private _items = call MCCMK_gpScan;
	private _now = _items apply {[_x select 0, _x select 1, _x select 2]};
	if !(_now isEqualTo _sig) then {_sig = _now; [] call MCCMK_gpRebuild} else {
		_tick = _tick + 1;
		if (_tick >= 4) then {_tick = 0; [] call MCCMK_gpBars};
	};
	sleep 0.25;
};
