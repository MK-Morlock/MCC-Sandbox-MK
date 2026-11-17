/*
	MCCMK_fnc_boatPatrol - server: enemy boat patrols along the coast, for the Mission Generator and the campaign.
	Its coastline map, coastal sweep, gentle turns, U-turn arcs,
	arrival radii, safety margins, per-leg speeds, watchdog and re-routing:
	  - the boats are MCC's own picks (_fleetIn): a class to spawn (crewed by its own faction crew), or a boat that
	    already exists (it joins its new route at the nearest point it can reach);
	  - a boat 13.5 m or more across (config mapSize) uses the large (combat boat) margins, smaller ones the small-boat
	    margins; anything over 3 x a combat boat's size is left out of the coastal shallows;
	  - log lines only with MCC's debug logging on.
	[AO position, enemy side, [class or boat, ...], done key - set true in missionNamespace once the boats are out]
*/
if (!isServer) exitWith {};

params [["_aoPos", [], [[]]], ["_enemySide", east, [east]], ["_fleetIn", [], [[]]], ["_doneKey", "", [""]], ["_crewFaction", "", [""]]];
private _aoCandidates = [[_aoPos, true]];

// ---------------------------------------------------------------------
// Adjustable parameters - everything meant to be tweaked lives here.
// ---------------------------------------------------------------------
private _spawnChance = 1.0;                         // 0.0-1.0 chance that boats spawn when the AO qualifies (1.0 = always)
private _twoSmallChance = 0.5;                      // Fleet = 1 combat boat + small boats: chance of TWO small boats (otherwise one)
private _smallBoatClass = "O_Boat_Armed_01_hmg_F";  // Small boat hull (requested class, before MK Pool substitution)
private _largeBoatClass = "EF_O_CombatBoat_HMG_OPF";// Combat boat hull (Expeditionary Forces CDLC)
private _vanillaFallbackClass = "O_Boat_Armed_01_hmg_F"; // Used when a requested class isn't loaded (e.g. no EF CDLC) and the pool has nothing suitable
private _largeBoatFallbackProfile = [18, 2];        // [mapSize, armedTurrets] used to judge "similar" for the combat boat ONLY when its class isn't loaded - adjust if pool picks look wrong
private _maxSizeRatio = 3;                          // Pool boats more than this many times the reference boat's size are rejected (keeps big ships out of the shallows)

// Sea detection / coastline map
private _oceanSearchRadius = 2000;                  // AO must have sea within this distance (metres)
private _oceanMinDepth = 3;                         // Water this deep or more counts as "sea" for the detection check (metres)
private _minOceanArea = 200000;                     // At least this much sea (m2, 200000 = 0.2 km2) within _oceanSearchRadius - ignores tiny inland water
private _detectHalfSize = 2500;                     // Sea-detection map covers this far each way from the objective (metres) - keep ~500 beyond _oceanSearchRadius
private _gridHalfSize = 3500;                       // Patrol coastline map covers this far each way from the coast anchor (metres) - keep ~500 beyond _alongCoastHalf
private _gridStep = 50;                             // Coastline map resolution (metres)

// Patrol area
private _alongCoastHalf = 3000;                     // Patrol extends up to this far along the coast each way from the coast anchor - the point on the beach nearest the objective (3000 = 6 km of coast in total)
private _maxAnchorDist = 3300;                      // No waypoint further than this from the coast anchor (a little over _alongCoastHalf, so the ends of the stretch can sit offshore) (metres)
private _maxShoreDist = 1000;                       // No waypoint further than this from the beach (metres)
private _bandClose = [60, 250];                     // "Very close to the beach" band - distance from the beach [min, max] (metres)
private _bandMid = [250, 600];                      // Mid band (metres)
private _bandOuter = [600, 1000];                   // Outer band - the furthest from the beach a waypoint can be (metres)
private _bandWeights = [0.50, 0.35, 0.15];          // COMBAT BOAT: chance of each band [close, mid, outer] when picking a station's waypoint
private _returnStationStep = 2;                     // COMBAT BOAT: return sweep uses every Nth station: longer legs (about 1.3 km) for FULL-speed runs back along the coast
private _returnBandWeights = [0.20, 0.45, 0.35];    // COMBAT BOAT: return sweep band weights [close, mid, outer] - further out, in open water, so the long legs qualify for FULL speed
private _minCloseShare = 0.4;                       // COMBAT BOAT: while less than this share of a route's waypoints so far are close in, the close band is favoured 2.5x more
private _smallBandWeights = [0.75, 0.20, 0.05];     // SMALL BOATS: outbound band weights - they draw less water, so they work closer to the beach
private _smallReturnBandWeights = [0.60, 0.30, 0.10]; // SMALL BOATS: return sweep band weights (they come back close in too; the combat boat does the fast offshore runs)
private _smallReturnStationStep = 1;                // SMALL BOATS: return sweep uses every station (more, closer waypoints) - see _returnStationStep
private _smallMinCloseShare = 0.6;                  // SMALL BOATS: close-in share target (see _minCloseShare)
private _smallMaxTurnAngle = 60;                    // SMALL BOATS: preferred max heading change at a waypoint (they're nimbler, so they can weave in closer)
private _inletProbe = 700;                          // Water counts as inside an inlet/bay if there's land within this distance both ways along the coast (metres)
private _inletMinCells = 4;                         // An inlet needs at least this many usable 50 m cells (about 10,000 m2) to be worth patrolling
private _maxInlets = 3;                             // Most inlet trips added to one route (the biggest inlets are chosen)
private _stationSpacing = 650;                      // Rough spacing between waypoint stations along the coast (metres)
private _minStations = 4;                           // Stations along the coast (the loop has 2 x stations - 2 waypoints, e.g. 4 -> 6, 7 -> 12)
private _maxStations = 10;
private _minCoastRange = 800;                       // Less usable coast than this -> fall back to a random loop instead of a sweep (metres)

// Depth / beach-avoidance safety margins - small boat values (the combat boat adds _largeBoatDepthBonus to the depths)
private _wpMinDepth = 2.5;                          // Minimum water depth at a waypoint / spawn point (metres)
private _shoreClearance = 35;                       // Every waypoint must have water all around it at this distance...
private _shoreClearanceDepth = 1.2;                 // ...at least this deep (metres)
private _segmentStep = 20;                          // Legs between waypoints are sampled every this many metres...
private _segmentMinDepth = 2.0;                     // ...along the centre line at this depth or more...
private _segmentLateral = 20;                       // ...and this far either side of the line...
private _segmentLateralDepth = 1.2;                 // ...at this depth or more
private _obstacleClearance = 20;                    // Keep at least this far from piers, jetties, breakwaters, rocks and other solid objects in the water (metres; +10 for the combat boat)
private _obstacleMinSize = 3;                       // Ignore objects smaller than this across (buoys, clutter) (metres)
private _largeBoatDepthBonus = 1.0;                 // Extra depth margin for the combat boat (metres) - the depths above are the small boats' values

// Fallback random loop (short / broken coastlines only)
private _waypointCount = 5;                         // Waypoints per boat (before any back-tracking is added)
private _minLegLength = 300;                        // Leg length limits between consecutive waypoints (metres)
private _maxLegLength = 900;
private _minWpSpacing = 250;                        // Consecutive waypoints are at least this far apart (metres) - also used by the coastal sweep. Long legs = steadier steering

// Smooth driving (so boats keep their speed)
private _maxTurnAngle = 45;                         // When choosing the next waypoint, prefer ones needing a heading change of this many degrees or less
private _uTurnAngle = 135;                          // Corners sharper than this (e.g. the end of each sweep) become a wide U-turn arc instead
private _uTurnWidths = [400, 300, 220];             // U-turn arc widths to try, widest first (metres)
// Per-leg speed (the speed a boat uses while heading to each waypoint)
private _narrowProbe = 120;                         // LIMITED: land within this distance on BOTH sides somewhere along the leg (a small inlet / narrow channel) (metres)
private _fullSpeedLegLength = 800;                  // FULL: leg at least this long...
private _fullSpeedClearance = 200;                  // ...with no land within this distance either side along its whole length...
private _fullSpeedMaxTurn = 60;                     // ...and a heading change of no more than this at the end of it. Anything else is NORMAL.
private _completionRadii = [150, 110, 75, 45];      // Per-waypoint arrival radius: the widest of these that's safe is used, so the boat starts
                                                    // its turn onto the next leg early and curves round the corner instead of steering hard
                                                    // to hit the exact point (widest first; the last one is the minimum) (metres)

private _boatSeparation = 150;                      // Boats spawn at least this far apart (metres)
private _playerAvoidDist = 400;                     // Avoid spawning a boat within this distance of any player (best effort) (metres)
private _hqExclusionDist = 0;                          // No spawn points, waypoints or legs within this distance of the HQ marker (metres)
// Passing HQ: where HQ sits on the patrol stretch, the usual "within _maxShoreDist of the beach" limit would leave no
// usable water abeam of it and the sweep would stop short. There, waypoints may be pushed further offshore instead,
// so the patrol can go round HQ (still never inside _hqExclusionDist) and carry on along its full stretch of coast.
private _hqPassBand = 600;                          // The further-offshore water is only usable within this distance beyond _hqExclusionDist of HQ (metres)
private _hqPassMaxShoreDist = 2600;                 // ...and up to this far from the beach (metres)
private _hqPassMargin = 200;                        // ...and at least this much outside _hqExclusionDist, so the legs between such waypoints stay clear of it too (metres)
private _watchdogInterval = 3;                      // Seconds between beach-avoidance watchdog checks (at full speed a boat covers 24 m a second)
private _shallowDepth = 1.2;                        // Watchdog steers the boat back to its route if the water under it is shallower than this (metres; + half the depth bonus for the combat boat)
private _steerCooldown = 30;                        // After steering a boat out of the shallows, wait this long before steering it again (seconds)
private _stuckWindow = 120;
private _stuckDist = 50;
private _cyclesBeforeReroute = 2;                  // After this many full laps of its route, a boat is given a freshly generated route
private _rerouteCheckInterval = 15;                 // Seconds between lap-count checks
private _debugMarkers = false;                      // true = draw each boat's patrol waypoints on the map (for testing)
// ---------------------------------------------------------------------

// Always clean up the previous mission's boats first - even if this
// mission then ends up with no boats at all.
MCCMK_boatPatrol_obstacles = [];   // filled once the coast anchor is known (see below)
private _gen = missionNamespace getVariable ["MCCMK_EnemyBoatPatrol_Gen", 0];

if (count _aoCandidates == 0) exitWith {
};

// Depth margins. The values above are the small boats'; the combat boat
// adds _largeBoatDepthBonus. The coastline is scanned with the small-boat
// values (the shallower set); the combat boat's usable spots are then
// filtered from that with its own values (see _fnBuildProfile).
private _smallDepthVals = [_wpMinDepth, _shoreClearance, _shoreClearanceDepth, _segmentMinDepth, _segmentLateral, _segmentLateralDepth, _shallowDepth, _obstacleClearance];
private _combatRouting = [+_bandWeights, +_returnBandWeights, _minCloseShare, _maxTurnAngle, _returnStationStep];
private _smallRouting = [+_smallBandWeights, +_smallReturnBandWeights, _smallMinCloseShare, _smallMaxTurnAngle, _smallReturnStationStep];
private _fnSetDepthProfile = {
	params ["_large"];
	_smallDepthVals params ["_d0", "_c0", "_cd0", "_sm0", "_sl0", "_sld0", "_sh0", "_oc0"];
	private _bonus = if (_large) then {_largeBoatDepthBonus} else {0};
	_wpMinDepth = _d0 + _bonus;
	_shoreClearance = _c0 + (if (_large) then {10} else {0});
	_shoreClearanceDepth = _cd0 + _bonus;
	_segmentMinDepth = _sm0 + _bonus;
	_segmentLateral = _sl0 + (if (_large) then {10} else {0});
	_segmentLateralDepth = _sld0 + _bonus;
	_shallowDepth = _sh0 + (_bonus / 2);
	_obstacleClearance = _oc0 + (if (_large) then {10} else {0});
};
private _bands = [_bandClose, _bandMid, _bandOuter];

// ---------------------------------------------------------------------
// Shared helpers (global so the per-boat watchdog, which runs in its own
// spawned thread, can use them too).
// ---------------------------------------------------------------------

// Water depth in metres at a position; -1 on land.
MCCMK_boatPatrol_fnDepth = {
	params ["_p"];
	if (surfaceIsWater _p) then {-(getTerrainHeightASL _p)} else {-1}
};

// True if a straight leg from _a to _b stays in water deep enough along
// its centre line and on both sides, and (optionally) never comes within
// _hqDist of _hqPos.
// Distance from point _p to the segment _a-_b (2D).
MCCMK_boatPatrol_fnPointSegDist = {
	params ["_p", "_a", "_b"];
	private _abx = (_b select 0) - (_a select 0);
	private _aby = (_b select 1) - (_a select 1);
	private _len2 = (_abx * _abx) + (_aby * _aby);
	private _t = 0;
	if (_len2 > 0) then {
		_t = ((((_p select 0) - (_a select 0)) * _abx) + (((_p select 1) - (_a select 1)) * _aby)) / _len2;
		_t = 0 max (_t min 1);
	};
	[(_a select 0) + (_t * _abx), (_a select 1) + (_t * _aby)] distance2D [_p select 0, _p select 1]
};

// True if the straight line _a -> _b (or the point, if _a == _b) comes
// within _clr metres of any solid object in the water (piers, jetties,
// breakwaters, rocks...) in MCCMK_boatPatrol_obstacles. Each obstacle is
// its real outline (the object's bounding box, in its own rotation), so a
// long thin pier is handled properly, and the test is exact (Liang-Barsky
// line vs box), not sampled - a thin pier can't slip between samples.
MCCMK_boatPatrol_fnSegHitsObstacle = {
	params ["_a", "_b", "_clr"];
	private _hit = false;
	{
		if (!_hit) then {
			_x params ["_obj", "_cxm", "_cym", "_hx", "_hy", "_cw", "_rad"];
			// Quick reject: the line doesn't come near this object at all.
			if (!isNull _obj && {([_cw, _a, _b] call MCCMK_boatPatrol_fnPointSegDist) <= (_rad + _clr)}) then {
				private _ma = _obj worldToModel [_a select 0, _a select 1, 0];
				private _mb = _obj worldToModel [_b select 0, _b select 1, 0];
				private _x0 = (_ma select 0) - _cxm;
				private _y0 = (_ma select 1) - _cym;
				private _dx = (_mb select 0) - (_ma select 0);
				private _dy = (_mb select 1) - (_ma select 1);
				private _ex = _hx + _clr;
				private _ey = _hy + _clr;
				private _t0 = 0;
				private _t1 = 1;
				private _inside = true;
				{
					_x params ["_pp", "_qq"];
					if (_inside) then {
						if (_pp == 0) then {
							if (_qq < 0) then {_inside = false;};
						} else {
							private _r = _qq / _pp;
							if (_pp < 0) then {
								if (_r > _t1) then {_inside = false;} else {if (_r > _t0) then {_t0 = _r;};};
							} else {
								if (_r < _t0) then {_inside = false;} else {if (_r < _t1) then {_t1 = _r;};};
							};
						};
					};
				} forEach [[-_dx, _x0 + _ex], [_dx, _ex - _x0], [-_dy, _y0 + _ey], [_dy, _ey - _y0]];
				if (_inside) then {_hit = true;};
			};
		};
	} forEach (missionNamespace getVariable ["MCCMK_boatPatrol_obstacles", []]);
	_hit
};

MCCMK_boatPatrol_fnSegmentClear = {
	params ["_a", "_b", "_step", "_minDepth", "_lateral", "_lateralDepth", ["_hqPos", []], ["_hqDist", 0], ["_obsClear", -1]];
	if (_obsClear >= 0 && {[_a, _b, _obsClear] call MCCMK_boatPatrol_fnSegHitsObstacle}) exitWith {false};
	private _dist = _a distance2D _b;
	private _dir = _a getDir _b;
	private _steps = (ceil (_dist / _step)) max 1;
	private _ok = true;
	for "_i" from 0 to _steps do {
		private _p = _a getPos [(_dist * _i / _steps), _dir];
		if (_hqDist > 0 && {(_p distance2D _hqPos) < _hqDist}) exitWith {_ok = false;};
		if (([_p] call MCCMK_boatPatrol_fnDepth) < _minDepth) exitWith {_ok = false;};
		if (([_p getPos [_lateral, _dir + 90]] call MCCMK_boatPatrol_fnDepth) < _lateralDepth) exitWith {_ok = false;};
		if (([_p getPos [_lateral, _dir - 90]] call MCCMK_boatPatrol_fnDepth) < _lateralDepth) exitWith {_ok = false;};
	};
	_ok
};

// Arrival (completion) radius for waypoint _v, coming from _p and going
// on to _nx. Once a boat is inside this radius it switches to the next
// waypoint, so a wide radius makes it curve onto the next leg early
// instead of steering hard to hit the exact point, which is what causes
// the left-right over-correction. The boat then cuts the corner from roughly
// the point _r before _v straight towards _nx, so that short cut must
// also be clear water (it's checked). Uses the widest safe radius from
// MCCMK_boatPatrol_completionRadii.
MCCMK_boatPatrol_fnCornerRadius = {
	params ["_p", "_v", "_nx", ["_spIn", []]];
	private _sp = if (count _spIn > 0) then {_spIn} else {missionNamespace getVariable ["MCCMK_boatPatrol_segParams", []]};
	private _radii = missionNamespace getVariable ["MCCMK_boatPatrol_completionRadii", [40]];
	private _minR = _radii select ((count _radii) - 1);
	if (count _sp == 0) exitWith {_minR};
	private _res = _minR;
	private _found = false;
	{
		if (!_found) then {
			private _r = (_x min ((_p distance2D _v) * 0.8)) min ((_v distance2D _nx) * 0.8);
			if (_r >= _minR) then {
				private _e = _v getPos [_r, _v getDir _p];
				if (([_e, _nx] + _sp) call MCCMK_boatPatrol_fnSegmentClear) then {_res = _r; _found = true;};
			};
		};
	} forEach _radii;
	_res
};

// Speed for the leg _a -> _b (next waypoint after _b is _c):
//  LIMITED - land close on both sides somewhere along it (a small inlet or
//            narrow channel), so the boat slows down to thread it;
//  FULL    - a long leg in open water with a gentle turn at the end;
//  NORMAL  - everything else.
// Probes the water either side of the leg every 40 m.
MCCMK_boatPatrol_fnLegSpeed = {
	params ["_a", "_b", "_c"];
	(missionNamespace getVariable ["MCCMK_boatPatrol_speedParams", [120, 800, 200, 60]]) params ["_narrow", "_fullLen", "_fullClear", "_fullTurn"];
	private _dist = _a distance2D _b;
	private _dir = _a getDir _b;
	private _steps = (ceil (_dist / 40)) max 1;
	private _isNarrow = false;
	private _isOpen = true;
	for "_i" from 0 to _steps do {
		private _p = _a getPos [(_dist * _i / _steps), _dir];
		private _lBlocked = false;
		private _rBlocked = false;
		{
			if (([_p getPos [_x, _dir - 90]] call MCCMK_boatPatrol_fnDepth) < 1) then {_lBlocked = true;};
			if (([_p getPos [_x, _dir + 90]] call MCCMK_boatPatrol_fnDepth) < 1) then {_rBlocked = true;};
		} forEach [_narrow * 0.5, _narrow];
		if (_lBlocked && _rBlocked) exitWith {_isNarrow = true;};
		if (_isOpen) then {
			{
				if ((([_p getPos [_x, _dir - 90]] call MCCMK_boatPatrol_fnDepth) < 1) || {([_p getPos [_x, _dir + 90]] call MCCMK_boatPatrol_fnDepth) < 1}) then {_isOpen = false;};
			} forEach [_fullClear * 0.5, _fullClear];
		};
	};
	if (_isNarrow) exitWith {"LIMITED"};
	private _turn = abs (((((_b getDir _c) - _dir) + 540) mod 360) - 180);
	if (_isOpen && {_dist >= _fullLen} && {_turn <= _fullTurn}) exitWith {"FULL"};
	"NORMAL"
};

// Replaces a group's waypoints with a looping MOVE route. Waypoints are
// placed exactly (placement radius 0) so the engine doesn't scatter them
// into the shallows; each gets its own arrival radius and leg speed (see
// above); and UNCHANGED behaviour/combat mode so the crew's default
// reaction to contact isn't overridden each time a waypoint activates.
// Returns the list of leg speeds (for the RPT log).
MCCMK_boatPatrol_fnApplyRoute = {
	params ["_grp", "_route", ["_lead", []]];	// (MCC MK) _lead: a water path to the loop's first point, sailed once first
	for "_i" from ((count (waypoints _grp)) - 1) to 0 step -1 do {
		deleteWaypoint [_grp, _i];
	};
	// (MCC MK) the way in by water first (once - not part of the loop the CYCLE closes)
	private _leadWp = [];
	{
		private _lw = _grp addWaypoint [[_x select 0, _x select 1, 0], 0];
		_lw setWaypointType "MOVE";
		_lw setWaypointCompletionRadius 60;
		_lw setWaypointBehaviour "UNCHANGED";
		_lw setWaypointSpeed "NORMAL";
		_lw setWaypointCombatMode "NO CHANGE";
		_lw setWaypointFormation "NO CHANGE";
		if (_leadWp isEqualTo []) then {_leadWp = _lw;};
	} forEach _lead;
	private _n = count _route;
	private _sp = _grp getVariable ["MCCMK_BoatSegParams", []];   // this boat's depth margins (combat boat vs small boat)
	private _firstWp = [];
	private _rad0 = 40;
	private _spd0 = "NORMAL";
	private _speeds = [];
	{
		private _prevPt = _route select ((_forEachIndex - 1 + _n) mod _n);
		private _nextPt = _route select ((_forEachIndex + 1) mod _n);
		private _rad = if (_n > 2) then {[_prevPt, _x, _nextPt, _sp] call MCCMK_boatPatrol_fnCornerRadius} else {40};
		private _spd = if (_n > 1) then {[_prevPt, _x, _nextPt] call MCCMK_boatPatrol_fnLegSpeed} else {"NORMAL"};
		_speeds pushBack _spd;
		if (_forEachIndex == 0) then {_rad0 = _rad; _spd0 = _spd;};
		private _wp = _grp addWaypoint [[_x select 0, _x select 1, 0], 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointCompletionRadius _rad;
		_wp setWaypointBehaviour "UNCHANGED";
		_wp setWaypointSpeed _spd;
		_wp setWaypointCombatMode "NO CHANGE";
		_wp setWaypointFormation "NO CHANGE";
		if (_forEachIndex == 0) then {_firstWp = _wp;};
		// Last waypoint of the loop: reaching it = one full lap. The
		// re-route loop at the end of enemyBoatPatrol.sqf reads this count.
		if (_forEachIndex == (count _route) - 1 && {count _route > 1}) then {
			_wp setWaypointStatements ["true", "private _g = group this; _g setVariable ['MCCMK_BoatLaps', (_g getVariable ['MCCMK_BoatLaps', 0]) + 1];"];
		};
	} forEach _route;
	if (count _route > 1) then {
		// CYCLE on top of the first waypoint loops the route. The route is
		// built so the final leg back to the first point is always clear water.
		private _cyc = _grp addWaypoint [[(_route select 0) select 0, (_route select 0) select 1, 0], 0];
		_cyc setWaypointType "CYCLE";
		_cyc setWaypointCompletionRadius _rad0;
		_cyc setWaypointSpeed _spd0;
	};
	if !(_firstWp isEqualTo []) then {
		_grp setCurrentWaypoint (if (_leadWp isEqualTo []) then {_firstWp} else {_leadWp});	// (MCC MK)
		// Lets the watchdog map "route point N" to the group's waypoint index
		// and steer with setCurrentWaypoint instead of rebuilding waypoints.
		_grp setVariable ["MCCMK_BoatAppliedRoute", _route];
		_grp setVariable ["MCCMK_BoatWpOffset", _firstWp select 1];
	};
	_speeds
};

// (MCC MK) A straight line clear of the beach and obstacles (the shared segment check, usable from any thread).
MCCMK_boatPatrol_fnSegClearG = {
	params ["_a", "_b"];
	([_a, _b] + MCCMK_boatPatrol_segParams) call MCCMK_boatPatrol_fnSegmentClear
};

// (MCC MK) The way BY WATER from one point to another, round headlands and peninsulas: a search through the coastline
// map's water cells at least one cell from the beach (8 neighbours, shortest), then trimmed to as few straight, clear
// legs as possible. Returns the legs' end points (the last is the target), or [] when there is no way by water.
// _water: [coastline map (cell -> distance to the beach), map origin x, origin y, cell size] (the group's "MCCMK_BoatWater").
MCCMK_boatPatrol_fnLineWet = {
	params ["_a", "_b"];
	private _d = _a distance2D _b;
	private _dir = _a getDir _b;
	private _n = (ceil (_d / 10)) max 1;
	private _ok = true;
	for "_i" from 0 to _n do {
		if (([_a getPos [_d * _i / _n, _dir]] call MCCMK_boatPatrol_fnDepth) < 1) exitWith {_ok = false};
	};
	_ok
};

MCCMK_boatPatrol_fnWaterPath = {
	params ["_from", "_to", "_water"];
	_water params ["_map", "_ox", "_oy", "_st"];
	private _cellOf = {params ["_p"]; [round (((_p select 0) - _ox) / _st), round (((_p select 1) - _oy) / _st)]};
	private _okCell = {params ["_c"]; (_map getOrDefault [_c, -1]) >= _st};
	private _snap = {	// the cell, or the nearest usable one within 3 cells
		params ["_c"];
		if ([_c] call _okCell) exitWith {_c};
		private _best = [];
		for "_r" from 1 to 3 do {
			if (_best isEqualTo []) then {
				for "_dx" from -_r to _r do {
					for "_dy" from -_r to _r do {
						private _k = [(_c select 0) + _dx, (_c select 1) + _dy];
						if (_best isEqualTo [] && {[_k] call _okCell}) then {_best = _k;};
					};
				};
			};
		};
		_best
	};
	private _s = [[_from] call _cellOf] call _snap;
	if (_s isEqualTo []) then {
		private _c0 = [_from] call _cellOf;
		private _ring = [];
		for "_dx" from -8 to 8 do {
			for "_dy" from -8 to 8 do {
				private _k = [(_c0 select 0) + _dx, (_c0 select 1) + _dy];
				if ([_k] call _okCell) then {_ring pushBack [_dx * _dx + _dy * _dy, _k]};
			};
		};
		_ring sort true;
		{
			if ([_from, [_ox + ((_x select 1) select 0) * _st, _oy + ((_x select 1) select 1) * _st, 0]] call MCCMK_boatPatrol_fnLineWet) exitWith {_s = _x select 1};
		} forEach (_ring select [0, 10]);
	};
	private _g = [[_to] call _cellOf] call _snap;
	if (_s isEqualTo [] || {_g isEqualTo []}) exitWith {[]};
	private _prev = createHashMapFromArray [[_s, _s]];
	private _queue = [_s];
	private _qi = 0;
	private _found = _s isEqualTo _g;
	while {_qi < count _queue && {!_found}} do {
		private _c = _queue select _qi;
		_qi = _qi + 1;
		{
			private _n = [(_c select 0) + (_x select 0), (_c select 1) + (_x select 1)];
			if (!_found && {!(_n in _prev)} && {[_n] call _okCell}) then {
				_prev set [_n, _c];
				_queue pushBack _n;
				if (_n isEqualTo _g) then {_found = true;};
			};
		} forEach [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]];
	};
	if (!_found) exitWith {[]};
	private _cells = [_g];
	private _c = _g;
	while {!(_c isEqualTo _s)} do {_c = _prev get _c; _cells pushBack _c;};
	reverse _cells;
	private _pts = _cells apply {[_ox + (_x select 0) * _st, _oy + (_x select 1) * _st, 0]};
	_pts set [(count _pts) - 1, [_to select 0, _to select 1, 0]];
	// as few legs as possible: from each point, the furthest point on in a clear straight line
	private _out = [];
	private _cur = [_from select 0, _from select 1, 0];
	private _i = 0;
	while {_i < (count _pts) - 1} do {
		private _j = (count _pts) - 1;
		while {_j > _i + 1 && {!([_cur, _pts select _j] call MCCMK_boatPatrol_fnSegClearG)}} do {_j = _j - 1;};
		_cur = _pts select _j;
		_out pushBack _cur;
		_i = _j;
	};
	if (_out isEqualTo []) then {_out = [[_to select 0, _to select 1, 0]];};
	_out
};

// (MCC MK) Where a boat at _pos joins a route: the nearest route point in a clear straight line (more than _minD away); with
// none, the six nearest tried BY WATER and the shortest way kept - the boat sails that way first. Never straight at a
// point across land. Returns [the route from the join point, the way in by water (may be empty)], or [] (none by water).
MCCMK_boatPatrol_fnJoin = {
	params ["_route", "_pos", ["_water", []], ["_minD", 60]];
	private _n = count _route;
	if (_n < 2) exitWith {[]};
	private _idx = -1;
	private _bestD = 1e10;
	{
		private _d = _x distance2D _pos;
		if (_d < _bestD && {_d > _minD} && {[_pos, _x] call MCCMK_boatPatrol_fnSegClearG}) then {_bestD = _d; _idx = _forEachIndex;};
	} forEach _route;
	private _lead = [];
	if (_idx < 0 && {_water isNotEqualTo []}) then {
		private _order = [];
		{_order pushBack [_x distance2D _pos, _forEachIndex];} forEach _route;
		_order sort true;
		private _bestLen = 1e10;
		{
			_x params ["", "_k"];
			private _path = [_pos, _route select _k, _water] call MCCMK_boatPatrol_fnWaterPath;
			if (_path isNotEqualTo []) then {
				private _len = 0;
				private _a = _pos;
				{_len = _len + (_a distance2D _x); _a = _x;} forEach _path;
				if (_len < _bestLen) then {_bestLen = _len; _idx = _k; _lead = _path select [0, (count _path) - 1];};
			};
		} forEach (_order select [0, 6]);
	};
	if (_idx < 0) exitWith {[]};
	[(_route select [_idx, _n]) + (_route select [0, _idx]), _lead]
};

private _hqPos = [-100000, -100000, 0];	// (MCC MK: no HQ zone)
private _worldSize = worldSize;

private _fnIsSafePoint = {
	params ["_p"];
	if (([_p] call MCCMK_boatPatrol_fnDepth) < _wpMinDepth) exitWith {false};
	if ([_p, _p, _obstacleClearance] call MCCMK_boatPatrol_fnSegHitsObstacle) exitWith {false};
	private _ok = true;
	for "_a" from 0 to 315 step 45 do {
		if (([_p getPos [_shoreClearance, _a]] call MCCMK_boatPatrol_fnDepth) < _shoreClearanceDepth) exitWith {_ok = false;};
	};
	_ok
};

private _fnSegClear = {
	params ["_a", "_b"];
	[_a, _b, _segmentStep, _segmentMinDepth, _segmentLateral, _segmentLateralDepth, _hqPos, _hqExclusionDist, _obstacleClearance] call MCCMK_boatPatrol_fnSegmentClear
};

// Shared with MCCMK_boatPatrol_fnCornerRadius, which runs from the
// watchdog/re-route threads as well as here.
MCCMK_boatPatrol_segParams = [_segmentStep, _segmentMinDepth, _segmentLateral, _segmentLateralDepth, _hqPos, _hqExclusionDist, _obstacleClearance];
MCCMK_boatPatrol_completionRadii = _completionRadii;
MCCMK_boatPatrol_speedParams = [_narrowProbe, _fullSpeedLegLength, _fullSpeedClearance, _fullSpeedMaxTurn];

// ---------------------------------------------------------------------
// 1. Coastline map. Covers _half metres each way from _center.
//    Sea area is counted within _oceanSearchRadius of the objective _ao;
//    waypoint candidates (within _maxAnchorDist) and shoreline cells are
//    measured from _center.
//    Returns [seaArea m2, candidates [[pos, shoreDist], ...], shoreline cell positions].
//    Distance to the beach comes from a two-pass chamfer distance transform
//    over the grid (land and very shallow cells = 0), so it's one cheap
//    pass over the cells rather than a search per point.
// ---------------------------------------------------------------------
private _fnScanAO = {
	params ["_ao", "_center", "_half"];
	private _n = (floor ((2 * _half) / _gridStep)) + 1;
	private _ox = (_center select 0) - _half;
	private _oy = (_center select 1) - _half;
	private _big = 1e9;
	private _depths = [];
	private _dist = [];
	for "_j" from 0 to (_n - 1) do {
		for "_i" from 0 to (_n - 1) do {
			private _px = _ox + _i * _gridStep;
			private _py = _oy + _j * _gridStep;
			// Outside the terrain counts as water in Arma - only use real map area.
			if (_px > 0 && {_py > 0} && {_px < _worldSize} && {_py < _worldSize}) then {
				private _d = [[_px, _py]] call MCCMK_boatPatrol_fnDepth;
				_depths pushBack _d;
				_dist pushBack (if (_d < 0.5) then {0} else {_big});
			} else {
				_depths pushBack -2;
				_dist pushBack _big;
			};
		};
	};

	// Inland AO with no real sea anywhere on the map section - skip the rest.
	if ((_depths findIf {_x >= _oceanMinDepth}) < 0) exitWith {[0, [], [], createHashMap, _ox, _oy]};

	private _d1 = _gridStep;
	private _d2 = _gridStep * 1.4142;
	// Forward pass
	for "_j" from 0 to (_n - 1) do {
		for "_i" from 0 to (_n - 1) do {
			private _k = _i + _j * _n;
			private _v = _dist select _k;
			if (_v > 0) then {
				if (_i > 0) then {_v = _v min ((_dist select (_k - 1)) + _d1);};
				if (_j > 0) then {
					_v = _v min ((_dist select (_k - _n)) + _d1);
					if (_i > 0) then {_v = _v min ((_dist select (_k - _n - 1)) + _d2);};
					if (_i < _n - 1) then {_v = _v min ((_dist select (_k - _n + 1)) + _d2);};
				};
				_dist set [_k, _v];
			};
		};
	};
	// Backward pass
	for "_j" from (_n - 1) to 0 step -1 do {
		for "_i" from (_n - 1) to 0 step -1 do {
			private _k = _i + _j * _n;
			private _v = _dist select _k;
			if (_v > 0) then {
				if (_i < _n - 1) then {_v = _v min ((_dist select (_k + 1)) + _d1);};
				if (_j < _n - 1) then {
					_v = _v min ((_dist select (_k + _n)) + _d1);
					if (_i < _n - 1) then {_v = _v min ((_dist select (_k + _n + 1)) + _d2);};
					if (_i > 0) then {_v = _v min ((_dist select (_k + _n - 1)) + _d2);};
				};
				_dist set [_k, _v];
			};
		};
	};

	private _seaCells = 0;
	private _cands = [];
	private _shore = [];
	private _sdMap = createHashMap;   // [i, j] -> distance to the beach, for every water cell
	for "_j" from 0 to (_n - 1) do {
		for "_i" from 0 to (_n - 1) do {
			private _k = _i + _j * _n;
			private _d = _depths select _k;
			if (_d >= 0.5) then {
				private _p = [_ox + _i * _gridStep, _oy + _j * _gridStep, 0];
				private _aoDist = _p distance2D _ao;
				private _cDist = _p distance2D _center;
				private _sd = _dist select _k;
				_sdMap set [[_i, _j], _sd];
				if (_d >= _oceanMinDepth && {_aoDist <= _oceanSearchRadius}) then {_seaCells = _seaCells + 1;};
				if (_sd <= _gridStep * 1.5 && {_cDist <= _alongCoastHalf + 500}) then {_shore pushBack _p;};
				// Further-offshore water that may be used only to get past HQ (see _hqPassBand).
				private _hqD = _p distance2D _hqPos;
				private _hqPass = (_sd > _maxShoreDist) && {_sd <= _hqPassMaxShoreDist} && {_hqD >= (_hqExclusionDist + _hqPassMargin)} && {_hqD <= (_hqExclusionDist + _hqPassBand)};
				if (
					(_cDist <= _maxAnchorDist || {_hqPass})
					&& {_sd >= (_bandClose select 0)}
					&& {(_sd <= _maxShoreDist) || {_hqPass}}
					&& {_d >= _wpMinDepth}
					&& {_hqD >= _hqExclusionDist}
					&& {[_p] call _fnIsSafePoint}
				) then {
					_cands pushBack [_p, _sd];
				};
			};
		};
	};
	[_seaCells * _gridStep * _gridStep, _cands, _shore, _sdMap, _ox, _oy]
};

// ---------------------------------------------------------------------
// Pick the AO: first candidate (main objectives first) with enough sea.
// ---------------------------------------------------------------------
private _sortedAOs = (_aoCandidates select {(_x select 1) isEqualTo true}) + (_aoCandidates select {!((_x select 1) isEqualTo true)});
private _aoPos = [];
private _cands = [];
private _shorePts = [];
{
	private _ao = [(_x select 0) select 0, (_x select 0) select 1, 0];
	([_ao, _ao, _detectHalfSize] call _fnScanAO) params ["_seaArea", "_c", "_s"];
	if (_seaArea >= _minOceanArea && {count _c > 0}) exitWith {
		_aoPos = _ao;
		_cands = _c;
		_shorePts = _s;
	};
} forEach _sortedAOs;

if (_aoPos isEqualTo []) exitWith {
};

// Spawn chance is rolled only once the AO is confirmed coastal, so the log
// above always shows whether the coast was detected.
private _roll = random 1;
if (_roll >= _spawnChance) exitWith {
};

// ---------------------------------------------------------------------
// Coast anchor: the shoreline point nearest the objective. The patrol
// stretch is centred here rather than on the objective itself, so an objective
// well inland doesn't trim the ends of the sweep. The coastline is then
// re-mapped around the anchor for the patrol.
// ---------------------------------------------------------------------
// Nearest shoreline point that actually has usable sea within 1.2 km, so a
// small inland pond next to the objective can't become the anchor.
private _coastAnchor = _aoPos;
private _byDist = _shorePts apply {[_x distance2D _aoPos, _x]};
_byDist sort true;
{
	private _sp = _x select 1;
	if ((_cands findIf {((_x select 0) distance2D _sp) < 1200}) >= 0) exitWith {_coastAnchor = _sp;};
} forEach _byDist;
// ---------------------------------------------------------------------
// Solid objects in the water around the patrol stretch - piers, jetties,
// breakwaters, rocks, wrecks, platforms. These are map objects, not
// terrain, so the water-depth checks can't see them. Any static object at
// least _obstacleMinSize across that reaches over water is recorded by its
// real outline (bounding box in its own rotation), and every waypoint,
// leg, corner cut and U-turn is kept _obstacleClearance clear of it.
// ---------------------------------------------------------------------
// HQ near the patrol stretch: the ring of water the boats use to get round
// HQ's closed water (out to _hqExclusionDist + _hqPassBand from HQ) has to be
// on the coastline map, or the route stops short of HQ. If part of it would
// fall outside, the map is made big enough to take all of it in.
// Only when HQ sits ON the patrol stretch (nearer the patrol's centre than the
// stretch reaches): that is the only case in which the boats have to go
// round it to carry on. With HQ beyond the end of the stretch there is
// nothing to go round - the stretch simply stops at HQ's closed water - so
// the map stays its normal size.
private _hqAnchorDist = _coastAnchor distance2D _hqPos;
if (_hqAnchorDist < _maxAnchorDist) then {
	private _needHalf = (ceil ((_hqAnchorDist + _hqExclusionDist + _hqPassBand) / _gridStep)) * _gridStep;
	if (_needHalf > _gridHalfSize) then {
		_gridHalfSize = _needHalf;
	};
};

private _obstacles = [];
{
	private _o = _x;
	if (!isNull _o && {!(_o isKindOf "AllVehicles")}) then {
		private _bb = boundingBoxReal _o;
		_bb params ["_b1", "_b2"];
		private _hx = ((_b2 select 0) - (_b1 select 0)) / 2;
		private _hy = ((_b2 select 1) - (_b1 select 1)) / 2;
		if (((_hx max _hy) * 2) >= _obstacleMinSize && {(_hx max _hy) < 400}) then {
			private _cxm = ((_b1 select 0) + (_b2 select 0)) / 2;
			private _cym = ((_b1 select 1) + (_b2 select 1)) / 2;
			// Does any part of it (centre or corners) sit over water?
			private _wet = false;
			{
				if (!_wet) then {
					private _w = _o modelToWorld [_x select 0, _x select 1, 0];
					if (([[_w select 0, _w select 1]] call MCCMK_boatPatrol_fnDepth) > 0.3) then {_wet = true;};
				};
			} forEach [[_cxm, _cym], [_b1 select 0, _b1 select 1], [_b2 select 0, _b1 select 1], [_b1 select 0, _b2 select 1], [_b2 select 0, _b2 select 1]];
			if (_wet) then {
				private _cw = _o modelToWorld [_cxm, _cym, 0];
				_obstacles pushBack [_o, _cxm, _cym, _hx, _hy, [_cw select 0, _cw select 1], sqrt ((_hx * _hx) + (_hy * _hy))];
			};
		};
	};
} forEach (nearestObjects [_coastAnchor, ["Static"], _gridHalfSize + 500, true]);
MCCMK_boatPatrol_obstacles = _obstacles;

([_aoPos, _coastAnchor, _gridHalfSize] call _fnScanAO) params ["_seaArea2", "_c2", "_s2", "_sdMap", "_gox", "_goy"];
if (count _c2 > 0) then {
	_cands = _c2;
	_shorePts = _s2;
};
// Distance to the beach at any point (nearest map cell); -1 = unknown.
private _fnShoreDistAt = {
	params ["_p"];
	_sdMap getOrDefault [[round (((_p select 0) - _gox) / _gridStep), round (((_p select 1) - _goy) / _gridStep)], -1]
};

// ---------------------------------------------------------------------
// Coast direction: principal axis of the shoreline cells around the coast
// anchor. If there's too little shoreline to tell (open water), run the
// axis across the line from the anchor to the sea instead.
// ---------------------------------------------------------------------
private _axis = [1, 0];
if (count _shorePts >= 5) then {
	private _mx = 0; private _my = 0;
	{ _mx = _mx + (_x select 0); _my = _my + (_x select 1); } forEach _shorePts;
	_mx = _mx / (count _shorePts); _my = _my / (count _shorePts);
	private _sxx = 0; private _syy = 0; private _sxy = 0;
	{
		private _dx = (_x select 0) - _mx;
		private _dy = (_x select 1) - _my;
		_sxx = _sxx + _dx * _dx; _syy = _syy + _dy * _dy; _sxy = _sxy + _dx * _dy;
	} forEach _shorePts;
	private _theta = 0.5 * ((2 * _sxy) atan2 (_sxx - _syy));
	_axis = [cos _theta, sin _theta];
} else {
	private _mx = 0; private _my = 0;
	{ _mx = _mx + ((_x select 0) select 0); _my = _my + ((_x select 0) select 1); } forEach _cands;
	_mx = _mx / (count _cands); _my = _my / (count _cands);
	private _toSea = [_mx - (_coastAnchor select 0), _my - (_coastAnchor select 1)];
	private _len = sqrt (((_toSea select 0) ^ 2) + ((_toSea select 1) ^ 2));
	if (_len > 1) then {_axis = [-(_toSea select 1) / _len, (_toSea select 0) / _len];};
};

// Seaward direction (perpendicular to the coast, pointing away from the
// beach): the normal whose side has the larger beach distances. Used to
// pick which way to swing a U-turn when either side would do.
private _seaNormal = [-(_axis select 1), _axis select 0];
private _msd = 0;
{ _msd = _msd + (_x select 1); } forEach _cands;
_msd = _msd / ((count _cands) max 1);
private _cov = 0;
{
	private _proj = ((((_x select 0) select 0) - (_coastAnchor select 0)) * (_seaNormal select 0)) + ((((_x select 0) select 1) - (_coastAnchor select 1)) * (_seaNormal select 1));
	_cov = _cov + _proj * ((_x select 1) - _msd);
} forEach _cands;
if (_cov < 0) then {_seaNormal = [-(_seaNormal select 0), -(_seaNormal select 1)];};

// ---------------------------------------------------------------------
// Per-boat-type "profiles": each boat type (small boat / combat boat)
// gets its own set of usable spots, sweep stations and inlets, built with
// its own depth margins. _fnUseProfile switches the working variables
// below to a profile before building or re-building that boat's route.
// ---------------------------------------------------------------------
private _coastPts = [];
private _sMin = 0;
private _sMax = 0;
private _coastRange = 0;
private _useCoastSweep = false;
private _stationCount = _minStations;
private _binHalf = 150;
private _inlets = [];
private _patrolPts = [];

private _fnBuildProfile = {
	params ["_large"];
	[_large] call _fnSetDepthProfile;
	// Each candidate becomes [pos, shoreDist, alongCoastOffset].
	// (For the combat boat, only cells that also pass its deeper margins.)
	_coastPts = [];
	{
		_x params ["_p", "_sd"];
		private _s = (((_p select 0) - (_coastAnchor select 0)) * (_axis select 0)) + (((_p select 1) - (_coastAnchor select 1)) * (_axis select 1));
		if ((abs _s) <= _alongCoastHalf && {!_large || {[_p] call _fnIsSafePoint}}) then {_coastPts pushBack [_p, _sd, _s];};
	} forEach _cands;

	_sMin = 1e9;
	_sMax = -1e9;
	{ _sMin = _sMin min (_x select 2); _sMax = _sMax max (_x select 2); } forEach _coastPts;
	_coastRange = if (count _coastPts > 0) then {_sMax - _sMin} else {0};
	_useCoastSweep = (count _coastPts >= 4) && {_coastRange >= _minCoastRange};
	_stationCount = ((round (_coastRange / _stationSpacing)) + 1) max _minStations min _maxStations;
	_binHalf = if (_stationCount > 1) then {((_coastRange / (_stationCount - 1)) / 2) max 150} else {150};

	// ---------------------------------------------------------------------
	// Inlets / bays: usable water with land within _inletProbe both ways
	// ALONG the coast (straight-coast water only has land on its landward
	// side). Grouped into separate inlets by along-coast offset; the biggest
	// _maxInlets are kept. Each inlet: [alongCoastCentre, cells sorted
	// landward-first as [pos, shoreDist, alongCoastOffset, seawardOffset]].
	// ---------------------------------------------------------------------
	_inlets = [];
	if (_useCoastSweep) then {
		private _inletCells = [];
		{
			_x params ["_p", "_sd", "_s"];
			private _blockedPlus = false;
			private _blockedMinus = false;
			for "_d" from 50 to _inletProbe step 50 do {
				if (!_blockedPlus && {([[(_p select 0) + ((_axis select 0) * _d), (_p select 1) + ((_axis select 1) * _d)]] call MCCMK_boatPatrol_fnDepth) < 1}) then {_blockedPlus = true;};
				if (!_blockedMinus && {([[(_p select 0) - ((_axis select 0) * _d), (_p select 1) - ((_axis select 1) * _d)]] call MCCMK_boatPatrol_fnDepth) < 1}) then {_blockedMinus = true;};
			};
			if (_blockedPlus && _blockedMinus) then {
				private _n = (((_p select 0) - (_coastAnchor select 0)) * (_seaNormal select 0)) + (((_p select 1) - (_coastAnchor select 1)) * (_seaNormal select 1));
				_inletCells pushBack [_s, _p, _sd, _n];
			};
		} forEach _coastPts;
		_inletCells sort true;

		private _clusters = [];
		private _cur = [];
		private _lastS = -1e9;
		{
			if (((_x select 0) - _lastS) > 150 && {count _cur > 0}) then {_clusters pushBack _cur; _cur = [];};
			_cur pushBack _x;
			_lastS = _x select 0;
		} forEach _inletCells;
		if (count _cur > 0) then {_clusters pushBack _cur;};

		_clusters = _clusters select {count _x >= _inletMinCells};
		private _bySize = _clusters apply {[count _x, _x]};
		_bySize sort false;
		{
			if (_forEachIndex < _maxInlets) then {
				private _cl = _x select 1;
				private _sMid = 0;
				{ _sMid = _sMid + (_x select 0); } forEach _cl;
				_sMid = _sMid / (count _cl);
				// Landward-first: [seawardOffset, pos, shoreDist, s] sorted by seawardOffset ascending.
				private _cells = _cl apply {[_x select 3, _x select 1, _x select 2, _x select 0]};
				_cells sort true;
				_inlets pushBack [_sMid, _cells apply {[_x select 1, _x select 2, _x select 3, _x select 0]}];
			};
		} forEach _bySize;
		_inlets sort true;
	};

	// Fallback random-loop pool: every usable cell (within _maxAnchorDist of the coast anchor).
	_patrolPts = (_cands select {!_large || {[_x select 0] call _fnIsSafePoint}}) apply {_x select 0};


	createHashMapFromArray [
		["large", _large], ["coastPts", _coastPts], ["sMin", _sMin], ["sMax", _sMax], ["coastRange", _coastRange],
		["useSweep", _useCoastSweep], ["stationCount", _stationCount], ["binHalf", _binHalf], ["inlets", _inlets], ["patrolPts", _patrolPts]
	]
};

private _fnUseProfile = {
	params ["_prof"];
	private _large = _prof get "large";
	[_large] call _fnSetDepthProfile;
	_coastPts = _prof get "coastPts";
	_sMin = _prof get "sMin";
	_sMax = _prof get "sMax";
	_coastRange = _prof get "coastRange";
	_useCoastSweep = _prof get "useSweep";
	_stationCount = _prof get "stationCount";
	_binHalf = _prof get "binHalf";
	_inlets = _prof get "inlets";
	_patrolPts = _prof get "patrolPts";
	(if (_large) then {_combatRouting} else {_smallRouting}) params ["_bw", "_rbw", "_mcs", "_mta", "_rss"];
	_bandWeights = +_bw;
	_returnBandWeights = +_rbw;
	_minCloseShare = _mcs;
	_maxTurnAngle = _mta;
	_returnStationStep = _rss;
};

// Path into an inlet: first to an approach point 150-350 m seaward of the
// mouth (so the boat lines up with the entrance instead of clipping the
// headlands either side), then in through the mouth (the most seaward
// inlet cell) to the deepest point reachable in clear straight legs,
// directly or via one intermediate point. Returns
// [approach, mouth, (mid,) head] or [].
private _fnInletPath = {
	params ["_cells"];
	private _mouth = (_cells select ((count _cells) - 1)) select 0;
	private _approach = [];
	{
		if (_approach isEqualTo []) then {
			private _t = [(_mouth select 0) + ((_seaNormal select 0) * _x), (_mouth select 1) + ((_seaNormal select 1) * _x), 0];
			private _best = [];
			private _bestD = 1e10;
			{
				private _d = (_x select 0) distance2D _t;
				if (_d < _bestD) then {_bestD = _d; _best = _x select 0;};
			} forEach _coastPts;
			if (_bestD <= 80 && {[_best, _mouth] call _fnSegClear}) then {_approach = _best;};
		};
	} forEach [150, 250, 350];
	if (_approach isEqualTo []) exitWith {[]};

	private _path = [];
	{
		if (_path isEqualTo []) then {
			private _h = _x select 0;
			if ((_h distance2D _mouth) >= 150) then {
				if ([_mouth, _h] call _fnSegClear) then {
					_path = [_approach, _mouth, _h];
				} else {
					private _mids = (_cells select {
						private _m = _x select 0;
						(_m distance2D _mouth) > 100 && {(_m distance2D _h) > 100}
					}) call BIS_fnc_arrayShuffle;
					{
						if (_path isEqualTo []) then {
							private _m = _x select 0;
							if (([_mouth, _m] call _fnSegClear) && {[_m, _h] call _fnSegClear}) then {_path = [_approach, _mouth, _m, _h];};
						};
					} forEach (_mids select [0, 15]);
				};
			};
		};
	} forEach (_cells select [0, 8]);
	_path
};

private _profSmall = [false] call _fnBuildProfile;
private _profLarge = [true] call _fnBuildProfile;
// If there's nowhere deep enough for the combat boat's margins, it uses the
// small-boat spots rather than not spawning at all.
private _profCombat = _profLarge;
if (count (_profLarge get "patrolPts") < 4) then {
	_profCombat = _profSmall;
};

// ---------------------------------------------------------------------
// 2-3. (MCC MK) The boats: MCC's own picks. Each is [class or existing boat, large?]. A boat 13.5 m or more across
//      uses the large (combat boat) margins; anything more than _maxSizeRatio x a combat boat's size is left out.
// ---------------------------------------------------------------------
private _fleet = [];
{
	private _cls = if (_x isEqualType objNull) then {typeOf _x} else {_x};
	private _sz = getNumber (configFile >> "CfgVehicles" >> _cls >> "mapSize");
	if (_sz <= 0 || {_sz <= ((_largeBoatFallbackProfile select 0) * _maxSizeRatio)}) then {_fleet pushBack [_x, _sz >= 13.5]};
} forEach _fleetIn;
if (_fleet isEqualTo []) exitWith {};

// ---------------------------------------------------------------------
// 4. Route building.
// ---------------------------------------------------------------------

// Heading change in degrees at _b when travelling _a -> _b -> _c
// (0 = straight on, 180 = hairpin).
private _fnTurnAngle = {
	params ["_a", "_b", "_c"];
	abs (((((_b getDir _c) - (_a getDir _b)) + 540) mod 360) - 180)
};

// Semicircular arc from _from to _to, bulging in unit direction _w. The
// bulge direction must be roughly perpendicular to the _from->_to chord.
// Returns 2 intermediate arc points (60-degree steps - kept few and far
// apart so the driver isn't constantly re-aiming), or [] if any part of it
// would cross land, shallows or the HQ zone.
private _fnArc = {
	params ["_from", "_to", "_w"];
	private _mx = ((_from select 0) + (_to select 0)) / 2;
	private _my = ((_from select 1) + (_to select 1)) / 2;
	private _vx = (_from select 0) - _mx;
	private _vy = (_from select 1) - _my;
	private _r = sqrt ((_vx * _vx) + (_vy * _vy));
	private _pts = [];
	{
		_pts pushBack [
			_mx + (_vx * (cos _x)) + ((_w select 0) * _r * (sin _x)),
			_my + (_vy * (cos _x)) + ((_w select 1) * _r * (sin _x)),
			0
		];
	} forEach [60, 120];
	private _chain = [_from] + _pts + [_to];
	private _ok = true;
	for "_k" from 0 to ((count _chain) - 2) do {
		if !([_chain select _k, _chain select (_k + 1)] call _fnSegClear) exitWith {_ok = false;};
	};
	if (_ok) then {_pts} else {[]}
};

// Returns the replacement for corner _v (coming from _p, going on to _nx):
// a U-turn arc for a very sharp corner (e.g. the end of a sweep, or a route
// that runs back along itself), otherwise just [_v]. Ordinary corners are
// left alone - the wide per-waypoint arrival radius makes the boat
// curve round them, and adding extra close-together waypoints only makes
// the AI driver over-correct. The U-turn: the boat carries on through a
// semicircular arc to a point _uTurnWidths to the side, then heads back.
// It swings towards the side the next waypoint is on, or seaward if that's
// unclear.
private _fnSmoothVertex = {
	params ["_p", "_v", "_nx"];
	private _turn = [_p, _v, _nx] call _fnTurnAngle;
	private _res = [_v];
	private _done = false;
	if (_turn >= _uTurnAngle) then {
		private _dIn = _p getDir _v;
		private _dx = sin _dIn;
		private _dy = cos _dIn;
		private _left = [-_dy, _dx];
		private _right = [_dy, -_dx];
		// Positive = next waypoint is to the left of the incoming line.
		private _cross = (_dx * ((_nx select 1) - (_v select 1))) - (_dy * ((_nx select 0) - (_v select 0)));
		private _sides = [];
		if (_cross > 20) then {
			_sides = [_left, _right];
		} else {
			if (_cross < -20) then {
				_sides = [_right, _left];
			} else {
				_sides = if ((((_left select 0) * (_seaNormal select 0)) + ((_left select 1) * (_seaNormal select 1))) >= 0) then {[_left, _right]} else {[_right, _left]};
			};
		};
		{
			private _side = _x;
			{
				if (!_done) then {
					private _v2 = [(_v select 0) + ((_side select 0) * _x), (_v select 1) + ((_side select 1) * _x), 0];
					if ([_v2, _nx] call _fnSegClear) then {
						private _arc = [_v, _v2, [_dx, _dy]] call _fnArc;
						if !(_arc isEqualTo []) then {
							_res = [_v] + _arc + [_v2];
							_done = true;
						};
					};
				};
			} forEach _uTurnWidths;
		} forEach _sides;
	};
	_res
};

// Turns every very sharp corner of a closed loop into a U-turn arc.
// Corners are processed in order, each one from the point actually placed
// before it, so neighbouring changes join up properly. Every leg of the
// finished loop is then re-checked (water, depth, HQ); if any fails, the
// unmodified route (already fully checked) is used instead.
private _fnSmoothRoute = {
	params ["_route"];
	private _n = count _route;
	if (_n < 3) exitWith {_route};
	private _out = [_route select 0];
	for "_i" from 1 to (_n - 1) do {
		_out append ([_out select ((count _out) - 1), _route select _i, _route select ((_i + 1) mod _n)] call _fnSmoothVertex);
	};
	// Finally the corner at the start/end of the loop.
	private _chain0 = [_out select ((count _out) - 1), _route select 0, _out select 1] call _fnSmoothVertex;
	private _res = _chain0 + (_out select [1, (count _out) - 1]);

	private _m = count _res;
	private _allOk = true;
	for "_i" from 0 to (_m - 1) do {
		if !([_res select _i, _res select ((_i + 1) mod _m)] call _fnSegClear) exitWith {_allOk = false;};
	};
	if (_allOk) then {_res} else {
		_route
	}
};

// Closes a route into a valid loop: if the direct leg from the last
// waypoint back to the first would cross land, the route runs back along
// its own legs instead (every leg already checked).
private _fnCloseLoop = {
	params ["_route"];
	if (count _route > 2 && {!([_route select ((count _route) - 1), _route select 0] call _fnSegClear)}) then {
		private _back = _route select [1, (count _route) - 2];
		reverse _back;
		_route = _route + _back;
	};
	_route
};

// Coastal sweep: picks a waypoint near along-coast offset _sTarget, in a
// randomly weighted beach-distance band (close / mid / outer), reachable
// from _prev by a clear leg. _avoidBand (index, or -1) is made less
// likely, so the return sweep takes a different line from the outbound one.
// Returns [pos, bandIndex] or [].
private _fnPickAt = {
	params ["_sTarget", "_prev", "_avoidBand", ["_prevPrev", []], ["_boostClose", false], ["_weights", []]];
	private _bin = _coastPts select {abs ((_x select 2) - _sTarget) <= _binHalf};
	if (count _bin == 0) exitWith {[]};
	private _w = if (count _weights == 3) then {+_weights} else {+_bandWeights};
	if (_avoidBand >= 0) then {_w set [_avoidBand, (_w select _avoidBand) * 0.3];};
	if (_boostClose) then {_w set [0, (_w select 0) * 2.5];};
	private _first = [0, 1, 2] selectRandomWeighted _w;
	private _order = [_first] + ([0, 1, 2] - [_first]);
	// Takes the first reachable option (in band-preference order) whose turn
	// at _prev is within _maxTurnAngle. If nothing is that gentle, takes the
	// reachable option with the smallest turn (the arrival radius / U-turn
	// handling softens it).
	private _res = [];
	private _fallback = [];
	private _fallbackTurn = 1e9;
	{
		if (_res isEqualTo []) then {
			private _bi = _x;
			private _band = _bands select _bi;
			private _opts = _bin select {
				(_x select 1) >= (_band select 0)
				&& {(_x select 1) <= (_band select 1)}
				&& {(_prev isEqualTo []) || {((_x select 0) distance2D _prev) >= _minWpSpacing}}
			};
			_opts = (_opts call BIS_fnc_arrayShuffle) select [0, 12];
			{
				if (_res isEqualTo []) then {
					private _c = _x select 0;
					if ((_prev isEqualTo []) || {[_prev, _c] call _fnSegClear}) then {
						private _turn = if ((_prev isEqualTo []) || {_prevPrev isEqualTo []}) then {0} else {[_prevPrev, _prev, _c] call _fnTurnAngle};
						if (_turn <= _maxTurnAngle) then {
							_res = [_c, _bi];
						} else {
							if (_turn < _fallbackTurn) then {_fallbackTurn = _turn; _fallback = [_c, _bi];};
						};
					};
				};
			} forEach _opts;
		};
	} forEach _order;
	if (_res isEqualTo []) then {_res = _fallback;};
	// Nothing usable at this station within the normal distance of the beach
	// (HQ's exclusion zone covers it, or blocks the way to it): take a
	// waypoint further offshore instead, so the route goes round HQ and
	// carries on along the coast. Such cells only exist near HQ (_hqPassBand).
	if (_res isEqualTo []) then {
		private _far = _bin select {
			(_x select 1) > _maxShoreDist
			&& {(_prev isEqualTo []) || {((_x select 0) distance2D _prev) >= _minWpSpacing}}
		};
		if (count _far > 0) then {
			// nearest the beach first, sampled evenly through the list
			_far = [_far, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy;
			private _stepFar = (ceil ((count _far) / 40)) max 1;
			for "_fi" from 0 to ((count _far) - 1) step _stepFar do {
				if (_res isEqualTo []) then {
					private _c = (_far select _fi) select 0;
					if ((_prev isEqualTo []) || {[_prev, _c] call _fnSegClear}) then {
						_res = [_c, 2];
					};
				};
			};
		};
	};
	_res
};

// Coastal sweep. Built outward from the AO in both directions, so it
// always covers all the coast that's connected to the AO. A station that
// can't be reached in a clear straight line (e.g. a cove behind a
// headland) is skipped rather than breaking the whole sweep; two misses in a
// row mark the end of the reachable coast in that direction. The outbound
// line runs from the low-offset end to the high-offset end; the return
// line comes back on different picks. _dirSign +1 starts the boat at the
// low end, -1 at the high end.
private _fnBuildCoastRoute = {
	params ["_dirSign"];
	private _stations = [];
	for "_i" from 0 to (_stationCount - 1) do {
		_stations pushBack (_sMin + _coastRange * _i / (_stationCount - 1));
	};
	private _pickCount = 0;    // close-band share tracking (see _minCloseShare)
	private _closeCount = 0;

	// Grows along the coast from a start point, one station at a time.
	// Returns [[pos, stationIndex, bandIndex], ...].
	private _fnGrow = {
		params ["_fromIdx", "_step", "_startPt", "_startPrevPrev"];
		private _chain = [];
		private _prev = _startPt;
		private _pp = _startPrevPrev;
		private _misses = 0;
		private _i = _fromIdx + _step;
		while {_i >= 0 && {_i < _stationCount} && {_misses < 2}} do {
			private _r = [_stations select _i, _prev, -1, _pp, (_pickCount > 0 && {(_closeCount / _pickCount) < _minCloseShare})] call _fnPickAt;
			if (_r isEqualTo []) then {
				_misses = _misses + 1;
			} else {
				_pickCount = _pickCount + 1;
				if ((_r select 1) == 0) then {_closeCount = _closeCount + 1;};
				_chain pushBack [_r select 0, _i, _r select 1];
				_pp = _prev;
				_prev = _r select 0;
				_misses = 0;
			};
			_i = _i + _step;
		};
		_chain
	};

	// Outbound line through a seed at station _seedIdx. The "down" side is
	// grown with the first "up" point as the point before the seed, so the
	// turn through the seed is kept gentle as well.
	private _fnLineFrom = {
		params ["_seedIdx"];
		private _seed = [_stations select _seedIdx, [], -1, []] call _fnPickAt;
		if (_seed isEqualTo []) exitWith {[]};
		_pickCount = 1;
		_closeCount = if ((_seed select 1) == 0) then {1} else {0};
		private _up = [_seedIdx, 1, _seed select 0, []] call _fnGrow;
		private _down = [_seedIdx, -1, _seed select 0, (if (count _up > 0) then {(_up select 0) select 0} else {[]})] call _fnGrow;
		reverse _down;
		_down + [[_seed select 0, _seedIdx, _seed select 1]] + _up
	};

	// Seed at the stations nearest the AO first; a seed can land in an
	// isolated pocket of water, so try a few and keep the longest line.
	private _order = [];
	{ _order pushBack [abs _x, _forEachIndex]; } forEach _stations;
	_order sort true;
	private _line = [];
	private _tries = 0;
	{
		if (_tries < 6 && {count _line < _stationCount}) then {
			_tries = _tries + 1;
			private _l = [_x select 1] call _fnLineFrom;
			if (count _l > count _line) then {_line = _l;};
		};
	} forEach (_order + _order);
	if (count _line < 2) exitWith {_line apply {_x select 0}};

	// Return sweep from the high end back to the low end, on different
	// picks (a station taken inshore on the way out tends to be taken
	// further out on the way back). Its first pick follows the end-of-sweep
	// reversal, which becomes a U-turn arc, so it has no turn preference.
	private _hiIdx = (_line select ((count _line) - 1)) select 1;
	private _loIdx = (_line select 0) select 1;
	private _hiPos = (_line select ((count _line) - 1)) select 0;
	private _ret = [];
	private _prev = _hiPos;
	private _pp = [];
	_pickCount = count _line;
	_closeCount = {(_x select 2) == 0} count _line;
	// Every _returnStationStep-th station, further offshore (_returnBandWeights),
	// so the way back is a faster run with long open legs. If a station
	// can't be reached, the one it skipped is tried instead.
	for "_i" from (_hiIdx - _returnStationStep) to (_loIdx + 1) step -_returnStationStep do {
		private _avoid = -1;
		{ if ((_x select 1) == _i) exitWith {_avoid = _x select 2;}; } forEach _line;
		private _r = [_stations select _i, _prev, _avoid, _pp, false, _returnBandWeights] call _fnPickAt;
		if (_r isEqualTo [] && {_returnStationStep > 1} && {(_i + 1) < _hiIdx}) then {
			_r = [_stations select (_i + 1), _prev, -1, _pp, false, _returnBandWeights] call _fnPickAt;
		};
		if !(_r isEqualTo []) then {
			_pickCount = _pickCount + 1;
			if ((_r select 1) == 0) then {_closeCount = _closeCount + 1;};
			_ret pushBack (_r select 0);
			_pp = _prev;
			_prev = _r select 0;
		};
	};

	// Inlet trips, spliced into the outbound line between the two waypoints
	// either side of each inlet: in from the mouth to the far end, then out
	// again - straight on to the next waypoint if that's clear, otherwise
	// back out the way it came.
	private _out = _line apply {_x select 0};
	private _inletTrips = 0;
	{
		_x params ["_sIn", "_cells"];
		private _k = -1;
		{
			if (_forEachIndex < (count _out) - 1) then {
				private _sA = (((_x select 0) - (_coastAnchor select 0)) * (_axis select 0)) + (((_x select 1) - (_coastAnchor select 1)) * (_axis select 1));
				private _nb = _out select (_forEachIndex + 1);
				private _sB = (((_nb select 0) - (_coastAnchor select 0)) * (_axis select 0)) + (((_nb select 1) - (_coastAnchor select 1)) * (_axis select 1));
				if (_k < 0 && {_sIn >= (_sA min _sB)} && {_sIn <= (_sA max _sB)}) then {_k = _forEachIndex;};
			};
		} forEach _out;
		if (_k >= 0) then {
			private _path = [_cells] call _fnInletPath;
			if (count _path >= 2) then {
				private _a = _out select _k;
				private _b = _out select (_k + 1);
				if ([_a, _path select 0] call _fnSegClear) then {
					private _trip = [];
					private _back = +_path;
					reverse _back;
					// Leave from the deepest point we can: head, then back out
					// through the path, whichever first has a clear leg to _b.
					{
						if (_trip isEqualTo [] && {[_x, _b] call _fnSegClear}) then {
							_trip = _path + (_back select [1, _forEachIndex]);
						};
					} forEach _back;
					if !(_trip isEqualTo []) then {
						_out = (_out select [0, _k + 1]) + _trip + (_out select [_k + 1, count _out]);
						_inletTrips = _inletTrips + 1;
					};
				};
			};
		};
	} forEach _inlets;
	_lastInletTrips = _inletTrips;

	private _route = _out + _ret;
	_route = [_route] call _fnCloseLoop;
	_route = [_route] call _fnSmoothRoute;
	if (_dirSign < 0) then {
		private _k = _route findIf {_x isEqualTo _hiPos};
		if (_k > 0) then {_route = (_route select [_k, count _route]) + (_route select [0, _k]);};
	};
	_route
};

// Fallback random loop (short or broken-up coastlines).
private _fnBuildRoute = {
	params ["_start", "_pts"];
	private _route = [_start];
	private _cur = _start;
	private _fnTryLeg = {
		params ["_minLeg"];
		private _opts = _pts select {
			private _c = _x;
			private _d = _cur distance2D _c;
			_d >= _minLeg && {_d <= _maxLegLength} && {(_route findIf {(_x distance2D _c) < _minWpSpacing}) < 0}
		};
		_opts = (_opts call BIS_fnc_arrayShuffle) select [0, 25];
		private _next = [];
		private _fb = [];
		private _fbTurn = 1e9;
		private _pp = if (count _route >= 2) then {_route select ((count _route) - 2)} else {[]};
		{
			if ((_next isEqualTo []) && {[_cur, _x] call _fnSegClear}) then {
				private _turn = if (_pp isEqualTo []) then {0} else {[_pp, _cur, _x] call _fnTurnAngle};
				if (_turn <= _maxTurnAngle) then {
					_next = _x;
				} else {
					if (_turn < _fbTurn) then {_fbTurn = _turn; _fb = _x;};
				};
			};
		} forEach _opts;
		if (_next isEqualTo []) then {_next = _fb;};
		_next
	};
	for "_n" from 2 to _waypointCount do {
		private _next = [_minLegLength] call _fnTryLeg;
		if (_next isEqualTo []) exitWith {};
		_route pushBack _next;
		_cur = _next;
	};
	// Tight bay / narrow channel: accept shorter legs rather than no patrol.
	if (count _route == 1) then {
		private _minWpSpacingOrig = _minWpSpacing;
		_minWpSpacing = 80;
		for "_n" from 2 to 3 do {
			private _next = [80] call _fnTryLeg;
			if (_next isEqualTo []) exitWith {};
			_route pushBack _next;
			_cur = _next;
		};
		_minWpSpacing = _minWpSpacingOrig;
	};
	[[_route] call _fnCloseLoop] call _fnSmoothRoute
};

private _allPlayersNoHC = allPlayers - (entities "HeadlessClient_F");
private _usedStarts = [];

private _fnStartOk = {
	params ["_c", "_checkPlayers"];
	((!_checkPlayers) || {(_allPlayersNoHC findIf {alive _x && {(_x distance2D _c) < _playerAvoidDist}}) < 0})
	&& {(_usedStarts findIf {(_x distance2D _c) < _boatSeparation}) < 0}
};

private _fnPickStart = {
	private _opts = _patrolPts select {[_x, true] call _fnStartOk};
	if (count _opts == 0) then {_opts = _patrolPts select {[_x, false] call _fnStartOk};};
	// (nowhere far enough from the other boats: the point furthest from them, so
	// two boats are never created on the same spot)
	if (count _opts == 0) exitWith {
		if ((count _usedStarts) == 0) then {selectRandom _patrolPts} else {
			private _best = _patrolPts select 0;
			private _bestDist = -1;
			{
				private _p = _x;
				private _d = selectMin (_usedStarts apply {_x distance2D _p});
				if (_d > _bestDist) then {_bestDist = _d; _best = _p;};
			} forEach _patrolPts;
			_best
		};
	};
	selectRandom _opts
};

// Builds one boat's route and returns it starting at its spawn point. A
// coastal route is a closed loop, so it can be rotated to start at any
// waypoint: it starts at its own first waypoint (one end of the coast)
// unless that's too close to a player or the other boat.
private _lastRouteType = "";
private _lastInletTrips = 0;
private _fnRouteForBoat = {
	params ["_boatIndex", "_firstDir"];
	private _route = [];
	if (_useCoastSweep) then {
		private _dirSign = if ((_boatIndex mod 2) == 1) then {_firstDir} else {-_firstDir};
		_route = [_dirSign] call _fnBuildCoastRoute;
	};
	if (count _route < 3) then {
		if (_useCoastSweep) then {
		};
		_route = [call _fnPickStart, _patrolPts] call _fnBuildRoute;
		_lastRouteType = "random loop";
		_lastInletTrips = 0;
	} else {
		_lastRouteType = "coastal sweep";
		private _idx = _route findIf {[_x, true] call _fnStartOk};
		if (_idx < 0) then {_idx = _route findIf {[_x, false] call _fnStartOk};};
		// (no waypoint far enough from the other boats: start at the one furthest from them)
		if (_idx < 0 && {(count _usedStarts) > 0}) then {
			private _bestDist = -1;
			{
				private _p = _x;
				private _d = selectMin (_usedStarts apply {_x distance2D _p});
				if (_d > _bestDist) then {_bestDist = _d; _idx = _forEachIndex;};
			} forEach _route;
		};
		if (_idx > 0) then {_route = (_route select [_idx, count _route]) + (_route select [0, _idx]);};
	};
	_route
};

// One-line summary of a route for the RPT: how many waypoints are close
// to the beach, and the leg speeds.
private _fnRouteSummary = {
	params ["_route", "_speeds"];
	private _close = {private _d = [_x] call _fnShoreDistAt; _d >= 0 && {_d <= (_bandClose select 1)}} count _route;
	format ["%1 of %2 waypoints within %3m of the beach, %4 inlet trip(s), legs: %5 LIMITED / %6 NORMAL / %7 FULL",
		_close, count _route, _bandClose select 1, _lastInletTrips,
		{_x == "LIMITED"} count _speeds, {_x == "NORMAL"} count _speeds, {_x == "FULL"} count _speeds]
};

// A new mission may have started (and cleaned up) while this was scanning.
if ((missionNamespace getVariable ["MCCMK_EnemyBoatPatrol_Gen", 0]) != _gen) exitWith {};

private _firstDir = selectRandom [1, -1];


// ---------------------------------------------------------------------
// 5. Spawn boats, crews, routes and watchdogs.
// ---------------------------------------------------------------------
if (isNil "MCCMK_EnemyBoatPatrol_Vehicles") then {MCCMK_EnemyBoatPatrol_Vehicles = [];};
if (isNil "MCCMK_EnemyBoatPatrol_Units") then {MCCMK_EnemyBoatPatrol_Units = [];};
if (isNil "MCCMK_EnemyBoatPatrol_Groups") then {MCCMK_EnemyBoatPatrol_Groups = [];};
// (a new patrol starts with HQ off limits again - see the "Hit" handler below)
MCCMK_boatsHQReleased = false;
publicVariable "MCCMK_boatsHQReleased";
if (isNil "MCCMK_EnemyBoatPatrol_Markers") then {MCCMK_EnemyBoatPatrol_Markers = [];};

// Debug markers for a boat's current route (replaced on every re-route).
private _fnDrawRouteMarkers = {
	params ["_grp", "_b", "_route"];
	if (!_debugMarkers) exitWith {};
	{ deleteMarker _x; } forEach (_grp getVariable ["MCCMK_BoatMarkers", []]);
	private _lap = _grp getVariable ["MCCMK_BoatRouteNo", 1];
	private _names = [];
	{
		private _m = createMarker [format ["MCCMK_boatWP_%1_%2_%3_%4", _gen, _b, _lap, _forEachIndex], _x]; [_m] call MCCMK_fnc_genTag;
		_m setMarkerType "mil_dot";
		_m setMarkerColor "ColorOPFOR";
		_m setMarkerText format ["Boat %1 route %2 WP%3", _b, _lap, _forEachIndex];
		_names pushBack _m;
		MCCMK_EnemyBoatPatrol_Markers pushBack _m;
	} forEach _route;
	_grp setVariable ["MCCMK_BoatMarkers", _names];
};

private _boatRecords = [];   // [vehicle, group, boatIndex, isCombatBoat] - used by the re-route loop

for "_b" from 1 to (count _fleet) do {
	(_fleet select (_b - 1)) params ["_boatClass", "_isLarge"];
	[(if (_isLarge) then {_profCombat} else {_profSmall})] call _fnUseProfile;
	private _route = [_b, _firstDir] call _fnRouteForBoat;
	private _start = _route select 0;
	_usedStarts pushBack _start;

	private _veh = objNull;
	private _grp = grpNull;
	if (_boatClass isEqualType objNull) then {
		// (MCC MK) a boat that already exists: it joins its route at the nearest point it can reach in a clear line
		_veh = _boatClass;
		_grp = group (effectiveCommander _veh);
		private _pos = getPosASL _veh;
		private _jn = [_route, _pos, [_sdMap, _gox, _goy, _gridStep], 60] call MCCMK_boatPatrol_fnJoin;	// (MCC MK) by water if need be
		if (_jn isNotEqualTo []) then {_route = _jn select 0; _grp setVariable ["MCCMK_BoatLeadIn", _jn select 1];};
	} else {
		_veh = createVehicle [_boatClass, [_start select 0, _start select 1, 0], [], 0, "CAN_COLLIDE"]; [_veh] call MCCMK_fnc_genTag;
		if (isNull _veh) then {
			_veh = createVehicle [_vanillaFallbackClass, [_start select 0, _start select 1, 0], [], 0, "CAN_COLLIDE"]; [_veh] call MCCMK_fnc_genTag;
		};
		if (!isNull _veh) then {
			_veh setDir (if (count _route > 1) then {_start getDir (_route select 1)} else {random 360});
			_grp = createGroup [_enemySide, true]; [_grp] call MCCMK_fnc_genTag;
			(units (createVehicleCrew _veh)) joinSilent _grp;
			[_veh, _crewFaction] call MCCMK_fnc_crewFix;	// (MCC MK) the enemy faction's crew, never the side's vanilla one
		};
	};
	if (!isNull _veh && {!isNull _grp}) then {
		_veh setVariable ["MCCMK_BoatPatrol", true, true];
		_veh setUnloadInCombat [false, false];  // gunners stay aboard rather than bailing into the sea
		_veh allowCrewInImmobile true;         // and stay aboard if the boat is disabled

		_grp setBehaviour "AWARE";
		_grp setSpeedMode "NORMAL";
		// Combat mode deliberately left at the AI default (YELLOW) so the
		// crew reacts to contact the normal way.

		_grp setVariable ["MCCMK_BoatSegParams", [_segmentStep, _segmentMinDepth, _segmentLateral, _segmentLateralDepth, _hqPos, _hqExclusionDist, _obstacleClearance]];

		private _speeds = [_grp, _route, _grp getVariable ["MCCMK_BoatLeadIn", []]] call MCCMK_boatPatrol_fnApplyRoute;
		_grp setVariable ["MCCMK_BoatRoute", _route];

		[_grp, _b, _route] call _fnDrawRouteMarkers;
		_boatRecords pushBack [_veh, _grp, _b, _isLarge];
		_grp setVariable ["MCCMK_BoatWater", [_sdMap, _gox, _goy, _gridStep]];	// (MCC MK) for the way by water (MCCMK_boatPatrol_fnWaterPath)
		// LOG (boat patrol): each boat, and every watchdog action below
		if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["MCC [BOAT] boat patrol | boat %1 %2 spawned at %3 (depth %4 m) | route of %5 points | crew %6, side %7", _b, typeOf _veh, mapGridPosition _veh, (round (([getPosASL _veh] call MCCMK_boatPatrol_fnDepth) * 10)) / 10, count _route, count (crew _veh), side _grp]};


		// Watchdog: shallow-water steering, stall recovery, aground recovery.
		[_veh, _grp, _gen, _b, _watchdogInterval, _shallowDepth, _steerCooldown, _stuckWindow, _stuckDist] spawn {
			params ["_veh", "_grp", "_gen", "_b", "_interval", "_shallowDepth", "_steerCooldown", "_stuckWindow", "_stuckDist"];
			private _stuckStrikes = 0;
			private _lastSteer = -1e6;
			private _hist = [];
			private _stuckSince = -1;
			private _stuckStep = 0;
			private _wasCombat = false;
			private _fnBLog = { if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["MCC [BOAT] boat patrol | boat %1 %2 at %3 (depth %4 m, %5 km/h, %6) - %7", _b, typeOf _veh, mapGridPosition _veh, (round (([getPosASL _veh] call MCCMK_boatPatrol_fnDepth) * 10)) / 10, round (speed _veh), behaviour (leader _grp), _this]}; };

			// Route point index the group is currently heading for (CYCLE = 0).
			private _fnCurIdx = {
				private _applied = _grp getVariable ["MCCMK_BoatAppliedRoute", []];
				private _i = (currentWaypoint _grp) - (_grp getVariable ["MCCMK_BoatWpOffset", 0]);
				if (_i < 0 || {_i >= count _applied}) then {_i = 0;};
				_i
			};
			// Point the group at route point _i without rebuilding its waypoints.
			private _fnGoTo = {
				params ["_i"];
				_grp setCurrentWaypoint [_grp, (_grp getVariable ["MCCMK_BoatWpOffset", 0]) + _i];
			};
			// Rebuild the waypoints starting from the route point nearest the boat
			// (only when the waypoints are gone or steering hasn't worked).
			// (MCC MK) the nearest route point it can sail to: in a clear straight line, else by water round the land (never
			// straight at a point across a peninsula ). None by water: the waypoints stay as they are.
			private _fnReapplyFromNearest = {
				params ["_pos"];
				private _route = _grp getVariable ["MCCMK_BoatRoute", []];
				if (count _route < 2) exitWith {};
				private _j = [_route, _pos, _grp getVariable ["MCCMK_BoatWater", []], 50] call MCCMK_boatPatrol_fnJoin;
				if (_j isEqualTo []) exitWith {"no route point reachable by water - waypoints kept" call _fnBLog;};
				[_grp, _j select 0, _j select 1] call MCCMK_boatPatrol_fnApplyRoute;
				if ((_j select 1) isNotEqualTo []) then {(format ["back to the route by water, %1 legs round the land", count (_j select 1)]) call _fnBLog;};
			};

			private _fnOpenWater = {
				params ["_pos"];
				(_grp getVariable ["MCCMK_BoatWater", []]) params [["_map", createHashMap], ["_ox", 0], ["_oy", 0], ["_st", 50]];
				private _c0 = [round (((_pos select 0) - _ox) / _st), round (((_pos select 1) - _oy) / _st)];
				private _r = ceil (400 / _st);
				private _cand = [];
				for "_dx" from -_r to _r do {
					for "_dy" from -_r to _r do {
						private _v = _map getOrDefault [[(_c0 select 0) + _dx, (_c0 select 1) + _dy], -1];
						if (_v >= _st) then {_cand pushBack [_v, [_ox + ((_c0 select 0) + _dx) * _st, _oy + ((_c0 select 1) + _dy) * _st, 0]]};
					};
				};
				_cand sort false;
				private _open = [];
				private _clear = 0;
				{
					if ([_pos, _x select 1] call MCCMK_boatPatrol_fnLineWet) exitWith {_open = _x select 1; _clear = _x select 0};
				} forEach (_cand select [0, 12]);
				if (_open isEqualTo []) exitWith {"still stuck - no open water in a clear line within 400 m" call _fnBLog};
				private _route = _grp getVariable ["MCCMK_BoatRoute", []];
				if (count _route < 2) exitWith {};
				private _j = [_route, _open, _grp getVariable ["MCCMK_BoatWater", []], 50] call MCCMK_boatPatrol_fnJoin;
				if (_j isEqualTo []) then {_j = [_route, []]};
				[_grp, _j select 0, [_open] + (_j select 1)] call MCCMK_boatPatrol_fnApplyRoute;
				(format ["still stuck - sent to open water %1 m away (%2 m from the beach), then back to its route", round (_pos distance2D _open), round _clear]) call _fnBLog;
			};

			while {
				(missionNamespace getVariable ["MCCMK_EnemyBoatPatrol_Gen", 0]) == _gen
				&& {alive _veh}
				&& {!isNull _grp}
				&& {({alive _x} count (crew _veh)) > 0}
			} do {
				sleep _interval;
				if ((missionNamespace getVariable ["MCCMK_EnemyBoatPatrol_Gen", 0]) != _gen || {!alive _veh} || {isNull _grp}) exitWith {};
				private _applied = _grp getVariable ["MCCMK_BoatAppliedRoute", []];
				if (count _applied < 2) exitWith {};   // stationary boat - nothing to steer

				private _pos = getPosASL _veh;
				private _depth = [_pos] call MCCMK_boatPatrol_fnDepth;
				private _inCombat = (behaviour (leader _grp)) == "COMBAT";
				if (_inCombat && {!_wasCombat}) then { "crew in COMBAT" call _fnBLog; };
				if (!_inCombat && {_wasCombat}) then { "crew out of COMBAT" call _fnBLog; };
				_wasCombat = _inCombat;

				// 1. Waypoints gone (replaced by another script / a command).
				if ((count (waypoints _grp)) < 2) then {
					"waypoints gone - route re-applied from the nearest point" call _fnBLog;
					[_pos] call _fnReapplyFromNearest;
					_lastSteer = time;
				} else {
					// 2. Shallow water: steer at the next route point (no rebuild),
					// then give it time to get clear before steering again.
					// (and LOOKING AHEAD: the water 50 m and 100 m along its course - it turns away before the shallows,
					//  not on reaching them; three depth readings a check, cheap)
					private _ahead = 1e3;
					if ((abs (speed _veh)) > 5) then {
						private _vd = vectorNormalized [(velocity _veh) select 0, (velocity _veh) select 1, 0];
						_ahead = ([_pos vectorAdd (_vd vectorMultiply 50)] call MCCMK_boatPatrol_fnDepth) min ([_pos vectorAdd (_vd vectorMultiply 100)] call MCCMK_boatPatrol_fnDepth);
					};
					if ((_depth < _shallowDepth || {_ahead < _shallowDepth}) && {(time - _lastSteer) >= _steerCooldown}) then {
						private _nearest = 0;
						private _bestD = 1e10;
						{
							private _d = _pos distance2D _x;
							if (_d < _bestD) then {_bestD = _d; _nearest = _forEachIndex;};
						} forEach _applied;
						private _target = if (_bestD < 60) then {(_nearest + 1) mod (count _applied)} else {_nearest};
						[_target] call _fnGoTo;
						(format ["shallow water %1 (under %2 m) - steered at route point %3", (if (_depth < _shallowDepth) then {"under it"} else {"ahead"}), _shallowDepth, _target]) call _fnBLog;
						_lastSteer = time;
					};
				};

				// 3. Stalled (barely moving).
				_hist pushBack [time, _pos];
				while {(count _hist) > 1 && {(time - ((_hist select 1) select 0)) >= _stuckWindow}} do {_hist deleteAt 0};
				private _span = time - ((_hist select 0) select 0);
				private _moved = ((_hist select 0) select 1) distance2D _pos;
				if (_span >= _stuckWindow && {_moved < _stuckDist}) then {
					if (_stuckSince < 0) then {_stuckSince = time; _stuckStep = 0;};
					private _el = time - _stuckSince;
					switch (true) do {
						case (_stuckStep == 0): {
							private _nx = ((call _fnCurIdx) + 1) mod (count _applied);
							[_nx] call _fnGoTo;
							(format ["stuck (under %1 m in %2 s) - moved on to route point %3", _stuckDist, _stuckWindow, _nx]) call _fnBLog;
							_stuckStep = 1;
						};
						case (_stuckStep == 1 && {_el >= 60}): {
							[_pos] call _fnReapplyFromNearest;
							(format ["still stuck after %1 s - route rebuilt from the nearest point", round (_el + _stuckWindow)]) call _fnBLog;
							_stuckStep = 2;
						};
						case (_stuckStep == 2 && {_el >= 120}): {
							[_pos] call _fnOpenWater;
							_stuckStep = 3;
						};
						case (_stuckStep == 3 && {_el >= 180}): {
							"still stuck - starting again from the first step" call _fnBLog;
							_stuckSince = -1;
							_stuckStep = 0;
							_hist = [[time, _pos]];
						};
					};
				} else {
					if (_stuckSince >= 0) then {
						(format ["moving again (%1 m in the last %2 s)", round _moved, round _span]) call _fnBLog;
						_stuckSince = -1;
						_stuckStep = 0;
					};
				};

				// 4. Actually aground: back it off the beach after a few checks.
				if (_depth < 0.8 && {(abs (speed _veh)) < 2} && {isTouchingGround _veh || {_depth < 0}}) then {
					_stuckStrikes = _stuckStrikes + 1;
					if (_stuckStrikes == 1) then { "aground (touching bottom, barely moving)" call _fnBLog; };
					// eased off towards the deepest water close by - 3 m at a time, each check, until it floats again
					// (8 depth readings 25 m round it, then a small move: cheap, and only while it is aground)
					if (_stuckStrikes >= 2) then {
						private _bestB = -1;
						private _bestDp = _depth;
						for "_bb" from 0 to 315 step 45 do {
							private _dp = [_pos getPos [25, _bb]] call MCCMK_boatPatrol_fnDepth;
							if (_dp > _bestDp) then { _bestDp = _dp; _bestB = _bb; };
						};
						if (_bestB >= 0) then {
							if (_stuckStrikes == 2) then { (format ["still aground - easing it off towards deeper water (%1 m, bearing %2)", (round (_bestDp * 10)) / 10, _bestB]) call _fnBLog; };
							private _np = (getPosASL _veh) vectorAdd [3 * (sin _bestB), 3 * (cos _bestB), 0.2];
							_veh setPosASL _np;
							_veh setVelocity [3 * (sin _bestB), 3 * (cos _bestB), 0];
						} else {
							if (_stuckStrikes == 2) then { "still aground - no deeper water within 25 m" call _fnBLog; };
						};
					};
				} else {
					_stuckStrikes = 0;
				};
			};
			(format ["watchdog ended (alive %1, crew alive %2)", alive _veh, {alive _x} count (crew _veh)]) call _fnBLog;
		};
	};
};

// ---------------------------------------------------------------------
// 6. Re-route after every _cyclesBeforeReroute laps. This runs in the
//    main script thread (rather than a spawned one) because it needs the
//    coastline map and route builders above, which only exist here. Each
//    boat gets a freshly generated route - new random direction and new
//    random beach distances - and joins it at the waypoint nearest its
//    current position, so it doesn't turn back to a far-off start point. A
//    boat in combat is left alone until it drops out of COMBAT, then gets
//    its new route.
// ---------------------------------------------------------------------
if (_doneKey != "") then {missionNamespace setVariable [_doneKey, true]};	// (MCC MK) boats are out
if (count _boatRecords == 0) exitWith {};

while {
	(missionNamespace getVariable ["MCCMK_EnemyBoatPatrol_Gen", 0]) == _gen
	&& {(_boatRecords findIf {(_x select 0) isEqualType objNull && {alive (_x select 0)} && {!isNull (_x select 1)}}) > -1}
} do {
	sleep _rerouteCheckInterval;
	if ((missionNamespace getVariable ["MCCMK_EnemyBoatPatrol_Gen", 0]) != _gen) exitWith {};

	{
		_x params ["_veh", "_grp", "_b", ["_isLarge", false]];
		if (
			alive _veh
			&& {!isNull _grp}
			&& {({alive _x} count (crew _veh)) > 0}
			&& {(_grp getVariable ["MCCMK_BoatLaps", 0]) >= _cyclesBeforeReroute}
			&& {(behaviour (leader _grp)) != "COMBAT"}
		) then {
			private _pos = getPosASL _veh;
			[(if (_isLarge) then {_profCombat} else {_profSmall})] call _fnUseProfile;
			private _newRoute = [];
			private _newType = "coastal sweep";
			if (_useCoastSweep) then {
				_newRoute = [selectRandom [1, -1]] call _fnBuildCoastRoute;
			};
			if (count _newRoute < 3) then {
				_newType = "random loop";
				// Random loop, started from the usable point nearest the boat.
				private _nearest = _patrolPts select 0;
				{ if ((_x distance2D _pos) < (_nearest distance2D _pos)) then {_nearest = _x;}; } forEach _patrolPts;
				_newRoute = [_nearest, _patrolPts] call _fnBuildRoute;
			};

			if (count _newRoute >= 2) then {
				// Join the new loop at the waypoint nearest the boat
				// (preferring one with a clear leg from where it is now).
				// (MCC MK) (preferring a clear straight leg; else by water round the land - never straight across it). None by
				// water: the boat keeps the route it is on and tries again after another set of laps.
				private _join = [_newRoute, _pos, _grp getVariable ["MCCMK_BoatWater", []], 60] call MCCMK_boatPatrol_fnJoin;
				if (_join isEqualTo []) exitWith {
					_grp setVariable ["MCCMK_BoatLaps", 0];
					if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["MCC [BOAT] boat patrol | boat %1 %2 at %3 - new route (%4) not reachable by water - kept the current route", _b, typeOf _veh, mapGridPosition _veh, _newType]};
				};
				_newRoute = _join select 0;
				private _lead = _join select 1;

				private _routeNo = (_grp getVariable ["MCCMK_BoatRouteNo", 1]) + 1;
				_grp setVariable ["MCCMK_BoatRouteNo", _routeNo];
				_grp setVariable ["MCCMK_BoatRoute", _newRoute];
				_grp setVariable ["MCCMK_BoatLaps", 0];
				if (_newType == "random loop") then {_lastInletTrips = 0;};
				private _newSpeeds = [_grp, _newRoute, _lead] call MCCMK_boatPatrol_fnApplyRoute;	// (MCC MK) the way in by water first
				[_grp, _b, _newRoute] call _fnDrawRouteMarkers;
				if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["MCC [BOAT] boat patrol | boat %1 %2 at %3 - new route %4 (%5, %6 points)", _b, typeOf _veh, mapGridPosition _veh, _routeNo, _newType, count _newRoute]};

			} else {
				// Couldn't build anything new - keep the current route, count again.
				_grp setVariable ["MCCMK_BoatLaps", 0];
			};
		};
	} forEach _boatRecords;
};
