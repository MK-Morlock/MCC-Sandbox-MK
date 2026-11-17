/*
	MCCMK_fnc_view3D - the MCC console's 3D View button: the 3D view
	(fnc\mkhq\altView\MCCMK_altView.sqf) on the unit selected in the Units / Groups list - a group: its leader (or the
	pilot / driver of the vehicle he is in). The console closes while it is open and opens again when it is left
	(right-click / Esc). The view's script is loaded the first time it is used. Run scheduled ([] spawn).
*/
disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
private _list = _d displayCtrl 3069;	// the Units / Groups list
private _row = (lbSelection _list) param [0, lbCurSel _list];
private _u = objNull;
private _selObj = objNull;	// what was selected in the list (a unit, or a group) - selected again on the way back
if (_row >= 0) then {
	if ((missionNamespace getVariable ["MCC_UMUnit", 0]) == 0) then {
		_u = (missionNamespace getVariable ["MCC_UMunitsNames", []]) param [_row, objNull];
		_selObj = _u;
	} else {
		private _g = (missionNamespace getVariable ["UMgroupNames", []]) param [_row, grpNull];
		if (!isNull _g) then {_u = leader _g; _selObj = _g};
	};
};
// the console as it was: the groups selected on the map, Units or Groups, and that row (back on the camera feed if it is on)
private _selGroups = +(missionNamespace getVariable ["MCC_GroupGenGroupSelected", []]);
private _selMode = missionNamespace getVariable ["MCC_UMUnit", 0];
if (!(_u isEqualType objNull) || {isNull _u} || {!alive _u}) exitWith {["Select a living unit or group in the Units / Groups list first."] call MCCMK_fnc_hint};
// the view's script, once
if (isNil "MCCMK_fnc_avOpen") then {
	[] execVM ((missionNamespace getVariable ["MCC_path", "\mcc_sandbox_mod\"]) + "mcc\fnc\mkhq\altView\MCCMK_altView.sqf");
	private _t = time + 10;
	waitUntil {!isNil "MCCMK_fnc_avOpen" || {time > _t}};
};
if (isNil "MCCMK_fnc_avOpen") exitWith {["3D View could not be started."] call MCCMK_fnc_hint};
if (missionNamespace getVariable ["MCCMK_av_on", false]) exitWith {};
// a group: its leader, or whoever flies / drives the vehicle he is in
if ((vehicle _u) != _u && {(missionNamespace getVariable ["MCC_UMUnit", 0]) != 0}) then {_u = [group _u] call MCCMK_fnc_avTarget};
["INFO", "MCCMK_fnc_view3D", "3D View on %1 (%2)", [name _u, typeOf (vehicle _u)]] call MCC_fnc_log;
// the console's map - its centre and zoom - kept, to be put back when the console opens again (a new map starts on the player)
// (from the map SHOWN: the normal one, 9000, or the contour one, 9010 - the map layers button)
private _map = _d displayCtrl ([9000, 9010] select (uiNamespace getVariable ["MCC_consoleMapContour", false]));
private _mapPos = [];
private _mapScale = -1;
if (!isNull _map) then {
	(ctrlPosition _map) params ["_mx", "_my", "_mw", "_mh"];
	_mapPos = _map ctrlMapScreenToWorld [_mx + _mw / 2, _my + _mh / 2];
	_mapScale = ctrlMapScale _map;
};
// the console out of the way, the view on, and the console back once it is left
while {dialog} do {closeDialog 0; uiSleep 0.05};
// (half a second for the console to be gone and the game's own input to be live again - opened straight away, the view's
//  mouse could find the look input silent)
private _tg = time + 2;
waitUntil {uiSleep 0.05; isNull (findDisplay 2994) || {time > _tg}};
uiSleep 0.5;
MCCMK_av_reqView = cameraView;
[_u] spawn MCCMK_fnc_avOpen;
private _t = time + 5;
waitUntil {(missionNamespace getVariable ["MCCMK_av_on", false]) || {time > _t}};
// the view distance for whoever is watched (with TAW View Distance: TAW's for what he is in), as he changes
["start", "3d", {missionNamespace getVariable ["MCCMK_av_unit", objNull]}] call MCCMK_fnc_vdFor;
waitUntil {uiSleep 0.25; !(missionNamespace getVariable ["MCCMK_av_on", false])};
["stop", "3d"] call MCCMK_fnc_vdFor;
uiSleep 0.3;
if (alive player && {!dialog}) then {
	[nil, nil, nil, nil, 0] execVM ((missionNamespace getVariable ["MCC_path", "\mcc_sandbox_mod\"]) + "mcc\Dialogs\mcc_PopupMenu.sqf");
	// (the console finished opening first - it sets its maps' own view as it opens)
	private _t2 = time + 5;
	waitUntil {uiSleep 0.1; !isNull ((uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]) displayCtrl 9000) || {time > _t2}};
	uiSleep 1;
	// the unit (or group) selected again - as a click on it in the list: on the small camera feed again if the feed is on
	private _d2 = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
	if (!isNull _d2 && {!isNull _selObj}) then {
		MCC_GroupGenGroupSelected = _selGroups select {!isNull _x};
		MCC_UMUnit = _selMode;
		(_d2 displayCtrl 9134) lbSetCurSel _selMode;
		[9134, _selMode] call MCC_fnc_umToolboxHighlight;
		MCC_UMFocus = false;
		[] call MCC_fnc_groupGenUMRefresh;
		private _list2 = _d2 displayCtrl 3069;
		private _row2 = if (_selMode == 0) then {(missionNamespace getVariable ["MCC_UMunitsNames", []]) find _selObj} else {(missionNamespace getVariable ["UMgroupNames", []]) find _selObj};
		if (_row2 >= 0) then {
			_list2 lbSetSelected [_row2, true];
			MCC_selectedUnits = [_selObj];
			ctrlSetFocus _list2;
			[4, [_list2, _row2]] execVM format ["%1mcc\general_scripts\unitManage\um.sqf", MCC_path];
		};
	};
	//(MK) THEN the zoom it had. Centred on the selected unit (as its selection does), else where the map was; both maps
	// (normal and contour).
	if (_mapScale > 0) then {
		uiSleep 0.8;	// (the selection's own 0.5 s re-centre done)
		private _d3 = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
		private _ctr = if (!isNull _selObj) then {
			private _o = if (_selObj isEqualType grpNull) then {leader _selObj} else {_selObj};
			if (!isNull _o) then {getPosATL (vehicle _o)} else {_mapPos}
		} else {_mapPos};
		{
			private _m2 = _d3 displayCtrl _x;
			if (!isNull _m2) then {_m2 ctrlMapAnimAdd [0, _mapScale, _ctr]; ctrlMapAnimCommit _m2};
		} forEach [9000, 9010];
	};
};
