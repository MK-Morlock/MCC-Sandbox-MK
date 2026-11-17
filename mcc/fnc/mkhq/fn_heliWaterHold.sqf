/*
	MCCMK_fnc_heliWaterHold - (where the helicopter is local) lowers a helicopter onto the water and keeps it there:
	[helicopter, spot, id] (from MCCMK_fnc_heliWaterLand); [helicopter] alone lets it go.
	  - "down": straight down at 1 m/s (eased in over the last 2 m), moved over the spot at up to 2 m/s, and HELD LEVEL - if
	    the pilot tips it, its attitude is eased back to level (its heading kept), so the rotors can't reach the water;
	  - "afloat" once its underside is within 0.4 m of the water: from then on it may not climb (any upward speed above
	    0.2 m/s taken off - the pilot with his engine running), and any drift is eased back towards the spot, 1 m/s at most.
	Ends when let go, on a new order (another id), if a player takes the controls, or if it is lost.
*/
params [["_h", objNull], ["_spot", []], ["_id", 0]];
if (isNull _h || {!local _h}) exitWith {};
private _old = _h getVariable ["MCCMK_waterEH", -1];
if (_old >= 0) then {removeMissionEventHandler ["EachFrame", _old]; _h setVariable ["MCCMK_waterEH", -1]};
if (_spot isEqualTo []) exitWith {_h setVariable ["MCCMK_waterState", nil, true]};
_h setVariable ["MCCMK_waterState", "down", true];
_h setVariable ["MCCMK_waterTick", diag_tickTime];
// (from its centre down to its underside)
_h setVariable ["MCCMK_waterFoot", -(((boundingBoxReal _h) select 0) select 2)];
private _eh = addMissionEventHandler ["EachFrame", {
	_thisArgs params ["_h", "_spot", "_id"];
	if (isNull _h || {!alive _h} || {!local _h} || {(_h getVariable ["MCCMK_waterId", 0]) != _id} || {isNil {_h getVariable "MCCMK_waterState"}} || {isPlayer (driver _h)}) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
		if (!isNull _h) then {_h setVariable ["MCCMK_waterEH", -1]};
	};
	private _now = diag_tickTime;
	private _dt = ((_now - (_h getVariable ["MCCMK_waterTick", _now])) max 0.001) min 0.1;
	_h setVariable ["MCCMK_waterTick", _now];
	if (isGamePaused) exitWith {};
	private _pos = getPosASL _h;
	private _vel = velocity _h;
	private _gap = ((_pos select 2) - (_h getVariable ["MCCMK_waterFoot", 1])) - ((getTerrainHeightASL _pos) max 0);	// (underside above the water)
	private _dx = (_spot select 0) - (_pos select 0);
	private _dy = (_spot select 1) - (_pos select 1);
	private _dist = sqrt ((_dx * _dx) + (_dy * _dy));
	private _state = _h getVariable ["MCCMK_waterState", "down"];
	if (_state == "down" && {_gap < 0.4}) then {_state = "afloat"; _h setVariable ["MCCMK_waterState", "afloat", true]};
	private _top = [2, 1] select (_state == "afloat");
	private _want = if (_dist < 0.5) then {0} else {(sqrt (2 * 0.6 * (_dist - 0.5))) min _top};
	private _wx = 0; private _wy = 0;
	if (_dist > 0.01) then {_wx = (_dx / _dist) * _want; _wy = (_dy / _dist) * _want};
	private _ax = _wx - (_vel select 0);
	private _ay = _wy - (_vel select 1);
	private _aLen = sqrt ((_ax * _ax) + (_ay * _ay));
	private _aMax = 1.5 * _dt;
	if (_aLen > _aMax) then {_ax = (_ax / _aLen) * _aMax; _ay = (_ay / _aLen) * _aMax};
	private _vz = _vel select 2;
	if (_state == "down") then {
		private _wz = -(((_gap * 0.75) max 0.3) min 1);
		_vz = _vz + (((_wz - _vz) max (-3 * _dt)) min (3 * _dt));
	} else {
		if (_vz > 0.2) then {_vz = 0.2};
	};
	_h setVelocity [(_vel select 0) + _ax, (_vel select 1) + _ay, _vz];
	// (MK) level: its up vector eased towards straight up (a third of the way each 0.1 s), heading kept
	private _up = vectorUp _h;
	if ((_up select 2) < 0.998) then {
		private _d = vectorDir _h;
		private _fl = vectorNormalized [_d select 0, _d select 1, 0];
		private _nu = vectorNormalized (_up vectorAdd (([0, 0, 1] vectorDiff _up) vectorMultiply ((3 * _dt) min 1)));
		// (its heading made square to the new up - the two must be at right angles)
		_h setVectorDirAndUp [vectorNormalized (_fl vectorDiff (_nu vectorMultiply (_fl vectorDotProduct _nu))), _nu];
	};
}, [_h, _spot, _id]];
_h setVariable ["MCCMK_waterEH", _eh];
