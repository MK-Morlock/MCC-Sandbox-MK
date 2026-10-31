private _perSecondChecks = 0;
private "_target";
private _missile = objNull;
private "_travelTime";
private _steps = 0;
private _relDirHor = [];
private "_relDirVer";
private _fireLight = "";
private "_velocityForCheck";
private _targetIsHeliEmpty = false;
params ["_primaryTarget", "_missileStart", "_missileType", "_missileSpeed", "_light", "_code", ["_steerToImpact", false]];
_targetIsHeliEmpty = false;

_perSecondChecks = 25; //direction checks per second

//Is target or create one
if (typeName _primaryTarget == "OBJECT") then {
	_target = _primaryTarget;
} else {
	_target = "O_TargetSoldier" createVehicle _primaryTarget;
	_targetIsHeliEmpty = true;
};

//Create a projectile or use the one available
if (typeName _missileType == typeName "") then {
	_missile = _missileType createVehicle [_missileStart select 0, _missileStart select 1,(_missileStart select 2)-5];
} else {
	_missile = _missileType;
};

_missile setPos [_missileStart select 0, _missileStart select 1,(_missileStart select 2)-5];

//broadcast onwership
[_missile,(owner player)] remoteExec ["setOwner", 2];

//procedure for guiding the missile
_homeMissile = {
				//altering the direction, pitch and trajectory of the missile
				_travelTime = (_target distance _missile) / _missileSpeed;
				_steps = floor (_travelTime * _perSecondChecks);

				_relDirHor = [getpos _missile, getpos _target] call BIS_fnc_DirTo;
				_missile setDir _relDirHor;

				_relDirVer = asin ((((getPosASL _missile) select 2) - ((getPosASL _target) select 2)) / (_target distance _missile));
				_relDirVer = (_relDirVer * -1);
				[_missile, _relDirVer, 0] call BIS_fnc_setPitchBank;

				_velocityX = (((getPosASL _target) select 0) - ((getPosASL _missile) select 0)) / _travelTime;
				_velocityY = (((getPosASL _target) select 1) - ((getPosASL _missile) select 1)) / _travelTime;
				_velocityZ = (((getPosASL _target) select 2) - ((getPosASL _missile) select 2)) / _travelTime;

				[_velocityX, _velocityY, _velocityZ]
			};


if (_light) then {
	//fuel burning should illuminate the landscape
	_fireLight = "#lightpoint" createVehicle position _missile;
	_fireLight setLightBrightness 0.5;
	_fireLight setLightAmbient [0.5, 0.5, 0.5];
	_fireLight setLightColor [1.0, 1.0, 1.0];
	_fireLight lightAttachObject [_missile, [0, -0.5, 0]];
};

//missile flying
private _lastPos = getPosASL _missile;
if (_steerToImpact) then {
	private _ehC = addMissionEventHandler ["EachFrame", {
		_thisArgs params ["_m", "_tg", "_spd"];
		if (isNull _m || {!alive _m} || {isNull _tg}) exitWith {};
		private _mp = getPosASL _m;
		private _tp = getPosASL _tg;
		if (((_mp select 2) - ((getTerrainHeightASL _mp) max 0)) < 0.3) exitWith {triggerAmmo _m};
		private _d2 = _mp distance2D _tp;
		private _hDir = vectorNormalized [(_tp select 0) - (_mp select 0), (_tp select 1) - (_mp select 1), 0];
		private _toT = vectorNormalized ((_tp vectorAdd [0, 0, -3]) vectorDiff _mp);
		private _desired = _toT;
		if (_d2 > 1100) then {
			private _ahead = _mp vectorAdd (_hDir vectorMultiply 300);
			private _ground = (getTerrainHeightASL _mp) max (getTerrainHeightASL _ahead) max 0;
			private _t = ((2600 - _d2) / 1500) max 0 min 1;
			_t = _t * _t * (3 - 2 * _t);
			private _alt = (((_ground + 100) * (1 - _t)) + (((_tp select 2) + 800) * _t)) max (_ground + 100);
			private _climb = ((_alt - (_mp select 2)) * 0.8) max -60 min 120;
			private _h = _hDir vectorMultiply (sqrt (((_spd ^ 2) - (_climb ^ 2)) max 1));
			_desired = vectorNormalized [_h select 0, _h select 1, _climb];
		};
		private _cur = _m getVariable ["MCC_cmDir", []];
		private _tl = _m getVariable ["MCC_cmTime", time];
		if (count _cur == 0) then {_cur = _desired};
		if ((_cur vectorDotProduct _toT) < 0 && {_d2 < 400}) then {_desired = _cur};
		private _step = ([35, 70] select (_d2 <= 1100)) * (((time - _tl) max 0.001) min 0.1);
		private _cosA = ((_cur vectorDotProduct _desired) max -1) min 1;
		private _ang = acos _cosA;
		private _dir = if (_ang <= _step) then {_desired} else {
			private _perp = vectorNormalized (_desired vectorDiff (_cur vectorMultiply _cosA));
			vectorNormalized ((_cur vectorMultiply (cos _step)) vectorAdd (_perp vectorMultiply (sin _step)))
		};
		private _rt = _dir vectorCrossProduct [0, 0, 1];
		if ((vectorMagnitude _rt) < 0.01) then {_rt = [1, 0, 0]};
		_m setVectorDirAndUp [_dir, vectorNormalized (_rt vectorCrossProduct _dir)];
		_m setVelocity (_dir vectorMultiply _spd);
		_m setVariable ["MCC_cmDir", _dir];
		_m setVariable ["MCC_cmTime", time];
	}, [_missile, _target, _missileSpeed]];
	waitUntil {sleep 0.1; !alive _missile};
	removeMissionEventHandler ["EachFrame", _ehC];
} else {
	while {alive _missile && ((_missile distance _target) > 10)} do {
		_lastPos = getPosASL _missile;
		_velocityForCheck = call _homeMissile;
		if ({(typeName _x) == (typeName 0)} count _velocityForCheck == 3) then {_missile setVelocity _velocityForCheck};
		sleep (1 / _perSecondChecks)
	};
};

if (_light) then {deleteVehicle _fireLight}; //delete ligh source
if (_targetIsHeliEmpty) then {deleteVehicle _target};
if (_code != "") then {[_primaryTarget] call compile (_code)};