/*
	MCCMK_fnc_shipPreview  (client) - after picking a ship's spot on the map (bought from the RTS screen): the RTS camera
	frames the spot and the ship's outline is drawn at sea level. Arrow keys move it (10 m; Shift: 2 m) relative to the
	camera, up to 300 m from the spot picked; Q / E rotate it (5 degrees; Shift: 1). Green / red as the map (the same
	check). Enter: confirm (the costs panel); Backspace: cancel. [ship type, position, direction, free, parent display]
*/
disableSerialization;
params [["_t", 0, [0]], ["_pos", [0, 0], [[]]], ["_dir", 0, [0]], ["_free", false, [true]], ["_parent", displayNull, [displayNull]]];
private _cam = missionNamespace getVariable ["MCC_CONST_CAM", objNull];
private _d = uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", displayNull];
if (isNull _cam || {isNull _d}) exitWith {["buy", _t, objNull, _pos, _dir, _free, _parent] call MCCMK_fnc_shipPickConfirm};
_pos = [_pos select 0, _pos select 1];
MCCMK_prev = [_t, +_pos, _dir, true, "", +_pos, _free, _parent];
private _half = (([_t] call MCCMK_fnc_shipCfg) select 3);
private _dist = ((_half select 1) * 1.8) + 60;
private _cp = _pos getPos [_dist, _dir + 180];
_cp set [2, ((_half select 1) * 0.9) + 60];
_cam setPos _cp;
_cam camSetTarget [_pos select 0, _pos select 1, 0];
_cam camCommit 0;
_cam camSetTarget objNull;
_cam camCommit 0;

MCCMK_prevCheck = {
	MCCMK_prev params ["_t", "_p", "_d"];
	([[_p select 0, _p select 1, 0], _d, _t, playerSide, objNull] call MCCMK_fnc_shipPosCheck) params ["_ok", ["_why", ""]];
	MCCMK_prev set [3, _ok];
	MCCMK_prev set [4, _why];
	private _txt = uiNamespace getVariable ["MCCMK_prevTxt", controlNull];
	if (!isNull _txt) then {
		_txt ctrlSetStructuredText parseText format ["<t align='center'>%1</t><br/><t align='center' color='#aaaaaa' size='0.9'>Arrows: move (Shift: fine)  -  Q / E: rotate (Shift: 1&#176;)  -  Enter: confirm  -  Backspace: cancel</t>",
			if (_ok) then {"<t color='#88ee88'>The ship can arrive here.</t>"} else {format ["<t color='#ff7777'>Not here: %1.</t>", _why]}];
	};
};
private _txt = _d ctrlCreate ["RscStructuredText", -1];
_txt ctrlSetPosition [safezoneX + safezoneW * 0.3, safezoneY + safezoneH * 0.1, safezoneW * 0.4, safezoneH * 0.05];
_txt ctrlSetBackgroundColor [0.055, 0.063, 0.07, 0.86];
_txt ctrlSetFontHeight (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 0.85);
_txt ctrlCommit 0;
uiNamespace setVariable ["MCCMK_prevTxt", _txt];
[] call MCCMK_prevCheck;

MCCMK_prevDraw = addMissionEventHandler ["Draw3D", {
	MCCMK_prev params ["_t", "_p", "_d", "_ok"];
	([_p, _d, _t, 40] call MCCMK_fnc_shipShape) params ["_corners", "_bowPt"];
	private _c = [[1, 0.3, 0.3, 1], [0.4, 1, 0.4, 1]] select _ok;
	private _w = _corners apply {[_x select 0, _x select 1, 1]};
	private _top = _corners apply {[_x select 0, _x select 1, 12]};
	{
		drawLine3D [ASLToAGL (_w select _forEachIndex), ASLToAGL (_w select ((_forEachIndex + 1) mod 4)), _c];
		drawLine3D [ASLToAGL (_top select _forEachIndex), ASLToAGL (_top select ((_forEachIndex + 1) mod 4)), _c];
		drawLine3D [ASLToAGL (_w select _forEachIndex), ASLToAGL (_top select _forEachIndex), _c];
	} forEach _w;
	drawLine3D [ASLToAGL [_p select 0, _p select 1, 6], ASLToAGL [_bowPt select 0, _bowPt select 1, 6], _c];
	drawIcon3D ["", _c, ASLToAGL [_bowPt select 0, _bowPt select 1, 14], 0, 0, 0, "BOW", 2, 0.035, "RobotoCondensedBold"];
}];

MCCMK_prevKeys = _d displayAddEventHandler ["KeyDown", {
	params ["_disp", "_key", "_shift"];
	MCCMK_prev params ["_t", "_p", "_d", "_ok", "_why", "_origin", "_free", "_parent"];
	private _cam = missionNamespace getVariable ["MCC_CONST_CAM", objNull];
	private _camDir = if (isNull _cam) then {0} else {getDir _cam};
	private _step = [10, 2] select _shift;
	private _rot = [5, 1] select _shift;
	private _move = {
		params ["_a"];
		private _np = _p getPos [_step, _camDir + _a];
		if ((_np distance2D _origin) <= 300) then {MCCMK_prev set [1, [_np select 0, _np select 1]]};
		[] call MCCMK_prevCheck;
	};
	switch (_key) do {
		case 200: {[0] call _move; true};
		case 208: {[180] call _move; true};
		case 203: {[270] call _move; true};
		case 205: {[90] call _move; true};
		case 16: {MCCMK_prev set [2, (_d - _rot + 360) mod 360]; [] call MCCMK_prevCheck; true};
		case 18: {MCCMK_prev set [2, (_d + _rot) mod 360]; [] call MCCMK_prevCheck; true};
		case 28;
		case 156: {
			if (!_ok) exitWith {[format ["The ship can't arrive there: %1.", _why]] call MCCMK_fnc_hint; true};
			[] call MCCMK_prevEnd;
			["buy", _t, objNull, [_p select 0, _p select 1, 0], _d, _free, _parent] call MCCMK_fnc_shipPickConfirm;
			true
		};
		case 14: {[] call MCCMK_prevEnd; true};
		default {false};
	};
}];
MCCMK_prevEnd = {
	removeMissionEventHandler ["Draw3D", missionNamespace getVariable ["MCCMK_prevDraw", -1]];
	private _d = uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", displayNull];
	if (!isNull _d) then {_d displayRemoveEventHandler ["KeyDown", missionNamespace getVariable ["MCCMK_prevKeys", -1]]};
	ctrlDelete (uiNamespace getVariable ["MCCMK_prevTxt", controlNull]);
};
// the RTS screen closed while previewing: tidy up
[] spawn {
	waitUntil {sleep 0.5; isNull (uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", displayNull]) || {isNull (uiNamespace getVariable ["MCCMK_prevTxt", controlNull])}};
	if (!isNull (uiNamespace getVariable ["MCCMK_prevTxt", controlNull]) || {isNull (uiNamespace getVariable ["MCC_LOGISTICS_BASE_BUILD", displayNull])}) then {[] call MCCMK_prevEnd};
};
