/*
	MCCMK_fnc_heliRopePos - (server; waits) "Fast Rope Pos" for MCC MK's fast-ropes and rope extraction: the Commander Console's Fast-rope waypoint
	(MCCMK_fnc_fastRopeRun), the Evac's Fast-Rope and its Rope extraction (MCC_fnc_evacMove). Not the rescue boat's hover
	(MCCMK_fnc_heliHoverAt / MCCMK_fnc_heliHold - its own, tuned for a moving boat).
	[helicopter, spot, hover height (m, the waypoint's / the Evac's Hover height; -1 for 20-35 m), {still wanted?}]
	-> true once it is HELD over the spot (false if it wasn't within a minute of the takeover). Let go with
	[helicopter] remoteExec ["MCCMK_fnc_heliRopeHold", helicopter].
	  1. The pilot's own approach to a MOVE waypoint put 90 m PAST the spot along the line he comes in on: his own stopping
	     point (he pulls up short of a move waypoint - the game's own behaviour) then falls close to the spot.
	  2. He has finished his approach when his waypoint is done (and he is under 6 m/s), or when he has been all but still
	     in the air (under 2 m/s) for 2 seconds within 300 m of the spot, once he has got going (or had 20 s to).
	  3. His waypoints are taken away - nowhere left for him to go, so he doesn't fight being moved - and the helicopter is
	     carried the rest of the way and held there frame by frame (MCCMK_fnc_heliRopeHold): the speed a 1.2 m/s2 brake
	     gives from that distance, 12 m/s at most, changed by 2.5 m/s a second (4 once held); the height checked above the
	     ground or the top of whatever stands there - under it, on the next 30 m of its path, within rotor reach, and on the
	     spot; never in over something it hasn't climbed above; eased to a stop if something solid is within 5 m ahead.
	The height: by default it aims for 20 m above the ground (or whatever stands there) and leaves it
	alone up to 35 m. Here the aim is the Hover height asked for, left alone from 3 m below it to 5 m above (it isn't locked:
	held at one exact height the pilot fights it). With no Hover height (-1): 20-35 m.
	(One addition, for MCC: the pilot's approach is also given as a move order to the same point, and ended at the takeover
	- an order already standing outranks a waypoint, and the helicopters come here from other orders.)
	FINE-TUNING (MK):
	  - the descent on the way in (MCCMK_fnc_heliGlide) is ended here, so only this sets the pilot's flying height;
	  - above its band it is brought down more firmly (its climb / sink changed by 4 m/s a second, not 2.5);
	  - the takeover also comes once it is within 150 m and slower than 60 km/h - before the pilot's own flare (console:
	    MCCMK_ropeTakeDist, MCCMK_ropeTakeKmh; 0 turns it off - step 2's rule only);
	  - carried faster: a 2 m/s2 brake, 16 m/s at most, its speed changed by up to 4 m/s a second (console:
	    MCCMK_ropeBrake, MCCMK_ropeTop, MCCMK_ropeAccel - without them 1.2, 12 and 2.5);
	  - at the takeover the pilot's move order is the dot itself (he heads the way he is carried);
	  - the doors and ramp open as it comes within 20 m (the 4th parameter: [... , {cond}, doors?]);
	  - it RETURNS as soon as it is within 1 m of the dot and slower than 1.5 m/s over the ground (or once held): the
	    ropes go then, not after "held" (the hold carries on keeping it there). 60 s at most.
*/
params [["_h", objNull], ["_spot", [0, 0, 0]], ["_hover", -1], ["_cond", {true}], ["_doors", true]];
if (isNull _h || {!alive _h} || {isNull (driver _h)}) exitWith {false};
_spot = [_spot select 0, _spot select 1, 0];
private _band = if (_hover > 0) then {[_hover, 3, 5]} else {[20, 0, 15]};	// [aim, room below, room above]
// (MK) the carry: [brake m/s2, top speed m/s, speed change m/s2 while carrying] - without the console settings: 1.2, 12 and 2.5
_band append [(missionNamespace getVariable ["MCCMK_ropeBrake", 2]) max 0.5, (missionNamespace getVariable ["MCCMK_ropeTop", 16]) max 3, (missionNamespace getVariable ["MCCMK_ropeAccel", 4]) max 1];
_h setVariable ["MCCMK_glideId", -1];	// (MK) the descent on the way in ended: only this sets the flying height
private _id = (_h getVariable ["MCCMK_ropePosId", 0]) + 1;
_h setVariable ["MCCMK_ropePosId", _id, true];
[_h] remoteExec ["MCCMK_fnc_heliRopeHold", _h];	// (any earlier hold let go)
[_h] remoteExec ["MCCMK_fnc_heliHold", _h];
_h land "NONE";
_h flyInHeight (_band select 0);
private _drv = driver _h;
private _g = group _drv;
for "_w" from ((count (waypoints _g)) - 1) to 0 step -1 do {deleteWaypoint [_g, _w]};
// 1. the waypoint 90 m past the spot, along the line he comes in on
private _from = getPos _h;
private _wpPos = _spot;
if ((_from distance2D _spot) > 5) then {
	private _pp = _spot getPos [90, _from getDir _spot];
	_wpPos = [_pp select 0, _pp select 1, 0];
};
private _wp = _g addWaypoint [_wpPos, 0];
_wp setWaypointType "MOVE";
_wp setWaypointSpeed "FULL";
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointCombatMode "BLUE";
_wp setWaypointCompletionRadius 100;
_g setCurrentWaypoint _wp;
_h doMove _wpPos;
private _dbg = missionNamespace getVariable ["MCC_debug", false];
if (_dbg) then {["INFO", "ropePos", "%1 to %2: approach to a waypoint 90 m past it, from %3 m away | hover %4 (%5 m below to %6 m above left alone)", [typeOf _h, mapGridPosition _spot, round (_from distance2D _spot), _band select 0, _band select 1, _band select 2]] call MCC_fnc_log};
// 2. his own approach over
private _t0 = time;
private _stillSince = -1;
private _hasFlown = false;
waitUntil {
	sleep 0.25;
	private _v = vectorMagnitude (velocity _h);
	private _air = ((getPos _h) select 2) > 5;
	if (_v > 5) then {_hasFlown = true};
	if (_air && {_hasFlown || {(time - _t0) > 20}} && {(_h distance2D _spot) < 300} && {_v < 2}) then {
		if (_stillSince < 0) then {_stillSince = time};
	} else {
		_stillSince = -1;
	};
	private _pg = group (driver _h);
	!alive _h || {isNull (driver _h)} || {!(call _cond)} || {(time - _t0) > 420}
	|| {(_h getVariable ["MCCMK_ropePosId", 0]) != _id}
	|| {_air && {(currentWaypoint _pg) >= (count (waypoints _pg))} && {_v < 6}}
	|| {_stillSince > 0 && {(time - _stillSince) > 2}}
	// (MK) or once it is close and slow enough (0 m or 0 km/h: step 2's rule only)
	|| {_air && {_hasFlown} && {(_h distance2D _spot) < (missionNamespace getVariable ["MCCMK_ropeTakeDist", 150])} && {(_v * 3.6) < (missionNamespace getVariable ["MCCMK_ropeTakeKmh", 60])}}
};
if (!alive _h || {isNull (driver _h)} || {!(call _cond)} || {(_h getVariable ["MCCMK_ropePosId", 0]) != _id}) exitWith {false};
// 3. nowhere left for him to go; carried over the spot and held
_g = group (driver _h);
for "_w" from ((count (waypoints _g)) - 1) to 0 step -1 do {deleteWaypoint [_g, _w]};
// (MK) his move order pointed at the dot itself: he heads the way he is being carried.
_h doMove _spot;
if (_dbg) then {["INFO", "ropePos", "%1 takeover after %2 s: %3 m from the spot, %4 km/h, %5 m up", [typeOf _h, round (time - _t0), round (_h distance2D _spot), round (speed _h), round ((getPosATL _h) select 2)]] call MCC_fnc_log};
[_h, _spot, _band, _id] remoteExec ["MCCMK_fnc_heliRopeHold", _h];
private _t1 = time;
// (MK) ready: within 1 m of the dot, slower than 1.5 m/s over the ground (or held) - the doors open on the way, within 20 m
private _opened = !_doors;
private _ready = {
	private _vv = velocity _h;
	((_h distance2D _spot) < 1 && {(sqrt (((_vv select 0) ^ 2) + ((_vv select 1) ^ 2))) < 1.5}) || {(_h getVariable ["MCCMK_ropeState", ""]) == "hold"}
};
waitUntil {
	sleep 0.1;
	if (!_opened && {(_h distance2D _spot) < 20}) then {_opened = true; [_h, true] call MCCMK_fnc_heliDoorsAll};
	!alive _h || {!(call _cond)} || {call _ready} || {(time - _t1) > 60}
};
if (!_opened && {alive _h}) then {[_h, true] call MCCMK_fnc_heliDoorsAll};
private _held = alive _h && {call _ready};
// (MK) THE PILOT'S HEIGHT MATCHED TO THE HOVER'S: once it has settled, how far the helicopter sits from the height the
// hover wants is measured, and the pilot's flying height moved by that much, twice - the pilot and the hover measured
// height differently.
[_h, (_h getVariable ["MCCMK_ropeSpotTgt", ((getTerrainHeightASL _spot) max 0) + (_band select 0)]), (_band select 0)] spawn {
	params ["_h", "_wantASL", "_fly"];
	private _t = time + 12;
	waitUntil {sleep 0.5; !alive _h || {time > _t} || {true}};
	sleep 3;
	for "_k" from 1 to 2 do {
		if (!alive _h || {isNull (driver _h)} || {isPlayer (driver _h)}) exitWith {};
		// (MK) only while it is held at the hover height - never once it starts down onto the water
		if (!isNil {_h getVariable "MCCMK_waterState"} || {!(!isNil {_h getVariable "MCCMK_ropeState"})}) exitWith {};
		private _err = ((getPosASL _h) select 2) - _wantASL;
		if ((abs _err) > 1.5) then {
			_fly = (_fly - _err) max 3;
			_h flyInHeight _fly;
		};
		sleep 4;
	};
};

_held
