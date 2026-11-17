/*
	MCCMK_fnc_sarRope - (server) the rope pickup: [helicopter, caller, what he's on (the caller himself in the water, or
	the crippled boat / aircraft he's aboard), side] -> the people it picked up.
	Everyone of the side in the water within 50 m of the caller (and everyone aboard the crippled boat or aircraft) is
	included. The helicopter hovers 18 m over the middle of them (over the deck, for a boat) and drops two ropes; the two
	closest go first; AI swim to the nearest rope and take it within 3 m; players swim there and use "Climb rope"
	(MCCMK_fnc_sarClimbReq). It waits 2 minutes (longer, to 5, while people are still in the water) and moves over
	stragglers. A rope is free again once its climber is aboard.
*/
params [["_heli", objNull], ["_caller", objNull], ["_tgt", objNull], ["_side", sideUnknown]];
if (isNull _heli || {isNull _caller}) exitWith {[]};
private _pts = switch (true) do {
	case (_heli isKindOf "Heli_Transport_04_base_F");
	case (_heli isKindOf "Heli_Transport_03_base_F"): {[[1, -4, -1], [-1, -4, -1]]};
	default {[[1.3, 1.3, 0], [-1.3, 1.3, 0]]};
};
// (MK) Harness: Advanced Rappelling's own rope points (its first two), so a man climbs the very rope he swam to
if (call MCCMK_ropeHarness) then {
	private _ar = [_heli] call ARMK_Get_Heli_Rappel_Points;
	if ((count _ar) >= 2) then {_pts = [_ar select 0, _ar select 1]};
};
private _deckOn = !(_tgt isEqualTo _caller) && {!isNull _tgt};
private _whoFn = {
	private _w = allUnits select {
		alive _x && {(side group _x) isEqualTo _side} && {vehicle _x == _x} && {surfaceIsWater (getPos _x)}
		&& {((getPosASL _x) select 2) < 1.5} && {((_x distance2D _caller) < 50) || {((group _x) isEqualTo (group _caller)) && {(_x distance2D _caller) < 300}}}
	};
	if (_deckOn) then {_w append ((crew _tgt) select {alive _x})};
	_w arrayIntersect _w
};
private _centre = {
	params ["_l"];
	if (_l isEqualTo []) exitWith {getPos _caller};
	private _s = [0, 0, 0];
	{_s = _s vectorAdd (getPos _x)} forEach _l;
	_s vectorMultiply (1 / (count _l))
};
private _who = call _whoFn;
private _all = +_who;
private _deck = if (_deckOn) then {((getPosASL _tgt) select 2) + 1} else {0};
private _c = if (_deckOn) then {getPos _tgt} else {[_who] call _centre};
// (MK) MCCMK_fnc_heliHoverAt: the pilot's own approach, then carried over the boat - following it as
// it drifts - or the middle of the swimmers, and held there, 15 m up. (MK) the ropes drop once it is HELD over the boat
// - or, if it hasn't settled but is within 6 m of it, anyway (the hold goes on keeping it there). Over 6 m off: another
// try (30 s each), 6 minutes at most, then the ropes drop wherever it is.
private _tHold = time + 360;
private _ready = false;
while {!_ready && {alive _heli} && {alive (driver _heli)} && {time < _tHold}} do {
	_ready = [_heli, [[_c select 0, _c select 1, 0], _tgt] select _deckOn, 15, {alive _heli}] call MCCMK_fnc_heliHoverAt;
	if (!_ready) then {_ready = (_heli distance2D ([_c, getPos _tgt] select _deckOn)) < 6};
};
// (MK) the ropes are measured from where it is NOW, so the hold keeps this height from here
private _hsp = _heli getVariable ["MCCMK_holdSpot", []];
if (_hsp isNotEqualTo []) then {
	private _spt = _hsp select 0;
	private _baseZ = if (_spt isEqualType objNull) then {((getPosASL _spt) select 2) + 1} else {_spt select 2};
	_heli setVariable ["MCCMK_holdSpot", [_spt, (((getPosASL _heli) select 2) - _baseZ) max 5], true];
};
[_heli, true] call MCCMK_fnc_heliDoorsAll;	// (MK) doors open while the ropes are down
// (MK) each rope MEASURED: from its point on the helicopter straight down to whatever is under it - the boat's deck, or
// the sea - so its end is at the deck / the water
private _ropeLen = {
	params ["_pt"];
	private _top = _heli modelToWorldWorld _pt;
	private _hits = lineIntersectsSurfaces [_top, [_top select 0, _top select 1, -2], _heli, objNull, true, 1, "GEOM", "NONE"];
	private _z = if (_hits isEqualTo []) then {0} else {(((_hits select 0) select 0) select 2) max 0};
	((((_top select 2) - _z) + 0.4) max 5) min 60
};
private _ropes = _pts apply {ropeCreate [_heli, _x, [_x] call _ropeLen]};
_heli setVariable ["MCCMK_sarRopeObjs", _ropes];
_heli setVariable ["MCCMK_sarRope", [_pts, [true, true]], true];
_heli setVariable ["MCCMK_sarRopeAll", _who];
{_x setVariable ["MCCMK_sarRopeHeli", _heli, true]; _x setVariable ["MCCMK_sarRopeDeck", [objNull, _tgt] select _deckOn, true]} forEach _who;
// a man onto a rope (MCCMK_fnc_sarClimbLocal where he's local); the rope free again once he's aboard
// (MK) the pilot as it is now - for the log lines when someone boards from a rope (nothing runs in between)
MCCMK_sarPilotState = {
	params ["_h"];
	private _p = driver _h;
	private _lz = _h getVariable ["MCCMK_sarLZ", []];
	format ["pilot: %1 m up, %2 km/h, order '%3', %4 waypoint(s), engine %5, %6 m from the landing spot, over %7, order finished %8, planning to go to %9", round ((getPosATL _h) select 2), round (speed _h), if (isNull _p) then {"no pilot"} else {currentCommand _p}, if (isNull _p) then {0} else {count (waypoints group _p)}, isEngineOn _h, if (_lz isEqualTo []) then {"?"} else {str (round (_h distance2D _lz))}, ["land", "water"] select (surfaceIsWater (getPos _h)), if (isNull _p) then {"?"} else {unitReady _p}, if (isNull _p) then {"?"} else {str (expectedDestination _p)}]
};
// (MK) one line, at most every 5 s for the same man: why he is not going up
MCCMK_sarWhy = {
	params ["_u", "_text", "_args"];
	if (time > (_u getVariable ["MCCMK_sarLogT", 0])) then {
		_u setVariable ["MCCMK_sarLogT", time + 5];
		["INFO", "sarClimb", _text, _args] call MCC_fnc_log;
	};
};
MCCMK_sarStartClimb = {
	params ["_heli", "_u", "_i"];
	private _st = _heli getVariable ["MCCMK_sarRope", []];
	if (_st isEqualTo [] || {!((_st select 1) select _i)} || {_u getVariable ["MCCMK_sarClimbing", false]}) exitWith {false};
	// a seat for him: the empty passenger seats less those already climbing (no seat: he'd have nowhere to go at the top)
	private _up = {_x getVariable ["MCCMK_sarClimbing", false]} count ((_heli getVariable ["MCCMK_sarRopeAll", []]) select {alive _x});
	if ((([_heli] call MCCMK_seatsFree) - _up) < 1) exitWith {
		[_u, "%1 waits: no seat (%2 free, %3 already climbing)", [name _u, [_heli] call MCCMK_seatsFree, _up]] call MCCMK_sarWhy;
		false
	};
	if (call MCCMK_ropeHarness) exitWith {
		_u setVariable ["MCCMK_ropeQuiet", true, true];
		_u setVariable ["MCCMK_ropeObj", (_heli getVariable ["MCCMK_sarRopeObjs", []]) param [_i, objNull], true];	// the rope he climbs
		if !([_u, _heli, _i] call MCCMK_fnc_ropeUp) exitWith {
			_u setVariable ["MCCMK_ropeQuiet", nil, true]; _u setVariable ["MCCMK_ropeObj", nil, true];
			[_u, "%1 refused by the rope code on rope %2", [name _u, _i]] call MCCMK_sarWhy;
			false
		};
		["INFO", "sarClimb", "%1 starts up rope %2 (%3 climbing now, %4 seats free)", [name _u, _i, _up + 1, [_heli] call MCCMK_seatsFree]] call MCC_fnc_log;
		(_st select 1) set [_i, false];
		_heli setVariable ["MCCMK_sarRope", _st, true];
		_u setVariable ["MCCMK_sarClimbing", true, true];
		[_heli, _u, _i] spawn {
			params ["_heli", "_u", "_i"];
			private _t = time + 120;
			waitUntil {sleep 1; !alive _u || {!alive _heli} || {(vehicle _u) isEqualTo _heli} || {!(_u getVariable ["ARMK_Is_Rappelling", false])} || {_u getVariable ["MCCMK_ropeWait", false]} || {time > _t}};
			// (MK) the rope flag clears 0.6 s BEFORE he is seated, and this watch looks once a second, so it would catch
			// him before the seat. So: wait for the seat (3 s at most) - unless he is hanging below with no
			// seat free (MCCMK_ropeWait).
			if (alive _u && {alive _heli} && {!((vehicle _u) isEqualTo _heli)} && {!(_u getVariable ["ARMK_Is_Rappelling", false])} && {!(_u getVariable ["MCCMK_ropeWait", false])}) then {
				private _ts = time + 3;
				waitUntil {sleep 0.2; !alive _u || {!alive _heli} || {(vehicle _u) isEqualTo _heli} || {time > _ts}};
			};
			// (MK) aboard from the rope: where the pilot is, and 10 s later - to see what he does when someone boards
			if (alive _u && {alive _heli} && {(vehicle _u) isEqualTo _heli}) then {
				["INFO", "sarBoard", "%1 aboard from the rope - %2", [name _u, [_heli] call MCCMK_sarPilotState]] call MCC_fnc_log;
				[_heli, _u] spawn {
					params ["_h", "_u"];
					sleep 10;
					["INFO", "sarBoard", "%1 aboard 10 s ago - %2", [name _u, [_h] call MCCMK_sarPilotState]] call MCC_fnc_log;
				};
			};
			_u setVariable ["MCCMK_sarClimbing", false, true];
			private _st = _heli getVariable ["MCCMK_sarRope", []];
			if (_st isNotEqualTo []) then {
				(_st select 1) set [_i, true];
				_heli setVariable ["MCCMK_sarRope", _st, true];
			};
		};
		true
	};
	(_st select 1) set [_i, false];
	_heli setVariable ["MCCMK_sarRope", _st, true];
	_u setVariable ["MCCMK_sarClimbing", true, true];
	private _h = (((getPosASL _heli) select 2) - (((getPosASL _u) select 2) max 0)) max 4;
	private _spd = missionNamespace getVariable ["MCCMK_sarClimbSpeed", 1.5];
	[_u, _heli, (_st select 0) select _i, _h, _spd] remoteExec ["MCCMK_fnc_sarClimbLocal", _u];
	[_heli, _u, _i, (_h / (_spd max 0.3)) + 8] spawn {
		params ["_heli", "_u", "_i", "_dt"];
		private _t = time + _dt;
		waitUntil {sleep 0.5; !alive _u || {!alive _heli} || {(vehicle _u) isEqualTo _heli} || {time > _t}};
		_u setVariable ["MCCMK_sarClimbing", false, true];
		private _st = _heli getVariable ["MCCMK_sarRope", []];
		if (_st isNotEqualTo []) then {(_st select 1) set [_i, true]; _heli setVariable ["MCCMK_sarRope", _st, true]};
	};
	true
};
// (MK) a player-led squad's AI go up only when the leader sends them ("Rescue: send selected up" / "... everyone up");
// AI-led squads go by themselves. It leaves when told ("Send the helicopter off") or once everyone sent is aboard and
// nobody is left in the water - and only once someone has actually been sent up or come aboard (no time limit).
private _goFn = {
	params ["_u"];
	(_u getVariable ["MCCMK_sarSent", false]) || {!isPlayer (leader group _u)}
};
private _t0 = time;
private _shift = time;
private _ldr = leader group _caller;
_heli setVariable ["MCCMK_sarGo", false, true];
while {alive _heli && {alive (driver _heli)}} do {
	_who = (_who + ((call _whoFn) - _who)) select {alive _x && {!((vehicle _x) isEqualTo _heli)}};
	{_x setVariable ["MCCMK_sarRopeHeli", _heli, true]; _x setVariable ["MCCMK_sarRopeDeck", [objNull, _tgt] select _deckOn, true]} forEach (_who - _all);
	_all = _all + (_who - _all);
	_heli setVariable ["MCCMK_sarRopeAll", _all];
	private _up = {_x getVariable ["MCCMK_sarClimbing", false]} count _all;
	if (_heli getVariable ["MCCMK_sarGo", false]) exitWith {};
	// everyone sent is aboard and nobody's left swimming: done - but only once someone has been sent up or come aboard
	private _waiting = _who select {(vehicle _x == _x) || {[_x] call _goFn}};
	private _aboard = {(vehicle _x) isEqualTo _heli} count _all;
	private _started = _aboard > 0 || {({_x getVariable ["MCCMK_sarSent", false]} count _all) > 0} || {!isPlayer _ldr};
	// (MK) a player leading: it stays until he sends it off ("Send the helicopter off") or there's nobody left to take
	// - he may send his men up one or a few at a time 
	if (_up == 0 && {_waiting isEqualTo []} && {_started} && {!isPlayer _ldr || {_who isEqualTo []}}) exitWith {};
	// full (no seat left, nobody on the way up): done
	if (([_heli] call MCCMK_seatsFree) < 1 && {_up == 0}) exitWith {};
	private _bot = _pts apply {private _w = _heli modelToWorld _x; [_w select 0, _w select 1, 0]};
	// (MK) ORDER AT THE ROPES: each rope has ONE man swimming to it at a time - the nearest of those waiting, chosen again the
	// moment the one before is on it and climbing, so both ropes are always working; the rest tread water 8 m off (they all
	// swam at the ropes together and got in each other's way)
	private _cand = _who select {!isPlayer _x && {vehicle _x == _x} && {!(_x getVariable ["MCCMK_sarClimbing", false])} && {[_x] call _goFn}};
	private _q = +(_heli getVariable ["MCCMK_sarRopeQ", []]);
	while {(count _q) < (count _bot)} do {_q pushBack objNull};
	{
		private _r = _forEachIndex;
		private _cur = _q select _r;
		if (isNull _cur || {!alive _cur} || {!(_cur in _cand)}) then {
			private _rest = (_cand - _q) apply {[_x distance2D (_bot select _r), _x]};
			_rest sort true;
			_q set [_r, if (_rest isEqualTo []) then {objNull} else {(_rest select 0) select 1}];
		};
	} forEach _bot;
	_heli setVariable ["MCCMK_sarRopeQ", _q];
	private _mid = [0, 0, 0];
	{_mid = _mid vectorAdd _x} forEach _bot;
	_mid = _mid vectorMultiply (1 / ((count _bot) max 1));
	{
		private _u = _x;
		if !(_u in _q) then {
			if ((_u distance2D _mid) < 6 || {(_u distance2D _mid) > 14}) then {
				if (time > (_u getVariable ["MCCMK_sarMoveT", 0])) then {_u setVariable ["MCCMK_sarMoveT", time + 3]; _u doMove (_mid getPos [8, _mid getDir _u])};
			};
		};
	} forEach _cand;
	{
		private _u = _x;
		if (!isPlayer _u && {!(_u getVariable ["MCCMK_sarClimbing", false])} && {[_u] call _goFn} && {vehicle _u != _u || {_u in _q}}) then {
			private _free = ((_heli getVariable ["MCCMK_sarRope", [[], [false, false]]]) select 1);
			if (_deckOn && {(vehicle _u) isEqualTo _tgt}) then {
				private _fi = _free find true;
				if (_fi >= 0) then {[_heli, _u, _fi] call MCCMK_sarStartClimb} else {
					[_u, "%1 waits: no free rope (free: %2, climbing now: %3)", [name _u, _free, {_x getVariable ["MCCMK_sarClimbing", false]} count _all]] call MCCMK_sarWhy;
				};
			} else {
				private _ri = _q find _u;	// (MK) the rope he was given
				if (_ri < 0) then {_ri = [1, 0] select ((_u distance2D (_bot select 0)) <= (_u distance2D (_bot select 1)))};
				if ((_u distance2D (_bot select _ri)) < 3 && {_free select _ri}) then {[_heli, _u, _ri] call MCCMK_sarStartClimb} else {
					if (time > (_u getVariable ["MCCMK_sarMoveT", 0])) then {_u setVariable ["MCCMK_sarMoveT", time + 3]; _u doMove (_bot select _ri)};
				};
			};
		};
	} forEach _who;
	// moving over swimmers who are left
	if ((time - _shift) > 20) then {
		_shift = time;
		private _sw = _who select {vehicle _x == _x};
		if (_sw isNotEqualTo [] && {_up == 0}) then {
			private _c2 = [_sw] call _centre;
			if ((_c2 distance2D (getPos _heli)) > 10) then {[_heli, [_c2 select 0, _c2 select 1, 0], 15] remoteExec ["MCCMK_fnc_heliHold", _heli]};
		};
	};
	sleep 1;
};
[_heli] remoteExec ["MCCMK_fnc_heliHold", _heli];
[_heli, false] call MCCMK_fnc_heliDoorsAll;	// (shut as it leaves)
private _riders = _all select {alive _x && {_x getVariable ["ARMK_Is_Rappelling", false]} && {(_x getVariable ["MCCMK_ropeHeli", objNull]) isEqualTo _heli}};
if (_riders isEqualTo []) then {
	{ropeDestroy _x} forEach (((_heli getVariable ["MCCMK_sarRopeObjs", []]) + _ropes) select {!isNull _x});
} else {
	// (taken in once they're off - at the base, MCCMK_fnc_sarRun)
	_heli setVariable ["MCCMK_sarKeepRopes", ((_heli getVariable ["MCCMK_sarRopeObjs", []]) + _ropes) select {!isNull _x}];
	// (MK) and they come up as soon as nobody is on a rope any more - even in flight, not only at the base. One waiter, which
	// ends when the last rider is aboard (or at the base, which takes the ropes in itself, or after 15 minutes).
	[_heli, _all] spawn {
		params ["_heli", "_all"];
		private _tw = time + 900;
		waitUntil {sleep 1; !alive _heli || {time > _tw} || {isNil {_heli getVariable "MCCMK_sarKeepRopes"}} || {(_all findIf {alive _x && {_x getVariable ["ARMK_Is_Rappelling", false]} && {(_x getVariable ["MCCMK_ropeHeli", objNull]) isEqualTo _heli}}) < 0}};
		if (alive _heli && {!isNil {_heli getVariable "MCCMK_sarKeepRopes"}}) then {
			sleep 1.5;	// the last man seated
			{ropeDestroy _x} forEach ((_heli getVariable ["MCCMK_sarKeepRopes", []]) select {!isNull _x});
			_heli setVariable ["MCCMK_sarKeepRopes", nil];
			["INFO", "sarRope", "last rider aboard - ropes taken in", []] call MCC_fnc_log;
		};
	};
};
_heli setVariable ["MCCMK_sarRopeObjs", nil];
_heli setVariable ["MCCMK_sarRope", nil, true];
_heli setVariable ["MCCMK_sarRopeAll", nil];
{
	_x setVariable ["MCCMK_sarRopeHeli", nil, true]; _x setVariable ["MCCMK_sarRopeDeck", nil, true];
	// (MK) sent but left in the water (the helicopter full): kept as sent - the next helicopter takes him in his turn
	if ((vehicle _x) isEqualTo _heli || {!alive _x} || {!(_x getVariable ["MCCMK_sarSent", false])}) then {_x setVariable ["MCCMK_sarSent", nil, true]};
} forEach _all;
_heli setVariable ["MCCMK_sarRopeQ", nil];
_heli setVariable ["MCCMK_sarGo", nil, true];
_all select {alive _x && {((vehicle _x) isEqualTo _heli) || {(_x getVariable ["ARMK_Is_Rappelling", false]) && {(_x getVariable ["MCCMK_ropeHeli", objNull]) isEqualTo _heli}}}}
