params [["_h", objNull], ["_pt", [0, 0, 0]], ["_cond", {true}]];
if (isNull _h || {!alive _h}) exitWith {false};
private _mkDescId = diag_tickTime + random 1;
_h setVariable ["MCCMK_glideId", _mkDescId];
private _mkTgt = 1e9;
private _mkStill = 0;
private _mkReady = false;
while {alive _h && {(_h getVariable ["MCCMK_glideId", 0]) isEqualTo _mkDescId} && {call _cond}} do {
	private _mkD = _h distance2D _pt;
	private _mkAlt = (getPos _h) select 2;
	private _mkVel = velocity _h;
	private _mkSpd = sqrt (((_mkVel select 0) ^ 2) + ((_mkVel select 1) ^ 2));
	private _mkF = 15 + (((_mkD - 150) max 0) * 0.1);
	if (_mkD > 250) then {_mkF = _mkF max 20};
	if (_mkF < _mkTgt && {_mkF < (_mkAlt + 10)}) then {
		_mkTgt = _mkF;
		_h flyInHeight _mkTgt;
	};
	private _mkLose = (_mkAlt - 15) max 0;
	private _mkV = if (_mkLose < 3) then {70} else {((_mkD - 150) max 0) * 4 / _mkLose};
	_mkV = (_mkV max 12) min 70;
	if (_mkD < 500) then {_mkV = _mkV min (12 + (((_mkD - 150) max 0) * 0.05))};
	_h limitSpeed (_mkV * 3.6);
	if (_mkD < 250 && {_mkSpd < 3}) then {_mkStill = _mkStill + 1} else {_mkStill = 0};
	if ((_mkD < 160 && {_mkAlt < 25} && {_mkSpd < 16}) || {_mkStill >= 4}) exitWith {_mkReady = true};
	sleep 0.5;
};
if (alive _h) then {_h limitSpeed 1000};
_mkReady
