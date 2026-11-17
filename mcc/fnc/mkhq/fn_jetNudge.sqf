/*
	MCCMK_fnc_jetNudge - (server, postInit) AI jets about to collide head-on (Arma's AI points both straight at each other
	through the merge): while two or more hostile AI jets are airborne, their courses are checked four times a second; a
	pair due to pass within 25 m in the next 2.5 s is nudged apart - BOTH, equally, one up and one down (which, at random)
	- so they pass close, one just over the other, and fight on. A jet with a player in it is never nudged. With fewer
	than two jets in the air it only looks every 3 s.
*/
if (!isServer) exitWith {};
[] spawn {
	private _last = createHashMap;	// a pair's last nudge (a pair is nudged once per merge)
	while {true} do {
		private _jets = (entities [["Plane"], ["ParachuteBase"], false, true]) select {
			alive _x && {!isTouchingGround _x} && {(speed _x) > 150} && {!isNull (driver _x)} && {((crew _x) findIf {isPlayer _x}) < 0}
		};
		if (count _jets < 2) then {sleep 3} else {
			for "_i" from 0 to (count _jets) - 2 do {
				for "_j" from _i + 1 to (count _jets) - 1 do {
					private _a = _jets select _i;
					private _b = _jets select _j;
					if ([side (group (driver _a)), side (group (driver _b))] call BIS_fnc_sideIsEnemy) then {
						private _p = (getPosASL _b) vectorDiff (getPosASL _a);
						private _v = (velocity _b) vectorDiff (velocity _a);
						private _vv = _v vectorDotProduct _v;
						if (_vv > 1) then {
							private _t = -((_p vectorDotProduct _v) / _vv);	// when they're closest
							if (_t > 0.3 && {_t < 2.5}) then {
								private _miss = vectorMagnitude (_p vectorAdd (_v vectorMultiply _t));
								private _key = [netId _a, netId _b];
								if (_miss < 25 && {time > (_last getOrDefault [_key, -10]) + 4}) then {
									_last set [_key, time];
									// enough to open ~30 m between them by then, shared equally
									private _k = ((30 / _t) / 2) min 15;
									private _up = selectRandom [_a, _b];
									private _dn = [_a, _b] select (_up isEqualTo _a);
									{
										_x params ["_veh", "_dz"];
										private _nv = (velocity _veh) vectorAdd [0, 0, _dz];
										if (local _veh) then {_veh setVelocity _nv} else {[_veh, _nv] remoteExec ["setVelocity", _veh]};
									} forEach [[_up, _k], [_dn, -_k]];
									if (missionNamespace getVariable ["MCC_debug", false]) then {["INFO", "MCCMK_fnc_jetNudge", "%1 and %2 nudged apart (%3 m apart in %4 s) - %5 m/s each, %1 %6", [typeOf _a, typeOf _b, round _miss, (round (_t * 10)) / 10, round _k, ["down", "up"] select (_up isEqualTo _a)]] call MCC_fnc_log};
								};
							};
						};
					};
				};
			};
			sleep 0.25;
		};
	};
};
