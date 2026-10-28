disableSerialization;
params [["_mode", "init", [""]], ["_screen", "console", [""]]];
//[display, normal map idc, contour map idc, button idcs [round, icon, button] or [], memory key, draw handlers]
private _cfg = switch (_screen) do {
	case "cc": {[findDisplay 2993, 9120, 9130, [-1, -1, 9133], "MCC_ccMapContour", ["_this call MCC_fnc_mapDrawWPConsole;"]]};
	case "pda": {[uiNamespace getVariable ["MCC_SQLPDA", displayNull], 9120, 9130, [9131, 9132, 9133], "MCC_pdaMapContour", ["_this call MCC_fnc_mapDrawWPPDA;"]]};
	case "pdaRsc": {[uiNamespace getVariable ["MCC_SQLPDA_rscDisp", displayNull], 9120, 9130, [], "MCC_pdaMapContour", ["_this call MCC_fnc_mapDrawWPPDA;"]]};
	default {[uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull], 9000, 9010, [9011, 9012, 9013], "MCC_consoleMapContour", ["_this call MCC_fnc_mapDrawWP;"]]};
};
_cfg params ["_d", "_mapIdc", "_topoIdc", "_btns", "_key", "_draws"];
if (isNull _d) exitWith {};
private _map = _d displayCtrl _mapIdc;
private _topo = _d displayCtrl _topoIdc;
if (isNull _map || {isNull _topo}) exitWith {};

_topo ctrlSetPosition (ctrlPosition _map);
_topo ctrlCommit 0;
private _ctrPt = {(ctrlPosition _map) params ["_x", "_y", "_w", "_h"]; [_x + _w / 2, _y + _h / 2]};
private _fnc_view = {	//[scale, world position at the normal map's centre point]
	params ["_c"];
	[ctrlMapScale _c, _c ctrlMapScreenToWorld (call _ctrPt)]
};
private _fnc_setView = {
	params ["_c", "_v"];
	_c ctrlMapAnimAdd [0, _v select 0, _v select 1];
	ctrlMapAnimCommit _c;
};

if (_mode == "init") then {
	//same place and size as the normal map (the PDA sizes its map by its scale setting)
	_topo ctrlSetPosition (ctrlPosition _map);
	_topo ctrlCommit 0;
	{_topo ctrlAddEventHandler ["Draw", _x]} forEach _draws;
	//Track units (MCC console): only while the console's Track units button has it on, as on the terrain map (um.sqf adds /
	//removes it on both maps) - it was added for good by mistake and drew editor-style unit icons and leader lines
	if (_screen == "console" && {missionNamespace getVariable ["MCC_trackMarker", false]}) then {
		MCC_trackMarkerHandlerC = _topo ctrlAddEventHandler ["Draw", "_this call MCC_fnc_trackUnits;"];
	};
	//the button: top right of the map, the same distance from the corner as the MCC console's (?) button from its corner
	if (count _btns == 3 && {_screen == "pda"}) then {	//(PDA only: its map is sized by its scale setting; the MCC console's button is placed by its dialog; the Commander Console uses its Fn key)
		(ctrlPosition _map) params ["_mx", "_my", "_mw", "_mh"];
		private _bw = 0.0103125 * safezoneW; private _bh = 0.0165 * safezoneH;
		private _bx = _mx + _mw - 0.0021875 * safezoneW - _bw; private _by = _my + 0.0009 * safezoneH;
		(_d displayCtrl (_btns select 0)) ctrlSetPosition [_bx, _by, _bw, _bh];
		(_d displayCtrl (_btns select 1)) ctrlSetPosition [_bx + 0.0015 * safezoneW, _by + 0.00225 * safezoneH, _bw - 0.003 * safezoneW, _bh - 0.0045 * safezoneH];
		(_d displayCtrl (_btns select 2)) ctrlSetPosition [_bx, _by, _bw, _bh];
		{(_d displayCtrl _x) ctrlCommit 0} forEach _btns;
	};
};

private _contour = uiNamespace getVariable [_key, false];
//The view to carry over is read from the map shown NOW, before switching
private _carry = [];
if (_mode == "toggle") then {
	_carry = [[_map] call _fnc_view, [_topo] call _fnc_view] select (uiNamespace getVariable [_key, false]);
	_contour = !_contour;
	uiNamespace setVariable [_key, _contour];
};
if (_mode in ["init", "init2"] && {_contour}) then {_carry = [_map] call _fnc_view};
_topo ctrlShow _contour;
_map ctrlShow !_contour;
_map ctrlEnable true;
_map ctrlCommit 0;
_topo ctrlCommit 0;
if (count _carry == 2) then {
	private _shown = [_map, _topo] select _contour;
	private _offKey = format ["MCC_layersOff_%1_%2_%3", _screen, (ctrlPosition _map) apply {round (_x * 1000)}, _contour];
	private _offN = uiNamespace getVariable [_offKey, [0, 0, 0]];
	private _aim = (_carry select 1) vectorAdd (_offN vectorMultiply (_carry select 0));
	[_shown, [_carry select 0, _aim]] call _fnc_setView;
	[_shown, _carry, _aim, _offN, _offKey, _fnc_setView, _map, _topo, _screen] spawn {
		params ["_c", "_v", "_aim", "_offN", "_offKey", "_f", "_m", "_t", "_scr"];
		uiSleep 0.1;
		if (isNull _c) exitWith {};
		(ctrlPosition _m) params ["_x", "_y", "_w", "_h"];
		private _got = _c ctrlMapScreenToWorld [_x + _w / 2, _y + _h / 2];
		private _miss = (_v select 1) vectorDiff _got;
		if ((vectorMagnitude [_miss select 0, _miss select 1, 0]) > 1) then {
			private _newAim = _aim vectorAdd _miss;
			[_c, [_v select 0, _newAim]] call _f;
			uiNamespace setVariable [_offKey, (_newAim vectorDiff (_v select 1)) vectorMultiply (1 / ((_v select 0) max 0.0001))];
		};
		//Debug logging (only with MCC debug on): the map moving when switching
		uiSleep 0.25;
		if (isNull _c) exitWith {};
		private _now = [ctrlMapScale _c, _c ctrlMapScreenToWorld [_x + _w / 2, _y + _h / 2]];
		["DEBUG", "mapLayers", "%1 switch | carried centre %2 | now centre %3 | moved %4 m | corrected on this switch: %5", [_scr, (_v select 1) apply {round _x}, (_now select 1) apply {round _x}, round ((_v select 1) distance2D (_now select 1)), (vectorMagnitude [_miss select 0, _miss select 1, 0]) > 1]] call MCC_fnc_log;
	};
};
//the PDA pinned to the screen shows the PDA's choice
if (_mode == "toggle" && {_screen == "pda"}) then {["init2", "pdaRsc"] call MCC_fnc_consoleMapLayers};
//MCC console: the panel behind the map is paper-coloured in contour view - the contour map's paper is one layer, so at the
//transparency slider's fade the dark grey panel showed through and the land looked dark (alpha kept from the slider)
if (_screen == "console") then {
	private _bg = _d displayCtrl 9001;
	private _a = uiNamespace getVariable ["MCC_consoleMapBgAlpha", 1];
	_bg ctrlSetBackgroundColor (([[0.17, 0.18, 0.20], [0.969, 0.957, 0.949]] select _contour) + [_a]);
	_bg ctrlCommit 0;
};
if (count _btns == 3) then {
	(_d displayCtrl (_btns select 2)) ctrlSetTooltip "Map Layers";
};
