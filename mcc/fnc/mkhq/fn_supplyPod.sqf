// (server) A Taru supply pod: the side's Taru, in its livery, flies in from 5 km back along the drawn line with the pod
// on its sling, parachutes it in (method 0) or lowers it on the winch onto a clear spot (method 1), then flies off to
// the map edge. The pod is a service point (fuel, repair, ammunition, medical, cargo) and can be picked up later
// ("Pick up pod"). [caller, side, pod index, method, position, direction]
params [["_u", objNull, [objNull]], ["_side", west, [west]], ["_i", 0, [0]], ["_method", 0, [0]], ["_pos", [0, 0, 0], [[]]], ["_dir", 0, [0]],
	["_free", false, [false]],	//(MK) the mission maker's pod (MCC console Supply Drop): no cost
	["_crewFac", "", [""]],
	["_dd", [], [[]]],	//(MK) the drop id [id, owner]: its green dot goes when the pod is down,	//(MK) the faction that crews the Taru (the MCC console's chosen faction); "": the caller's
	["_smoke", -1, [0]],
	["_height", 120, [0]]];	//(MK) the parachute drop's flight height (the MCC console's Height list)	//(MK) 1 / 0: smoke where it lands or not (the MCC console's Smoke box); -1: the Airdrop panel's
private _smokeOn = if (_smoke < 0) then {missionNamespace getVariable ["MCCMK_dropSmoke", true]} else {_smoke == 1};
if (!isServer) exitWith {};
((call MCCMK_fnc_podInfo) param [_i, ["box", "Logistics"]]) params ["_kind", "_label"];
private _say = {params ["_m"]; if (!isNull _u) then {[_m] remoteExec ["MCCMK_fnc_hint", _u]}};
private _cost = [_i] call MCCMK_fnc_podCost;
private _var = format ["MCC_res%1", _side];
private _r = +(missionNamespace getVariable [_var, [0, 0, 0, 0, 0]]);
//(MK) no charge for the mission maker's pod, or while resources are Free (the screen skipped the check, the server
// still charged - and refused a side that couldn't pay)
private _charge = !_free && {!(call MCCMK_fnc_resFree)};
if (_charge && {(_r select 0) < (_cost select 0) || {(_r select 1) < (_cost select 1)} || {(_r select 2) < (_cost select 2)} || {(_r select 4) < (_cost select 3)}}) exitWith {["Not enough resources for that pod."] call _say};
if (_charge) then {
	_r set [0, (_r select 0) - (_cost select 0)];
	_r set [1, (_r select 1) - (_cost select 1)];
	_r set [2, (_r select 2) - (_cost select 2)];
	_r set [4, (_r select 4) - (_cost select 3)];
	missionNamespace setVariable [_var, _r];
	publicVariable _var;
};
([_side, _kind] call MCCMK_fnc_podClasses) params ["_heliCls", "_podCls"];
_pos set [2, 0];
//(MK) No wind: the aim point is the mark. Arma's own canopy brings the pod down (below).
private _aim = +_pos;
//(MK) Seconds of the Taru's speed to release before the mark (the pod's forward carry): the free fall (it keeps its
// forward speed while it falls) plus ~0.3 s of carry under the canopy.
private _tFall = if (_height > 120) then {sqrt (2 * (_height - 120) / 9.81)} else {[1.5, 1] select (_height < 50)};	// the free fall: down to 120 m from higher, 1.5 s (1 s below 50 m) otherwise
private _leadS = _tFall + 1.2;	// plus the forward carry while the canopy brakes it; the steering under the canopy corrects the rest
private _relDist = 63 * _leadS;	// the release point, before the mark - at its ~230 km/h
private _start = _aim getPos [_relDist + 5000, _dir + 180];
private _h = createVehicle [_heliCls, _start, [], 0, "FLY"];
_h setPosASL [_start select 0, _start select 1, ((getTerrainHeightASL _start) max 0) + (150 max _height)];
_h setDir _dir;
_h setVelocityModelSpace [0, 50, 0];
private _g = createVehicleCrew _h;
[_h, if (_crewFac != "") then {_crewFac} else {if (isNull _u) then {_side} else {faction _u}}] call MCCMK_fnc_crewFix;	//(MK) the caller's faction flies it
if ((side _g) != _side) then {private _ng = createGroup [_side, true]; (units _g) joinSilent _ng; _g = _ng};
[_h, [faction _u, _side] call MCCMK_fnc_factionPilot] call MCCMK_fnc_recrew;
_g setBehaviour "CARELESS";
_g setCombatMode "BLUE";
_h flyInHeight ([_height, 60] select (_method == 1));
private _pod = createVehicle [_podCls, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_pod setVariable ["MCCMK_dd", _dd];
_pod attachTo [_h, [0, 0, -1.2]];
[_pod, _h] remoteExecCall ["disableCollisionWith", 0, _pod];	//(MK) the pod can't bump the Taru while attached
_h setVariable ["MCC_attachedPod", _pod, true];
_pod setVariable ["MCCMK_podSide", _side, true];
if (_charge) then {_pod setVariable ["MCCMK_podPaid", [_cost, _side], true]};	//(MK) for salvaging it (a free pod: nothing back)
[format ["%1 pod on its way.", _label]] call _say;
["INFO", "pods", "%1 pod (%2) for %3 by %4 at grid %5", [_label, ["parachute", "winch"] select _method, _side, name _u, mapGridPosition _pos]] call MCC_fnc_log;
private _t = time;
if (_method == 0) then {
	//(MK) through the mark at speed: sent 3 km past it (sent TO it, the Taru stops and hovers short of it)
	// (MK) the run-in as waypoints along the line (Arma's AI flies them - nothing forces it onto the line): a lead-in
	// 3 km before the aim point to straighten up, the aim point itself (15 m), then 3 km past it
	{deleteWaypoint _x} forEachReversed (waypoints _g);
	{
		_x params ["_wpPos", "_rad"];
		private _w = _g addWaypoint [[_wpPos select 0, _wpPos select 1, _height], 0];
		_w setWaypointType "MOVE";
		_w setWaypointSpeed "FULL";
		_w setWaypointBehaviour "CARELESS";
		_w setWaypointCombatMode "BLUE";
		_w setWaypointCompletionRadius _rad;
	} forEach [[_aim getPos [_relDist + 3000, _dir + 180], 150], [_aim getPos [_relDist + 1000, _dir + 180], 30], [_aim getPos [_relDist, _dir + 180], 50], [_aim getPos [3000, _dir], 300]];	//(MK) lead-in 3 km, alignment 1 km before the release point (30 m), the release point (50 m), then 3 km past the mark - the pattern that got the Taru nearest the line (25-37 m)
	_g setSpeedMode "FULL";
	_h flyInHeight _height;
} else {
	_h doMove _pos;
};
if (_method == 0) then {
	// (MK) released at the mark - within 15 m, or as soon as the Taru passes it: at low speed the pod falls nearly
	// straight down.
	private _apDir = _start getDir _aim;
	// (MK) Checked every frame: the scheduler can be seconds late with a lot running (the pods went 350-550 m past the
	// mark at 228 km/h). Released early by its forward carry - _leadS, set by the drop height (above).
	_h setVariable ["MCCMK_podRel", []];
	private _eh = addMissionEventHandler ["EachFrame", {
		_thisArgs params ["_h", "_pod", "_pos", "_apDir", "_leadS"];
		if (!alive _h || {isNull _pod}) exitWith {removeMissionEventHandler ["EachFrame", _thisEventHandler]};
		private _hp = getPosATL _h;
		private _ahead = (((_pos select 0) - (_hp select 0)) * (sin _apDir)) + (((_pos select 1) - (_hp select 1)) * (cos _apDir));
		if (_ahead <= (((vectorMagnitude (velocity _h)) * _leadS) min 1500)) then {	// (MK) _leadS: by height (above)
			removeMissionEventHandler ["EachFrame", _thisEventHandler];
			private _v = velocity _h;
			_h setVariable ["MCCMK_podRel", [getPosASL _pod, _v]];
			_pod allowDamage false;	//(MK) no damage for the first 2 s after release (the parachute lowers it gently)
			_pod disableCollisionWith _h;	//(MK) and no knock from the Taru as it's let go
			detach _pod;
			// (MK) straight along the line: its forward (and vertical) speed, not the Taru's sideways weave
			private _u = [sin _apDir, cos _apDir, 0];
			_pod setVelocity ((_u vectorMultiply (_v vectorDotProduct _u)) vectorAdd [0, 0, _v select 2]);
			_pod setAngularVelocity [0, 0, 0];	// (MK) no spin from the Taru's turning as it's let go
		};
	}, [_h, _pod, _aim, _apDir, _leadS]];	//(MK) released by the aim point (the mark)
	waitUntil {sleep 0.1; !alive _h || {isNull _pod} || {(_h getVariable ["MCCMK_podRel", []]) isNotEqualTo []} || {(time - _t) > 300}};
	removeMissionEventHandler ["EachFrame", _eh];
	if (alive _h && {alive _pod} && {(_h getVariable ["MCCMK_podRel", []]) isEqualTo []}) then {	// the 5-minute backstop
		_h setVariable ["MCCMK_podRel", [getPosASL _pod, velocity _h]];
		_pod allowDamage false;
		detach _pod;
		_pod setVelocity (velocity _h);
		_pod setAngularVelocity [0, 0, 0];
	};
	if (alive _h && {alive _pod}) then {
		(_h getVariable ["MCCMK_podRel", [getPosASL _pod, velocity _h]]) params ["_relPos", "_v"];
		// (MK) where it's released and where it lands, along the Taru's line from the mark (negative: before it)
		private _ld = _apDir;
		private _rel = _relPos vectorDiff (AGLToASL [_pos select 0, _pos select 1, 0]);
		private _relA = _relPos vectorDiff (AGLToASL [_aim select 0, _aim select 1, 0]);
		["INFO", "pods", "%1 pod released | along %2 m, side %3 m from the mark (negative: before it) | %4 m up | %5 km/h | Taru %6 m off its own line, moving %7 m/s sideways", [_label, round (_rel vectorDotProduct [sin _ld, cos _ld, 0]), round (_rel vectorDotProduct [cos _ld, -(sin _ld), 0]), round ((ASLToATL _relPos) select 2), round ((vectorMagnitude _v) * 3.6), round (_relA vectorDotProduct [cos _ld, -(sin _ld), 0]), (round ((_v vectorDotProduct [cos _ld, -(sin _ld), 0]) * 10)) / 10]] call MCC_fnc_log;
		_pod setVariable ["MCCMK_dropInfo", [_pos, _ld, _label]];
		[_pod] spawn {params ["_pod"]; sleep 2; if (!isNull _pod) then {_pod allowDamage true}};	//(MK) vulnerable 2 s after release
		[_pod, _smokeOn, _apDir, _aim, _height] spawn {
			params ["_pod", "_smokeOn", "_apDir", "_aim", "_height"];
			//(MK) High-velocity style, at every height (the one behaviour): a free fall - the familiar 1.5 s (1 s below 50 m),
			// or from above 120 m down to 120 m - then the canopy: its crumpled opening seen (it appears 1.2 s before, riding
			// along without holding the pod), then a scripted opening shock and descent, because Arma's own canopy needs
			// 150-230 m to stop a fast pod: the forward speed braked away in ~2.5 s, 8 m/s down, canopy upright with the pod
			// hanging straight below, steered gently to the mark (and nudged towards it during the free fall). A cushioned
			// landing, the crushable pads of a real high-velocity drop. ~10 s under the canopy from any height.
			private _hOf = {params ["_o"]; (([getPosATL _o, getPosASL _o] select (surfaceIsWater (getPos _o))) select 2)};
			private _aimASL = AGLToASL [_aim select 0, _aim select 1, 0];
			private _u = [sin _apDir, cos _apDir, 0];
			private _n = [cos _apDir, -(sin _apDir), 0];
			private _t0 = time;
			private _p0 = getPosASL _pod;
			private _ffT = [1.5, 1] select (_height < 50);	// the timed free fall (drops of 120 m or less)
			private _byHeight = _height > 120;	// higher: the free fall down to 120 m
			// the free fall: its rotation cleared, and nudged towards the line of the mark
			// (a few m/s sideways while it does 60 m/s forward - unseen), until the canopy takes it. Its orientation is not
			// held (that froze its fall) - Arma's physics has it.
			[_pod, _aimASL, _n] spawn {
				params ["_pod", "_aimASL", "_n"];
				private _t = time + 20;
				while {!isNull _pod && {isNull (attachedTo _pod)} && {time < _t}} do {
					_pod setAngularVelocity [0, 0, 0];	// (MK) its rotation cleared through the free fall (holding its orientation froze its fall)
					private _off = ((getPosASL _pod) vectorDiff _aimASL) vectorDotProduct _n;	// right of the line
					private _v = velocity _pod;
					private _side = _v vectorDotProduct _n;
					private _want = ((-_off * 0.5) max -5) min 5;
					private _d = ((_want - _side) max -0.5) min 0.5;
					if (_d != 0) then {_pod setVelocity (_v vectorAdd (_n vectorMultiply _d))};
					sleep 0.1;
				};
			};
			// the canopy appears 1.2 s before it takes the pod
			waitUntil {
				sleep 0.02;
				private _vz = abs ((velocity _pod) select 2);
				isNull _pod || {if (_byHeight) then {(([_pod] call _hOf) - (_vz * 1.2) - 7.06) <= 120 && {(time - _t0) >= 0.3}} else {(time - _t0) >= ((_ffT - 1.2) max 0.3)}} || {time > _t0 + 40}
			};
			if (isNull _pod) exitWith {};
			private _cp = (getPosASL _pod) vectorAdd [0, 0, 1.3];
			private _chute = createVehicle ["B_Parachute_02_F", ASLToAGL _cp, [], 0, "CAN_COLLIDE"];
			_chute disableCollisionWith _pod;
			_pod disableCollisionWith _chute;
			_chute attachTo [_pod, [0, 0, 1.3]];
			_chute setDir (_apDir - (getDir _pod));
			// ...and takes it: at 120 m, or at the end of the timed free fall
			waitUntil {sleep 0.02; isNull _pod || {if (_byHeight) then {([_pod] call _hOf) <= 120} else {(time - _t0) >= _ffT}} || {time > _t0 + 45}};
			if (isNull _pod || {isNull _chute}) exitWith {if (!isNull _chute) then {deleteVehicle _chute}};
			isNil {
				private _podDir = getDir _pod;
				detach _chute;
				_chute setDir _apDir;
				_chute setPosASL ((getPosASL _pod) vectorAdd [0, 0, 1.3]);
				_chute setVelocity (velocity _pod);
				_pod attachTo [_chute, [0, 0, -1.3]];
				_pod setDir (_podDir - _apDir);	// (MK) keeps the heading it had - attached, it would snap round to the canopy's
			};
			["INFO", "pods", "free fall: %1 s, %2 m forward | canopy took it %3 m up, falling %4 m/s", [round ((time - _t0) * 10) / 10, round (_p0 distance2D (getPosASL _pod)), round ([_pod] call _hOf), round (abs ((velocity _chute) select 2))]] call MCC_fnc_log;
			// the scripted descent: the opening shock (forward speed braked away, the fall brought to 8 m/s, in ~2.5 s), then
			// 8 m/s down, steered to the mark (6 m/s at most), the canopy held upright - every frame until the underside is down
			private _bbz = ((boundingBoxReal _pod) select 0) select 2;
			private _touch = 0;
			while {!isNull _pod && {!isNull _chute} && {(attachedTo _pod) isEqualTo _chute}} do {
				private _v = velocity _chute;
				private _to = _aimASL vectorDiff (getPosASL _chute);
				_to set [2, 0];
				private _dist = vectorMagnitude _to;
				private _wantH = if (_dist > 0.5) then {_to vectorMultiply (((_dist * 0.4) min 6) / _dist)} else {[0, 0, 0]};
				private _dH = (_wantH vectorDiff [_v select 0, _v select 1, 0]);
				private _mH = vectorMagnitude _dH;
				if (_mH > 1.3) then {_dH = _dH vectorMultiply (1.3 / _mH)};
				private _dZ = ((-8 - (_v select 2)) max -1.3) min 1.3;
				_chute setVelocity [(_v select 0) + (_dH select 0), (_v select 1) + (_dH select 1), (_v select 2) + _dZ];
				_chute setVectorUp [0, 0, 1];
				_touch = vectorMagnitude (velocity _chute);
				if (((_pod modelToWorld [0, 0, _bbz]) select 2) < 0.4) exitWith {};
				sleep 0.05;
			};
			// the cushioned landing - the crushable pads of a real high-velocity drop: set down on its pads, no landing damage
			if (!isNull _pod) then {
				_pod allowDamage false;
				detach _pod;
				_pod setVelocity [0, 0, -1];
				[_pod] spawn {params ["_pod"]; sleep 2; if (!isNull _pod) then {_pod allowDamage true}};
			};
			if (!isNull _pod && _smokeOn) then {"SmokeShellGreen" createVehicle (_pod getPos [3, (getDir _pod) + 90])};	//(MK) Smoke tick box
			if (!isNull _pod) then {
				sleep 2;
				(_pod getVariable ["MCCMK_dropInfo", [getPos _pod, 0, "Supply"]]) params ["_mk", "_ld", "_lb"];
				private _o = (getPosASL _pod) vectorDiff (AGLToASL [_mk select 0, _mk select 1, 0]);
				[_pod getVariable ["MCCMK_dd", []], -1] call MCCMK_fnc_dropDone;	//(MK) its green dot off the map
				["INFO", "pods", "%1 pod landed | along %2 m, side %3 m from the mark (negative: before it) | %4 m/s at touchdown | damage %5%6", [_lb, round (_o vectorDotProduct [sin _ld, cos _ld, 0]), round (_o vectorDotProduct [cos _ld, -(sin _ld), 0]), (round (_touch * 10)) / 10, round ((damage _pod) * 100), "%"]] call MCC_fnc_log;
			};
			sleep 3;
			if (!isNull _chute) then {deleteVehicle _chute};
		};
	};
} else {
	// winch: exactly as an AI Taru does it (MCC_fnc_taruAI "winch"): its approach and hover, the pod lowered on its ropes
	// (a clear spot found first) - and left on the ground, the ropes cut
	waitUntil {sleep 0.5; !alive _h || {(_h distance2D _pos) < 1000} || {(time - _t) > 300}};
	["INFO", "pods", "%1 %2 m out - the Taru's own winch drop takes over", [typeOf _h, round (_h distance2D _pos)]] call MCC_fnc_log;
	if (alive _h && {alive _pod}) then {[_h, "winch", _pos, true] call MCC_fnc_taruAI};
	if (alive _pod && {isNull (attachedTo _pod)} && _smokeOn) then {"SmokeShellGreen" createVehicle (_pod getPos [3, (getDir _pod) + 90])};	//(MK) Smoke tick box
};
if (!alive _h) exitWith {["The Taru was lost before it could deliver the pod."] call _say};
[format ["%1 pod delivered at grid %2.", _label, mapGridPosition _pod]] remoteExec ["systemChat", _side];
[_h, _g] spawn MCCMK_fnc_podExit;
