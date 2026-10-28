params ["_ctrl", "_rt", "_cam", "_getTarget", "_isOpen"];
disableSerialization;

private _res = missionNamespace getVariable ["MCC_pipResolution", 1024];
(ctrlPosition _ctrl) params ["", "", "_w", "_h"];
private _aspect = if (_h > 0) then {((_w / pixelW) / (_h / pixelH)) max 0.25} else {1};
_ctrl ctrlSetText format ["#(argb,%1,%1,1)r2t(%2,%3)", _res, _rt, _aspect];
[_cam, _rt] spawn {
	params ["_cam2", "_rt2"];
	uiSleep 0.3;
	if (!isNull _cam2) then {_cam2 cameraEffect ["INTERNAL", "BACK", _rt2]};
};

private _view = 0;
_cam camSetFov 0.75;
MCC_pipState = [_cam, _getTarget, _isOpen, _view, nil, nil, diag_tickTime];

private _old = missionNamespace getVariable ["MCC_pipFollowEH", -1];
if (_old >= 0) then {removeMissionEventHandler ["EachFrame", _old]};

MCC_pipFollowEH = addMissionEventHandler ["EachFrame", {
	private _data = missionNamespace getVariable ["MCC_pipState", []];
	if (_data isEqualTo [] || {isNull (_data select 0)} || {!(call (_data select 2))}) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
		MCC_pipFollowEH = -1;
	};
	_data params ["_cam", "_getTarget", "_isOpen", "_view", "_curPos", "_curDir", ["_lastTick", diag_tickTime]];
	private _dt = ((diag_tickTime - _lastTick) max 0.001) min 0.5;
	private _t = vehicle (call _getTarget);
	if (isNull _t) exitWith {};

	private _size = ((sizeOf typeOf _t) max 2) min 40;
	private _isMan = _t isKindOf "CAManBase";
	private _tPos = getPosASLVisual _t;
	private _heading = getDirVisual _t;

	private _s = ((missionNamespace getVariable ["MCC_pipSmoothing", 0.85]) min 0.97) max 0;
	private _a = 1 - (_s ^ ((_dt * 30) max 0.01));
	if (isNil "_curDir") then {_curDir = _heading; _a = 1};
	_curDir = _curDir + ((((_heading - _curDir) + 540) mod 360) - 180) * _a;

	private _orbit = missionNamespace getVariable ["MCC_pipOrbit", [0, 0, 0.75]];
	_orbit params [["_oYaw", 0], ["_oPitch", 0], ["_oZoom", 0.75]];
	private _back = if (_isMan) then {4.5} else {5 + _size * 1.3};
	private _upB = if (_isMan) then {0.6} else {2 + _size * 0.5};
	private _dist = ((sqrt (_back ^ 2 + _upB ^ 2)) * _oZoom) max ([_size * 0.5 + 0.5, 1.2] select _isMan);
	private _elev = ((atan (_upB / _back)) + _oPitch) max -40 min 80;
	private _az = _curDir + 180 + _oYaw;
	private _center = _tPos vectorAdd [0, 0, [_size * 0.25, 1.0] select _isMan];
	if (!_isMan) then {
		(boundingBoxReal _t) params ["_bb1", "_bb2"];
		_center = AGLToASL (_t modelToWorldVisual ((_bb1 vectorAdd _bb2) vectorMultiply 0.5));
	};
	if (_isMan) then {
		private _sp = _t selectionPosition "spine3";
		if !(_sp isEqualTo [0,0,0]) then {_center = AGLToASL (_t modelToWorldVisual _sp)};
	};
	private _want = _center vectorAdd [(sin _az) * (cos _elev) * _dist, (cos _az) * (cos _elev) * _dist, (sin _elev) * _dist];
	private _gz = (getTerrainHeightASL _want) + 0.5;
	if ((_want select 2) < _gz) then {
		private _el2 = asin ((((_gz - (_center select 2)) / (_dist max 0.1)) max -1) min 1);
		_want = _center vectorAdd [(sin _az) * (cos _el2) * _dist, (cos _az) * (cos _el2) * _dist, (sin _el2) * _dist];
		_want set [2, (_want select 2) max ((getTerrainHeightASL _want) + 0.5)];
		private _o = missionNamespace getVariable ["MCC_pipOrbit", []];
		if (count _o > 1 && {(_o select 1) < (_el2 - (atan (_upB / _back)))}) then {_o set [1, (_el2 - (atan (_upB / _back))) min 70]};
	};
	private _wantOff = _want vectorDiff _center;
	if (isNil "_curPos") then {_curPos = _wantOff};
	_curPos = _curPos vectorAdd ((_wantOff vectorDiff _curPos) vectorMultiply _a);
	private _camPos = _center vectorAdd _curPos;
	_camPos set [2, (_camPos select 2) max ((getTerrainHeightASL _camPos) + 0.5)];

	private _look = _center;

	_cam camSetPos (ASLToAGL _camPos);
	_cam camSetTarget (ASLToAGL _look);
	_cam camCommit 0;
	MCC_pipState = [_cam, _getTarget, _isOpen, _view, _curPos, _curDir, diag_tickTime];
}];
true
