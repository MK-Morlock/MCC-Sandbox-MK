params ["_target", ["_mode", 0], ["_orbit", [0, 0, 0.75]]];
if (missionNamespace getVariable ["MCC_isBroadcasting", false]) exitWith {};
if (isNull _target) exitWith {};
MCC_isBroadcasting = true;
if (isNil {missionNamespace getVariable "MCC_bcOrbit"}) then {MCC_bcOrbit = +_orbit};

private _source = "Sign_Sphere10cm_F" createVehicleLocal [0, 0, 0];	//local: only this player's camera follows it
_source hideObject true;
_source setPosASL ((getPosASL (vehicle _target)) vectorAdd [0, -6, 3]);

MCC_bcState = [_source, _target, nil, nil, diag_tickTime];
MCC_bcEH = addMissionEventHandler ["EachFrame", {
	private _st = missionNamespace getVariable ["MCC_bcState", []];
	if (_st isEqualTo [] || {isNull (_st select 0)}) exitWith {removeMissionEventHandler ["EachFrame", _thisEventHandler]};
	_st params ["_src", "_unit", "_curDir", "_curPos", "_last"];
	private _t = vehicle _unit;
	if (isNull _t) exitWith {};
	private _dt = ((diag_tickTime - _last) max 0.001) min 0.5;
	private _s = ((missionNamespace getVariable ["MCC_pipSmoothing", 0.85]) min 0.97) max 0;
	private _a = 1 - (_s ^ ((_dt * 30) max 0.01));
	private _heading = getDirVisual _t;
	if (isNil "_curDir") then {_curDir = _heading; _a = 1};
	_curDir = _curDir + ((((_heading - _curDir) + 540) mod 360) - 180) * _a;

	//Same chase camera as the console feed (MCC_fnc_pipFollow), with the console's swing / tilt / zoom
	(missionNamespace getVariable ["MCC_bcOrbit", [0, 0, 0.75]]) params [["_oYaw", 0], ["_oPitch", 0], ["_oZoom", 0.75]];
	private _size = ((sizeOf typeOf _t) max 2) min 40;
	private _isMan = _t isKindOf "CAManBase";
	private _back = if (_isMan) then {4.5} else {5 + _size * 1.3};
	private _upB = if (_isMan) then {0.6} else {2 + _size * 0.5};
	private _dist = ((sqrt (_back ^ 2 + _upB ^ 2)) * _oZoom) max ([_size * 0.5 + 0.5, 1.2] select _isMan);
	private _elev = ((atan (_upB / _back)) + _oPitch) max -40 min 80;
	private _az = _curDir + 180 + _oYaw;
	private _center = (getPosASLVisual _t) vectorAdd [0, 0, [_size * 0.25, 1.0] select _isMan]; if (!_isMan) then {(boundingBoxReal _t) params ["_bb1", "_bb2"]; _center = AGLToASL (_t modelToWorldVisual ((_bb1 vectorAdd _bb2) vectorMultiply 0.5))};
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
	};
	if (isNil "_curPos") then {_curPos = _want};
	_curPos = _curPos vectorAdd ((_want vectorDiff _curPos) vectorMultiply _a);
	_src setPosASL _curPos;
	private _bcCam = missionNamespace getVariable ["MCC_bcCam", objNull];
	if (!isNull _bcCam) then {_bcCam setPosASL _curPos; _bcCam camSetTarget (ASLToAGL _center); _bcCam camCommit 0};
	MCC_bcState = [_src, _unit, _curDir, _curPos, diag_tickTime];
}];

private _bcCam = "camera" camCreate (ASLToAGL (getPosASL _source));
MCC_bcCam = _bcCam;
_bcCam cameraEffect ["INTERNAL", "BACK", "mccbroadcastrt"];
["mccbroadcastrt", _mode, ""] call MCC_fnc_feedVision;
"MCC_bcLayer" cutRsc ["MCC_rscBroadcast", "PLAIN"];
private _disp = uiNamespace getVariable ["MCC_rscBroadcast", displayNull];
if (!isNull _disp) then {
	private _pic = _disp displayCtrl 1;
	private _res = missionNamespace getVariable ["MCC_pipResolution", 1024];
	(ctrlPosition _pic) params ["", "", "_w", "_h"];
	private _aspect = if (_h > 0) then {((_w / pixelW) / (_h / pixelH)) max 0.25} else {1};
	_pic ctrlSetText format ["#(argb,%1,%1,1)r2t(mccbroadcastrt,%2)", _res, _aspect];
};

sleep 25;

"MCC_bcLayer" cutText ["", "PLAIN"];
_bcCam cameraEffect ["TERMINATE", "BACK"];
camDestroy _bcCam;
MCC_bcCam = objNull;
if (!isNil "MCC_PIPcam" && {!isNull MCC_PIPcam} && {!isNull (uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull])}) then {
	MCC_PIPcam cameraEffect ["INTERNAL", "BACK", "rendertarget10"];
	["rendertarget10", missionNamespace getVariable ["MCC_UMPIPView", 0], ""] call MCC_fnc_feedVision;
};
removeMissionEventHandler ["EachFrame", missionNamespace getVariable ["MCC_bcEH", -1]];
MCC_bcState = [];
deleteVehicle _source;
MCC_bcOrbit = nil;
MCC_isBroadcasting = false;
