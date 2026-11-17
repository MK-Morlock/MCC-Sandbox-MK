disableSerialization;
params [["_mode", "buy", [""]], ["_t", 0, [0]], ["_ship", objNull, [objNull]], ["_parent", displayNull, [displayNull]], ["_free", false, [true]]];
if (isNull _parent) then {_parent = findDisplay 46};
private _side = playerSide;
private _centre = if (!isNull _ship) then {getPos _ship} else {
	private _hq = missionNamespace getVariable [format ["MCC_START_%1", _side], []];
	if (_hq isEqualType [] && {count _hq > 1} && {!(_hq isEqualTo [0, 0, 0])}) then {_hq} else {getPos player}
};
private _startDir = if (!isNull _ship) then {getDir _ship} else {0};
uiNamespace setVariable ["MCCMK_pick", [_mode, _t, _ship, _side, [], false, _startDir, _free, _parent, !isNull _ship]];
MCCMK_fnc_pickUpdate = {
	params ["_d"];
	(uiNamespace getVariable ["MCCMK_pick", []]) params ["_mode", "_t", "_ship", "_side", "_last", "_ok", "_dir", "_free", "_parent", "_rot"];
	if (_last isEqualTo []) exitWith {};
	([_last, _dir, _t, _side, _ship] call MCCMK_fnc_shipPosCheck) params ["_good", "_why", "_depth"];
	uiNamespace setVariable ["MCCMK_pick", [_mode, _t, _ship, _side, _last, _good, _dir, _free, _parent, _rot]];
	([_t] call MCCMK_fnc_shipCfg) params ["_nm"];
	(_d displayCtrl 9603) ctrlSetStructuredText parseText format ["<t size='1.05'>%1 the %2: click a spot at sea.</t>  <t size='0.85' color='#aaaaaa'>Q / E rotate (Shift: 1&#176;), right-click or Esc cancels.</t><br/><t size='0.9' color='%3'>%4</t>", ["Place", "Move"] select (_mode == "move"), toLower _nm, ["#ff6666", "#99ff66"] select _good, if (_good) then {format ["OK - depth %1 m, heading %2&#176;, grid %3", _depth, round _dir, mapGridPosition _last]} else {format ["Can't place here: %1", _why]}];
};
private _d = _parent createDisplay "RscDisplayEmpty";
private _map = _d ctrlCreate ["RscMapControl", 9601];
_map ctrlSetPosition [safezoneX, safezoneY, safezoneW, safezoneH];
_map ctrlCommit 0;
_map ctrlMapAnimAdd [0, 0.12, _centre];
ctrlMapAnimCommit _map;
private _bar = _d ctrlCreate ["RscText", 9602];
_bar ctrlSetPosition [safezoneX + 0.25 * safezoneW, safezoneY + 0.02 * safezoneH, 0.5 * safezoneW, 0.075 * safezoneH];
_bar ctrlSetBackgroundColor [0.08, 0.09, 0.1, 0.9];
_bar ctrlCommit 0;
private _txt = _d ctrlCreate ["RscStructuredText", 9603];
_txt ctrlSetPosition [safezoneX + 0.26 * safezoneW, safezoneY + 0.025 * safezoneH, 0.48 * safezoneW, 0.07 * safezoneH];
_txt ctrlCommit 0;
([_t] call MCCMK_fnc_shipCfg) params ["_nm"];
_txt ctrlSetStructuredText parseText format ["<t size='1.05'>%1 the %2: click a spot at sea.</t>  <t size='0.85' color='#aaaaaa'>Q / E rotate (Shift: 1&#176;), right-click or Esc cancels.</t>", ["Place", "Move"] select (_mode == "move"), toLower _nm];
_map ctrlAddEventHandler ["MouseMoving", {
	params ["_c", "_mx", "_my"];
	(uiNamespace getVariable ["MCCMK_pick", []]) params ["_mode", "_t", "_ship", "_side", "_last", "_ok", "_dir", "_free", "_parent", "_rot"];
	private _p = _c ctrlMapScreenToWorld [_mx, _my];
	if (_last isNotEqualTo [] && {(_p distance2D _last) < 15}) exitWith {};
	if (!_rot) then {
		private _ref = missionNamespace getVariable [format ["MCC_START_%1", _side], []];
		if !(_ref isEqualType [] && {count _ref > 1} && {!(_ref isEqualTo [0, 0, 0])}) then {_ref = getPos player};
		_dir = if ((_ref distance2D _p) > 5) then {((_ref getDir _p) - ([180, 0, 0, 0] select _t) + 360) mod 360} else {0};
	};
	uiNamespace setVariable ["MCCMK_pick", [_mode, _t, _ship, _side, _p, _ok, _dir, _free, _parent, _rot]];
	[ctrlParent _c] call MCCMK_fnc_pickUpdate;
}];
_d displayAddEventHandler ["KeyDown", {
	params ["_d", "_key", "_shift"];
	if !(_key in [16, 18]) exitWith {false};
	(uiNamespace getVariable ["MCCMK_pick", []]) params ["_mode", "_t", "_ship", "_side", "_last", "_ok", "_dir", "_free", "_parent", "_rot"];
	private _step = [5, 1] select _shift;
	_dir = (_dir + ([_step, -_step] select (_key == 16)) + 360) mod 360;
	uiNamespace setVariable ["MCCMK_pick", [_mode, _t, _ship, _side, _last, _ok, _dir, _free, _parent, true]];
	[_d] call MCCMK_fnc_pickUpdate;
	true
}];
_map ctrlAddEventHandler ["Draw", {
	params ["_c"];
	(uiNamespace getVariable ["MCCMK_pick", []]) params ["_mode", "_t", "_ship", "_side", "_last", "_ok", "_dir"];
	if (_last isEqualTo []) exitWith {};
	[_c, _last, _dir, _t, [[1, 0.3, 0.3, 1], [0.4, 1, 0.4, 1]] select _ok] call MCCMK_fnc_shipDraw;
}];
_map ctrlAddEventHandler ["MouseButtonClick", {
	params ["_c", "_b"];
	if (_b == 1) exitWith {(ctrlParent _c) closeDisplay 2};
	if (_b != 0) exitWith {};
	(uiNamespace getVariable ["MCCMK_pick", []]) params ["_mode", "_t", "_ship", "_side", "_last", "_ok", "_dir", "_free", "_parent"];
	if (!_ok || {_last isEqualTo []}) exitWith {};
	(ctrlParent _c) closeDisplay 1;
	// buying from the RTS screen: a 3D preview first, to rotate / nudge it before confirming (MCCMK_fnc_shipPreview)
	if (_mode == "buy" && {!isNull (missionNamespace getVariable ["MCC_CONST_CAM", objNull])} && {!isNull (uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", displayNull])}) exitWith {
		[_t, _last, _dir, _free, _parent] call MCCMK_fnc_shipPreview;
	};
	[_mode, _t, _ship, _last, _dir, _free, _parent] call MCCMK_fnc_shipPickConfirm;
}];
