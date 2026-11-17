params [["_h", objNull, [objNull]], ["_tgt", [], [[]]], ["_retry", false, [false]], ["_leave", false, [false]]];	//(MK) _leave: a supply pod stays on the ground (ropes cut) instead of being winched back up
//(MK) bushes aren't obstacles (a pod sits on a bush, and Altis is covered in them)
private _fnc_clear = {
	params ["_q"];
	!(surfaceIsWater _q)
	&& {(nearestTerrainObjects [_q, ["TREE", "SMALL TREE", "ROCK", "ROCKS", "BUILDING", "HOUSE", "CHURCH", "CHAPEL", "FUELSTATION", "HOSPITAL", "LIGHTHOUSE", "POWER LINES", "TRANSMITTER", "WATERTOWER", "WALL", "FENCE", "RUIN"], 6, false, true]) isEqualTo []}
	&& {(nearestObjects [_q, ["House", "Building"], 6]) isEqualTo []}
};
private _fnc_spot = {
	params ["_from", "_start"];
	private _dir = getDir _h;
	private _found = [];
	{
		private _q = _from getPos [_start + _x, _dir];
		_q set [2, 0];
		if ([_q] call _fnc_clear) exitWith {_found = _q};
	} forEach [0, 5, -5, 10, -10, 15, -15, 20, -20, 25, -25, 30, -30, 40, -40, 50, -50];
	_found
};
private _fnc_moveTo = {
	params ["_np"];
	private _held = false;
	if (_h getVariable ["MCC_podHoldOn", false]) then {_h setVariable ["MCC_podHoldTgt", _np]; _held = true};
	if (!isNil {_h getVariable "MCC_taruHold"}) then {
		private _ht = (_h getVariable "MCC_taruHold") param [1, 30];
		_h setVariable ["MCC_taruHold", [_np, _ht]];
		_held = true;
	};
	if (!_held) exitWith {false};
	//(MK) at most 8 s, within 10 m at a slow drift; otherwise it lowers where it is - a fast insertion
	private _tw = time + 8;
	waitUntil {sleep 0.25; !alive _h || {time > _tw} || {((_h distance2D _np) < 10) && {(vectorMagnitude (velocity _h)) < 5}}};
	alive _h && {(_h distance2D _np) < 10}
};
private _p = _h getVariable ["MCC_attachedPod", objNull];
if (isNull _p) then {_p = getSlingLoad _h};
if (isNull _p || {(attachedTo _p) != _h}) exitWith {["WARN", "podAssault", "%1: no pod docked", [typeOf _h]] call MCC_fnc_log; false};
private _here = getPosATL _h;
_here set [2, 0];
if !([_here] call _fnc_clear) then {
	private _np = [_here, 0] call _fnc_spot;
	if (count _np > 1) then {
		if ([_np] call _fnc_moveTo) then {
			["INFO", "podAssault", "%1: moved %2 m to a clear spot before lowering", [typeOf _h, round (_here distance2D _np)]] call MCC_fnc_log;
		} else {
			["INFO", "podAssault", "%1: couldn't reach a clearer spot %2 m away within 8 s - lowering where it is", [typeOf _h, round (_here distance2D _np)]] call MCC_fnc_log;
		};
	};
};
_h setCustomWeightRTD 0;
_h setMass ((getMass _h) - (_h getVariable ["MCC_attachedPodMass", 0]));
_h setVariable ["MCC_attachedPod", objNull, true];
_h setVariable ["MCC_attachedPodMass", 0, true];
_h enableRopeAttach true;
_p enableRopeAttach true;
detach _p;
// (MK) A heavy pod (the fuel pod, about 13 t) is too heavy for the ropes: it's made lighter while it
// hangs, and gets its own weight back once it's off the ropes (on the ground, or docked). The bench and the other pods
// (around 1 t) are untouched.
private _podMass = getMass _p;
if (_podMass > 4000) then {
	_p setMass 3000;
	[_p, _podMass] spawn {
		params ["_p", "_m"];
		sleep 2;
		waitUntil {sleep 0.5; isNull _p || {!alive _p} || {isNull (ropeAttachedTo _p)}};
		if (!isNull _p && {alive _p}) then {_p setMass _m};
	};
};
private _sling = _h setSlingLoad _p;
if (!_sling || {count (ropes _h) == 0}) then {
	(boundingBoxReal _p) params ["_b1", "_b2"];
	private _z = _b2 select 2;
	{ropeCreate [_h, [0, 0, -1], _p, [_x select 0, _x select 1, _z], ((_h modelToWorld [0, 0, -1]) distance (_p modelToWorld [_x select 0, _x select 1, _z])) + 0.5]} forEach [[(_b1 select 0) * 0.6, (_b1 select 1) * 0.6], [(_b2 select 0) * 0.6, (_b1 select 1) * 0.6], [(_b1 select 0) * 0.6, (_b2 select 1) * 0.6], [(_b2 select 0) * 0.6, (_b2 select 1) * 0.6]];
};
["INFO", "podAssault", "%1: pod on %2 ropes (%3)", [typeOf _h, count (ropes _h), ["ropes made by script", "Arma sling load"] select _sling]] call MCC_fnc_log;
// (MK) The fuel pod only: it exploded at the knock of leaving the Taru, so it takes no damage until 5 m more rope is out
// (clear of the Taru) - then it can be destroyed as normal. The other pods take a knock without harm.
if (((toLower (typeOf _p)) find "_fuel") >= 0) then {
	_p allowDamage false;
	private _r0 = if (count (ropes _h) > 0) then {ropeLength ((ropes _h) select 0)} else {0};
	[_p, _h, _r0] spawn {
		params ["_p", "_h", "_r0"];
		private _t = time + 30;
		waitUntil {sleep 0.2; isNull _p || {!alive _h} || {count (ropes _h) == 0} || {(ropeLength ((ropes _h) select 0)) >= (_r0 + 5)} || {time > _t}};
		if (!isNull _p) then {_p allowDamage true};
	};
};
["INFO", "podAssault", "%1 lowering the pod on its ropes from %2 m", [typeOf _h, round ((getPosATL _h) select 2)]] call MCC_fnc_log;

// (MK) The transport (covered) pod: its ramp opens as it's lowered, and it's "down" when its underside is on the ground
// (its centre sits higher than the bench's).
private _covered = ((toLower (typeOf _p)) find "covered") >= 0;
if (_covered) then {
	{
		private _an = toLower (configName _x);
		if ((_an find "door") >= 0 || {(_an find "ramp") >= 0}) then {_p animateSource [configName _x, 1]};
	} forEach ("true" configClasses (configOf _p >> "AnimationSources"));
};
// (MK) every pod - bench and transport - is "down" when its underside is on the ground (the bench went by its centre)
private _botOff = ((getPosATL _p) select 2) - ((_p modelToWorld ((boundingBoxReal _p) select 0)) select 2);
//(MK) "down" when the LOWEST corner of the underside is within 0.2 m of what's below it (measured under each corner, not
// just the centre - on a slope the downhill edge hung a metre up); checked 10 times a second in the last metres, at the
// same lowering speed (0.3 s checks let it move 0.6 m between them)
(boundingBoxReal _p) params ["_bb1", "_bb2"];
private _corners = [[_bb1 select 0, _bb1 select 1], [_bb2 select 0, _bb1 select 1], [_bb1 select 0, _bb2 select 1], [_bb2 select 0, _bb2 select 1]] apply {[(_x select 0) * 0.9, (_x select 1) * 0.9, _bb1 select 2]};
private _lowGap = 99;
private _v = 4;
private _t = time + 90;
private _arrived = false;
private _stuck = false;
private _rel = 0;
private _atl = 0;
private _hitObj = objNull;
private _lastZ = (getPosATL _p) select 2;
private _lastMove = time;
waitUntil {
	private _pw = getPosWorld _p;
	private _crewP = crew _p;
	private _ins = (lineIntersectsSurfaces [_pw, _pw vectorAdd [0, 0, -1000], _h, _p, true, 6]) select {
		private _o = _x select 2;
		isNull _o || {!(_o isKindOf "CAManBase") && {!(_o in _crewP)} && {!(_o isKindOf "Rope")} && {_o != _h}}
	};
	_atl = (getPosATL _p) select 2;
	_rel = if (count _ins > 0) then {(_pw select 2) - (((_ins select 0) select 0) select 2)} else {_atl};
	_atl = _atl - _botOff + 1.5; _rel = _rel - _botOff + 1.5;	// underside within 0.5 m counts as down (< 2 below)
	_hitObj = if (count _ins > 0) then {(_ins select 0) select 2} else {objNull};
	// the lowest corner: its height above the terrain or whatever is under it
	_lowGap = 99;
	{
		private _c = _p modelToWorldWorld _x;
		private _hit = (lineIntersectsSurfaces [_c vectorAdd [0, 0, 0.5], _c vectorAdd [0, 0, -60], _h, _p, true, 4]) select {
			private _o = _x select 2;
			isNull _o || {!(_o isKindOf "CAManBase") && {!(_o in _crewP)} && {!(_o isKindOf "Rope")} && {_o != _h}}
		};
		private _gz = if (count _hit > 0) then {((_hit select 0) select 0) select 2} else {getTerrainHeightASL _c};
		_lowGap = _lowGap min ((_c select 2) - _gz);
	} forEach _corners;
	_arrived = (_lowGap <= 0.2) || {!isNull _hitObj && {_hitObj isKindOf "Building"} && {_rel < 1.5} && {abs ((velocity _p) select 2) < 0.5}};
	if (abs (_atl - _lastZ) > 0.3) then {_lastZ = _atl; _lastMove = time};
	_stuck = !_arrived && {(time - _lastMove) > 3} && {count (ropes _h) > 0} && {ropeLength ((ropes _h) select 0) > 8};
	if (count (ropes _h) > 0 && {ropeLength ((ropes _h) select 0) <= 5}) then {_h disableCollisionWith _p} else {_h enableCollisionWith _p};
	_v = if (_rel < 1.5) then {15} else {if (_rel < 7) then {2} else {(_v + 0.3) min 12}};
	if (_h getVariable ["MCC_taruHoldAI", false]) then {
		// (MK) A player's waypoint drop (the pilot's own hover): the rope accounts for the Taru's own climb or descent, so the
		// pod comes down at the speeds above whatever the Taru does - let out slower (or wound in) while it descends,
		// faster while it climbs. The AI drop and the supply pods: the original line below, unchanged.
		private _rate = _v + ((velocity _h) select 2);
		if (_rate >= 0) then {
			{ropeUnwind [_x, _rate max 0.05, 100]} forEach (ropes _h);
		} else {
			{ropeUnwind [_x, -_rate, ((ropeLength _x) - 3) max 1]} forEach (ropes _h);
		};
	} else {
		{ropeUnwind [_x, _v, 100]} forEach (ropes _h);
	};
	sleep ([0.3, 0.1] select (_rel < 7));
	!alive _h || {!alive _p} || {time > _t} || {count (ropes _h) == 0} ||
	{_arrived} || {_stuck} || {ropeLength ((ropes _h) select 0) >= 99.5}
};
if (missionNamespace getVariable ["MCC_debug", false]) then {
	["INFO", "podAssault", "lowering stopped: %1 | pod underside %2 m above the ground, %3 m above %4 | touching %5 | rope %6 m | lowest corner %7 m up", [
		if (_arrived) then {"down"} else {if (_stuck) then {"stuck"} else {"rope or time limit"}},
		(round ((_atl - 1.5) * 10)) / 10, (round ((_rel - 1.5) * 10)) / 10, if (isNull _hitObj) then {"the terrain"} else {typeOf _hitObj},
		isTouchingGround _p, if (count (ropes _h) > 0) then {round (ropeLength ((ropes _h) select 0))} else {0}, (round (_lowGap * 100)) / 100
	]] call MCC_fnc_log;
};
{ropeUnwind [_x, 0, ropeLength _x]} forEach (ropes _h);
if (alive _h && {alive _p} && {_arrived}) then {sleep 1};	//(MK) held where it stopped - no more rope paid out (no slack)
if (!alive _h || {!alive _p} || {count (ropes _h) == 0}) exitWith {["WARN", "podAssault", "%1: the pod was lost while lowering", [typeOf _h]] call MCC_fnc_log; false};
if (!_arrived) exitWith {
	private _docked = if (_sling) then {[_h, 5, false, false] call MCC_fnc_podDock} else {_h call MCC_fnc_attachPod; !isNull (_h getVariable ["MCC_attachedPod", objNull])};
	private _res = false;
	if (!_retry && {_docked}) then {
		private _here2 = getPosATL _h;
		_here2 set [2, 0];
		private _np = [_here2, 25] call _fnc_spot;
		if (count _np > 1 && {[_np] call _fnc_moveTo}) then {
			["INFO", "podAssault", "%1: pod stopped above the ground - winched up, moved %2 m, trying again", [typeOf _h, round (_here2 distance2D _np)]] call MCC_fnc_log;
			_res = [_h, _tgt, true, _leave] call MCC_fnc_podAssault;
		} else {
			["WARN", "podAssault", "%1: pod stopped above the ground and could not move to try again - troops kept aboard", [typeOf _h]] call MCC_fnc_log;
		};
	} else {
		["WARN", "podAssault", "%1: pod stopped above the ground %2 - troops kept aboard", [typeOf _h, ["(again)", "and could not be winched back up"] select (!_docked)]] call MCC_fnc_log;
	};
	_res
};

// (MK) a supply pod: set down and left there - the ropes cut, the Taru goes without it
if (_leave) exitWith {
	{ropeDestroy _x} forEach (ropes _h);
	_h setVariable ["MCC_attachedPod", objNull, true];
	["INFO", "podAssault", "%1: pod set down at %2 and left there", [typeOf _h, mapGridPosition _p]] call MCC_fnc_log;
	true
};
private _n = count (crew _p);
{
	["podMoveOut", [_x, "podAssault"]] remoteExec ["MCC_fnc_secAction", _x, false];
	sleep 0.15;
} forEach (crew _p);
private _tl = time + 20;
waitUntil {
	sleep 0.2;
	// (MK) the ropes kept just taut while the passengers get out (taut ropes hold the bench upright): the pod lifted off
	// the ground (the Taru climbing in its hover) - a little more rope; slack (the Taru sinking) - wound back in
	if (alive _p && {count (ropes _h) > 0}) then {
		if ((((getPosATL _p) select 2) - _botOff) > 0.4) then {
			{ropeUnwind [_x, 2, ((ropeLength _x) + 0.5) min 100]} forEach (ropes _h);
		} else {
			{
				(ropeEndPosition _x) params [["_e1", []], ["_e2", []]];
				if (count _e1 > 2 && {count _e2 > 2}) then {
					private _slack = (ropeLength _x) - (_e1 distance _e2);
					if (_slack > 0.6) then {ropeUnwind [_x, 2, ((ropeLength _x) - (_slack - 0.2)) max 1]};
				};
			} forEach (ropes _h);
		};
	};
	count (crew _p) == 0 || {!alive _p} || {time > _tl}
};
[_p getVariable ["MCCMK_dd", []], -1] call MCCMK_fnc_dropDone;	//(MK) a supply pod lowered: its green dot off the map
["INFO", "podAssault", "drop pod lowered at %1 - %2 passengers out%3", [mapGridPosition _p, _n, if (count _tgt > 1) then {format [" - %1 m from its place on the line", round (_p distance2D _tgt)]} else {""}]] call MCC_fnc_log;
sleep 1;

if (_sling) exitWith {
	[_h] spawn {
		params ["_hh"];
		private _ok = [_hh, 5, false, false] call MCC_fnc_podDock;
		["INFO", "podAssault", "%1: pod %2", [typeOf _hh, ["NOT docked again", "winched up and docked again"] select _ok]] call MCC_fnc_log;
	};
	true
};
_h call MCC_fnc_attachPod;
!isNull (_h getVariable ["MCC_attachedPod", objNull])
