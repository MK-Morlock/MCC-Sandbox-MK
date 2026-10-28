/*================================================================== MCC_fnc_assetsPreview ==================================================================
	3D preview on the console Assets page. The chosen class is created high above the sea outside the map, and a camera
	renders it into the preview picture (render target mccassetrt). Vehicles and objects are lightweight model objects
	that exist only on this computer. Soldiers are a switched-off unit (no AI, no movement, no damage) so that head, face
	and equipment show; such a unit exists for the other players too, but far off the map, and only while the page is open.

	Mouse over the preview: left-drag turns the view, right-drag moves it, the wheel zooms. Buttons under the preview do
	the same (Left, Right, Up, Down, +, -) and Reset view goes back to the starting view. The mouse is read from the
	page itself (display event handlers), because the picture control does not report mouse events.

	Modes
		["show", [class]]   preview a class (removes the previous one first)
		["attach", [display]]   add the mouse handlers to the Assets page
		["panLeft"] ["panRight"] ["panUp"] ["panDown"] ["zoomIn"] ["zoomOut"] ["reset"]
		["close"]           remove the object, light and camera (page closed)
	State (missionNamespace MCC_assetPrev): [object, camera, size, yaw, pitch, distance, panX, panY]
==============================================================================================================================================================*/
#define IDC_PREVIEW 9530
params [["_mode", "", [""]], ["_args", []]];
//Show runs in one go: two shows started at the same moment (picking a row also selects a suggestion) both created an
//object and only one was remembered, so the other was never deleted
if (_mode == "show" && {canSuspend}) exitWith {isNil {["show", _args] call MCC_fnc_assetsPreview}};
private _state = missionNamespace getVariable ["MCC_assetPrev", []];
private _log = {	//only with MCC debug on (it confirmed the preview works)
	params ["_what"];
	if !(missionNamespace getVariable ["MCC_debug", false]) exitWith {};
	private _s = missionNamespace getVariable ["MCC_assetPrev", []];
	private _cam = _s param [1, objNull];
	if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC [PREVIEW] %1 | object %2 | camera %3 at %4 | yaw %5 pitch %6 dist %7 pan %8", _what,
		typeOf (_s param [0, objNull]), !isNull _cam, if (isNull _cam) then {"-"} else {(getPosASL _cam) apply {round _x}},
		_s param [3, "-"], _s param [4, "-"], _s param [5, "-"], [_s param [6, "-"], _s param [7, "-"]]]};
};

private _update = {
	private _s = missionNamespace getVariable ["MCC_assetPrev", []];
	if (count _s < 8) exitWith {};
	_s params ["_obj", "_cam", "_size", "_yaw", "_pitch", "_dist", "_panX", "_panY"];
	if (isNull _obj || {isNull _cam}) exitWith {};
	//Aim at the middle of the model (a soldier position is at his feet), moved by the pan
	private _bb = boundingBoxReal _obj;
	private _c = _obj modelToWorldWorld (((_bb select 0) vectorAdd (_bb select 1)) vectorMultiply 0.5);
	private _right = [cos _yaw, -(sin _yaw), 0];
	_c = _c vectorAdd (_right vectorMultiply _panX) vectorAdd [0, 0, _panY];
	private _off = [(sin _yaw) * (cos _pitch) * _dist, (cos _yaw) * (cos _pitch) * _dist, (sin _pitch) * _dist];
	_cam camSetPos (ASLToAGL (_c vectorAdd _off));
	_cam camSetTarget (ASLToAGL _c);
	_cam camSetFov 0.75;
	_cam camCommit 0;
	private _light = missionNamespace getVariable ["MCC_assetPrevLight", objNull];
	if (!isNull _light) then {_light setPosASL (_c vectorAdd (_off vectorMultiply 0.8))};
};
private _set = {
	params ["_i", "_v"];
	_state set [_i, _v];
	missionNamespace setVariable ["MCC_assetPrev", _state];
	call _update;
};
private _overPreview = {
	private _d = findDisplay 1031985;
	if (isNull _d) exitWith {false};
	(ctrlPosition (_d displayCtrl IDC_PREVIEW)) params ["_px", "_py", "_pw", "_ph"];
	getMousePosition params ["_mx", "_my"];
	_mx >= _px && {_mx <= _px + _pw} && {_my >= _py} && {_my <= _py + _ph}
};

switch (_mode) do {
	case "attach": {
		_args params [["_d", displayNull]];
		if (isNull _d) exitWith {};
		["attach mouse handlers"] call _log;
		_d displayAddEventHandler ["MouseButtonDown", {
			params ["", "_button"];
			private _over = ["over"] call MCC_fnc_assetsPreview;
			if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text format ["MCC [PREVIEW] mouse button %1 down, over preview %2, mouse %3", _button, _over, getMousePosition]};
			if (_button in [0, 1] && {_over}) then {missionNamespace setVariable ["MCC_assetPrevDrag", _button]};
		}];
		_d displayAddEventHandler ["MouseButtonUp", {missionNamespace setVariable ["MCC_assetPrevDrag", -1]}];
		_d displayAddEventHandler ["MouseMoving", {
			params ["", "_dx", "_dy"];
			private _b = missionNamespace getVariable ["MCC_assetPrevDrag", -1];
			if (_b >= 0) then {["drag", [_b, _dx, _dy]] call MCC_fnc_assetsPreview};
		}];
		_d displayAddEventHandler ["MouseZChanged", {
			params ["", "_z"];
			if (["over"] call MCC_fnc_assetsPreview) then {["zoom", [_z]] call MCC_fnc_assetsPreview};
		}];
	};

	case "over": {call _overPreview};

	case "show": {
		_args params [["_class", "", [""]]];
		if (_class == "" || {!isClass (configFile >> "CfgVehicles" >> _class)}) exitWith {};
		if (count _state > 0 && {!isNull (_state select 0)} && {typeOf (_state select 0) == _class}) exitWith {};
		//Remove every earlier preview object before the new one is created
		{deleteVehicle _x} forEach (missionNamespace getVariable ["MCC_assetPrevObjects", []]);
		missionNamespace setVariable ["MCC_assetPrevObjects", []];

		private _pos = [-1500, -1500, 1500];
		private _obj = objNull;
		if (_class isKindOf "CAManBase") then {
			_obj = createAgent [_class, [0, 0, 0], [], 0, "CAN_COLLIDE"];
			_obj enableSimulation false;
			_obj allowDamage false;
			_obj disableAI "ALL";
			_obj setVariable ["MCC_assetPreviewDummy", true, true];
			_obj setPosASL _pos;
		} else {
			_obj = createSimpleObject [_class, _pos, true];
		};
		if (isNull _obj) then {
			_obj = _class createVehicleLocal [0, 0, 0];
			_obj enableSimulation false;
			_obj setPosASL _pos;
		};
		_obj setDir 0;
		missionNamespace setVariable ["MCC_assetPrevObjects", [_obj]];

		//Size: the largest side of the model; the start distance shows all of it with a margin
		private _bb = boundingBoxReal _obj;
		private _dims = (_bb select 1) vectorDiff (_bb select 0);
		private _size = ((_dims select 0) max (_dims select 1) max (_dims select 2)) max 0.5;

		private _cam = if (count _state > 1 && {!isNull (_state select 1)}) then {_state select 1} else {
			private _c = "camera" camCreate (ASLToAGL _pos);
			_c cameraEffect ["INTERNAL", "BACK", "mccassetrt"];
			"mccassetrt" setPiPEffect [0];
			_c
		};
		private _light = missionNamespace getVariable ["MCC_assetPrevLight", objNull];
		if (isNull _light && {sunOrMoon < 0.5}) then {
			_light = "#lightpoint" createVehicleLocal [0, 0, 0];
			_light setLightBrightness 4;
			_light setLightAmbient [1, 1, 1];
			_light setLightColor [1, 1, 1];
			missionNamespace setVariable ["MCC_assetPrevLight", _light];
		};
		//Front three-quarter view from slightly above (models face north)
		missionNamespace setVariable ["MCC_assetPrev", [_obj, _cam, _size, 30, 15, _size * 1.9, 0, 0]];
		call _update;
		//Bind the picture to the camera picture now that the camera exists (set before, it can stay on its first frame)
		[] spawn {
			for "_i" from 1 to 2 do {
				sleep 0.1;
				private _d = findDisplay 1031985;
				if (!isNull _d) then {(_d displayCtrl 9530) ctrlSetText "#(argb,512,512,1)r2t(mccassetrt,1.0)"};
			};
		};
		[format ["show %1 (size %2)", _class, _size toFixed 1]] call _log;
	};

	case "drag": {
		_args params ["_b", "_dx", "_dy"];
		if (diag_tickTime - (missionNamespace getVariable ["MCC_assetPrevDragLog", 0]) > 1) then {
			missionNamespace setVariable ["MCC_assetPrevDragLog", diag_tickTime];
			[format ["drag button %1 dx %2 dy %3", _b, _dx, _dy]] call _log;
		};
		if (count _state < 8) exitWith {};
		if (_b == 0) then {
			_state set [3, ((_state select 3) + _dx * 4) mod 360];
			_state set [4, (((_state select 4) + _dy * 3) max -85) min 85];
		} else {
			private _step = (_state select 5) * 0.004;
			_state set [6, (_state select 6) + _dx * _step];	//right-drag: the view follows the mouse sideways
			_state set [7, (_state select 7) + _dy * _step];
		};
		missionNamespace setVariable ["MCC_assetPrev", _state];
		call _update;
	};

	case "zoom": {
		_args params [["_z", 0]];
		[format ["wheel %1", _z]] call _log;
		if (count _state < 8) exitWith {};
		private _s = _state select 2;
		[5, (((_state select 5) * (1 - _z * 0.1)) max (_s * 0.6)) min (_s * 6)] call _set;
	};
	case "zoomIn": {["zoomIn"] call _log; if (count _state >= 8) then {[5, ((_state select 5) * 0.85) max ((_state select 2) * 0.6)] call _set}};
	case "zoomOut": {["zoomOut"] call _log; if (count _state >= 8) then {[5, ((_state select 5) * 1.18) min ((_state select 2) * 6)] call _set}};
	case "panLeft": {["panLeft"] call _log; if (count _state >= 8) then {[6, (_state select 6) - (_state select 2) * 0.1] call _set}};
	case "panRight": {["panRight"] call _log; if (count _state >= 8) then {[6, (_state select 6) + (_state select 2) * 0.1] call _set}};
	case "panUp": {["panUp"] call _log; if (count _state >= 8) then {[7, (_state select 7) + (_state select 2) * 0.1] call _set}};
	case "panDown": {["panDown"] call _log; if (count _state >= 8) then {[7, (_state select 7) - (_state select 2) * 0.1] call _set}};
	case "reset": {
		if (count _state >= 8) then {
			_state set [3, 30]; _state set [4, 15]; _state set [5, (_state select 2) * 1.9]; _state set [6, 0]; _state set [7, 0];
			missionNamespace setVariable ["MCC_assetPrev", _state];
			call _update;
		};
	};

	case "close": {
		{deleteVehicle _x} forEach (missionNamespace getVariable ["MCC_assetPrevObjects", []]);
		missionNamespace setVariable ["MCC_assetPrevObjects", []];
		if (count _state > 1) then {
			private _cam = _state select 1;
			if (!isNull _cam) then {_cam cameraEffect ["TERMINATE", "BACK"]; camDestroy _cam};
		};
		deleteVehicle (missionNamespace getVariable ["MCC_assetPrevLight", objNull]);
		missionNamespace setVariable ["MCC_assetPrev", []];
		missionNamespace setVariable ["MCC_assetPrevLight", objNull];
		missionNamespace setVariable ["MCC_assetPrevDrag", -1];
	};
};
