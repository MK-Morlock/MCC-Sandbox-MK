/*
	MCCMK_fnc_heliRopeHold - (where the helicopter is local) the carry and hold of "Fast Rope Pos":
	[helicopter, spot, [aim, room below, room above],
	the order's id]; [helicopter] alone lets it go. See MCCMK_fnc_heliRopePos.
	  - over the ground: the speed a steady 1.2 m/s2 brake would give from the edge of a half-metre circle round the spot,
	    never over 12 m/s, straight at it; the helicopter's speed moved towards it by at most 2.5 m/s each second (4 once
	    held);
	  - height: the aim above the ground, or above the top of whatever stands under it, on the next 30 m of its path,
	    within rotor reach to each side, and on the spot (within 40 m) - whichever is highest. Inside the band round the aim
	    it is left alone, its own climb and sink damped (a fifth a second, 1.5 m/s at most); below the band it is raised to
	    it, above it lowered to it, at up to 4 m/s, changed by 2 m/s a second (6 once held);
	  - it does not move in over the spot until it is nearly up to the height needed there, and is eased to a stop if
	    something solid is within 5 m ahead at its height;
	  - over the spot (within 0.75 m), slow and in its band for a second: HELD there until the next order.
	Heading and attitude are never touched. It ends with the next order (a new id), if a player takes the controls, or if
	the engine stops or the helicopter is lost.
*/
params [["_veh", objNull], ["_spot", []], ["_band", [20, 0, 15]], ["_id", 0]];
if (isNull _veh || {!local _veh}) exitWith {};
private _old = _veh getVariable ["MCCMK_ropeEH", -1];
if (_old >= 0) then {removeMissionEventHandler ["EachFrame", _old]; _veh setVariable ["MCCMK_ropeEH", -1]};
if (_spot isEqualTo []) exitWith {_veh setVariable ["MCCMK_ropeState", nil, true]};
_veh setVariable ["MCCMK_ropeTick", diag_tickTime];
_veh setVariable ["MCCMK_ropeCheck", 0];
_veh setVariable ["MCCMK_ropeBlocked", false];
_veh setVariable ["MCCMK_ropeState", "steer", true];
_veh setVariable ["MCCMK_ropeStill", -1];
_veh setVariable ["MCCMK_ropeTgt", (getPosASL _veh) select 2];
_veh setVariable ["MCCMK_ropeSpotTgt", 0];
// the height needed over a point: the aim above the ground there, or above the top of whatever stands on it
_veh setVariable ["MCCMK_ropeFnNeed", {
	params ["_p", "_veh", "_aim"];
	private _terr = getTerrainHeightASL _p;
	// (MK) not its own ropes, the men on them, or anything hung from it: the first thing below that is none of those
	// (the ropes are not "what stands there")
	private _hits = lineIntersectsSurfaces [[_p select 0, _p select 1, _terr + 300], [_p select 0, _p select 1, _terr + 0.2], _veh, objNull, true, 8, "GEOM", "NONE"];
	private _i = _hits findIf {
		private _o = _x select 2;
		isNull _o || {!(_o isKindOf "RopeSegment") && {!(_o isKindOf "CAManBase")} && {!((attachedTo _o) isEqualTo _veh)} && {!((ropeAttachedTo _o) isEqualTo _veh)}}
	};
	private _top = if (_i < 0) then {_terr} else {((((_hits select _i) select 0) select 2)) max _terr};
	((_terr max 0) + _aim) max (_top + _aim)
}];
private _eh = addMissionEventHandler ["EachFrame", {
	_thisArgs params ["_veh", "_spot", "_band", "_id"];
	if (
		isNull _veh || {!alive _veh} || {!local _veh}
		|| {(_veh getVariable ["MCCMK_ropePosId", 0]) != _id}
		|| {isNil {_veh getVariable "MCCMK_ropeState"}}
		|| {isPlayer (driver _veh)}
		|| {!isEngineOn _veh}
	) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
		if (!isNull _veh) then {_veh setVariable ["MCCMK_ropeEH", -1]};
	};
	_band params ["_aim", "_below", "_above", ["_brake", 1.2], ["_top", 12], ["_acc", 2.5]];
	private _now = diag_tickTime;
	private _dt = ((_now - (_veh getVariable ["MCCMK_ropeTick", _now])) max 0.001) min 0.1;
	_veh setVariable ["MCCMK_ropeTick", _now];
	if (isGamePaused || {((getPos _veh) select 2) < 3}) exitWith {};
	private _pos = getPosASL _veh;
	private _dx = (_spot select 0) - (_pos select 0);
	private _dy = (_spot select 1) - (_pos select 1);
	private _dist = sqrt ((_dx * _dx) + (_dy * _dy));
	private _vel = velocity _veh;
	private _hsNow = sqrt (((_vel select 0) ^ 2) + ((_vel select 1) ^ 2));

	// 4 times a second: the height to aim for (here, the next 30 m of the path, and the spot), and whether the path is
	// blocked at this height
	if (_now > (_veh getVariable ["MCCMK_ropeCheck", 0])) then {
		_veh setVariable ["MCCMK_ropeCheck", _now + 0.25];
		private _fnNeed = _veh getVariable ["MCCMK_ropeFnNeed", {0}];
		private _spotNeed = [_spot, _veh, _aim] call _fnNeed;
		_veh setVariable ["MCCMK_ropeSpotTgt", _spotNeed];
		private _tgt = [_pos, _veh, _aim] call _fnNeed;
		// (and whatever is within rotor reach to either side, front or back)
		{
			_tgt = _tgt max ([[(_pos select 0) + (_x select 0), (_pos select 1) + (_x select 1), 0], _veh, _aim] call _fnNeed);
		} forEach [[9, 0], [-9, 0], [0, 9], [0, -9]];
		if (_dist > 1) then {
			{
				if (_dist > _x) then {
					_tgt = _tgt max ([[(_pos select 0) + ((_dx / _dist) * _x), (_pos select 1) + ((_dy / _dist) * _x), 0], _veh, _aim] call _fnNeed);
				};
			} forEach [8, 16, 24, 30];
		};
		if (_dist < 40) then {_tgt = _tgt max _spotNeed};
		_veh setVariable ["MCCMK_ropeTgt", _tgt];
		private _blocked = false;
		if (_dist > 3) then {
			private _reach = _dist min 5;
			private _ahead = [(_pos select 0) + ((_dx / _dist) * _reach), (_pos select 1) + ((_dy / _dist) * _reach), _pos select 2];
			_blocked = (lineIntersectsSurfaces [_pos, _ahead, _veh, objNull, true, 1, "GEOM", "NONE"]) isNotEqualTo [];
		};
		_veh setVariable ["MCCMK_ropeBlocked", _blocked];
	};
	private _tgtASL = _veh getVariable ["MCCMK_ropeTgt", _pos select 2];
	// (MK) the band: from the room below the aim to the room above it - left alone inside it
	private _lo = _tgtASL - _below;
	private _hi = _tgtASL + _above;
	private _hErr = 0;
	if ((_pos select 2) < _lo) then {_hErr = _lo - (_pos select 2)};
	if ((_pos select 2) > _hi) then {_hErr = _hi - (_pos select 2)};

	// over the spot, in its band and still: from here it is HELD there
	if ((_veh getVariable ["MCCMK_ropeState", "steer"]) != "hold") then {
		if (_dist < 0.75 && {_hsNow < 0.4} && {(abs _hErr) < 1.5} && {(abs (_vel select 2)) < 0.5}) then {
			if ((_veh getVariable ["MCCMK_ropeStill", -1]) < 0) then {_veh setVariable ["MCCMK_ropeStill", _now]};
			if ((_now - (_veh getVariable ["MCCMK_ropeStill", _now])) > 1) then {_veh setVariable ["MCCMK_ropeState", "hold", true]};
		} else {
			_veh setVariable ["MCCMK_ropeStill", -1];
		};
	};
	private _holding = ((_veh getVariable ["MCCMK_ropeState", "steer"]) == "hold");

	// over the ground (measured from the edge of the half-metre circle, so the speed asked for falls away to nothing)
	private _want = if (_dist < 0.5) then {0} else {(sqrt (2 * _brake * (_dist - 0.5))) min _top};	// (MK: set by MCCMK_fnc_heliRopePos)
	if (_veh getVariable ["MCCMK_ropeBlocked", false]) then {_want = 0};
	// (not in over the spot until it is nearly up to the height needed there)
	if (_dist < 30 && {_dist > 2} && {(_pos select 2) < (((_veh getVariable ["MCCMK_ropeSpotTgt", 0]) - _below) - 4)}) then {_want = 0};
	private _wx = 0;
	private _wy = 0;
	if (_dist > 0.01) then {_wx = (_dx / _dist) * _want; _wy = (_dy / _dist) * _want};
	private _ax = _wx - (_vel select 0);
	private _ay = _wy - (_vel select 1);
	private _aLen = sqrt ((_ax * _ax) + (_ay * _ay));
	private _aMax = (if (_holding) then {4} else {_acc}) * _dt;	// (MK: set by MCCMK_fnc_heliRopePos)
	if (_aLen > _aMax) then {_ax = (_ax / _aLen) * _aMax; _ay = (_ay / _aLen) * _aMax};

	// height: towards the band - faster the further off it is, 4 m/s at most, changed by at most 2 m/s each second
	private _wz = ((_hErr * 0.5) max -4) min 4;
	if ((abs _hErr) < 0.3) then {_wz = 0};
	private _az = _wz - (_vel select 2);
	// (MK) above its band: brought down more firmly (4 m/s a second)
	private _azMax = (if (_holding) then {6} else {[2.5, 4] select (_hErr < 0)}) * _dt;
	_az = (_az max (-_azMax)) min _azMax;
	// inside the band: the pilot's own climb or sink stands, damped (a fifth a second) and capped at 1.5 m/s
	if (_hErr == 0) then {
		private _vzDamped = ((_vel select 2) * (1 - ((0.2 * _dt) min 1)));
		_az = ((_vzDamped max -1.5) min 1.5) - (_vel select 2);
	};

	_veh setVelocity [(_vel select 0) + _ax, (_vel select 1) + _ay, (_vel select 2) + _az];
	// (MK) debug: once a second while it isn't held - where it is against the dot and its height band
	if ((missionNamespace getVariable ["MCC_debug", false]) && {!_holding} && {_now > (_veh getVariable ["MCCMK_ropeLogT", 0])}) then {
		_veh setVariable ["MCCMK_ropeLogT", _now + 1];
		private _gAgl = (_pos select 2) - ((getTerrainHeightASL _pos) max 0);
		["INFO", "ropeHold", "%1: %2 m from the dot, %3 m/s across, %4 m/s up/down | %5 m above ground, band %6-%7 m (aim %8 above the ground or what stands there), %9 m to go | path blocked %10", [typeOf _veh, _dist toFixed 1, _hsNow toFixed 1, (_vel select 2) toFixed 1, round _gAgl, round (_lo - ((getTerrainHeightASL _pos) max 0)), round (_hi - ((getTerrainHeightASL _pos) max 0)), _aim, _hErr toFixed 1, _veh getVariable ["MCCMK_ropeBlocked", false]]] call MCC_fnc_log;
	};
}, [_veh, _spot, _band, _id]];
_veh setVariable ["MCCMK_ropeEH", _eh];
