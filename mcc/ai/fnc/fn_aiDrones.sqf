if (!isServer) exitWith {};
private _active = [];
private _classCache = createHashMap;
private _tick = 0;

private _fnc_droneClass = {
	params ["_bp"];
	if (_bp in _classCache) exitWith {_classCache get _bp};
	private _cls = getText (configFile >> "CfgVehicles" >> _bp >> "assembleInfo" >> "assembleTo");
	if (_cls == "" || {!isClass (configFile >> "CfgVehicles" >> _cls)} || {getNumber (configFile >> "CfgVehicles" >> _cls >> "isUav") != 1}) then {_cls = ""};
	// (MK) only a drone with a camera is worth flying: a turret that is the UAV's gunner camera or has optics of its own.
	// Cargo and utility drones (the AL-6 Pelican) only have the driver's view - the operator keeps those packed.
	if (_cls != "") then {
		private _cv = configFile >> "CfgVehicles" >> _cls;
		private _tur = [_cls, false] call BIS_fnc_allTurrets;
		private _cam = (count _tur > 0) && {
			(getText (_cv >> "uavCameraGunnerPos") != "")
			|| {(_tur findIf {
				private _tc = [_cls, _x] call BIS_fnc_turretConfig;
				isClass (_tc >> "OpticsIn") || {getText (_tc >> "gunnerOpticsModel") != ""}
			}) >= 0}
		};
		if (!_cam) then {
			if (missionNamespace getVariable ["MCC_debug", false]) then {["INFO", "MCC_fnc_aiDrones", "%1 (from %2) has no camera - not launched", [_cls, _bp]] call MCC_fnc_log};
			_cls = "";
		};
	};
	_classCache set [_bp, _cls];
	_cls
};

private _fnc_pack = {
	params ["_e", "_restore", "_recharge"];
	private _d = _e get "drone";
	private _op = _e get "op";
	if (!isNull _d) then {
		{_d deleteVehicleCrew _x} forEach (crew _d);
		deleteVehicle _d;
	};
	if (!isNull (_e get "crew")) then {deleteGroup (_e get "crew")};
	if (!isNull _op) then {
		if (_restore && {alive _op} && {backpack _op == ""}) then {_op addBackpackGlobal (_e get "cls")};
		_op setVariable ["MCC_droneOut", false];
		if (_recharge) then {_op setVariable ["MCC_droneReadyAt", time + 900]};
	};
};

private _fnc_enemyPos = {
	params ["_op"];
	private _lead = leader group _op;
	private _t = _lead findNearestEnemy (getPosATL _op);
	if (isNull _t) exitWith {[]};
	private _k = _lead targetKnowledge _t;
	private _p = if (count _k > 6) then {_k select 6} else {getPosATL _t};
	[_p select 0, _p select 1, 0]
};

while {true} do {
	sleep 10;
	_tick = _tick + 1;
	private _on = missionNamespace getVariable ["MCC_aiDrones", true];

	private _playerSidesNow = [];	//(MK) for friendly drones' sightings
	{_playerSidesNow pushBackUnique (side group _x)} forEach allPlayers;
	{
		private _e = _x;
		private _d = _e get "drone";
		private _op = _e get "op";
		private _crew = _e get "crew";
		private _done = false;

		if (isNull _d || {!alive _d}) then {
			if (!isNull _op) then {_op setVariable ["MCC_droneOut", false]};
			if (!isNull _crew) then {_crew spawn {sleep 60; if (!isNull _this && {((units _this) findIf {alive _x}) < 0}) then {deleteGroup _this}}};
			_done = true;
		};
		if (!_done && {isNull _op || {!alive _op}}) then {
			_d setFuel 0;
			[_d, _crew] spawn {
				params ["_d", "_crew"];
				sleep 600;
				if (!isNull _d) then {{_d deleteVehicleCrew _x} forEach (crew _d); deleteVehicle _d};
				if (!isNull _crew) then {deleteGroup _crew};
			};
			if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_aiDrones", "operator lost - %1 cut out near %2", [typeOf _d, mapGridPosition _d]] call MCC_fnc_log};
			_done = true;
		};
		if (!_done && {((group _op) getVariable ["GAIA_CACHED_STAGE_1", false]) || {!simulationEnabled _op}}) then {
			[_e, true, false] call _fnc_pack;
			_done = true;
		};
		if (!_done && {(_e get "state") == "fly"} && {time > (_e get "end") || {!_on}}) then {
			if (_e get "air") then {
				_e set ["state", "return"];
				_e set ["t", time];
				{deleteWaypoint [_crew, 0]} forEach (waypoints _crew);
				_d doMove (getPosATL _op);
			} else {
				[_e, true, true] call _fnc_pack;
				_done = true;
			};
		};
		if (!_done && {(_e get "state") == "return"}) then {
			if ((_d distance2D _op) < 40 || {time > (_e get "t") + 90}) then {
				_d land "LAND";
				_e set ["state", "landing"];
				_e set ["t", time];
			} else {
				_d doMove (getPosATL _op);
			};
		};
		if (!_done && {(_e get "state") == "landing"}) then {
			if ((isTouchingGround _d && {speed _d < 1}) || {time > (_e get "t") + 120}) then {
				[_e, true, true] call _fnc_pack;
				_done = true;
			};
		};

		if (!_done && {(_e get "state") == "fly"}) then {
			private _target = [_op] call _fnc_enemyPos;
			if (count _target > 0) then {_e set ["mode", "scout"]} else {_e set ["mode", "circle"]};
			private _centre = if ((_e get "mode") == "scout") then {_target} else {
				if (_e get "air") then {getPosATL _op} else {_op getPos [150, getDir _op]}
			};
			_centre = [_centre select 0, _centre select 1, 0];
			if ((_centre distance2D (_e get "wp")) > 100) then {
				_e set ["wp", _centre];
				{deleteWaypoint [_crew, 0]} forEach (waypoints _crew);
				if (_e get "air") then {
					private _wp = _crew addWaypoint [_centre, 0];
					_wp setWaypointType "LOITER";
					_wp setWaypointLoiterType "CIRCLE_L";
					_wp setWaypointLoiterRadius 150;
				} else {
					_crew move _centre;
				};
			};

			private _seen = ((leader _crew) targets [true, 1500]) select {alive _x};
			// (MK) only a drone with a camera reveals players (a safeguard - one without a camera is never launched)
			if (!(_d getVariable ["MCCMK_droneCam", false])) then {_seen = []};
			if (count _seen > 0) then {
				private _side = side group _op;
				private _near = allGroups select {
					(side _x == _side)
					&& {!(_x getVariable ["MCC_droneGroup", false])}
					&& {alive leader _x}
					&& {!isPlayer leader _x}
					&& {((leader _x) distance2D _op) < 400}
				};
				{
					private _g = _x;
					{_g reveal [_x, 1]} forEach _seen;
					if ((behaviour leader _g) == "SAFE") then {_g setBehaviour "AWARE"};
				} forEach _near;
				//(MK) a friendly drone: its sightings given to the players of the sides friendly to it ("Friendly drone sightings")
				private _sm = missionNamespace getVariable ["MCC_aiDroneSightings", 1];
				if ((_e getOrDefault ["friendly", false]) && {_sm > 0}) then {
					private _sideCol = {params ["_t"]; switch (side group _t) do {case east: {[0.75, 0.1, 0.1]}; case west: {[0.1, 0.35, 0.8]}; case resistance: {[0.1, 0.6, 0.15]}; default {[0.6, 0.3, 0.7]}}};
					private _list = [];
					private _doneV = [];
					{
						private _v = vehicle _x;
						if !(_v in _doneV) then {
							_doneV pushBack _v;
							private _ic = getText (configOf _v >> "icon");
							if (isText (configFile >> "CfgVehicleIcons" >> _ic)) then {_ic = getText (configFile >> "CfgVehicleIcons" >> _ic)};
							if (_ic == "") then {_ic = "\A3\ui_f\data\map\vehicleicons\iconMan_ca.paa"};
							_list pushBack [_v, getPosATL _v, getDir _v, _ic, [_x] call _sideCol];
						};
					} forEach _seen;
					{
						private _ps = _x;
						if ((_ps getFriend _side) >= 0.6) then {[_list, _sm] remoteExec ["MCCMK_fnc_droneSightings", _ps]};
					} forEach _playerSidesNow;
				};
				if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_aiDrones", "%1 shared %2 sightings with %3 groups within 400 m", [typeOf _d, count _seen, count _near]] call MCC_fnc_log};
			};
		};

		if (_done) then {_e set ["gone", true]};
	} forEach _active;
	_active = _active select {!(_x getOrDefault ["gone", false])};

	if (_on && {_tick % 3 == 0}) then {
		private _playerSides = [];
		{_playerSides pushBackUnique (side group _x)} forEach allPlayers;
		private _offList = missionNamespace getVariable ["MCC_MWnoDroneMissions", []];
		{
			private _op = _x;
			private _bp = backpack _op;
			if (
				_bp != ""
				&& {!isPlayer _op}
				&& {vehicle _op == _op}
				&& {lifeState _op != "INCAPACITATED"}
				&& {simulationEnabled _op}
				&& {!(_op getVariable ["MCC_droneOut", false])}
				&& {time >= (_op getVariable ["MCC_droneReadyAt", 0])}
				&& {!isPlayer leader group _op}
				&& {side group _op != civilian}
				&& {!((group _op) getVariable ["GAIA_CACHED_STAGE_1", false])}
				&& {
					private _seenAt = (group _op) getVariable ["MCC_droneSeenAt", -1];
					if (_seenAt < 0) then {(group _op) setVariable ["MCC_droneSeenAt", time]; _seenAt = time};
					(time - _seenAt) >= 60
				}
				&& {
					//(MK) hostile to a player, or - "Friendly AI drones" - friendly to one
					private _sd = side group _op;
					((_playerSides findIf {(_x getFriend _sd) < 0.6}) >= 0)
					|| {(missionNamespace getVariable ["MCC_aiDronesFriendly", true]) && {(_playerSides findIf {(_x getFriend _sd) >= 0.6}) >= 0}}
				}
			) then {
				private _cls = [_bp] call _fnc_droneClass;
				private _mwid = (group _op) getVariable ["MCC_MWid", ""];
				if (_cls != "" && {!(_mwid in _offList)}) then {
					private _friendly = (_playerSides findIf {(_x getFriend (side group _op)) < 0.6}) < 0;	//(MK) no player is its enemy
					private _key = switch (true) do {
						case (_friendly): {format ["friendly_%1", side group _op]};	// its own one-at-a-time, apart from the enemy's
						case (_mwid isEqualType "" && {_mwid != ""}): {_mwid};
						default {format ["side_%1", side group _op]};
					};
					if ((_active findIf {(_x get "key") == _key}) < 0) then {
						private _mode = "";
						if (count ([_op] call _fnc_enemyPos) > 0) then {
							_mode = "scout";
						} else {
							private _roll = _op getVariable ["MCC_droneRollAt", -1];
							if (_roll < 0) then {
								_op setVariable ["MCC_droneRollAt", time + 900 + random 900];
							} else {
								if (time >= _roll) then {
									_op setVariable ["MCC_droneRollAt", time + 900 + random 900];
									if (random 1 < 0.5) then {_mode = "circle"};
								};
							};
						};
						if (_mode != "") then {
							private _isAir = _cls isKindOf "Air";
							private _p = _op getPos [3, getDir _op];
							removeBackpackGlobal _op;
							private _d = createVehicle [_cls, [_p select 0, _p select 1, 0], [], 0, ["NONE", "FLY"] select _isAir];
							if (_isAir) then {
								_d setPosATL [_p select 0, _p select 1, 15];
								_d flyInHeight (50 + random 30);
							};
							createVehicleCrew _d;
							private _crew = createGroup [side group _op, true];
							(crew _d) joinSilent _crew;
							if ((count crew _d) == 0) then {
								deleteVehicle _d;
								deleteGroup _crew;
								_op addBackpackGlobal _bp;
								_op setVariable ["MCC_droneReadyAt", time + 900];
							} else {
								_crew setVariable ["MCC_droneGroup", true, true];
								_d setVariable ["MCC_aiDrone", true, true];
								_d setVariable ["MCCMK_droneCam", true];	// launched only when it has a camera
								private _armed = ((magazinesAllTurrets _d) findIf {
									private _m = toLower (_x select 0);
									((_x select 2) > 0) && {(_m find "laser") < 0} && {(_m find "smoke") < 0} && {(_m find "flare") < 0}
								}) >= 0;
								_crew setCombatMode (["BLUE", "RED"] select _armed);
								_crew setBehaviour "AWARE";
								_op setVariable ["MCC_droneOut", true];
								_active pushBack (createHashMapFromArray [
									["op", _op], ["drone", _d], ["crew", _crew], ["key", _key], ["mode", _mode],
									["air", _isAir], ["state", "fly"], ["end", time + 600], ["cls", _bp], ["wp", [0, 0, 0]], ["t", time], ["friendly", _friendly]
								]);
								if (missionNamespace getVariable ["MCC_debug", false]) then {
									//(MK) a normal debug line: who launched what, and where it came from - the
									// operator's unit class and faction, his backpack and the drone it assembles into
									["INFO", "MCC_fnc_aiDrones", "%1 launched %2 (from backpack %3, armed %4, %5%12) near %6 | operator %7, faction %8 (%9), side %10, group %11", [name _op, _cls, _bp, _armed, _mode, mapGridPosition _op, typeOf _op, faction _op, getText (configFile >> "CfgFactionClasses" >> faction _op >> "displayName"), side group _op, groupId (group _op), ["", ", friendly"] select _friendly]] call MCC_fnc_log;
								};
							};
						};
					};
				};
			};
		} forEach allUnits;
	};
};
