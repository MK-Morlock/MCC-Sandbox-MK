params [["_plane", objNull, [objNull]], ["_tgt", [0, 0, 0], [[]]]];
private _tASL = AGLToASL _tgt;
private _end = time + 60;
waitUntil {
	sleep 0.02;
	if (!alive _plane || {time > _end}) exitWith {true};
	private _v = velocity _plane;
	private _vh = vectorMagnitude [_v select 0, _v select 1, 0];
	private _h = (((getPosASL _plane) select 2) - (_tASL select 2)) max 0;
	private _vd = -(_v select 2);
	private _t = (_vd + sqrt ((_vd * _vd) + (2 * 9.81 * _h))) / 9.81;
	(_plane distance2D _tgt) <= (_vh * _t)
};
