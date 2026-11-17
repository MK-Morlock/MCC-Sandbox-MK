/*
	MCCMK_fnc_heliHold - (where the helicopter is local) holds a helicopter exactly over a spot:
	eased in to within half a metre and then HELD there frame
	by frame (let go, the pilot drifts off). [helicopter, spot (an object it follows - a boat - or a position), height
	above the water / ground (or the object's deck)]; [helicopter] alone stops it.
	Over the ground: speed wanted falls away to nothing at the spot (sqrt (2 x 1.2 x distance), 12 m/s at most), changed by
	at most 2.5 m/s a second (4 once holding). Height: climb or sink at up to 4 m/s, changed by 2.5 m/s a second (6
	holding). The pilot pushing against it (nose or bank over 18 degrees for a second near the spot): the height is left to
	him, his climb or sink damped, until he's been level again for 2 seconds.
*/
params [["_h", objNull], ["_spot", objNull], ["_ht", -1]];
if (isNull _h || {!local _h}) exitWith {};
private _old = _h getVariable ["MCCMK_holdEH", -1];
if (_old >= 0) then {removeMissionEventHandler ["EachFrame", _old]; _h setVariable ["MCCMK_holdEH", -1]};
if (_ht < 0 || {(_spot isEqualType objNull) && {isNull _spot}}) exitWith {_h setVariable ["MCCMK_holdState", nil, true]};
_h setVariable ["MCCMK_holdSpot", [_spot, _ht]];
_h setVariable ["MCCMK_holdState", "steer", true];
_h setVariable ["MCCMK_holdStopped", false];
_h setVariable ["MCCMK_holdT", diag_tickTime];
private _eh = addMissionEventHandler ["EachFrame", {
	_thisArgs params ["_h"];
	if (!alive _h || {!local _h} || {isNil {_h getVariable "MCCMK_holdState"}}) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
		_h setVariable ["MCCMK_holdEH", -1];
	};
	private _now = diag_tickTime;
	private _dt = ((_now - (_h getVariable ["MCCMK_holdT", _now])) max 0.001) min 0.1;
	_h setVariable ["MCCMK_holdT", _now];
	(_h getVariable ["MCCMK_holdSpot", [objNull, 15]]) params ["_spot", "_ht"];
	private _sp = if (_spot isEqualType objNull) then {getPosASL _spot} else {_spot};
	// (a position's third number is the height above sea level it's measured from - the ground, the sea, or the top of
	// whatever stands on the spot: MCCMK_fnc_heliHoverAt)
	private _base = if (_spot isEqualType objNull) then {(_sp select 2) + 1} else {_sp select 2};
	private _tgt = _base + _ht;
	private _pos = getPosASL _h;
	private _vel = velocity _h;
	private _dx = (_sp select 0) - (_pos select 0);
	private _dy = (_sp select 1) - (_pos select 1);
	private _dist = sqrt ((_dx * _dx) + (_dy * _dy));
	private _hErr = _tgt - (_pos select 2);
	// (MK) a spot that MOVES (a drifting boat): the speed that counts is relative to it. A fixed point uses the helicopter's
	// own speed, but staying over a drifting boat means moving as it does.
	private _sv = if (_spot isEqualType objNull) then {velocity _spot} else {[0, 0, 0]};
	private _hs = sqrt ((((_vel select 0) - (_sv select 0)) ^ 2) + (((_vel select 1) - (_sv select 1)) ^ 2));
	// (MK) no height test here: the pilot will not come down to the asked height; the ropes are measured to the deck
	// from wherever it is
	if ((_h getVariable ["MCCMK_holdState", "steer"]) == "steer" && {_dist < 0.75} && {_hs < 0.4}) then {
		_h setVariable ["MCCMK_holdState", "hold", true];
		// (MK) held over the spot for the first time: the pilot is ordered to STOP, once. The move order he is left with
		// (to where he was at the handover) is a fixed point in the world: as the boat drifts off he would keep flying
		// back to it, against the hold. Under a stop order he does not hold a point. Not at the start: with the stop
		// order there the pilot halts well short and the carry crawls.
		if !(_h getVariable ["MCCMK_holdStopped", false]) then {
			_h setVariable ["MCCMK_holdStopped", true];
			if (!isNull (driver _h)) then {commandStop (driver _h)};
		};
	};
	if (_dist > 6 && {(_h getVariable ["MCCMK_holdState", "steer"]) == "hold"}) then {_h setVariable ["MCCMK_holdState", "steer", true]};
	private _holding = (_h getVariable ["MCCMK_holdState", "steer"]) == "hold";
	// over the ground
	private _want = if (_dist < 0.5) then {0} else {(sqrt (2 * 1.6 * (_dist - 0.5))) min 14};	// (MK) quicker over the boat, still easing in over the last metres
	// (MK) the speed asked for is the spot's own plus the closing speed (without the spot's it would trail a drifting boat)
	private _wx = _sv select 0; private _wy = _sv select 1;
	if (_dist > 0.01) then {_wx = _wx + ((_dx / _dist) * _want); _wy = _wy + ((_dy / _dist) * _want)};
	private _ax = _wx - (_vel select 0);
	private _ay = _wy - (_vel select 1);
	private _aLen = sqrt ((_ax * _ax) + (_ay * _ay));
	private _aMax = ([4, 4] select _holding) * _dt;	// (MK) 4 m/s2 while carrying over
	if (_aLen > _aMax) then {_ax = (_ax / _aLen) * _aMax; _ay = (_ay / _aLen) * _aMax};
	// the pilot pushing against the hold: the height left to him (damped) until he's level again for 2 s
	private _tilt = acos ((((vectorUp _h) select 2) max -1) min 1);
	if (_dist < 6 && {_tilt > 18}) then {
		if ((_h getVariable ["MCCMK_holdTilt", -1]) < 0) then {_h setVariable ["MCCMK_holdTilt", _now]};
		_h setVariable ["MCCMK_holdLevel", -1];
		if ((_now - (_h getVariable ["MCCMK_holdTilt", _now])) > 1) then {_h setVariable ["MCCMK_holdYield", true]};
	} else {
		_h setVariable ["MCCMK_holdTilt", -1];
		if ((_h getVariable ["MCCMK_holdYield", false]) && {_tilt < 8}) then {
			if ((_h getVariable ["MCCMK_holdLevel", -1]) < 0) then {_h setVariable ["MCCMK_holdLevel", _now]};
			if ((_now - (_h getVariable ["MCCMK_holdLevel", _now])) > 2) then {_h setVariable ["MCCMK_holdYield", false]};
		};
	};
	private _az = 0;
	if (_h getVariable ["MCCMK_holdYield", false]) then {
		_az = ((((_vel select 2) * (1 - ((0.2 * _dt) min 1))) max -1.5) min 1.5) - (_vel select 2);
	} else {
		private _wz = ((_hErr * 0.5) max -4) min 4;
		if ((abs _hErr) < 0.3) then {_wz = 0};
		_az = _wz - (_vel select 2);
		private _azMax = ([2.5, 6] select _holding) * _dt;
		_az = (_az max (-_azMax)) min _azMax;
	};
	// (MK) with MCC debug on, a line every 2 s: where it is against the spot, so a hover that won't settle can be read
	if ((missionNamespace getVariable ["MCC_debug", false]) && {_now > (_h getVariable ["MCCMK_holdLogT", 0])}) then {
		_h setVariable ["MCCMK_holdLogT", _now + 2];
		["INFO", "heliHold", "%1 %2: %3 m off | speed relative to the spot %4 m/s | height error %5 m | tilt %6 deg | spot moving %7 m/s", [typeOf _h, _h getVariable ["MCCMK_holdState", ""], _dist toFixed 1, _hs toFixed 2, _hErr toFixed 1, round _tilt, (sqrt (((_sv select 0) ^ 2) + ((_sv select 1) ^ 2))) toFixed 2]] call MCC_fnc_log;
	};
	_h setVelocity [(_vel select 0) + _ax, (_vel select 1) + _ay, (_vel select 2) + _az];
}, [_h]];
_h setVariable ["MCCMK_holdEH", _eh];
