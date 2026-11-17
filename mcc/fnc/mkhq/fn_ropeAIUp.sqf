/*
	MCCMK_fnc_ropeAIUp - (where the AI is local) an AI up a pickup rope: Advanced Pickup Rope's ascent (Dash; the STABO
	adaptation - MK_APR_Client_Pickup_Rope) as it is - the rope physics, the swinging with the rotor wash, the wind and the
	helicopter, Advanced Rappelling's harness pose - with "up" held all the way instead of the W key (it has no AI of its
	own). [unit, helicopter, its rope point]. Into a seat within 3 m of the helicopter.
*/
	params ["_player", "_heli", "_rappelPoint"];
	if (!local _player) exitWith {};
	// (MK) he gets onto the rope where he is - at deck level, aboard a boat (put out of his seat he was in the water
	// under it, on a rope 3 m longer than the helicopter's height, and was dragged up through the hull)
	private _quiet = _player getVariable ["MCCMK_ropeQuiet", false];	// (a rescue's rope: he's put ON MCC's hanging rope)
	private _eyeASL = eyePos _player;
	private _startASL = [_eyeASL select 0, _eyeASL select 1, ((_eyeASL select 2) - 1.5) max -0.5];
	private _arWasDamage = isDamageAllowed _player;	// (MK) put back as it was at the end
	[_player] orderGetIn false;
	moveOut _player;
	waitUntil {
		vehicle _player == _player
	};
	_player setPosASL _startASL;
	private _rappelPointPosition = AGLToASL (_heli modelToWorldVisual _rappelPoint);
	private _anchor = "Land_Can_V2_F" createVehicle _rappelPointPosition;
	_anchor allowDamage false;
	hideObject _anchor;
	[[_anchor], "ARMK_Hide_Object_Global"] call ARMK_RemoteExecServer;
	_anchor attachTo [_heli, _rappelPoint];
	private _rappelDevice = "B_static_AA_F" createVehicle position _player;
	if (_quiet) then {
		// (MK) at the rope, and at the SAME height for everyone: the surface straight under its point on the helicopter
		// (the deck; the sea if there's nothing there), feet on it - measured as the rope's length is.
		private _arHits = lineIntersectsSurfaces [_rappelPointPosition vectorAdd [0, 0, -1.5], [_rappelPointPosition select 0, _rappelPointPosition select 1, -2], _heli, _player, true, 1, "GEOM", "NONE"];
		private _arDeck = if (_arHits isEqualTo []) then {0} else {(((_arHits select 0) select 0) select 2) max 0};
		_startASL = [_rappelPointPosition select 0, _rappelPointPosition select 1, _arDeck + 0.9];
		_player setPosASL _startASL;
	};
	_rappelDevice setPosASL _startASL;
	_rappelDevice allowDamage false;
	// (MK) the helper is a missile launcher: emptied, so no missiles are drawn hanging in the air where hiding it for
	// everyone is late or blocked; locked; and both helpers marked for cleanup scripts to leave alone
	_rappelDevice setVehicleAmmo 0;
	_rappelDevice lock 2;
	{_x setVariable ["ARMK_helper", true, true]} forEach [_anchor, _rappelDevice];
	hideObject _rappelDevice;
	[[_rappelDevice], "ARMK_Hide_Object_Global"] call ARMK_RemoteExecServer;
	[[_player, _rappelDevice, _anchor], "ARMK_Play_Rappelling_Sounds_Global"] call ARMK_RemoteExecServer;
	private _bottomRopeLength = 3;
	// (MK) a rescue's rope (MCCMK_ropeQuiet): MCC's own rope already hangs from this point to the water - he climbs that,
	// so none of these are drawn (drawn, they'd show a rope rising out of the sea with him on top)
	private _bottomRope = if (_quiet) then {objNull} else {ropeCreate [_rappelDevice, [-0.15, 0, 0], _bottomRopeLength]};
	if (!isNull _bottomRope) then {_bottomRope allowDamage false};
	private _topRopeLength = ((_rappelPointPosition distance _startASL) + 0.3) max 3;	// (MK) from the rope point to where he is
	// (MK) created from the helicopter end, so it hangs down from the helicopter (from the man's end it grew up out of the
	// water or the ground - the original starts a man at the helicopter)
	// (MK) the original's own rope (its static object owns it - made the other way round, from the helicopter's end,
	// nothing was drawn at all). In a rescue it isn't drawn: he's ON MCC's hanging rope there (below).
	private _topRope = if (_quiet) then {objNull} else {ropeCreate [_rappelDevice, [0, 0.15, 0], _anchor, [0, 0, 0], _topRopeLength]};
	if (!isNull _topRope) then {_topRope allowDamage false};
	[_player] spawn ARMK_Enable_Rappelling_Animation_Client;
	private _gravityAccelerationVec = [0, 0, -9.8];
	private _velocityVec = [0, 0, 0];
	private _lastTime = diag_tickTime;
	private _lastPosition = AGLToASL (_rappelDevice modelToWorldVisual [0, 0, 0]);
	private _lookDirFreedom = 50;
	private _dir = (random 360) + (_lookDirFreedom / 2);
	private _dirSpinFactor = (((random 10) - 5) / 5) max 0.1;
	private _ropeKeyDownHandler = -1;
	private _ropeKeyUpHandler = -1;
	_player setVariable ["ARMK_DECEND_PRESSED", false];
	_player setVariable ["ARMK_FAST_DECEND_PRESSED", false];
	_player setVariable ["ARMK_RANDOM_DECEND_SPEED_ADJUSTMENT", 0];
	_player setVariable ["ARMK_ASCEND_PRESSED", false];
	_player setVariable ["ARMK_ASCEND_PRESSED", true];	// (MK) an AI: winched up - "up" held all the way
	[_player, _heli] spawn {
		params ["_player", "_heli"];
		while {_player getVariable ["ARMK_Is_Rappelling", false]} do {
			if (speed _heli > 150) then {
				[_player] call ARMK_Rappel_Detach_Action;
			};
			sleep 2;
		};
	};
	private _seatNow = false;
	while {true} do {
		if (!(_player getVariable ["MCCMK_ropeWait", false])) then {_player setVariable ["ARMK_ASCEND_PRESSED", true]};	// (MK) up again once a seat frees
		private _currentTime = diag_tickTime;
		private _timeSinceLastUpdate = _currentTime - _lastTime;
		_lastTime = _currentTime;
		if (_timeSinceLastUpdate > 1) then {
			_timeSinceLastUpdate = 0;
		};
		private _environmentWindVelocity = wind;
		private _playerWindVelocity = _velocityVec vectorMultiply -1;
		private _helicopterWindVelocity = (vectorUp _heli) vectorMultiply -30;
		private _totalWindVelocity = _environmentWindVelocity vectorAdd _playerWindVelocity vectorAdd _helicopterWindVelocity;
		private _totalWindForce = _totalWindVelocity vectorMultiply (9.8 / 53);
		private _accelerationVec = _gravityAccelerationVec vectorAdd _totalWindForce;
		_velocityVec = _velocityVec vectorAdd (_accelerationVec vectorMultiply _timeSinceLastUpdate);
		private _newPosition = _lastPosition vectorAdd (_velocityVec vectorMultiply _timeSinceLastUpdate);
		private _heliPos = AGLToASL (_heli modelToWorldVisual _rappelPoint);
		if (_newPosition distance _heliPos > _topRopeLength) then {
			_newPosition = _heliPos vectorAdd ((vectorNormalized (_heliPos vectorFromTo _newPosition)) vectorMultiply _topRopeLength);
			private _surfaceVector = vectorNormalized (_newPosition vectorFromTo _heliPos);
			_velocityVec = _velocityVec vectorAdd ((_surfaceVector vectorMultiply (_velocityVec vectorDotProduct _surfaceVector)) vectorMultiply -1);
		};
		// (MK) in a rescue: ON the hanging rope - his position taken from the rope's own segments at his height, so he
		// is on it. The rope passes 0.15 m in front of him, as the original's rope device does. No rope's segments
		// (multiplayer, a rope made elsewhere): straight under its point.
		if (_quiet) then {
			private _onRope = [_player getVariable ["MCCMK_ropeObj", objNull], _topRopeLength, _heliPos] call MCCMK_ropePosOn;
			if (_onRope isEqualTo []) then {_onRope = [_heliPos select 0, _heliPos select 1, (_heliPos select 2) - _topRopeLength]};
			private _fd = vectorDir _player;
			_newPosition = _onRope vectorAdd [-0.15 * (_fd select 0), -0.15 * (_fd select 1), 0];
			_velocityVec = [0, 0, 0];
		};
		_rappelDevice setPosWorld (_lastPosition vectorAdd ((_newPosition vectorDiff _lastPosition) vectorMultiply 6));
		_rappelDevice setVectorDir (vectorDir _player);
		_player setPosWorld [
			_newPosition select 0,
			_newPosition select 1,
			(_newPosition select 2) - 0.6
		];
		_player setVelocity [0, 0, 0];
		if (_player getVariable ["ARMK_DECEND_PRESSED", false]) then {
			private _decendSpeedMetersPerSecond = 3.5;
			if (_player getVariable ["ARMK_FAST_DECEND_PRESSED", false]) then {
				_decendSpeedMetersPerSecond = 5;
			};
			_decendSpeedMetersPerSecond = _decendSpeedMetersPerSecond + (_player getVariable ["ARMK_RANDOM_DECEND_SPEED_ADJUSTMENT", 0]);
			_bottomRopeLength = _bottomRopeLength - (_timeSinceLastUpdate * _decendSpeedMetersPerSecond);
			_topRopeLength = _topRopeLength + (_timeSinceLastUpdate * _decendSpeedMetersPerSecond);
			if (!isNull _topRope) then {ropeUnwind [_topRope, _decendSpeedMetersPerSecond, _topRopeLength]};
			if (!isNull _bottomRope) then {ropeUnwind [_bottomRope, _decendSpeedMetersPerSecond, _bottomRopeLength]};
		} else {
			if (_player getVariable ["ARMK_ASCEND_PRESSED", false]) then {
				private _decendSpeedMetersPerSecond = 3.5;
				_decendSpeedMetersPerSecond = _decendSpeedMetersPerSecond + (_player getVariable ["ARMK_RANDOM_DECEND_SPEED_ADJUSTMENT", 0]);
				// (MK) no shorter than 2 m: at the top he holds there until a seat is free (shortened past nothing, the rope
				// flung him above the helicopter)
				private _newTop = (_topRopeLength - (_timeSinceLastUpdate * _decendSpeedMetersPerSecond)) max 2;
				_bottomRopeLength = _bottomRopeLength + (_topRopeLength - _newTop);
				_topRopeLength = _newTop;
				if (!isNull _topRope) then {ropeUnwind [_topRope, _decendSpeedMetersPerSecond, _topRopeLength]};
				if (!isNull _bottomRope) then {ropeUnwind [_bottomRope, _decendSpeedMetersPerSecond, _bottomRopeLength]};
			};
		};
		_dir = _dir + ((360 / 1000) * _dirSpinFactor);
		private _currentDir = getDir _player;
		private _minDir = (_dir - (_lookDirFreedom / 2)) mod 360;
		private _maxDir = (_dir + (_lookDirFreedom / 2)) mod 360;
		private _minDegreesToMax = 0;
		private _minDegreesToMin = 0;
		if (_currentDir > _maxDir) then {
			_minDegreesToMax = (_currentDir - _maxDir) min (360 - _currentDir + _maxDir);
		};
		if (_currentDir < _maxDir) then {
			_minDegreesToMax = (_maxDir - _currentDir) min (360 - _maxDir + _currentDir);
		};
		if (_currentDir > _minDir) then {
			_minDegreesToMin = (_currentDir - _minDir) min (360 - _currentDir + _minDir);
		};
		if (_currentDir < _minDir) then {
			_minDegreesToMin = (_minDir - _currentDir) min (360 - _minDir + _currentDir);
		};
		if (_minDegreesToMin > _lookDirFreedom || {_minDegreesToMax > _lookDirFreedom}) then {
			if (_minDegreesToMin < _minDegreesToMax) then {
				_player setDir _minDir;
			} else {
				_player setDir _maxDir;
			};
		} else {
			_player setDir (_currentDir + ((360 / 1000) * _dirSpinFactor));
		};
		_lastPosition = _newPosition;
		// (MK) seated at the top of the rope (within 3 m of the helicopter, or the rope at its shortest - it stops 2 m
		// below the rope point, which on a big helicopter is further than 3 m from its centre), only with a seat free;
		// none: let 5 m back down the rope to hang below it, and winched up again when one frees
		if ((_player distance _heli < 3) || {_topRopeLength <= 2.05}) then {
			if (([_heli] call MCCMK_seatsFree) > 0) then {
				_seatNow = true;	// (MK) seated after the loop, once the rope's pose has ended - see the end
			} else {_player setVariable ["MCCMK_ropeWait", true, true]};
		};
		if (_player getVariable ["MCCMK_ropeWait", false]) then {
			if (([_heli] call MCCMK_seatsFree) > 0) then {_player setVariable ["MCCMK_ropeWait", false, true]} else {
				_player setVariable ["ARMK_ASCEND_PRESSED", false];
				if (_topRopeLength < 7) then {
					private _down = (_timeSinceLastUpdate * 2) min (7 - _topRopeLength);
					_topRopeLength = _topRopeLength + _down;
					_bottomRopeLength = (_bottomRopeLength - _down) max 1.1;
					if (!isNull _topRope) then {ropeUnwind [_topRope, 2, _topRopeLength]};
				};
			};
		};
		if (
			!alive _player ||
			{vehicle _player != _player} ||
			{_seatNow} ||
			{_bottomRopeLength <= 1} ||
			{_player getVariable ["ARMK_Detach_Rope", false]}
		) exitWith {};
		sleep 0.01;
	};
	if (!_seatNow && {_bottomRopeLength > 1} && {alive _player} && {vehicle _player == _player}) then {
		private _playerStartASLIntersect = getPosASL _player;
		private _playerEndASLIntersect = [
			_playerStartASLIntersect select 0,
			_playerStartASLIntersect select 1,
			(_playerStartASLIntersect select 2) - 5
		];
		private _surfaces = lineIntersectsSurfaces [
			_playerStartASLIntersect,
			_playerEndASLIntersect,
			_player,
			objNull,
			true,
			10
		];
		private _intersectionASL = [];
		{
			scopeName "surfaceLoop";
			private _intersectionObject = _x select 2;
			private _objectFileName = str _intersectionObject;
			if ((_objectFileName find " t_") == -1 && {(_objectFileName find " b_") == -1}) then {
				_intersectionASL = _x select 0;
				breakOut "surfaceLoop";
			};
		} forEach _surfaces;
		if ((count _intersectionASL) != 0) then {
			_player allowDamage false;
			_player setPosASL _intersectionASL;
		};
		if (_player getVariable ["ARMK_Detach_Rope", false]) then {
			if ((count _intersectionASL) == 0) then {
				_player allowDamage _arWasDamage;
			};
		};
		if (!isEngineOn _heli) then {
			_player allowDamage _arWasDamage;
		};
	};
	_player setVariable ["MCCMK_ropeWait", nil, true];
	_player setVariable ["MCCMK_ropeQuiet", nil, true];
	_player setVariable ["MCCMK_ropeObj", nil, true];
	if (!isNull _topRope) then {ropeDestroy _topRope};
	if (!isNull _bottomRope) then {ropeDestroy _bottomRope};
	deleteVehicle _anchor;
	deleteVehicle _rappelDevice;
	// (MK) at the top with a seat free: held at the rope point while the rope's pose ends, then seated - an ordinary
	// passenger seat first, a firing-from-vehicle seat if that's all there is
	// (MK) seated ONCE: never put through the boarding again when he is already in the helicopter or being seated by another
	// run of it (some men were seated twice, half a second apart - the second reset their pose IN the seat: they stood)
	private _doSeat = _seatNow && {alive _player} && {alive _heli} && {!((vehicle _player) isEqualTo _heli)} && {!(_player getVariable ["MCCMK_seating", false])};
	if (_doSeat) then {_player setVariable ["MCCMK_seating", true]};
	if (_doSeat && {alive _player} && {alive _heli}) then {
		_player attachTo [_heli, _rappelPoint vectorAdd [0, 0, -2]];
	};
	_player setVariable ["ARMK_Is_Rappelling", nil, true];
	_player setVariable ["ARMK_Rappelling_Vehicle", nil, true];
	_player setVariable ["ARMK_Detach_Rope", nil];
	if (_doSeat && {alive _player} && {alive _heli}) then {
		sleep 0.6;
		_player switchMove "";
		detach _player;
		_player moveInCargo _heli;
		if (vehicle _player == _player) then {_player moveInAny _heli};
		[_player] spawn {sleep 3; (_this select 0) setVariable ["MCCMK_seating", nil]};
		// (MK) the helicopter stays commanded by its own pilot. The last man up gets the last free seat, and if that
		// isn't a passenger seat he is put in "any free seat" - a crew seat can make him the helicopter's commander, and
		// an AI pilot then waits for his orders and stops. One call, and a line saying where he sat and who commanded
		// it.
		if (alive _heli && {!isNull (driver _heli)} && {!isPlayer (driver _heli)}) then {
			private _seat = ((fullCrew [_heli, "", false]) select {(_x select 0) isEqualTo _player}) param [0, []];
			["INFO", "sarBoard", "%1 seated: %2 - the helicopter was commanded by %3; handed back to its pilot", [name _player, if (_seat isEqualTo []) then {"not seated"} else {format ["%1%2", _seat select 1, ["", " (firing from vehicle)"] select (_seat param [4, false])]}, name (effectiveCommander _heli)]] call MCC_fnc_log;
			if (local _heli) then {_heli setEffectiveCommander (driver _heli)} else {[_heli, driver _heli] remoteExec ["setEffectiveCommander", _heli]};
			// (MK) and on its way home: the pilot given the order for where he is going again, now, as the rider sits down
			private _going = _heli getVariable ["MCCMK_sarGoing", []];
			if (_going isNotEqualTo []) then {[driver _heli, _going] remoteExec ["doMove", driver _heli]};
		};
	};
	sleep 2;
	_player allowDamage _arWasDamage;
