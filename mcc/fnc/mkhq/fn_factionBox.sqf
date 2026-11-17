/*
	MCCMK_fnc_factionBox - fills the MCC console's faction panel (rows group 9292), in one of three views chosen with the
	Factions / Forces / Missions switch above it (9294, remembered while the game runs):
	  Factions - one row per faction with living groups: flag, relation to the player (FRIENDLY / ALLY / ENEMY / NEUTRAL),
	             name (wrapped at a word), side. Click a row: that faction becomes the console's faction.
	  Forces   - each side's groups against Arma's limit of 288 (a bar: green; amber when a typical recent generated mission
	             wouldn't fit any more; red with fewer than 20 left, where any mission is refused), then each faction's groups, soldiers,
	             ground vehicles, aircraft and boats. Click a faction: it becomes the console's faction.
	  Missions - every mission on the player's task list (campaign, generated or made by hand), one per parent task: its
	             title, objectives done of all (its child tasks), and - for generated ones - how much of the enemy force
	             that came with it is left and how long it has been running. Click one: the map centres on it.
	The On / Off switch (9297) turns the whole box off (empty, and not refreshed) and on again.
	Each row is its own pieces (flags in flag proportions with a small gap). Rebuilt only when what it shows changes.
	[display] - a refresh; ["tab", index] - the switch; ["power"] - On / Off
*/
disableSerialization;
private _d = displayNull;
if (_this isEqualType [] && {(_this param [0, 0]) isEqualType ""}) then {
	if ((_this select 0) == "power") then {
		uiNamespace setVariable ["MCCMK_factionOn", !(uiNamespace getVariable ["MCCMK_factionOn", true])];
	} else {
		uiNamespace setVariable ["MCCMK_factionTab", _this param [1, 0]];
	};
	_d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
	if (!isNull _d) then {(_d displayCtrl 9292) setVariable ["MCCMK_sig", ""]};
} else {
	_d = _this param [0, displayNull];
};
if (isNull _d) exitWith {};
private _g = _d displayCtrl 9292;
if (isNull _g) exitWith {};
// On / Off: the switch's look, and an empty box (not refreshed) while off
private _on = uiNamespace getVariable ["MCCMK_factionOn", true];
private _pw = _d displayCtrl 9297;
if (!isNull _pw) then {
	_pw ctrlSetText (["Off", "On"] select _on);
	_pw ctrlSetTextColor ([[0.88, 0.89, 0.90, 1], [0.56, 0.75, 0.42, 1]] select _on);
};
if (!_on) exitWith {
	{ctrlDelete _x} forEach (_g getVariable ["MCCMK_rowCtrls", []]);
	_g setVariable ["MCCMK_rowCtrls", []];
	_g setVariable ["MCCMK_sig", "off"];
};
private _tab = uiNamespace getVariable ["MCCMK_factionTab", 0];
private _tabs = _d displayCtrl 9294;
if (!isNull _tabs && {(lbCurSel _tabs) != _tab}) then {_tabs lbSetCurSel _tab};
private _pSide = playerSide;
private _pFac = faction player;
private _sides = [west, east, resistance, civilian];
private _sideCol = {
	params ["_s"];
	switch (_s) do {case west: {[0.36, 0.6, 1, 1]}; case east: {[0.95, 0.32, 0.32, 1]}; case resistance: {[0.32, 0.82, 0.4, 1]}; default {[0.78, 0.52, 0.94, 1]}}
};
private _grey = [0.62, 0.64, 0.66, 1];
private _white = [0.88, 0.89, 0.9, 1];
private _facName = {
	params ["_f"];
	private _n = getText (configFile >> "CfgFactionClasses" >> _f >> "displayName");
	if (_n == "") then {_f} else {_n}
};

// ---- what the view shows (and its signature: rebuilt only when that changes)
private _rows = [];
private _sig = "";	// what rows there are - a change rebuilds the view
private _val = "";	// the numbers in them - a change only updates them where they are (no jump, no flicker)
// the texts and colours both a rebuild and an update use
private _barCol = {
	params ["_n"];
	private _free = 288 - _n;
	switch (true) do {case (_free < 20): {[0.9, 0.26, 0.26, 1]}; case (_free < (missionNamespace getVariable ["MCCMK_genTypical", 120])): {[0.96, 0.66, 0.16, 1]}; default {[0.32, 0.76, 0.36, 1]}}
};
private _subCol = {params ["_st"]; [[0.62, 0.64, 0.66, 1], [0.32, 0.82, 0.4, 1], [0.95, 0.32, 0.32, 1]] select (_st max 0 min 2)};
private _objTxt = {params ["_done", "_all"]; if (_all > 0) then {format ["%1 / %2", _done, _all]} else {"-"}};
private _objCol = {params ["_done", "_all"]; if (_all > 0 && {_done >= _all}) then {[0.32, 0.82, 0.4, 1]} else {[0.88, 0.89, 0.9, 1]}};
private _infoTxt = {
	params ["_left", "_mins"];
	private _info = [];
	if (_left >= 0) then {_info pushBack format ["enemy %1%2 left", _left, "%"]};
	if (_mins >= 0) then {_info pushBack format ["%1 min", _mins]};
	_info joinString "  -  "
};
switch (_tab) do {
	case 1: {	// Forces
		private _per = createHashMap;	// side|faction -> [side, faction, groups, men, ground, air, sea]
		{
			private _l = leader _x;
			private _s = side _x;
			if (!isNull _l && {!(_l isKindOf "Logic")} && {_s in _sides}) then {
				private _f = faction _l;
				if (_f != "") then {
					private _k = format ["%1|%2", _s, _f];
					private _e = _per getOrDefault [_k, [_s, _f, 0, 0, [], [], []]];
					_e set [2, (_e select 2) + 1];
					_e set [3, (_e select 3) + ({alive _x} count units _x)];
					{
						private _v = vehicle _x;
						if (_v != _x && {alive _v} && {!(_v isKindOf "StaticWeapon")}) then {
							(_e select ([4, [5, 6] select (_v isKindOf "Ship")] select ((_v isKindOf "Air") || {_v isKindOf "Ship"}))) pushBackUnique _v;
						};
					} forEach units _x;
					_per set [_k, _e];
				};
			};
		} forEach allGroups;
		private _bars = _sides apply {private _sd = _x; [_sd, {(side _x) isEqualTo _sd} count allGroups]};
		_rows = (values _per) apply {
			_x params ["_s", "_f", "_gr", "_men", "_gv", "_av", "_sv"];
			[_sides find _s, [_f] call _facName, _s, _f, _gr, _men, count _gv, count _av, count _sv]
		};
		_rows sort true;
		_rows = [_bars] + [_rows];
		_sig = "F" + str ((_rows select 1) apply {[_x select 2, _x select 3, _x select 1]});
		_val = str [_bars, (_rows select 1) apply {_x select [4, 5]}];
	};
	case 2: {	// Missions: the player's tasks, one entry per parent task (or a task with none)
		private _ids = [player] call BIS_fnc_tasksUnit;
		private _ended = {(toUpper (_this call BIS_fnc_taskState)) in ["SUCCEEDED", "FAILED", "CANCELED"]};
		private _kids = createHashMap;
		private _tops = [];
		{
			private _p = _x call BIS_fnc_taskParent;
			if (_p isEqualType "" && {_p != ""} && {_p in _ids}) then {(_kids getOrDefault [_p, [], true]) pushBack _x} else {_tops pushBack _x};
		} forEach _ids;
		private _gen = missionNamespace getVariable ["MCC_generatedMissionsList", []];
		{
			private _id = _x;
			private _ch = _kids getOrDefault [_id, []];
			// a mission still running: it, or one of its objectives, not ended
			if (!(_id call _ended) || {(_ch findIf {!(_x call _ended)}) >= 0}) then {
				private _t = (_id call BIS_fnc_taskDescription) param [1, ""];
				if (_t isEqualType []) then {_t = _t param [0, ""]};
				if (_t isEqualType "" && {_t == ""}) then {_t = _id};
				private _dst = _id call BIS_fnc_taskDestination;
				if (_dst isEqualType [] && {count _dst == 2} && {(_dst select 0) isEqualType objNull}) then {_dst = _dst select 0};
				private _ctr = switch (true) do {
					case (_dst isEqualType objNull): {if (isNull _dst) then {[]} else {getPosATL _dst}};
					case (_dst isEqualType [] && {count _dst >= 2} && {(_dst select 0) isEqualType 0}): {_dst};
					default {[]};
				};
				private _all = count _ch;
				private _done = {(toUpper (_x call BIS_fnc_taskState)) == "SUCCEEDED"} count _ch;
				if (_all == 0) then {_all = 1; _done = [0, 1] select ((toUpper (_id call BIS_fnc_taskState)) == "SUCCEEDED")};
				// a generated mission: its enemy left and time running, from MCC's record
				private _left = -1;
				private _mins = -1;
				private _gi = _gen findIf {private _tids = _x param [4, []]; (_tids findIf {_x in _ch || {_x == _id}}) >= 0};
				// not by its tasks: the generated mission nearest its position (within 1.5 km)
				if (_gi < 0 && {_ctr isNotEqualTo []}) then {
					private _best = 1500;
					{
						private _c = _x param [3, []];
						if (_c isEqualType [] && {count _c >= 2} && {(_c distance2D _ctr) < _best}) then {_best = _c distance2D _ctr; _gi = _forEachIndex};
					} forEach _gen;
				};
				if (_gi < 0 && {_gen isNotEqualTo []}) then {
					private _logged = uiNamespace getVariable ["MCCMK_mUnmatched", []];
					if !(_id in _logged) then {
						_logged pushBack _id;
						uiNamespace setVariable ["MCCMK_mUnmatched", _logged];
						["INFO", "MCCMK_fnc_factionBox", "mission task %1 (%2) not matched to a generated mission - its objectives %3, at %4; records: %5", [_id, _t, _ch, _ctr, _gen apply {[_x select 0, _x param [4, []], _x param [3, []]]}]] call MCC_fnc_log;
					};
				};
				if (_gi >= 0) then {
					(_gen select _gi) params ["", "", "", ["_gctr", []], "", ["_grps", []], ["_men0", 0], ["_t0", 0]];
					private _now = 0;
					{if (!isNull _x) then {_now = _now + ({alive _x} count units _x)}} forEach _grps;
					if (_men0 > 0) then {_left = round (100 * (_now min _men0) / _men0)};
					if (_t0 > 0) then {_mins = floor ((time - _t0) / 60)};
					if (_ctr isEqualTo []) then {_ctr = _gctr};
				};
				// its objectives: title, and 0 open / 1 done / 2 failed or cancelled
				private _subs = _ch apply {
					private _st = toUpper (_x call BIS_fnc_taskState);
					private _tt = (_x call BIS_fnc_taskDescription) param [1, ""];
					if (_tt isEqualType []) then {_tt = _tt param [0, ""]};
					if (!(_tt isEqualType "") || {_tt == ""}) then {_tt = _x};
					[_tt, switch (true) do {case (_st == "SUCCEEDED"): {1}; case (_st in ["FAILED", "CANCELED"]): {2}; default {0}}]
				};
				_rows pushBack [_id, _t, "", _ctr, _done, _all, _left, _mins, _subs];
			};
		} forEach _tops;
		_sig = "M" + str (_rows apply {[_x select 0, _x select 1, (_x select 6) >= 0 || {(_x select 7) >= 0}, (_x select 8) apply {_x select 0}]});
		_val = str (_rows apply {(_x select [4, 4]) + [(_x select 8) apply {_x select 1}]});
	};
	default {	// Factions
		private _found = createHashMap;
		{
			private _l = leader _x;
			if (!isNull _l && {alive _l} && {!(_l isKindOf "Logic")}) then {
				private _s = side _x;
				private _f = faction _l;
				if (_s in _sides && {_f != ""}) then {_found set [format ["%1|%2", _s, _f], [_s, _f]]};
			};
		} forEach allGroups;
		if !(format ["%1|%2", _pSide, _pFac] in _found) then {_found set [format ["%1|%2", _pSide, _pFac], [_pSide, _pFac]]};
		_rows = (values _found) apply {
			_x params ["_s", "_f"];
			private _rel = switch (true) do {
				case (_s isEqualTo _pSide && {_f == _pFac}): {"FRIENDLY"};
				case (_s isEqualTo civilian): {"NEUTRAL"};
				case (_s isEqualTo _pSide): {"ALLY"};
				case ([_pSide, _s] call BIS_fnc_sideIsEnemy): {"ENEMY"};
				default {"ALLY"};
			};
			[["FRIENDLY", "ALLY", "ENEMY", "NEUTRAL"] find _rel, _sides find _s, _rel, _s, _f]
		};
		_rows sort true;
		_sig = "A" + str (_rows apply {[_x select 2, _x select 3, _x select 4]});
	};
};
private _same = (_g getVariable ["MCCMK_sig", ""]) == _sig;
if (_same && {(_g getVariable ["MCCMK_val", ""]) == _val}) exitWith {};
_g setVariable ["MCCMK_val", _val];
// only the numbers changed: update them where they are
if (_same) exitWith {
	isNil {
		private _vc = _g getVariable ["MCCMK_valCtrls", []];
		switch (_tab) do {
			case 1: {
				_vc params [["_bc", []], ["_rc", []]];
				{
					_x params ["_sd", "_n"];
					(_bc param [_forEachIndex, []]) params [["_fill", controlNull], ["_cnt", controlNull], ["_bx", 0], ["_bw", 0]];
					if (!isNull _fill) then {
						private _col = [_n] call _barCol;
						private _fp = ctrlPosition _fill;
						_fill ctrlSetPosition [_bx, _fp select 1, _bw * ((_n / 288) min 1), _fp select 3];
						_fill ctrlSetBackgroundColor _col;
						_fill ctrlCommit 0;
						_cnt ctrlSetText format ["%1 / 288", _n];
						_cnt ctrlSetTextColor _col;
					};
				} forEach (_rows select 0);
				{
					private _cs = _rc param [_forEachIndex, []];
					{(_cs param [_forEachIndex, controlNull]) ctrlSetText str _x} forEach (_x select [4, 5]);
				} forEach (_rows select 1);
			};
			case 2: {
				{
					_x params ["", "", "", "", "_done", "_all", "_left", "_mins", ["_subs", []]];
					(_vc param [_forEachIndex, []]) params [["_oc", controlNull], ["_ic", controlNull], ["_sc", []]];
					if (!isNull _oc) then {_oc ctrlSetText ([_done, _all] call _objTxt); _oc ctrlSetTextColor ([_done, _all] call _objCol)};
					if (!isNull _ic) then {_ic ctrlSetText ([_left, _mins] call _infoTxt)};
					{(_sc param [_forEachIndex, controlNull]) ctrlSetTextColor ([_x select 1] call _subCol)} forEach _subs;
				} forEach _rows;
			};
		};
	};
};
_g setVariable ["MCCMK_sig", _sig];
// the rows changed: rebuilt in one go (unscheduled - never seen half-built), the scroll position kept
isNil {
private _scroll = ctrlScrollValues _g;
private _valCtrls = [];

// ---- the building blocks
{ctrlDelete _x} forEach (_g getVariable ["MCCMK_rowCtrls", []]);
private _made = [];
private _gw = (ctrlPosition _g) select 2;
private _fs = ((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.7;
private _lineH = 0.024;
private _fh = _lineH - 0.0024;
private _res = getResolution;
private _fw = _fh * 1.6 * ((_res select 1) * safezoneW) / ((_res select 0) * safezoneH);
private _pad = 0.0035 * safezoneW;
private _xRel = _pad + _fw + 0.0028 * safezoneW;
private _sbw = 0.004 * safezoneW;
private _meter = _d ctrlCreate ["RscText", -1];
_meter ctrlSetFont "RobotoCondensed";
_meter ctrlSetFontHeight _fs;
_meter ctrlSetPosition [-10, -10, 1, 0.05];
_meter ctrlCommit 0;
private _wrap = {
	params ["_txt", "_w"];
	private _lines = [];
	private _cur = "";
	{
		private _try = if (_cur == "") then {_x} else {_cur + " " + _x};
		_meter ctrlSetText _try;
		if (ctrlTextWidth _meter > _w && {_cur != ""}) then {_lines pushBack _cur; _cur = _x} else {_cur = _try};
	} forEach (_txt splitString " ");
	if (_cur != "") then {_lines pushBack _cur};
	if (_lines isEqualTo []) then {_lines = [_txt]};
	_lines
};
private _fit = {	// one line, shortened with "..." to fit
	params ["_txt", "_w"];
	_meter ctrlSetText _txt;
	if (ctrlTextWidth _meter <= _w) exitWith {_txt};
	private _t = _txt;
	while {count _t > 1 && {_meter ctrlSetText (_t + "..."); ctrlTextWidth _meter > _w}} do {_t = _t select [0, count _t - 1]};
	_t + "..."
};
private _text = {
	params ["_t", "_x", "_y", "_w", "_col"];
	private _c = _d ctrlCreate ["RscText", -1, _g];
	_c ctrlSetFont "RobotoCondensed";
	_c ctrlSetFontHeight _fs;
	_c ctrlSetText _t;
	_c ctrlSetTextColor _col;
	_c ctrlSetBackgroundColor [0, 0, 0, 0];
	_c ctrlSetPosition [_x, _y, _w, _lineH];
	_c ctrlCommit 0;
	_made pushBack _c;
	_c
};
private _box = {	// a filled box (bars)
	params ["_x", "_y", "_w", "_h", "_col"];
	private _c = _d ctrlCreate ["RscText", -1, _g];
	_c ctrlSetText "";
	_c ctrlSetBackgroundColor _col;
	_c ctrlSetPosition [_x, _y, _w, _h];
	_c ctrlCommit 0;
	_made pushBack _c;
	_c
};
private _flag = {
	params ["_f", "_y"];
	private _p = getText (configFile >> "CfgFactionClasses" >> _f >> "flag");
	if (_p == "") then {_p = "#(argb,8,8,3)color(0,0,0,1)"};
	private _c = _d ctrlCreate ["RscPicture", -1, _g];
	_c ctrlSetText _p;
	_c ctrlSetTextColor [1, 1, 1, 1];
	_c ctrlSetPosition [_pad, _y + (_lineH - _fh) / 2, _fw, _fh];
	_c ctrlCommit 0;
	_made pushBack _c;
};
private _click = {	// a row's click area (no tooltip): [y, height, code with _this = [display, value], value]
	params ["_y", "_h", "_code", "_val"];
	private _b = _d ctrlCreate ["MCCMK_RscRowButton", -1, _g];
	_b ctrlSetPosition [0, _y, _gw - _sbw, _h];
	_b ctrlCommit 0;
	_b setVariable ["MCCMK_val", _val];
	_b setVariable ["MCCMK_code", _code];
	_b ctrlAddEventHandler ["ButtonClick", {params ["_b"]; [ctrlParent _b, _b getVariable ["MCCMK_val", ""]] call (_b getVariable ["MCCMK_code", {}])}];
	_made pushBack _b;
};
private _pickFaction = {params ["_dd", "_f"]; [_dd, _f] call MCCMK_fnc_factionBoxClick};
private _y = 0;

// ---- the view
switch (_tab) do {
	case 1: {	// Forces
		_rows params ["_bars", "_facs"];
		private _barCtrls = [];
		private _rowNums = [];
		private _barX = _gw * 0.16;
		private _barW = _gw * 0.56;
		{
			_x params ["_sd", "_n"];
			private _col = [_n] call _barCol;
			[["WEST", "EAST", "GUER", "CIV"] select _forEachIndex, _pad, _y, _barX - _pad, [_sd] call _sideCol] call _text;
			private _bh = _lineH * 0.42;
			private _by = _y + (_lineH - _bh) / 2;
			[_barX, _by, _barW, _bh, [0.2, 0.21, 0.23, 1]] call _box;
			private _fill = [_barX, _by, _barW * ((_n / 288) min 1), _bh, _col] call _box;
			private _cnt = [format ["%1 / 288", _n], _barX + _barW + 0.004 * safezoneW, _y, _gw - _barX - _barW - _sbw, _col] call _text;
			_barCtrls pushBack [_fill, _cnt, _barX, _barW];
			private _tip = _d ctrlCreate ["MCCMK_RscTipArea", -1, _g];
			_tip ctrlSetPosition [_barX, _y, _gw - _barX - _sbw, _lineH];
			_tip ctrlCommit 0;
			_tip ctrlSetTooltip format ["%1 groups on the map, of Arma's limit of 288 per side. A generated mission that wouldn't fit is refused.", ["BLUFOR", "OPFOR", "Independent", "Civilian"] select _forEachIndex];
			_made pushBack _tip;
			_y = _y + _lineH;
		} forEach _bars;
		_y = _y + _lineH * 0.3;
		private _cols = [0.5, 0.6, 0.7, 0.8, 0.89] apply {_gw * _x};
		["FACTION", _xRel, _y, _cols select 0, _grey] call _text;
		{[_x, _cols select _forEachIndex, _y, _gw * 0.1, _grey] call _text} forEach ["GRP", "MEN", "VEH", "AIR", "SEA"];
		_y = _y + _lineH;
		private _facCount = createHashMap;
		{_facCount set [_x select 3, (_facCount getOrDefault [_x select 3, 0]) + 1]} forEach _facs;
		{
			_x params ["", "_name", "_s", "_f", "_gr", "_men", "_gv", "_av", "_sv"];
			if ((_facCount getOrDefault [_f, 0]) > 1) then {_name = format ["%1 (%2)", _name, ["WEST", "EAST", "GUER", "CIV"] select (_sides find _s)]};	// on more than one side
			[_f, _y] call _flag;
			[[_name, (_cols select 0) - _xRel - 0.003 * safezoneW] call _fit, _xRel, _y, (_cols select 0) - _xRel, [_s] call _sideCol] call _text;
			private _nc = [];
			{_nc pushBack ([str _x, _cols select _forEachIndex, _y, _gw * 0.1, _white] call _text)} forEach [_gr, _men, _gv, _av, _sv];	// each in its own column
			_rowNums pushBack _nc;
			[_y, _lineH, _pickFaction, _f] call _click;
			_y = _y + _lineH;
		} forEach _facs;
		_valCtrls = [_barCtrls, _rowNums];
	};
	case 2: {	// Missions
		if (_rows isEqualTo []) then {
			["No missions running.", _pad, _y, _gw - _pad - _sbw, _grey] call _text;
		};
		private _objX = _gw * 0.78;
		{
			_x params ["_id", "_name", "_tt", "_ctr", "_done", "_all", "_left", "_mins", ["_subs", []]];
			private _y0 = _y;
			[[_name, _objX - _pad - 0.003 * safezoneW] call _fit, _pad, _y, _objX - _pad, _white] call _text;
			private _oc = [[_done, _all] call _objTxt, _objX, _y, _gw - _objX - _sbw, [_done, _all] call _objCol] call _text;
			// its objectives, indented: grey while open, green done, red failed
			private _sc = [];
			{
				_sc pushBack ([[_x select 0, _gw - _pad - 0.009 * safezoneW - _sbw] call _fit, _pad + 0.006 * safezoneW, _y + _lineH * 0.9 * (_forEachIndex + 1), _gw - _pad - 0.006 * safezoneW - _sbw, [_x select 1] call _subCol] call _text);
			} forEach _subs;
			_y = _y + _lineH * 0.9 * (count _subs);
			private _ic = [[_left, _mins] call _infoTxt, _pad, _y + _lineH * 0.9, _gw - _pad - _sbw, _grey] call _text;
			_valCtrls pushBack [_oc, _ic, _sc];
			private _goto = {
				params ["_dd", "_c"];
				if (_c isEqualTo [] ) exitWith {};
				private _m = _dd displayCtrl 9000;
				if (isNull _m) exitWith {};
				_m ctrlMapAnimAdd [0.5, (ctrlMapScale _m) min 0.15, _c];
				ctrlMapAnimCommit _m;
			};
			[_y0, (_y - _y0) + _lineH * 1.9, _goto, _ctr] call _click;
			_y = _y + _lineH * 2.05;
		} forEach _rows;
	};
	default {	// Factions
		private _relCol = createHashMapFromArray [["FRIENDLY", [_pSide] call _sideCol], ["ALLY", [0.32, 0.82, 0.4, 1]], ["ENEMY", [0.95, 0.32, 0.32, 1]], ["NEUTRAL", [civilian] call _sideCol]];
		private _xFac = _gw * 0.346;
		private _mkGap = 0.004 * safezoneW;
		private _mkSideW = 0;
		{_meter ctrlSetText _x; _mkSideW = _mkSideW max (ctrlTextWidth _meter)} forEach ["WEST", "EAST", "GUER", "CIV"];
		_mkSideW = _mkSideW + _mkGap;
		private _colW = _gw - _xFac - _sbw - _mkSideW - _mkGap;
		{
			_x params ["", "", "_rel", "_s", "_f"];
			private _name = [_f] call _facName;
			private _lines = [_name, _colW] call _wrap;
			private _rowH = (count _lines) * _lineH;
			[_f, _y] call _flag;
			[_rel, _xRel, _y, _xFac - _xRel, _relCol get _rel] call _text;
			private _mkSt = ["WEST", "EAST", "GUER", "CIV"] select (_sides find _s);
			_meter ctrlSetText _mkSt;
			private _mkSw = (ctrlTextWidth _meter) + _mkGap;
			[_mkSt, _gw - _sbw - _mkSw, _y, _mkSw, [_s] call _sideCol] call _text;
			{[_x, _xFac, _y + _forEachIndex * _lineH, _colW, [_s] call _sideCol] call _text} forEach _lines;
			[_y, _rowH, _pickFaction, _f] call _click;
			_y = _y + _rowH;
		} forEach _rows;
	};
};
ctrlDelete _meter;
_g setVariable ["MCCMK_rowCtrls", _made];
_g setVariable ["MCCMK_valCtrls", _valCtrls];
_g ctrlSetScrollValues _scroll;
};
