//===================================================================MCC_fnc_evacMove======================================================================================
// Move a vehicle across to WP
// Example:[[wp1,wp2,wp3], flyInHight, insertion, [netid vehicle,vehicle],assignedCargo  _evac] remoteExec ["MCC_fnc_evacMove", true, false];
// Params:
// 	[wp1,wp2,wp3]: array, waypoint positions
// 	flyInHight: number, if evac is a chopper flight hight, set to 5000 for land or sea vehicle
//	insertion: number, for vehicles: 0 - engine on, 1 - engine off. For helicopters: 0 - engine on, 1 - engine off, 2 - hover, 3 - Helocasting, 4 - Smoke, 5 - Fast Rope
//	vehicle: object, the evac vehicle
//==============================================================================================================================================================================
private _endpos = [];
private _landing = 0;
private _pilot = objNull;
private _j = configNull;
private _pos = [];
private _startPos = nil;
private _class = "";
private _nearSmokes = [];
private _wp = [];
private _wp2 = [];
private _cargoUnits = [];

params ["_route", "_height", "_landing", "_heli", ["_paraOpen", [0, 0], [[]]]];

if (typeName _heli == typeName []) then {
	 _heli = if (isMultiplayer) then {objectFromNetId (_heli select 0)} else {(_heli select 1)};
};

_cargoUnits	   = [];
{
	_class = tolower (_x select 1);
	if (_class == "cargo" || (_class == "turret" && (_x select 4))) then
	{
		_cargoUnits pushBack (_x select 0);
	};
} foreach (fullCrew _heli);

if (!local _heli) exitWith {["vehicle must be local"] call MCCMK_fnc_hint;};

//A new order replaces the previous one: its waypoints, land mode and automatic return trip are cleared, so no older
//order can make the vehicle take off on its own later.
private _orderId = (_heli getVariable ["MCC_evacOrder", 0]) + 1;
_heli setVariable ["MCC_evacOrder", _orderId];
private _current = {(_heli getVariable ["MCC_evacOrder", 0]) == _orderId};
{
	private _grp = _x;
	if (!isNull _grp) then {
		for "_i" from (count waypoints _grp) - 1 to 1 step -1 do {deleteWaypoint [_grp, _i]};
	};
} forEach ([group driver _heli, group gunner _heli] arrayIntersect [group driver _heli, group gunner _heli]);
_heli land "NONE";
_heli engineOn true;
private _oldPad = _heli getVariable ["MCC_evacPad", objNull];
if (!isNull _oldPad) then {deleteVehicle _oldPad};
_heli setVariable ["MCC_evacPad", objNull];
private _fnc_pad = {
	params ["_veh", "_p"];
	if (surfaceIsWater _p) exitWith {};
	private _pad = createVehicle ["Land_HelipadEmpty_F", [_p select 0, _p select 1, 0], [], 0, "CAN_COLLIDE"];
	_veh setVariable ["MCC_evacPad", _pad];
};
if (missionNamespace getVariable ["MCC_debug", false]) then {
	["DEBUG", "MCC_fnc_evacMove", "order %1 for %2 (%3): insertion %4, route %5, passengers %6: %7", [
		_orderId, typeOf _heli, mapGridPosition _heli,
		(["free landing (engine on)", "free landing (engine off)", "hover", "helocasting", "smoke signal", "fast rope", "precise landing", "paradrop"] param [_landing, str _landing]),
		_route apply {mapGridPosition _x}, count _cargoUnits, _cargoUnits apply {name _x}
	]] call MCC_fnc_log;
};
if !(_heli getVariable ["MCC_evacLogEH", false]) then {
	_heli setVariable ["MCC_evacLogEH", true];
	_heli addEventHandler ["GetOut", {
		params ["_veh", "_role", "_unit"];
		if (missionNamespace getVariable ["MCC_debug", false]) then {
			["DEBUG", "MCC_fnc_evacMove", "%1 (%2) left %3 from the %4 seat at %5, %6 m above ground, evac order %7", [
				name _unit, if (isPlayer _unit) then {"player"} else {"AI"}, typeOf _veh, _role, mapGridPosition _veh,
				round ((getPosATL _veh) select 2), _veh getVariable ["MCC_evacOrder", 0]
			]] call MCC_fnc_log;
		};
	}];
};

if (_height == 5000) then //We got a vehicle
{
	for [{_j = 0},{_j < count _route},{_j = _j + 1}] do
	{
		if ((getText(configFile >> "CfgVehicles" >> typeOf _heli  >> "simulation")) == "submarinex") then {_heli swimInDepth -4};
		_pos = _route select _j;
		_wp = (group driver _heli) addWaypoint [_pos, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointCombatMode "BLUE";
		_wp setWaypointSpeed "FULL";
		_wp setWaypointBehaviour "CARELESS";

		_wp2 = (group gunner _heli) addWaypoint [_pos, 0];
		_wp2 setWaypointType "MOVE";
		_wp2 setWaypointCombatMode "YELLOW";
		_wp2 setWaypointSpeed "FULL";
		_wp2 setWaypointBehaviour "COMBAT";
	};
	if (_landing == 1) then {_wp setWaypointStatements ["true", " driver (vehicle this) action ['ENGINEOFF', (vehicle this)];"]};
	(group driver _heli) setCurrentWaypoint [group driver _heli, 1];
}
else
{
	// First of all chopper gets its indicated flying height for the route
	_pilot = driver _heli;
	_heli setfuel 1;
	_heli flyinHeight _height;
	if (((getPosATL _heli) select 2) < 5) then {
		_heli flyInHeight (_height min 30);
		[_heli, _height, _orderId, _route select ((count _route) - 1)] spawn {
			params ["_hh", "_tgtH", "_id", "_dest"];
			while {alive _hh && {(_hh getVariable ["MCC_evacOrder", 0]) == _id}} do {
				sleep 1;
				if ((_hh distance2D _dest) < 600) exitWith {};
				private _want = (((getPosATL _hh) select 2) + (((speed _hh) / 3.6) max 3) + 10) min _tgtH;
				_hh flyInHeight _want;
				if (_want >= _tgtH) exitWith {};
			};
		};
	};
	_heli setVariable ["wp_complete", false];

	_startPos = _heli getVariable"MCC_evacStartPos";

	if (_landing == 7) exitWith {
		private _lineA = +(_route select 0);
		_lineA set [2, 0];
		private _lineB = +(_route param [1, _route select 0]);
		_lineB set [2, 0];
		private _lineDir = if ((_lineA distance2D _lineB) > 5) then {_lineA getDir _lineB} else {_heli getDir _lineA};
		if ((_lineA distance2D _lineB) <= 5) then {_lineB = _lineA getPos [1, _lineDir]; _lineB set [2, 0]};
		private _aim = _lineA getPos [(_lineA distance2D _lineB) / 2, _lineDir];
		_aim set [2, 0];
		private _relA = _aim getPos [-(missionNamespace getVariable ["MCC_paraCarry", 350]), _lineDir];
		_relA set [2, 0];
		private _home = if (isNil "_startPos") then {getPosATL _heli} else {_startPos};
		private _home2 = [_home select 0, _home select 1, 0];
		private _here = [(getPosATL _heli) select 0, (getPosATL _heli) select 1, 0];

		private _zones = [];
		{
			private _zp = (missionNamespace getVariable ["mcc_zone_pos", []]) param [_x, []];
			private _zs = (missionNamespace getVariable ["mcc_zone_size", []]) param [_x, [0, 0]];
			if (_zp isEqualType [] && {count _zp > 1} && {(_zp select 0) > 0} && {(_zp select 1) > 0}) then {
				_zones pushBack [[_zp select 0, _zp select 1, 0], ((_zs param [0, 0]) max (_zs param [1, 0])) + 300];
			};
		} forEach (missionNamespace getVariable ["MCC_zones_numbers", []]);

		private _fnc_detour = {
			params ["_from", "_to"];
			private _pts = [_from, _to];
			for "_n" from 1 to 6 do {
				private _fix = [];
				for "_s" from 0 to ((count _pts) - 2) do {
					private _p = _pts select _s;
					private _q = _pts select (_s + 1);
					{
						_x params ["_c", "_r"];
						if (((_p distance2D _c) > _r) && {(_q distance2D _c) > _r}) then {
							private _d = _q vectorDiff _p;
							_d set [2, 0];
							private _len2 = _d vectorDotProduct _d;
							private _t = if (_len2 > 0) then {((((_c vectorDiff _p) vectorDotProduct _d) / _len2) max 0) min 1} else {0};
							private _near = _p vectorAdd (_d vectorMultiply _t);
							if ((_near distance2D _c) < _r) then {
								private _out = _near vectorDiff _c;
								_out set [2, 0];
								if ((vectorMagnitude _out) < 1) then {_out = [-(_d select 1), _d select 0, 0]};
								private _det = _c vectorAdd ((vectorNormalized _out) vectorMultiply (_r * 1.15));
								_det set [2, 0];
								_fix = [_s + 1, _det];
							};
						};
						if (count _fix > 0) exitWith {};
					} forEach _zones;
					if (count _fix > 0) exitWith {};
				};
				if (count _fix == 0) exitWith {};
				_pts = (_pts select [0, _fix select 0]) + [_fix select 1] + (_pts select [_fix select 0]);
			};
			_pts select [1, (count _pts) - 2]
		};

		private _leadIn = _relA getPos [-2500, _lineDir];
		_leadIn set [2, 0];
		private _runStart = _relA getPos [-1500, _lineDir];
		_runStart set [2, 0];
		private _runEnd = _relA getPos [2000, _lineDir];
		_runEnd set [2, 0];
		private _ao = [];
		{
			_x params ["_c"];
			if (((_c distance2D _aim) < 3000) && {count _ao == 0 || {(_c distance2D _aim) < (_ao distance2D _aim)}}) then {_ao = +_c};
		} forEach _zones;
		private _sides = [_runEnd getPos [1000, _lineDir + 90], _runEnd getPos [1000, _lineDir - 90]];
		private _side = if (count _ao > 1) then {
			if (((_sides select 0) distance2D _ao) >= ((_sides select 1) distance2D _ao)) then {_sides select 0} else {_sides select 1}
		} else {
			if (((_sides select 0) distance2D _home2) <= ((_sides select 1) distance2D _home2)) then {_sides select 0} else {_sides select 1}
		};
		_side set [2, 0];
		private _inDet = [_here, _leadIn] call _fnc_detour;
		private _homeDet = [_side, _home2] call _fnc_detour;
		private _plan = [];
		{_plan pushBack [_x, 150]} forEach _inDet;
		_plan append [[_leadIn, 150], [_runStart, 200], [_relA, 100], [_runEnd, 60], [_side, 150]];
		{_plan pushBack [_x, 150]} forEach _homeDet;
		private _stick = +_cargoUnits;

		_heli setVariable ["MCCJumperNumber", -1, true];
		_heli setVariable ["MCCisHALO", 0, true];
		_heli setVariable ["MCCjumpReady", false, true];
		_heli setVariable ["MCC_dropLine", [_lineA, _lineDir, 0], true];
		_heli setVariable ["MCC_stickMid", ((count _stick) - 1) / 2];
		_heli setVariable ["MCC_paraRouteDone", false];
		{_x setVariable ["MCC_paraOpen", _paraOpen, true]} forEach _stick;
		{[_heli, _x, _forEachIndex] remoteExec ["MCC_fnc_realParadropPlayer", _x]} forEach _stick;

		{
			_x params ["_wpPos", "_wpRad"];
			private _wpP = (group driver _heli) addWaypoint [_wpPos, 0];
			_wpP setWaypointType "MOVE";
			_wpP setWaypointCombatMode "BLUE";
			_wpP setWaypointSpeed "NORMAL";
			_wpP setWaypointBehaviour "CARELESS";
			_wpP setWaypointCompletionRadius _wpRad;
			if (_forEachIndex == ((count _plan) - 1)) then {_wpP setWaypointStatements ["true", "(vehicle this) setVariable ['MCC_paraRouteDone', true];"]};
		} forEach _plan;
		(group driver _heli) setCurrentWaypoint [group driver _heli, 1];
		if (missionNamespace getVariable ["MCC_debug", false]) then {
			["DEBUG", "MCC_fnc_evacMove", "order %1: paradrop of %2 at %3 m | line %4 to %5 | release point %6 | %7 detours in, lead-in %8, run %9 to %10, then %11 (away from %12), %13 detours home", [
				_orderId, count _stick, _height, mapGridPosition _lineA, mapGridPosition _lineB, mapGridPosition _relA, count _inDet, mapGridPosition _leadIn,
				mapGridPosition _runStart, mapGridPosition _runEnd, mapGridPosition _side,
				if (count _ao > 1) then {format ["the AO at %1", mapGridPosition _ao]} else {"no AO within 3 km - towards home"}, count _homeDet
			]] call MCC_fnc_log;
		};

		waitUntil {sleep 0.5; !(call _current) || {!alive _heli} || {!alive driver _heli} || {(_heli distance2D _relA) < 800}};
		if (!(call _current) || {!alive _heli} || {!alive driver _heli}) exitWith {};
		_heli setVariable ["MCCjumpReady", true, true];
		[_heli, true] call MCCMK_fnc_rampOrDoors;	//(MK) the ramp (side doors for a helicopter with none)

		[_heli, _relA, _lineDir] spawn {
			params ["_pl", "_mk", "_ld"];
			private _fw = [sin _ld, cos _ld, 0];
			private _rt = [cos _ld, -(sin _ld), 0];
			while {alive _pl && {!(_pl getVariable ["MCC_paraReleased", false])}} do {
				private _o = (getPosASL _pl) vectorDiff (AGLToASL _mk);
				private _along = _o vectorDotProduct _fw;
				if (_along > 50) exitWith {};
				if (_along > -1500) then {
					private _v = velocity _pl;
					private _want = ((-(_o vectorDotProduct _rt)) * 0.12) max -8 min 8;
					private _dv = ((_want - (_v vectorDotProduct _rt)) max -0.6) min 0.6;
					_pl setVelocity (_v vectorAdd (_rt vectorMultiply _dv));
				};
				sleep 0.1;
			};
		};

		private _jumpGap = missionNamespace getVariable ["MCC_paraJumpGap", 0.3];
		private _t0 = time;
		waitUntil {
			sleep 0.05;
			private _v = velocity _heli;
			private _vh = [_v select 0, _v select 1, 0];
			private _sp = vectorMagnitude _vh;
			private _ahead = if (_sp > 1) then {((AGLToASL _aim) vectorDiff (getPosASL _heli)) vectorDotProduct (vectorNormalized _vh)} else {1000000};
			private _hRel = ((getPosASL _heli) select 2) - (getTerrainHeightASL _aim);
			_jumpGap = ((missionNamespace getVariable ["MCC_paraJumpSpacing", 22.5]) / (_sp max 1)) max 0.1 min 0.6;
			private _carry = _sp * ((((missionNamespace getVariable ["MCC_paraCarryTimeHeli", 1.7]) + 0.012 * (_hRel - 100)) max 0.5) min 4.6);
			_carry = _carry + (_heli getVariable ["MCC_stickMid", 0]) * _jumpGap * _sp;
			!(call _current) || {!alive _heli} || {time - _t0 > 240} || {_ahead <= _carry}
		};
		if (!(call _current) || {!alive _heli}) exitWith {_heli setVariable ["MCC_paraReleased", true]};

		_heli lock false;
		_heli setVariable ["MCC_jumpGap", _jumpGap, true];
		_heli setVariable ["MCC_releaseTime", time, true];
		_heli setVariable ["MCCJumperNumber", 0, true];
		_heli setVariable ["MCC_paraReleased", true];
		if (missionNamespace getVariable ["MCC_debug", false]) then {
			["DEBUG", "MCC_fnc_evacMove", "order %1: paradrop release at %2, %3 m above ground, %4 km/h, %5 m before the middle of the line", [
				_orderId, mapGridPosition _heli, round ((getPosATL _heli) select 2), round (speed _heli), round ((_heli distance2D _aim))
			]] call MCC_fnc_log;
		};

		{
			private _g = _x;
			if (!isNull _g && {!isPlayer leader _g}) then {
				[_g, _aim] spawn {
					params ["_g", "_aim"];
					private _t = time + 180;
					waitUntil {sleep 2; isNull _g || {time > _t} || {((units _g) select {alive _x}) findIf {vehicle _x != _x || {((getPosATL _x) select 2) > 2}} < 0}};
					if (isNull _g || {({alive _x} count units _g) == 0}) exitWith {};
					for "_i" from (count waypoints _g) - 1 to 0 step -1 do {deleteWaypoint [_g, _i]};
					private _w = _g addWaypoint [_aim, 0];
					_w setWaypointType "MOVE";
				};
			};
		} forEach ((_stick apply {group _x}) arrayIntersect (_stick apply {group _x}));

		private _tOut = time + ((count _stick) * 0.6) + 20;
		waitUntil {sleep 0.5; !(call _current) || {!alive _heli} || {time > _tOut} || {(_stick findIf {alive _x && {vehicle _x == _heli}}) < 0}};
		[_heli, false] spawn MCC_fnc_heliOpenCloseDoor;
		[_heli, false] call MCCMK_fnc_rampOrDoors;	//(MK) and its ramp

		waitUntil {sleep 1; !(call _current) || {!alive _heli} || {!alive driver _heli} || {_heli getVariable ["MCC_paraRouteDone", false]}};
		if ((call _current) && {alive _heli} && {alive driver _heli}) then {
			if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_evacMove", "order %1: paradrop done - returning to its start at %2", [_orderId, mapGridPosition _home]] call MCC_fnc_log};
			[[_home], _height, 1, [netid _heli,_heli]] remoteExec ["MCC_fnc_evacMove", _heli, false];
		};
	};

	for [{_j = 0},{_j < count _route},{_j = _j + 1}] do
	{
		_pos = _route select _j;
		_wp = (group driver _heli) addWaypoint [_pos, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointCombatMode "BLUE";
		_wp setWaypointSpeed "FULL";
		_wp setWaypointBehaviour "CARELESS";

		_wp2 = (group gunner _heli) addWaypoint [_pos, 0];
		_wp2 setWaypointType "MOVE";
		_wp2 setWaypointCombatMode "YELLOW";
		_wp2 setWaypointSpeed "FULL";
		_wp2 setWaypointBehaviour "COMBAT"
	};

	_wp setWaypointCompletionRadius 10;
	_wp setWaypointStatements ["true", " (vehicle this) setVariable ['wp_complete', true];"];

	_heli setSpeedMode "FULL";
	//(MK) any hold from the last order let go; for the hover insertions (Hover, Fast-Rope, Precise Landing, Rope
	// extraction) it comes down from its Fly height to its Hover height ON THE WAY IN (MCCMK_fnc_heliGlide)
	[_heli] remoteExec ["MCCMK_fnc_heliHold", _heli];
	[_heli] remoteExec ["MCCMK_fnc_heliRopeHold", _heli];	//(MK) and the fast-rope / extraction hold (MCCMK_fnc_heliRopePos)
	//(MK) a stop order left by an earlier hover would outrank this order's waypoints: ended
	if (!isNull (driver _heli) && {(currentCommand (driver _heli)) == "STOP"}) then {_heli doMove (getPos _heli)};
	[_heli] call MCCMK_fnc_heliWaterEnd;	//(MK) on the water: the new order lifts it off
	//(MK) a Helocasting ramp left open: shut by this new order
	if (_heli getVariable ["MCCMK_helocastOpen", false]) then {_heli setVariable ["MCCMK_helocastOpen", false]; [_heli, false] call MCCMK_fnc_rampOrDoors};
	//(MK) a water landing: down from the Fly height ON THE WAY IN
	_heli setVariable ["MCCMK_glideId", -1];
	if (_landing in [10, 11]) then {
		_heli setVariable ["MCCMK_wdReady", false];
		[_heli, waypointPosition _wp] spawn {
			params ["_mkH", "_mkP"];
			private _mkR = [_mkH, _mkP] call MCCMK_fnc_heliWaterDescent;
			if (_mkR) then {_mkH setVariable ["MCCMK_wdReady", true]};
		};
	};
	if (_landing in [2, 5, 6, 9] && {_heli isKindOf "Helicopter"}) then {
		[_heli, waypointPosition _wp, _height, [((missionNamespace getVariable ["MCCMK_evacHover", 20]) max 5) min 50, (missionNamespace getVariable ["MCCMK_evacHover", 20]) max 5] select (_landing == 2)] spawn MCCMK_fnc_heliGlide;
	};
	(group driver _heli) setCurrentWaypoint [group driver _heli, 1];
	if (!isNull gunner _heli && {group gunner _heli != group driver _heli}) then {(group gunner _heli) setCurrentWaypoint [group gunner _heli, 1]};
	//(MK) Fast-Rope and Rope extraction: Fast Rope Pos makes its OWN final approach (a waypoint 90 m past the
	// point - MCCMK_fnc_heliRopePos), so it's handed over 400 m out, still flying in
	while {(!(_heli getVariable ["wp_complete", false]) || {_landing in [10, 11]}) && {call _current} && {alive _heli} && {alive driver _heli} && {!(_landing in [5, 9]) || {(_heli distance2D _pos) > 400}} && {!(_landing in [10, 11]) || {!(_heli getVariable ["MCCMK_wdReady", false])}}} do {sleep 1};
	if !(call _current) exitWith {};	//replaced by a newer order

	//(MK) doors and ramp: a landing (Free Landing, Smoke, Precise Landing) opens them as it touches down and shuts them as
	// it takes off (MCCMK_fnc_heliDoorWatch)
	// (Hover: no doors - it just hovers; they open only when something is done there, a fast rope, an extraction, a water
	// landing's ramp)
	// (Fast-Rope and Rope extraction: not here, 400 m out - the precise waypoint opens them 20 m from the point)
	if (_landing in [0, 1, 4, 6]) then {[_heli, 300] spawn MCCMK_fnc_heliDoorWatch} else {if !(_landing in [2, 3, 5, 9, 10, 11]) then {[_heli, true] call MCCMK_fnc_heliDoorsAll}};	//(MK) Helocasting: the ramp only, once it's low (below)

	switch (_landing) do		//Which insertion do we want
	{
		//(MK) Water landing, engine on / off: settled onto the water - the ramp only, as it comes down
		case 10;
		case 11:
		{
			private _ok = [_heli, [_pos select 0, _pos select 1, 0], _current, 10, _landing == 10] call MCCMK_fnc_heliWaterLand;
			if (!_ok && {call _current}) then {_heli vehicleChat "Water landing not possible here"};
		};
		case 0:			//Free Landing engine on
		{
			[_heli, _pos] call _fnc_pad;
			_heli land "GET IN";
			if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_evacMove", "order %1: landing (engine on) at %2", [_orderId, mapGridPosition _pos]] call MCC_fnc_log};
		};

		case 1:			//Free Landing engine off
		{
			[_heli, _pos] call _fnc_pad;
			_heli land "LAND";
			if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_evacMove", "order %1: landing (engine off) at %2", [_orderId, mapGridPosition _pos]] call MCC_fnc_log};
		};

		case 2:			//Hover
		{
			//(MK) carried over the point and held there, at the Hover height (MCCMK_fnc_heliHoverAt)
			[_heli, [_pos select 0, _pos select 1, 0], (missionNamespace getVariable ["MCCMK_evacHover", 20]) max 5, _current] call MCCMK_fnc_heliHoverAtMove;	//(MK) the pilot ordered at the spot (a short move rocked it)
		};

		case 3:			//Helocasting
		{
			//while {(_heli distance _pos)>55} do {_pilot doMove _pos; sleep 5;};
			while {((getposasl _heli) select 2) > 8 && {call _current}} do {_heli flyinHeight 3; sleep 1};	//(MK) a newer order: stops
			//(MK) down low: the RAMP only (side doors for a helicopter with none), open until it's given its next order
			if (call _current) then {[_heli, true] call MCCMK_fnc_rampOrDoors; _heli setVariable ["MCCMK_helocastOpen", true]};
			if !(call _current) exitWith {};
			_heli globalChat "Golf 1 in position, clear for helocasting";

			{
				[_x] spawn
					{
						private _unit = objNull;
						_unit = _this select 0;

						if (isMultiplayer) then
						{
							 ["eject", [_unit]] remoteExec ["MCC_fnc_secAction", _unit, false];
						}
						else
						{
							unassignVehicle _unit;
							_unit action ["eject", vehicle _unit];
						};
					};

				sleep ( 1 + ((random 6)/10) );
			} foreach _cargoUnits;
		};

		case 4:			//Smoke signal
		{
			_heli globalChat "Waiting for smoke signal to land";
			_nearSmokes = [];
			while {(count _nearSmokes < 1)} do
			{
				_nearSmokes = (getPos _heli) nearObjects ["SmokeShell", 300];
				sleep 1;
				if (!(alive _pilot) || (damage _heli >= 0.5) || !(call _current)) exitWith {};
			};

			if (count _nearSmokes == 0) exitWith {};
			_endpos = getPosASL (_nearSmokes select 0);
			_endpos = _endpos vectorAdd [0,0,_height];
			[_heli,_endpos, _current] call MCC_fnc_heliPreciseLanding;	//(MK) (stops for a newer order)
			if !(call _current) exitWith {};

			_heli setVelocity [0,0,0];
			_heli flyinHeight 2;
		};

		case 5:			//Fast-rope
		{
			private _rope = objNull;
			private _actualRopes = [];
			private _ropes = [];
			private _zc = 0;
			private _attachPoint = [];
			_actualRopes = [];

			switch (typeOf _heli) do
			{
				case "B_Heli_Light_01_F":
				{
					_ropes = [[0.6,0.5,0],[-0.8,0.5,0]];
				};

				case "B_Heli_Transport_01_F":
				{
					_ropes = [[-1.11,2.5,0],[1.11,2.5,0]];
				};

				case "I_Heli_Transport_02_F":
				{
					_ropes = [[1,-5,0],[-1,-5,0]];
				};

				case "O_Heli_Attack_02_F":
				{
					_ropes = [[1.35,1.35,0],[-1.45,1.35,0]];
				};

				case "O_Heli_Light_02_F":
				{
					_ropes = [[1.3,1.3,0],[-1.3,1.3,0]];
				};

				case "I_Heli_light_03_F":
				{
					_ropes = [[1.3,1.3,0],[-1.3,1.3,0]];
				};

				case "O_Heli_Transport_04_covered_F":
				{
					_ropes = [[1,-4,-1],[-1,-4,-1]];
				};

				case "B_Heli_Transport_03_F":
				{
					_ropes = [[1,-4,-1],[-1,-4,-1]];
				};

				case "I_Heli_light_03_unarmed_F":
				{
					_ropes = [[1.3,1.3,0],[-1.3,1.3,0]];
				};

				default
				{
					_ropes = [[1.3,1.3,0],[-1.3,1.3,0]];
				};
			};
			//(MK) a newer order stops it at every step; men already on a rope get down first (MCC_fnc_evacMove's order check)
			//(MK) "Fast Rope Pos" (MCCMK_fnc_heliRopePos), at the Evac's Hover height (55 m ropes: 50 m at
			// most) - not the rescue boat's hover
			[_heli, [_pos select 0, _pos select 1, 0], ((missionNamespace getVariable ["MCCMK_evacHover", 20]) max 5) min 50, _current] call MCCMK_fnc_heliRopePos;
			_pos = (AGLToASL _pos) vectorAdd [0,0,_height];
			if !(call _current) exitWith {};
			//(MK) in place (within 1 m of the point, slow): the ropes go now - no further wait
			_heli globalChat "Golf 1 in position, get ready for fast rope";
			if (!alive _heli || !alive (driver _heli) || !(call _current)) exitWith {};

			[_heli, true] call MCCMK_fnc_heliDoorsAll;
			//(MK) "Rope animation" Harness: Advanced Rappelling's descent; else MCC's own ropes below
			if ([_heli, _cargoUnits select {alive _x && {(vehicle _x) isEqualTo _heli}}] call MCCMK_fnc_ropeDescend) exitWith {};

			{
				_rope = ropeCreate [_heli, _x,55,[10]];
				_actualRopes pushBack _rope;
				/*
				_rope = createVehicle ["land_rope_f", [0,0,0], [], 0, "CAN_COLLIDE"];
				sleep 0.3;
				_rope allowDamage false;
				_rope disableCollisionWith _heli;
				_actualRopes set [count _actualRopes, _rope];
				_rope setdir (getdir _heli);
				_rope attachto [_heli, _x];
				*/
				sleep 0.5;
			} forEach _ropes;

			sleep 1;


			private _roped = [];
			{
				if !(call _current) exitWith {};	// a newer order: nobody else goes down - they stay aboard for it
				_rope = _actualRopes select (_forEachIndex % 2);

				[_x, _rope] remoteExec ["MCC_fnc_fastRopeLocal", _x, false];
				_roped pushBack _x;

				sleep ( 1 + ((random 6)/10) );
			} foreach _cargoUnits;

			// every man who went down the rope on the GROUND before the ropes go (none dragged off by a new order either)
			_timeOut = time + 60;
			waitUntil { sleep 1; (time > _timeOut) || (!alive _heli) || (!alive (driver _heli)) || {(_roped findIf {alive _x && {(vehicle _x == _heli) || {!isNull (attachedTo _x)} || {((getPosATL _x) select 2) > 1.5}}}) < 0}};
			sleep 3;

			// drop the ropes and delete them
			{
				_attachPoint = _ropes select _forEachIndex;
				_zc = -22;
				while { _zc > -50 } do
				{
					_x attachTo [_heli, [_attachPoint select 0 , _attachPoint select 1,_zc]];
					_zc = _zc - 2;
					sleep 0.1;
				};
				deletevehicle _x;
				/*
				ropeUnwind [ _x, 3, 0];
				_attachPoint = _ropes select _forEachIndex;
				_zc = -22;
				while { _zc > -50 } do
				{
					_x attachTo [_heli, [_attachPoint select 0 , _attachPoint select 1,_zc]];
					_zc = _zc - 2;
					sleep 0.1;
				};
				deletevehicle _x;
				*/
			} foreach _actualRopes;
		};

		case 9:			//(MK) Rope extraction: a hover 25 m over the point; everyone of the side on foot within 30 m winched up
		{
			//(MK) "Fast Rope Pos" (MCCMK_fnc_heliRopePos), at the Evac's Hover height
			[_heli, [_pos select 0, _pos select 1, 0], ((missionNamespace getVariable ["MCCMK_evacHover", 20]) max 5) min 50, _current] call MCCMK_fnc_heliRopePos;
			if !(call _current) exitWith {};
			[_heli, true] call MCCMK_fnc_heliDoorsAll;	//(MK) doors open while they're lifted (shut after the cases, as the others)
			_heli globalChat "Golf 1 in position - ropes down, get ready to be lifted";
			private _sd = side group (driver _heli);
			private _us = allUnits select {alive _x && {vehicle _x == _x} && {(_x distance2D _heli) < 30} && {[_sd, side group _x] call BIS_fnc_sideIsFriendly}};
			if (call MCCMK_ropeHarness) then {
				[_us, _heli] spawn MCCMK_fnc_ropeSquadUp;
				private _t = time + 240;
				waitUntil {sleep 2; !alive _heli || {!(call _current)} || {time > _t} || {(_us findIf {alive _x && {!((vehicle _x) isEqualTo _heli)}}) < 0}};
			} else {
				// (Ladder, or Advanced Rappelling not there: placed aboard - no rope physics without it)
				{if (([_heli] call MCCMK_seatsFree) > 0) then {[_x, _heli, "in"] remoteExec ["MCCMK_fnc_sarSeat", _x]; sleep 1}} forEach _us;
			};
			_heli flyInHeight _height;
		};
		case 6:			//Precise Landing
		{
			//(MK) carried over the point and held at the Hover height, then lowered straight down (2
			// m/s) and let go at 2 m.
			private _hovL = (missionNamespace getVariable ["MCCMK_evacHover", 20]) max 5;
			[_heli, [_pos select 0, _pos select 1, 0], _hovL, _current] call MCCMK_fnc_heliHoverAtMove;	//(MK) the pilot ordered at the spot
			if !(call _current) exitWith {};
			while {_hovL > 2 && {call _current} && {alive _heli}} do {
				_hovL = (_hovL - 1) max 2;
				_heli setVariable ["MCCMK_holdSpot", [(_heli getVariable ["MCCMK_holdSpot", [objNull, 0]]) select 0, _hovL], true];
				sleep 0.5;
			};
			sleep 2;
			[_heli] remoteExec ["MCCMK_fnc_heliHold", _heli];
			if !(call _current) exitWith {};
			_heli setVelocity [0,0,0];

			sleep 0.1;
			_heli flyInHeight 1;
			sleep 2;

			[_heli,true] spawn MCC_fnc_heliOpenCloseDoor;

			_timeOut = time + 10;
			waitUntil { sleep 1; (count (assignedCargo _heli) == 0) || (time > _timeOut)  || (!alive _heli) || (!alive (driver _heli)) || !(call _current)};	//(MK) a newer order
			sleep 3;
		};
	};

	//Close doors (MK: not after a landing - they shut as it takes off, MCCMK_fnc_heliDoorWatch)
	if (!(_heli getVariable ["MCCMK_doorWatch", false]) && {!(_landing in [3, 10, 11])}) then {[_heli, false] call MCCMK_fnc_heliDoorsAll};	//(MK) a water landing keeps its ramp open; Helocasting until its next order

	//Do we have a return trip (only when it carried passengers when the order was given)
	if (count _cargoUnits > 0 && {call _current}) then
	{
		private _crew = [];
		private _empty = false;
		//Wait until it is actually down before checking for passengers: the land command does not wait, and the time limit
		//must not start while it is still descending.
		if (_landing in [0, 1, 4, 6]) then {
			private _t = time + 120;
			waitUntil {sleep 1; isTouchingGround _heli || {((getPosATL _heli) select 2) < 2} || {time > _t} || {!alive _heli} || {!alive driver _heli} || {!(call _current)}};
			_heli vehicleChat "Landed - leaving once all passengers are out";
			if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_evacMove", "order %1: down at %2 (%3 m above ground)", [_orderId, mapGridPosition _heli, round ((getPosATL _heli) select 2)]] call MCC_fnc_log};
		};
		//Leave as soon as every passenger is out. No time limit: if nobody gets out it stays (until a new order).
		waitUntil
		{
			sleep 1;
			_empty = (_cargoUnits findIf {alive _x && {vehicle _x == _heli}}) < 0;
			_empty || (!alive _heli) || (!alive (driver _heli)) || !(call _current);
		};

		if (_empty && (!isnil "_startPos") && {call _current} && {!(_landing in [1, 11])}) then
		{
			if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_evacMove", "order %1: passengers out - returning to its start at %2", [_orderId, mapGridPosition _startPos]] call MCC_fnc_log};
			_heli vehicleChat "Passengers out - returning to base";
			[[_startPos], _height, 1, [netid _heli,_heli]] remoteExec ["MCC_fnc_evacMove", _heli, false];
		};
	};
};