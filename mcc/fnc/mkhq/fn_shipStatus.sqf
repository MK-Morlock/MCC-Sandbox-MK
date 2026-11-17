disableSerialization;
params [["_ship", objNull, [objNull]], ["_free", false, [true]], ["_parent", displayNull, [displayNull]]];
if (isNull _ship) exitWith {};
if (isNull _parent) then {_parent = findDisplay 46};
private _d = _parent createDisplay "RscDisplayEmpty";
uiNamespace setVariable ["MCCMK_statusDisp", _d];
uiNamespace setVariable ["MCCMK_statusShip", [_ship, _free]];
uiNamespace setVariable ["MCCMK_statusRadarWant", nil];
private _nW = count (_ship getVariable ["MCCMK_weaponSpecs", []]);
private _panW = 0.44 * safezoneW;
private _pad = 0.012 * safezoneW;
private _hH = 0.036 * safezoneH + ((_nW max 1) * 0.03 * safezoneH);
private _panH = 0.205 * safezoneH + _hH + 0.012 * safezoneH + 0.062 * safezoneH + 0.012 * safezoneH + 0.11 * safezoneH + 0.145 * safezoneH;
private _panX = safezoneX + (safezoneW - _panW) / 2;
private _panY = safezoneY + (safezoneH - _panH) / 2;
private _cardC = [0.13, 0.15, 0.17, 1];
private _mk = {
	params ["_cls", "_idc", "_cx", "_cy", "_cw", "_ch", ["_bg", []]];
	private _c = _d ctrlCreate [_cls, _idc];
	_c ctrlSetPosition [_panX + _cx, _panY + _cy, _cw, _ch];
	if (count _bg == 4) then {_c ctrlSetBackgroundColor _bg};
	_c ctrlCommit 0;
	_c
};
private _label = {
	params ["_cx", "_cy", "_cw", "_txt"];
	private _c = ["RscStructuredText", -1, _cx, _cy, _cw, 0.022 * safezoneH] call _mk;
	_c ctrlSetStructuredText parseText format ["<t size='0.75' color='#9ea6ad'>%1</t>", toUpper _txt];
	_c
};
["RscText", -1, 0, 0, _panW, _panH, [0.08, 0.09, 0.1, 0.95]] call _mk;
private _ti = ["RscStructuredText", -1, 0, 0.012 * safezoneH, _panW, 0.04 * safezoneH] call _mk;
_ti ctrlSetStructuredText parseText format ["<t align='center' size='1.25' font='PuristaMedium'>%1</t>", _ship getVariable ["MCC_LHDDisplayName", "Ship"]];
private _sub = ["RscStructuredText", 7952, 0, 0.05 * safezoneH, _panW, 0.025 * safezoneH] call _mk;
["RscStructuredText", 7953, (_panW - 0.09 * safezoneW) / 2, 0.08 * safezoneH, 0.09 * safezoneW, 0.026 * safezoneH] call _mk;
private _cy = 0.12 * safezoneH;
private _hullW = (_panW - 3 * _pad) * 0.56;
private _sensW = (_panW - 3 * _pad) - _hullW;
["RscText", -1, _pad, _cy, _hullW, 0.075 * safezoneH, _cardC] call _mk;
[_pad + 0.006 * safezoneW, _cy + 0.006 * safezoneH, _hullW, "Hull"] call _label;
private _barW = _hullW - 0.06 * safezoneW;
["RscText", -1, _pad + 0.008 * safezoneW, _cy + 0.042 * safezoneH, _barW, 0.012 * safezoneH, [0.05, 0.06, 0.07, 1]] call _mk;
["RscText", 7954, _pad + 0.008 * safezoneW, _cy + 0.042 * safezoneH, _barW, 0.012 * safezoneH, [0.11, 0.62, 0.46, 1]] call _mk;
["RscStructuredText", 7955, _pad + 0.012 * safezoneW + _barW, _cy + 0.034 * safezoneH, 0.045 * safezoneW, 0.03 * safezoneH] call _mk;
private _sx = 2 * _pad + _hullW;
["RscText", -1, _sx, _cy, _sensW, 0.075 * safezoneH, _cardC] call _mk;
[_sx + 0.006 * safezoneW, _cy + 0.006 * safezoneH, _sensW, "Sensors"] call _label;
private _bw3 = (_sensW - 0.024 * safezoneW) / 3;
for "_i" from 0 to 2 do {["RscStructuredText", 7956 + _i, _sx + 0.006 * safezoneW + _i * (_bw3 + 0.006 * safezoneW), _cy + 0.038 * safezoneH, _bw3, 0.024 * safezoneH] call _mk};
_cy = _cy + 0.085 * safezoneH;
["RscText", -1, _pad, _cy, _panW - 2 * _pad, _hH, _cardC] call _mk;
[_pad + 0.006 * safezoneW, _cy + 0.006 * safezoneH, 0.2 * safezoneW, "Weapons"] call _label;
private _rowBarX = _pad + 0.17 * safezoneW;
private _rowBarW = (_panW - 2 * _pad) - 0.17 * safezoneW - 0.06 * safezoneW;
for "_i" from 0 to (_nW - 1) do {
	private _ry = _cy + 0.034 * safezoneH + _i * 0.03 * safezoneH;
	["RscStructuredText", 8000 + _i, _pad + 0.008 * safezoneW, _ry, 0.07 * safezoneW, 0.026 * safezoneH] call _mk;
	["RscStructuredText", 8020 + _i, _pad + 0.08 * safezoneW, _ry + 0.002 * safezoneH, 0.075 * safezoneW, 0.022 * safezoneH] call _mk;
	["RscText", -1, _rowBarX, _ry + 0.008 * safezoneH, _rowBarW, 0.01 * safezoneH, [0.05, 0.06, 0.07, 1]] call _mk;
	["RscText", 8040 + _i, _rowBarX, _ry + 0.008 * safezoneH, _rowBarW, 0.01 * safezoneH, [0.22, 0.54, 0.87, 1]] call _mk;
	["RscStructuredText", 8060 + _i, _rowBarX + _rowBarW + 0.006 * safezoneW, _ry, 0.045 * safezoneW, 0.026 * safezoneH] call _mk;
};
if (_nW == 0) then {(["RscStructuredText", -1, _pad + 0.008 * safezoneW, _cy + 0.034 * safezoneH, 0.3 * safezoneW, 0.026 * safezoneH] call _mk) ctrlSetStructuredText parseText "<t size='0.9' color='#9ea6ad'>No weapon systems.</t>"};
_cy = _cy + _hH + 0.012 * safezoneH;
private _tW = ((_panW - 2 * _pad) - 3 * 0.008 * safezoneW) / 4;
{
	private _tx = _pad + _forEachIndex * (_tW + 0.008 * safezoneW);
	["RscText", -1, _tx, _cy, _tW, 0.062 * safezoneH, _cardC] call _mk;
	[_tx + 0.006 * safezoneW, _cy + 0.006 * safezoneH, _tW, _x] call _label;
	["RscStructuredText", 8080 + _forEachIndex, _tx + 0.006 * safezoneW, _cy + 0.03 * safezoneH, _tW - 0.008 * safezoneW, 0.028 * safezoneH] call _mk;
} forEach ["Repair", "Rearm", "Replace", "Hull repair"];
_cy = _cy + 0.074 * safezoneH;
["RscText", -1, _pad, _cy, _panW - 2 * _pad, 0.11 * safezoneH, _cardC] call _mk;
[_pad + 0.006 * safezoneW, _cy + 0.006 * safezoneH, 0.2 * safezoneW, "Contacts"] call _label;
["RscStructuredText", 8090, _pad + 0.008 * safezoneW, _cy + 0.03 * safezoneH, _panW - 2 * _pad - 0.016 * safezoneW, 0.078 * safezoneH] call _mk;
_cy = _cy + 0.118 * safezoneH;
["RscStructuredText", 7951, _pad, _cy, _panW - 2 * _pad, 0.026 * safezoneH] call _mk;
private _btnC = ["MCC_RscButtonRound", "MCC_RscButtonRound3D"] select (profileNamespace getVariable ["MCC_consoleButtons", false]);
// Two centred rows: the ship's systems on top, maintenance below.
private _rowsB = [[[7961, "Radar", "radar"], [7967, "Map circle", "radarmap"], [7968, "Guns", "guns"], [7969, "VLS", "vls"]],
	[[7962, "Repair", "repair"], [7963, "Rearm", "rearm"], [7964, "Replace", "replace"], [7965, "Repair hull", "hull"], [7966, "Close", "close"]]];
private _gap = 0.005 * safezoneW;
private _bw = ((_panW - 2 * _pad) - 4 * _gap) / 5;
private _btns = [];
{
	private _row = _x;
	private _ry = _panH - ([0.095, 0.05] select _forEachIndex) * safezoneH;
	private _x0 = (_panW - (((count _row) * _bw) + (((count _row) - 1) * _gap))) / 2;
	{_btns pushBack [_x select 0, _x select 1, _x select 2, _x0 + _forEachIndex * (_bw + _gap), _ry]} forEach _row;
} forEach _rowsB;
{
	_x params ["_idc", "_lbl", "_act", "_bx", "_by"];
	private _b = [_btnC, _idc, _bx, _by, _bw, 0.034 * safezoneH] call _mk;
	_b ctrlSetText _lbl;
	_b setVariable ["MCCMK_act", _act];
	_b ctrlAddEventHandler ["ButtonClick", {
		params ["_c"];
		(uiNamespace getVariable ["MCCMK_statusShip", [objNull, false]]) params ["_ship", "_free"];
		private _act = _c getVariable ["MCCMK_act", ""];
		switch (_act) do {
			case "close": {(ctrlParent _c) closeDisplay 1};
			case "guns";
			case "vls": {
				if !(_free || {[player, _ship getVariable ["MCC_side", playerSide]] call MCCMK_fnc_shipCanCommand}) exitWith {["Only the commander can change this."] call MCCMK_fnc_shipStatusMsg};
				private _var = ["MCCMK_navalVLS", "MCCMK_navalGuns"] select (_act == "guns");
				private _on = !(_ship getVariable [_var, false]);
				_ship setVariable [_var, _on, true];
				[format ["%1 %2 for fire support.", ["VLS", "Guns"] select (_act == "guns"), ["off", "on"] select _on]] call MCCMK_fnc_shipStatusMsg;
			};
			case "radarmap": {
				if !(_free || {[player, _ship getVariable ["MCC_side", playerSide]] call MCCMK_fnc_shipCanCommand}) exitWith {["Only the commander can change this."] call MCCMK_fnc_shipStatusMsg};
				_ship setVariable ["MCCMK_radarMap", !(_ship getVariable ["MCCMK_radarMap", false]), true];
			};
			case "radar": {
				if !(_free || {[player, _ship getVariable ["MCC_side", playerSide]] call MCCMK_fnc_shipCanCommand}) exitWith {["Only the commander can switch the radar."] call MCCMK_fnc_shipStatusMsg};
				private _want = !(_ship getVariable ["MCCMK_radarOn", false]);
				uiNamespace setVariable ["MCCMK_statusRadarWant", _want];
				[_ship, _want] remoteExec ["MCCMK_fnc_shipRadar", 2];
				[["Switching the radar off...", "Switching the radar on..."] select _want] call MCCMK_fnc_shipStatusMsg;
			};
			default {[_ship, _act, player, _free] remoteExec ["MCCMK_fnc_shipMaint", 2]; ["Order sent..."] call MCCMK_fnc_shipStatusMsg};
		};
	}];
} forEach _btns;
[_d, _nW, _barW, _rowBarW] spawn {
	disableSerialization;
	params ["_d", "_nW", "_barW", "_rowBarW"];
	private _badge = {
		params ["_c", "_txt", "_kind"];
		private _k = (["ok", "warn", "bad", "off"] find _kind) max 0;
		_c ctrlSetBackgroundColor ([[0.02, 0.2, 0.17, 1], [0.25, 0.14, 0.01, 1], [0.31, 0.07, 0.07, 1], [0.17, 0.17, 0.16, 1]] select _k);
		_c ctrlSetStructuredText parseText format ["<t align='center' size='0.8' color='%1'>%2</t>", ["#5DCAA5", "#EF9F27", "#F09595", "#B4B2A9"] select _k, _txt];
	};
	private _setW = {params ["_c", "_w"]; private _p = ctrlPosition _c; _p set [2, _w max 0.0001]; _c ctrlSetPosition _p; _c ctrlCommit 0};
	while {!isNull _d} do {
		(uiNamespace getVariable ["MCCMK_statusShip", [objNull, false]]) params ["_ship", "_free"];
		if (isNull _ship) exitWith {_d closeDisplay 2};
		private _hull = _ship getVariable ["MCCMK_hull", 1];
		private _radar = _ship getVariable ["MCCMK_radarOn", false];
		(_d displayCtrl 7952) ctrlSetStructuredText parseText format ["<t align='center' size='0.85' color='#9ea6ad'>Ship status  ·  grid %1</t>", mapGridPosition _ship];
		switch (true) do {
			case (_ship getVariable ["MCCMK_sinking", false]): {[_d displayCtrl 7953, "Sinking", "bad"] call _badge};
			case (_ship getVariable ["MCCMK_disabled", false]): {[_d displayCtrl 7953, "Disabled", "bad"] call _badge};
			case (_ship getVariable ["MCCMK_crippled", false]): {[_d displayCtrl 7953, "Crippled", "warn"] call _badge};
			case (_hull < 0.5): {[_d displayCtrl 7953, "Damaged", "warn"] call _badge};
			default {[_d displayCtrl 7953, "Operational", "ok"] call _badge};
		};
		[_d displayCtrl 7954, _barW * (_hull max 0 min 1)] call _setW;
		private _hk = 0;
		if (_hull < 0.5) then {_hk = 1};
		if (_hull < 0.25) then {_hk = 2};
		(_d displayCtrl 7954) ctrlSetBackgroundColor ([[0.11, 0.62, 0.46, 1], [0.73, 0.46, 0.09, 1], [0.89, 0.29, 0.29, 1]] select _hk);
		(_d displayCtrl 7955) ctrlSetStructuredText parseText format ["<t size='1.05' font='PuristaMedium'>%1%2</t>", round (_hull * 100), "%"];
		[_d displayCtrl 7956, ["Radar off", "Radar on"] select _radar, ["warn", "ok"] select _radar] call _badge;
		[_d displayCtrl 7957, ["Data link off", "Data link on"] select _radar, ["warn", "ok"] select _radar] call _badge;
		private _map = _ship getVariable ["MCCMK_radarMap", false];
		[_d displayCtrl 7958, ["Map off", "Map on"] select _map, ["off", "ok"] select _map] call _badge;
		private _info = [_ship] call MCCMK_fnc_shipWeaponInfo;
		for "_i" from 0 to (_nW - 1) do {
			(_info param [_i, []]) params [["_w", objNull], ["_name", ""], ["_st", ""], ["_dmg", 0], ["_frac", 0]];
			(_d displayCtrl (8000 + _i)) ctrlSetStructuredText parseText format ["<t size='0.95'>%1</t>", _name];
			private _dead = _st == "destroyed";
			switch (true) do {
				case (_dead): {[_d displayCtrl (8020 + _i), "Destroyed", "bad"] call _badge};
				case (_dmg > 0.01): {[_d displayCtrl (8020 + _i), format ["Damaged %1%2", round (_dmg * 100), "%"], "warn"] call _badge};
				default {[_d displayCtrl (8020 + _i), "OK", "ok"] call _badge};
			};
			[_d displayCtrl (8040 + _i), _rowBarW * ([_frac, 0] select _dead)] call _setW;
			(_d displayCtrl (8060 + _i)) ctrlSetStructuredText parseText format ["<t size='0.9' color='%1'>%2</t>", ["#ffffff", "#7f8a93"] select _dead, if (_dead) then {"-"} else {format ["%1%2", round (_frac * 100), "%"]}];
		};
		([_ship] call MCCMK_fnc_shipMaintCost) params ["_rep", "_ammo", "_rSup", "_rAmmo", "_nDam", "_nEmpty", "_nDest", "_hullC"];
		private _tile = {params ["_i", "_txt"]; if (_txt != "-" && {call MCCMK_fnc_resFree}) then {_txt = toString [8734]}; (_d displayCtrl (8080 + _i)) ctrlSetStructuredText parseText format ["<t size='0.95' color='%1'>%2</t>", ["#ffffff", "#7f8a93"] select (_txt == "-"), _txt]};
		[0, if (_rep > 0) then {format ["%1 Supply", _rep]} else {"-"}] call _tile;
		[1, if (_ammo > 0) then {format ["%1 Ammo", _ammo]} else {"-"}] call _tile;
		[2, if (_nDest > 0) then {format ["%1 Supply + %2 Ammo", _rSup, _rAmmo]} else {"-"}] call _tile;
		[3, if (_hullC > 0) then {format ["%1 Supply", _hullC]} else {"-"}] call _tile;
		private _cl = _ship getVariable ["MCCMK_contactLog", []];
		private _ct = if (!_radar) then {"<t size='0.9' color='#7f8a93'>Radar off - no contacts.</t>"} else {
			if (_cl isEqualTo []) then {"<t size='0.9' color='#7f8a93'>No contacts.</t>"} else {
				((+_cl call {reverse _this; _this}) select [0, 3]) apply {format ["<t size='0.9'>%1</t><t size='0.85' color='#7f8a93'>  ·  %2 min ago</t>", _x select 1, floor ((serverTime - (_x select 0)) / 60)]} joinString "<br/>"
			};
		};
		if ((_ship getVariable ["MCCMK_replacingUntil", 0]) > serverTime) then {_ct = _ct + format ["<br/><t size='0.9' color='#FAC775'>Replacing weapons: %1</t>", [((_ship getVariable ["MCCMK_replacingUntil", 0]) - serverTime), "MM:SS"] call BIS_fnc_secondsToString]};
		(_d displayCtrl 8090) ctrlSetStructuredText parseText _ct;
		private _want = uiNamespace getVariable "MCCMK_statusRadarWant";
		if (!isNil "_want" && {_want isEqualTo _radar}) then {
			uiNamespace setVariable ["MCCMK_statusRadarWant", nil];
			[["Radar off.", "Radar on."] select _radar] call MCCMK_fnc_shipStatusMsg;
		};
		if ((diag_tickTime - (uiNamespace getVariable ["MCCMK_statusMsgT", -100])) > 6) then {(_d displayCtrl 7951) ctrlSetStructuredText parseText ""};
		private _can = _free || {[player, _ship getVariable ["MCC_side", playerSide]] call MCCMK_fnc_shipCanCommand};
		{(_d displayCtrl (_x select 0)) ctrlEnable (_x select 1)} forEach [[7961, _can], [7967, _can], [7962, _can && {_rep > 0}], [7963, _can && {_ammo > 0}], [7964, _can && {_nDest > 0}], [7965, _can && {_hullC > 0}]];
		(_d displayCtrl 7961) ctrlSetText (["Radar: off", "Radar: on"] select _radar);
		(_d displayCtrl 7967) ctrlSetText (["Map: off", "Map: on"] select _map);
		private _hasGun = ((_ship getVariable ["MCCMK_weapons", []]) findIf {!isNull _x && {alive _x} && {(typeOf _x) isEqualTo "B_Ship_Gun_01_F"}}) >= 0;
		private _hasVLS = ((_ship getVariable ["MCCMK_weapons", []]) findIf {!isNull _x && {alive _x} && {(typeOf _x) isEqualTo "B_Ship_MRLS_01_F"}}) >= 0;
		(_d displayCtrl 7968) ctrlEnable (_can && {_hasGun});
		(_d displayCtrl 7969) ctrlEnable (_can && {_hasVLS});
		(_d displayCtrl 7968) ctrlSetText (["Guns: off", "Guns: on"] select (_ship getVariable ["MCCMK_navalGuns", false]));
		(_d displayCtrl 7969) ctrlSetText (["VLS: off", "VLS: on"] select (_ship getVariable ["MCCMK_navalVLS", false]));
		uiSleep 0.5;
	};
};
