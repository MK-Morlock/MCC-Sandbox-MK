/*================================================================== MCC_fnc_consoleMapFollow ==================================================================
	Commander console maps: keep the map centred on a moving object (cruise missile, UAV, gunship, evac helicopter) until
	the object is gone, another follow starts, or you right-click on the map to look elsewhere (then it stays where you put it).
	Done in the map's Draw event (every frame, smooth). Each frame the object's offset from the middle of the map is corrected,
	so it stays centred even where the map's own centre is not the middle of the control (it sat in the top-left corner).
	<IN>	0: CONTROL map
			1: OBJECT  what to follow
==============================================================================================================================================================*/
disableSerialization;
params [["_map", controlNull, [controlNull]], ["_target", objNull, [objNull]]];
if (isNull _map || {isNull _target}) exitWith {};

_map setVariable ["MCC_followTarget", _target];
_map setVariable ["MCC_followAim", getPosVisual _target];
MCC_mapFollowStopped = false;

if !(_map getVariable ["MCC_followEH", false]) then {
	_map setVariable ["MCC_followEH", true];
	//Right mouse button on the map: stop following
	_map ctrlAddEventHandler ["MouseButtonDown", {
		params ["", "_button"];
		if (_button == 1) then {MCC_mapFollowStopped = true};
	}];
	_map ctrlAddEventHandler ["Draw", {
		params ["_m"];
		private _t = _m getVariable ["MCC_followTarget", objNull];
		if (isNull _t || {!alive _t} || {missionNamespace getVariable ["MCC_mapFollowStopped", false]}) exitWith {};
		(ctrlPosition _m) params ["_x", "_y", "_w", "_h"];
		private _g = ctrlParentControlsGroup _m;
		if (!isNull _g) then {(ctrlPosition _g) params ["_gx", "_gy"]; _x = _x + _gx; _y = _y + _gy};
		private _c = _m ctrlMapScreenToWorld [_x + _w / 2, _y + _h / 2];
		private _tp = getPosVisual _t;
		private _aim = _m getVariable ["MCC_followAim", _tp];
		_aim = [(_aim select 0) + ((_tp select 0) - (_c select 0)), (_aim select 1) + ((_tp select 1) - (_c select 1)), 0];
		_m setVariable ["MCC_followAim", _aim];
		_m ctrlMapAnimAdd [0, ctrlMapScale _m, _aim];
		ctrlMapAnimCommit _m;
	}];
};
