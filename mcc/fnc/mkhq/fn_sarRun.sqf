/*
	MCCMK_fnc_sarRun - (server) search and rescue: [unit, "crew"]. The unit (and everyone with him) picked up - from the
	water, a crippled floating aircraft or a crippled boat (which is left where it is; there is no tow).
	Where it comes from: the side's nearest ship within 6 km (a boat within 1 km, else a helicopter); otherwise
	("Search and rescue without a ship": Out of sight) a helicopter out of sight about 4.5 km away, routed round the
	mission areas (MCCMK_fnc_sarSpawnPos, MCCMK_fnc_safeRoute). The pickup: ropes ("Rescue pickup": Rope climb,
	MCCMK_fnc_sarRope) or Instant (everyone placed aboard within 25 m). Home: back to the ship and aboard, or
	(no ship) landed at the side's nearest HQ or F.O.B. (MCCMK_fnc_sarHome), then off the edge of the map. The time it
	may take follows the distance (twice the expected trip, at least 8 minutes); 3 minutes between rescues from a ship,
	and from out of sight for the side.
*/
params [["_u", objNull], ["_mode", "crew"], ["_boat", objNull], ["_noCD", false]];
if (!isServer || {isNull _u}) exitWith {};
private _side = side group _u;
private _say = {params ["_m"]; [_m] remoteExec ["MCCMK_fnc_hint", _u]};

// ---- the crew ----
private _tgt = vehicle _u;	// the unit in the water, or the crippled boat / aircraft he's aboard
([getPos _u, _side] call MCCMK_fnc_sarSource) params ["_ship", "_dist"];
private _fromShip = !isNull _ship;
if (!_fromShip && {(missionNamespace getVariable ["MCCMK_sarNoShip", 1]) == 0}) exitWith {["No ship can reach you."] call _say};
private _cdObj = [missionNamespace, _ship] select _fromShip;
private _cdKey = if (_fromShip) then {"MCCMK_sarCD"} else {format ["MCCMK_sarCD_%1", _side]};
if (!_noCD && {(_cdObj getVariable [_cdKey, 0]) > serverTime}) exitWith {
	[format ["The rescue craft is busy - try again in %1.", [((_cdObj getVariable [_cdKey, 0]) - serverTime) / 3600, "HH:MM:SS"] call BIS_fnc_timeToString]] call _say;
};
private _t = if (_fromShip) then {_ship getVariable ["MCC_ShipType", 0]} else {0};
private _useHeli = if (_fromShip) then {_dist > 1000 && {_t != 2}} else {true};
private _faction = faction _u;
// how many to take: the caller's squad still to be picked up (in the water, or aboard the crippled boat / aircraft -
// wherever they've drifted), and anyone else aboard that boat or aircraft
private _need = count ((((units group _u) select {alive _x && {(vehicle _x == _x && {surfaceIsWater (getPos _x)} && {((getPosASL _x) select 2) < 1.5}) || {(vehicle _x) isEqualTo _tgt}}}) + (if (_tgt != _u) then {(crew _tgt) select {alive _x}} else {[]})) arrayIntersect ((units group _u) + (if (_tgt != _u) then {crew _tgt} else {[]}))) max 1;
private _seatsOf = {params ["_c"]; [_c] call MCCMK_seatsOf};	// every passenger seat, firing-from-vehicle seats too
private _cls = if (_useHeli) then {
	private _h = [_faction, "transportheli"] call MCCMK_fnc_factionAssets;
	if (count _h > 0) then {
		// the fewest seats that fit everyone, else the largest (a light helicopter filled up and men fell off the rope)
		private _fit = (_h apply {[[_x] call _seatsOf, _x]}) select {(_x select 0) >= _need};
		if (_fit isNotEqualTo []) then {_fit sort true; (_fit select 0) select 1} else {
			private _all = _h apply {[[_x] call _seatsOf, _x]};
			_all sort false;
			(_all select 0) select 1
		}
	} else {if !(missionNamespace getVariable ["MCCMK_vanillaFallback", true]) then {""} else {["O_Heli_Light_02_unarmed_F", "B_Heli_Transport_01_F", "I_Heli_Transport_02_F"] select ([east, west, independent] find _side max 0)}}
} else {
	private _b = [_faction, "smallboat"] call MCCMK_fnc_factionAssets;
	if (count _b > 0) then {selectRandom _b} else {if !(missionNamespace getVariable ["MCCMK_vanillaFallback", true]) then {""} else {["O_Boat_Transport_01_F", "B_Boat_Transport_01_F", "I_Boat_Transport_01_F"] select ([east, west, independent] find _side max 0)}}
};
if (_cls == "") exitWith {["No rescue craft available."] call _say};
private _veh = objNull;
private _route = [];
if (_fromShip) then {
	if (_useHeli) then {
		private _p = _ship modelToWorld [0, 0, 60];
		_veh = createVehicle [_cls, _p, [], 0, "FLY"];
		_veh setPosASL [_p select 0, _p select 1, 60];
	} else {
		private _half = (([_t] call MCCMK_fnc_shipCfg) select 3);
		private _p = _ship modelToWorld [((_half select 0) + 15) * ([1, -1] select (((_ship worldToModel (getPos _u)) select 0) < 0)), 0, 0];
		_veh = createVehicle [_cls, [_p select 0, _p select 1, 0], [], 0, "NONE"];
		_veh setPosASLW [_p select 0, _p select 1, 0];
		_veh setDir ((getPos _veh) getDir _u);
	};
} else {
	private _p = [getPos _u, 4500, false] call MCCMK_fnc_sarSpawnPos;
	if (_p isEqualTo []) then {_p = (getPos _u) getPos [4500, random 360]};
	_veh = createVehicle [_cls, [_p select 0, _p select 1, 80], [], 0, "FLY"];
	_veh setPosASL [_p select 0, _p select 1, (((getTerrainHeightASL _p) max 0) + 80)];
	_route = [_p, getPos _u] call MCCMK_fnc_safeRoute;
	_dist = _p distance2D _u;
};
_cdObj setVariable [_cdKey, serverTime + 180, true];
private _crew = createVehicleCrew _veh;
[_veh, _faction] call MCCMK_fnc_factionCrew;
{[_x, "NoVoice"] remoteExec ["setSpeaker", 0, _x]} forEach (crew _veh);
// (MK) the PILOT commands the helicopter from the start, and stays its commander. Otherwise its move orders are held by
// another member of the crew, and when a rider boards, command changes hands and the new commander has no order.
if (_useHeli && {!isNull (driver _veh)}) then {
	_veh setEffectiveCommander (driver _veh);
	["INFO", "sar", "helicopter crew: %1 | commander now %2", [(fullCrew [_veh, "", false]) apply {format ["%1 (%2)", name (_x select 0), _x select 1]}, name (effectiveCommander _veh)]] call MCC_fnc_log;
};
_crew setBehaviour "CARELESS";
_crew setCombatMode "BLUE";

[_veh, _side, ["Rescue boat", "Rescue helicopter"] select (_veh isKindOf "Air")] call MCCMK_fnc_supportAir;	//(MK) the "Support aircraft" options; destroyed: its side told
private _flagged = [_u] + (if (_tgt != _u) then {(crew _tgt) select {alive _x}} else {[]});
{_x setVariable ["MCCMK_sarActive", true, true]; _x setVariable ["MCCMK_sarVeh", _veh, true]} forEach _flagged;
private _what = ["boat", "helicopter"] select _useHeli;
private _spd = [12, 45] select _useHeli;
private _name = if (_fromShip) then {_ship getVariable ["MCC_LHDDisplayName", "Ship"]} else {"out of sight"};
[format ["Rescue %1 on its way%2.", _what, if (_fromShip) then {format [" from %1", _name]} else {""}]] call _say;
["INFO", "sar", "%1 requested rescue: %2 %3 from %4 (%5 m), pickup %6", [name _u, _what, _cls, _name, round _dist, ["rope", "instant"] select ((missionNamespace getVariable ["MCCMK_sarPickup", 0]) == 1 || {!_useHeli})]] call MCC_fnc_log;
private _id = format ["MCCMK_sar_%1", floor random 1e6];
private _end = serverTime + (((2 * _dist / _spd) + 60) max 480);
private _picked = [];
if (_useHeli) then {
	_veh flyInHeight 40;
	{if (_veh getVariable ["MCCMK_sarCancel", false]) exitWith {}; _veh doMove _x; waitUntil {sleep 2; !alive _veh || {(_veh distance2D _x) < 300} || {serverTime > _end} || {_veh getVariable ["MCCMK_sarCancel", false]}}} forEach _route;
};
private _rope = _useHeli && {(missionNamespace getVariable ["MCCMK_sarPickup", 0]) == 0};
while {serverTime < _end && {alive _veh} && {!isNull driver _veh} && {_picked isEqualTo []} && {!(_veh getVariable ["MCCMK_sarCancel", false])}} do {
	private _tp = getPos _tgt;
	_veh doMove _tp;
	if (_rope) then {
		if ((_veh distance2D _tgt) < 150) then {
			{_x setVariable ["MCCMK_sarNoCancel", true, true]} forEach _flagged;
			_picked = [_veh, _u, _tgt, _side] call MCCMK_fnc_sarRope;
			if (_picked isEqualTo []) then {_end = 0};	// (nobody came to the ropes)
		};
	} else {
		if (_useHeli && {(_veh distance2D _tgt) < 120}) then {_veh flyInHeight 4};
		if ((_veh distance2D _tgt) < ([15, 25] select _useHeli) && {!_useHeli || {((getPosATL _veh) select 2) < 10}}) then {
			private _who = (allUnits select {
				alive _x && {(side group _x) isEqualTo _side} && {vehicle _x == _x} && {surfaceIsWater (getPos _x)}
				&& {((getPosASL _x) select 2) < 1.5} && {(_x distance2D _u) < 50}
			}) + (if (_tgt != _u) then {(crew _tgt) select {alive _x}} else {[]});
			_who = _who arrayIntersect _who;
			{_x setVariable ["MCCMK_sarNoCancel", true, true]} forEach _flagged;
			{[_x, _veh, "in"] remoteExec ["MCCMK_fnc_sarSeat", _x]} forEach _who;
			sleep 2;
			_picked = _who select {(vehicle _x) isEqualTo _veh};
			if (_picked isEqualTo []) then {_picked = _who};
		};
	};
	sleep 3;
};
private _done = _picked isNotEqualTo [];
// (MK) anyone still on a rope rides below it home (Advanced Pickup Rope: over 150 km/h they'd lose their grip)
private _ridersFn = {allUnits select {alive _x && {_x getVariable ["ARMK_Is_Rappelling", false]} && {(_x getVariable ["MCCMK_ropeHeli", objNull]) isEqualTo _veh}}};
if (_done && {(call _ridersFn) isNotEqualTo []}) then {_veh limitSpeed 120};
// the helicopter full with people still waiting: another one for the rest, straight away
if (_done && {_useHeli}) then {
	private _left = (allUnits select {
		alive _x && {(side group _x) isEqualTo _side} && {vehicle _x == _x} && {surfaceIsWater (getPos _x)} && {((getPosASL _x) select 2) < 1.5} && {(_x distance2D _tgt) < 60}
	}) + (if (_tgt != _u && {alive _tgt}) then {(crew _tgt) select {alive _x}} else {[]});
	_left = _left - _picked;
	// (MK) only when this one is FULL - people who stayed behind by choice aren't sent another
	if (_left isNotEqualTo [] && {([_veh] call MCCMK_seatsFree) < 1}) then {
		["The helicopter is full - another one is coming for the rest."] call _say;
		[_left select 0, "crew", objNull, true] spawn MCCMK_fnc_sarRun;
	};
};
if (_done) then {
	sleep 2;
	if (_fromShip && {!_useHeli}) then {
		// the ship's boat: back alongside, everyone placed on deck 
		["Picked up - heading back to the ship."] call _say;
		private _back = serverTime + 300;
		while {serverTime < _back && {alive _veh} && {(_veh distance2D _ship) > 60}} do {
			_veh doMove (getPos _ship);
			sleep 3;
		};
		private _aboard = (crew _veh) select {_x in _picked};
		if (_aboard isNotEqualTo []) then {[_aboard, _ship] call MCCMK_fnc_shipBoardUnits};
		[format ["Back aboard %1.", _name]] call _say;
	};
	if (_fromShip && {_useHeli}) then {
		// (MK) THE SHIP'S HELICOPTER, the same routine as at a base: it LANDS on a free helipad of the ship, everyone gets out,
		// and it flies off the map. A pad with something parked on it is not used. No free pad (or it will not land): a hover
		// half a metre over a clear part of the deck, and everyone out there. Neither possible: everyone placed on deck.
		// Orders go to the PILOT himself, and where he is going is kept on the helicopter (MCCMK_sarGoing) so the rope
		// boarding code repeats it as a rider sits down - as on the way to a base.
		_veh flyInHeight 40;
		["Picked up - heading back to the ship."] call _say;
		private _foot = -(((boundingBoxReal _veh) select 0) select 2);	// from its centre down to its wheels or skids
		private _clear = {
			params ["_agl"];
			(((nearestObjects [_agl, ["Air", "LandVehicle", "Ship"], 11]) - [_veh]) select {!(_x isKindOf "StaticWeapon")}) isEqualTo []
		};
		private _pads = (nearestObjects [_ship, ["HeliH"], 350]) select {((getPosASL _x) select 2) > 3};
		private _free = _pads select {[ASLToAGL (getPosASL _x)] call _clear};
		private _pad = objNull;
		if (_free isNotEqualTo []) then {
			_free = [_free, [], {_x distance2D _veh}, "ASCEND"] call BIS_fnc_sortBy;
			_pad = _free select 0;
		};
		private _dest = if (isNull _pad) then {getPos _ship} else {getPos _pad};
		["INFO", "sarShip", "flight to %1: %2 helipad(s) on the ship, %3 free - %4, %5 m away", [_name, count _pads, count _free, ["no free pad: a hover over the deck", "landing on the nearest free pad"] select (!isNull _pad), round (_veh distance2D _dest)]] call MCC_fnc_log;
		_veh setVariable ["MCCMK_sarGoing", _dest, true];
		(driver _veh) doMove _dest;
		private _back = serverTime + 300;
		private _moved = false;
		private _again = false;
		waitUntil {
			sleep 2;
			if ((speed _veh) > 30) then {_moved = true};
			// once, if it comes to a stop well short (as on the way to a base)
			if (!_again && {_moved} && {(speed _veh) < 3} && {(_veh distance2D _dest) > 200}) then {
				_again = true;
				["INFO", "sarShip", "the helicopter has STOPPED %1 m short of the ship (order '%2', finished %3) - move order given again, once", [round (_veh distance2D _dest), currentCommand (driver _veh), unitReady (driver _veh)]] call MCC_fnc_log;
				(driver _veh) doMove _dest;
			};
			!alive _veh || {(_veh distance2D _dest) < 150} || {serverTime > _back}
		};
		_veh setVariable ["MCCMK_sarGoing", nil, true];
		// anyone still on a rope: let go and placed on deck (they cannot be set down by a landing), ropes in
		private _rd = call _ridersFn;
		{_x setVariable ["ARMK_Detach_Rope", true, true]} forEach _rd;
		if (_rd isNotEqualTo []) then {sleep 2};
		{ropeDestroy _x} forEach ((_veh getVariable ["MCCMK_sarKeepRopes", []]) select {!isNull _x});
		_veh setVariable ["MCCMK_sarKeepRopes", nil];
		_veh limitSpeed 1000;
		if ((_rd select {alive _x}) isNotEqualTo []) then {[_rd select {alive _x}, _ship] call MCCMK_fnc_shipBoardUnits};
		private _aboardFn = {(crew _veh) select {alive _x && {_x in _picked}}};
		private _down = false;
		// 1. a landing on the free pad: carried exactly over it first (the pilot lands on the NEAREST pad, so it must be this one)
		if (alive _veh && {!isNull _pad} && {[ASLToAGL (getPosASL _pad)] call _clear}) then {
			private _pp = getPosASL _pad;
			private _held = [_veh, [_pp select 0, _pp select 1, 0], 8, {alive _veh}] call MCCMK_fnc_heliHoverAt;
			[_veh] remoteExec ["MCCMK_fnc_heliHold", _veh];
			sleep 0.5;
			["INFO", "sarShip", "landing ordered on the pad: over it %1, %2 m from it, %3 m above it, %4 of the rescued aboard", [["NOT held", "held"] select _held, round (_veh distance2D _pad), round (((getPosASL _veh) select 2) - (_pp select 2)), count (call _aboardFn)]] call MCC_fnc_log;
			[_veh, 180] spawn MCCMK_fnc_heliDoorWatch;	//(MK) doors and ramp open as it touches down, shut as it takes off
		_veh land "LAND";
			private _t0 = serverTime;
			private _tl = serverTime + 90;
			private _onDeck = {isTouchingGround _veh || {((((getPosASL _veh) select 2) - (_pp select 2)) < (_foot + 0.4)) && {(vectorMagnitude (velocity _veh)) < 1}}};
			waitUntil {sleep 1; !alive _veh || {call _onDeck} || {serverTime > _tl}};
			_down = alive _veh && {call _onDeck};
			["INFO", "sarShip", "%1 after %2 s, %3 m from the pad, %4 m above it, engine %5", [["NOT down - the wait ran out", "touched down on the pad"] select _down, round (serverTime - _t0), round (_veh distance2D _pad), (((getPosASL _veh) select 2) - (_pp select 2)) toFixed 1, isEngineOn _veh]] call MCC_fnc_log;
			if (_down) then {
				[format ["Landed aboard %1.", _name]] call _say;
				{
					if (!isPlayer (leader group _x) || {((leader group _x) distance _veh) > 100}) then {unassignVehicle _x; [_x] orderGetIn false; doGetOut _x};
				} forEach (call _aboardFn);
				// exactly as at a base: it waits, landed, until everyone is out - no time limit (a player's squad get out when he
				// orders them; players by themselves)
				waitUntil {sleep 2; !alive _veh || {(call _aboardFn) isEqualTo []}};
			} else {
				_veh land "NONE";
				_veh engineOn true;
			};
		};
		// 2. no landing: a hover half a metre over a clear part of the deck
		if (alive _veh && {!_down}) then {
			private _cands = [];
			{
				private _q = getPosASL _x;
				_cands pushBack _q;
				private _pd = _x;
				{_cands pushBack (AGLToASL (_pd modelToWorld _x))} forEach [[16, 0, 0], [-16, 0, 0], [0, 16, 0], [0, -16, 0]];
			} forEach (_free + (_pads - _free));
			_cands pushBack (AGLToASL (_ship modelToWorld ([[0, 45, 10], [0, 0, 24], [15, 0, 1], [0, 45, 10]] param [_t, [0, 45, 10]])));
			private _spot = [];
			{
				if (_spot isEqualTo []) then {
					private _hits = lineIntersectsSurfaces [[_x select 0, _x select 1, 150], [_x select 0, _x select 1, 2], _veh, objNull, true, 1, "GEOM", "NONE"];
					if (_hits isNotEqualTo []) then {
						(_hits select 0) params ["_hp", "", "_ho"];
						if ((_hp select 2) > 3 && {isNull _ho || {!(_ho isKindOf "AllVehicles")}} && {[ASLToAGL _hp] call _clear}) then {_spot = _hp};
					};
				};
			} forEach _cands;
			if (_spot isNotEqualTo []) then {
				["INFO", "sarShip", "hover over the deck: a clear spot %1 m above the sea, %2 m from the helicopter", [(_spot select 2) toFixed 1, round (_veh distance2D _spot)]] call MCC_fnc_log;
				private _held = [_veh, [_spot select 0, _spot select 1, 0], 3, {alive _veh}] call MCCMK_fnc_heliHoverAt;
				// down to half a metre: the hold lowered, and the pilot's own flying height set to match (he flies it against the hold otherwise)
				_veh flyInHeight ((_spot select 2) + _foot + 0.5);
				[_veh, _spot, _foot + 0.5] remoteExec ["MCCMK_fnc_heliHold", _veh];
				private _tl = serverTime + 25;
				waitUntil {sleep 1; !alive _veh || {(((getPosASL _veh) select 2) - (_spot select 2)) < (_foot + 1.2)} || {serverTime > _tl}};
				private _gap = (((getPosASL _veh) select 2) - (_spot select 2)) - _foot;
				["INFO", "sarShip", "hover: over the spot %1, wheels %2 m above the deck, %3 m off the spot", [["NOT held", "held"] select _held, _gap toFixed 1, (_veh distance2D _spot) toFixed 1]] call MCC_fnc_log;
				if (alive _veh && {_gap < 1.5}) then {
					[format ["Hovering over the deck of %1 - get out.", _name]] call _say;
					{
						if (!isPlayer _x && {!isPlayer (leader group _x) || {((leader group _x) distance _veh) > 100}}) then {unassignVehicle _x; [_x] orderGetIn false; [_x] remoteExec ["moveOut", _x]};
					} forEach (call _aboardFn);
					private _to = serverTime + 25;
					waitUntil {sleep 1; !alive _veh || {(call _aboardFn) isEqualTo []} || {serverTime > _to}};
				};
			} else {
				["INFO", "sarShip", "no clear spot on the deck for a hover (%1 tried)", [count _cands]] call MCC_fnc_log;
			};
		};
		// 3. whoever is still aboard: placed on deck
		private _left = call _aboardFn;
		if (_left isNotEqualTo []) then {
			["INFO", "sarShip", "%1 still aboard - placed on deck", [count _left]] call MCC_fnc_log;
			[_left, _ship] call MCCMK_fnc_shipBoardUnits;
		};
		[format ["Back aboard %1.", _name]] call _say;
		// and off the edge of the map, as from a base
		if (alive _veh) then {
			sleep 5;
			_veh land "NONE";
			_veh engineOn true;
			_veh flyInHeight 80;
			[_veh] call MCCMK_fnc_heliLeave;
		};
	};
	if (!_fromShip) then {
		// home: landed at the nearest HQ or F.O.B. (or dry land), everyone out, then off the edge of the map
		_veh flyInHeight 40;
		private _lz = [_side, getPos _veh, false] call MCCMK_fnc_sarHome;
		["Picked up - heading for the nearest base."] call _say;
		private _pad = createVehicle ["Land_HelipadEmpty_F", _lz, [], 0, "CAN_COLLIDE"];
		private _hr = [getPos _veh, _lz] call MCCMK_fnc_safeRoute;
		// (MK) where home is, and a one-off line if the pilot comes to a stop on the way (it has been stopping over the sea):
		// where, how far from the next point and from home, and the pilot's order - read inside the waits that are there anyway
		_veh setVariable ["MCCMK_sarLZ", _lz];
		_veh setVariable ["MCCMK_sarMoved", false];
		_veh setVariable ["MCCMK_sarStopLogged", false];
		["INFO", "sarHome", "flight home: landing spot %1, %2 m away, %3 route point(s)", [mapGridPosition _lz, round (_veh distance2D _lz), count _hr]] call MCC_fnc_log;
		private _stopWatch = {
			params ["_what", "_pos"];
			if ((speed _veh) > 30) then {_veh setVariable ["MCCMK_sarMoved", true]};
			if ((speed _veh) < 3 && {_veh getVariable ["MCCMK_sarMoved", false]} && {!(_veh getVariable ["MCCMK_sarStopLogged", false])} && {(_veh distance2D _pos) > 150}) then {
				_veh setVariable ["MCCMK_sarStopLogged", true];
				["INFO", "sarHome", "the helicopter has STOPPED %1 m short of %2 (%3 km/h, %4 m from the landing spot, over %5, order '%6')", [round (_veh distance2D _pos), _what, round (speed _veh), round (_veh distance2D _lz), ["land", "water"] select (surfaceIsWater (getPos _veh)), currentCommand (driver _veh)]] call MCC_fnc_log;
				// (MK) what the pilot is planning when it stops - his order finished or not, and where he means to go (it stops 4-6 s after
				// the last man boards from a rope, mid-flight, and nothing in the rescue code gives it an order then)
				["INFO", "sarHome", "the pilot when it stopped: order finished %1, planning to go to %2", [if (isNull (driver _veh)) then {"?"} else {unitReady (driver _veh)}, if (isNull (driver _veh)) then {"?"} else {str (expectedDestination (driver _veh))}]] call MCC_fnc_log;
				// (MK) and ONCE, the move order given again - not a loop: only here, the first time it stops short on the way home
				(driver _veh) doMove _pos;
				["INFO", "sarHome", "move order to %1 given again, once", [_what]] call MCC_fnc_log;
			};
		};
		private _back = serverTime + (((2 * (_veh distance2D _lz) / 45) + 120) max 300);
		// (MK) each leg ordered to the PILOT himself, and where he is going kept on the helicopter: the rope boarding code gives
		// him that same order again at the moment a rider takes a seat (fn_ropeLib) - at the cause, not on a timer
		{_veh setVariable ["MCCMK_sarGoing", _x, true]; (driver _veh) doMove _x; waitUntil {sleep 2; ["a route point", _x] call _stopWatch; !alive _veh || {(_veh distance2D _x) < 300} || {serverTime > _back}}} forEach _hr;
		_veh setVariable ["MCCMK_sarGoing", _lz, true];
		(driver _veh) doMove _lz;
		waitUntil {sleep 2; ["the landing spot", _lz] call _stopWatch; !alive _veh || {(_veh distance2D _lz) < 150} || {serverTime > _back}};
		_veh setVariable ["MCCMK_sarGoing", nil, true];
		// landed and waiting, engine running: nobody is put out - a player-led squad's AI get out when ordered (F keys,
		// disembark), players by themselves; AI-led squads are ordered out by their own leader. Then it leaves.
		// (MK) anyone on a rope: down low over the spot first and let go there, on the ground (the rope's end touches
		// down - Advanced Pickup Rope sets him on the ground), then it lands
		private _rd = call _ridersFn;
		if (_rd isNotEqualTo []) then {
			_veh flyInHeight 8;
			private _tr = serverTime + 40;
			waitUntil {sleep 1; !alive _veh || {((getPosATL _veh) select 2) < 12} || {serverTime > _tr}};
			{_x setVariable ["ARMK_Detach_Rope", true, true]} forEach _rd;
			sleep 3;
			_veh limitSpeed 1000;
		};
		{ropeDestroy _x} forEach ((_veh getVariable ["MCCMK_sarKeepRopes", []]) select {!isNull _x});
		_veh setVariable ["MCCMK_sarKeepRopes", nil];
		// (MK) a FULL landing: down, gear down, and it stays down (the pilot shuts the engine off while he waits). "GET
		// OUT" is the game's drop-off landing: it lifts again as soon as some are out.
		["INFO", "sarHome", "landing ordered: %1 m from the spot, %2 m up, %3 km/h, %4 of the rescued aboard", [round (_veh distance2D _lz), round ((getPosATL _veh) select 2), round (speed _veh), {_x in _picked} count (crew _veh)]] call MCC_fnc_log;
		[_veh, 180] spawn MCCMK_fnc_heliDoorWatch;	//(MK) doors and ramp open as it touches down, shut as it takes off
		_veh land "LAND";
		private _tl0 = serverTime;
		private _tl = serverTime + 120;
		waitUntil {sleep 1; !alive _veh || {isTouchingGround _veh} || {serverTime > _tl}};
		["INFO", "sarHome", "%1 after %2 s, %3 m from the spot, engine %4", [["NOT down - the wait ran out", "touched down"] select (isTouchingGround _veh), round (serverTime - _tl0), round (_veh distance2D _lz), isEngineOn _veh]] call MCC_fnc_log;
		//(MK) "back at base" only to the players who were aboard; the caller, if he wasn't, told how many of his squad it brought
		{["Landed - you're back at base."] remoteExec ["MCCMK_fnc_hint", _x]} forEach ((crew _veh) select {isPlayer _x});
		if !(_u in (crew _veh)) then {
			private _mine = {(group _x) isEqualTo (group _u)} count (crew _veh);
			[format ["The rescue helicopter has landed at base with %1 of your squad.", _mine]] call _say;
		};
		{
			// (MK) and those whose leader isn't here to order them out
			if (!isPlayer (leader group _x) || {((leader group _x) distance _veh) > 100}) then {unassignVehicle _x; [_x] orderGetIn false; doGetOut _x};
		} forEach ((crew _veh) select {_x in _picked});
		waitUntil {sleep 2; !alive _veh || {((crew _veh) findIf {alive _x && {_x in _picked}}) < 0}};
		deleteVehicle _pad;
		["INFO", "sar", "rescue for %1: everyone out at base - leaving in 5 s", [name _u]] call MCC_fnc_log;
		sleep 5;
		// off the edge of the map, then gone
		_veh land "NONE";
		_veh engineOn true;
		_veh flyInHeight 80;
		[_veh] call MCCMK_fnc_heliLeave;	// (the nearest edge, round the mission areas)
	};
} else {
	[["The rescue was called off.", "Rescue cancelled."] select (_veh getVariable ["MCCMK_sarCancel", false])] call _say;
	// off the edge of the map first
	if (alive _veh && {_useHeli}) then {
		_veh flyInHeight 80;
		[_veh] call MCCMK_fnc_heliLeave;
	};
	if (alive _veh && {!_useHeli} && {!isNull driver _veh}) then {
		_veh doMove (if (_fromShip) then {getPos _ship} else {_veh getPos [3000, _u getDir _veh]});
		private _tb = serverTime + 240;
		waitUntil {sleep 2; !alive _veh || {serverTime > _tb} || {(allPlayers findIf {(_x distance2D _veh) < 800}) < 0} || {_fromShip && {(_veh distance2D _ship) < 150}}};
	};
};
{_x setVariable ["MCCMK_sarActive", false, true]; _x setVariable ["MCCMK_sarVeh", nil, true]; _x setVariable ["MCCMK_sarNoCancel", nil, true]} forEach (_flagged + _picked);
sleep 5;
{deleteVehicle _x} forEach ((units _crew) + [_veh]);
deleteGroup _crew;
["INFO", "sar", "rescue for %1 ended (%2)", [name _u, ["called off", "completed"] select _done]] call MCC_fnc_log;
