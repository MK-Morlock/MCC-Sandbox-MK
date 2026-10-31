/*================================================================== MCC_fnc_FLGenerate ==================================================================
	Front Lines generator - SERVER.
	MCC 4s Front Lines dialog was never finished by its author (it drew the line and stopped). This builds the enemy defensive
	line the dialogs options describe, using MCCs existing pieces:
		compositions (MCC_fnc_objectMapper), group spawning (MCC_fnc_spawnGroup / MCC_fnc_spawnVehicle), roadblocks
		(MCC_fnc_buildRoadblock), garrisons (MCC_fnc_garrison), minefields (MCC_fnc_mineSingle), artillery (MCC_fnc_MWSpawnStatic)
		and a GAIA zone (MCC_fnc_MWUpdateZone) rotated along the line.

	Layout, measured from the drawn line (the front is the side the mission maker clicked):
		Obstacle belt   in front        minefields (and wire)
		Band 1 main     0 .. 20% depth  strongpoints every 150-250 m, infantry defending them, sandbags/wire, roadblocks on roads
		Band 2 support  20 .. 55%       vehicles, armour (hold in the GAIA zone)
		Band 3 rear     55 .. 100%      artillery, reserves (patrol the GAIA zone)
		Deep only       ~60%            a second, thinner fallback line of strongpoints

	<IN>	0: ARRAY  line start
			1: ARRAY  line end
			2: ARRAY  a point on the side the enemy will attack from (the front)
			3: STRING defending faction
			4: ARRAY  [difficulty 0-2, vehicles 0/1/2, armor 0/1/2, artillery 0-3, minefields 0/1/2, minefield markers 0/1,
			           fortifications 0/1/2, fortification markers 0/1, markers 0/1, depth 0-2, task 0/1,
			           attack starts 0 = player near (max 15 min) / 1 = immediately / 2-7 = after 2,5,10,15,20,30 min,
			           reinforcements 0 none / 1 aerial / 2 motorized / 3 random,
			           reinforce when 0 = a player is near (MCC default) / 1 = always]
			5: STRING attacking faction ( = none)
			6: OBJECT the mission maker (for messages)
=========================================================================================================================================================*/
#define FL_MAX_LENGTH 3000

if (!isServer) exitWith {};
params [
	["_A", [0,0,0], [[]]],
	["_B", [0,0,0], [[]]],
	["_frontPoint", [0,0,0], [[]]],
	["_faction", "", [""]],
	["_opts", [], [[]]],
	["_attFaction", "", [""]],
	["_caller", objNull, [objNull]]
];
_opts params [["_diff",1],["_vehOpt",2],["_armorOpt",2],["_artillery",3],["_mineOpt",2],["_mineMarkers",0],["_fortOpt",2],["_fortMarkers",0],["_markers",0],["_depthIdx",1],["_taskOpt",1],["_attackStart",0],["_reinforcement",0],["_reinfWait",0]];

private _say = {
	params ["_text"];
	if (!isNull _caller) then {[format ["<t size='0.9' color='#E2EEE0'>%1</t>", _text],0,0.85,6,0.5,0,4] remoteExec ["BIS_fnc_dynamicText", _caller]};
	["INFO", "MCC_fnc_FLGenerate", "%1", [_text]] call MCC_fnc_log;
};
private _pick = {params ["_v"]; if (_v == 2) then {random 1 < 0.5} else {_v == 1}};	//Disabled / Enabled / Random

if (missionNamespace getVariable ["MCC_FLGenerating", false]) exitWith {["A front line is already being generated"] call _say};
if (_faction == "") exitWith {["Front Lines: no faction selected"] call _say};
MCC_FLGenerating = true;

//------------------------------------------------------------ Geometry ------------------------------------------------------------
_A = [_A select 0, _A select 1, 0];
_B = [_B select 0, _B select 1, 0];
private _len = _A distance2D _B;
private _u = (_B vectorDiff _A) vectorMultiply (1 / (_len max 1));		//along the line
private _C = _A vectorAdd (_u vectorMultiply (_len / 2));

//Cap the length around the centre
if (_len > FL_MAX_LENGTH) then {
	[format ["Front line shortened from %1 m to %2 m (maximum). Build longer fronts from several lines.", round _len, FL_MAX_LENGTH]] call _say;
	_len = FL_MAX_LENGTH;
	_A = _C vectorDiff (_u vectorMultiply (_len / 2));
	_B = _C vectorAdd (_u vectorMultiply (_len / 2));
};

private _n = [-(_u select 1), _u select 0, 0];							//perpendicular
private _sideDot = ((_frontPoint vectorDiff _C) vectorDotProduct _n);
private _front = if (_sideDot >= 0) then {_n} else {_n vectorMultiply -1};	//towards the attacker
private _back = _front vectorMultiply -1;
private _lineDir = _A getDir _B;
private _frontDir = _C getDir (_C vectorAdd (_front vectorMultiply 100));

private _depth = [600, 1500, 3000] select ((_depthIdx max 0) min 2);
private _mainDepth = (_depth * 0.2) max 150;
private _supportEnd = _depth * 0.55;

//Position at distance _t along the line and _d behind it (negative = in front)
private _at = {params ["_t","_d"]; (_A vectorAdd (_u vectorMultiply _t)) vectorAdd (_back vectorMultiply _d)};
//A dry, not too steep spot near _p ([] if none)
private _land = {
	params ["_p", ["_r", 60]];
	private _s = [_p, 0, _r, 4, 0, 0.35, 0, [], [[0,0,0],[0,0,0]]] call BIS_fnc_findSafePos;
	if ((_s select 0) == 0 && {(_s select 1) == 0}) exitWith {[]};
	_s = [_s select 0, _s select 1, 0];
	if (surfaceIsWater _s) exitWith {[]};
	_s
};

//------------------------------------------------------------ Faction data ------------------------------------------------------------
private _sideNr = [_faction] call MCC_fnc_factionSide;
private _defSide = [_sideNr] call BIS_fnc_sideType;
[_faction] call MCC_fnc_createConfigs;
[_faction, _defSide] call MCC_fnc_MWCreateUnitsArray;

private _infGroups = +(missionNamespace getVariable ["MCC_MWGroupArrayMen", []]);
private _infUnits = ([[_faction, "soldier", "men"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry) apply {_x select 0};
private _cars = (missionNamespace getVariable ["MCC_MWunitsArrayCar", []]) apply {_x select 1};
private _armour = (missionNamespace getVariable ["MCC_MWunitsArrayArmored", []]) apply {_x select 1};
if (_infGroups isEqualTo [] && {_infUnits isEqualTo []}) exitWith {
	MCC_FLGenerating = false;
	[format ["Front Lines: faction %1 has no infantry to spawn", _faction]] call _say;
};

private _skill = {
	params ["_grp"];
	{
		_x setSkill ["aimingspeed", missionNamespace getVariable ["MCC_AI_Aim",0.1]];
		_x setSkill ["aimingaccuracy", missionNamespace getVariable ["MCC_AI_Aim",0.1]];
		_x setSkill ["aimingshake", missionNamespace getVariable ["MCC_AI_Aim",0.1]];
		_x setSkill ["spotdistance", missionNamespace getVariable ["MCC_AI_Spot",0.3]];
		_x setSkill ["spottime", missionNamespace getVariable ["MCC_AI_Spot",0.3]];
		_x setSkill ["commanding", missionNamespace getVariable ["MCC_AI_Command",0.5]];
		_x setSkill ["general", missionNamespace getVariable ["MCC_AI_Skill",0.5]];
	} forEach units _grp;
	{_x addCuratorEditableObjects [units _grp, true]} forEach allCurators;
};
//Spawn one infantry group of _groups/_units at _p for _sideX
private _spawnInf = {
	params ["_p", "_sideX", "_groups", "_units"];
	private _grp = grpNull;
	if (count _groups > 0) then {
		_grp = [_p, _sideX, call compile ((selectRandom _groups) select 2), [], [], [0.1, missionNamespace getVariable ["MCC_AI_Skill",0.5]]] call MCC_fnc_spawnGroup;
	} else {
		private _types = [_units, 4 + floor random 3] call MCCMK_fnc_buildSquad;
		_grp = [_p, _sideX, _types] call MCC_fnc_spawnGroup;
	};
	if (!isNull _grp) then {[_grp] call _skill};
	_grp
};
private _marker = {
	params ["_p", "_type", "_text", ["_shape","ICON"], ["_size",[1,1]], ["_dir",0]];
	private _m = createMarker [format ["MCC_FL_%1", ["MCC_FLMarkerCounter",1] call BIS_fnc_counter], _p];
	_m setMarkerShape _shape;
	if (_shape == "ICON") then {_m setMarkerType _type} else {_m setMarkerBrush "DiagGrid"; _m setMarkerSize _size; _m setMarkerDir _dir};
	_m setMarkerColor "ColorRed";
	_m setMarkerText _text;
	MCC_FLMarkers = (missionNamespace getVariable ["MCC_FLMarkers", []]) + [_m];
	_m
};

["Generating the front line..."] call _say;

//Record what is created so it can be deleted again ("Delete Missions")
private _registryId = format ["FL_%1", ["MCC_generatedMissionCounter",1] call BIS_fnc_counter];
["start", [_registryId]] call MCC_fnc_generatedMissions;
["genStart", [_registryId]] call MCC_fnc_perfLog;
private _taskIds = [];

//------------------------------------------------------------ GAIA zone over the whole defended area ------------------------------------------------------------
private _zoneNumber = call MCC_fnc_nextZoneNumber;
[_zoneNumber, [_A, _len / 2, _depth / 2] call _at, [(_len / 2) + 50, _depth / 2, _lineDir - 90]] call MCC_fnc_MWUpdateZone;
sleep 1;

//------------------------------------------------------------ Band 1: strongpoints ------------------------------------------------------------
private _spacing = [250, 200, 150] select ((_diff max 0) min 2);
private _strongpoints = [];
private _fortify = [_fortOpt] call _pick;
private _t = _spacing / 2;
while {_t < _len} do {
	private _p = [[_t, 40 + random 40] call _at, 50] call _land;
	if !(_p isEqualTo []) then {
		[_p, 15, true] call MCC_fnc_hideTerrainObjectsArea;
		[_p, _frontDir + 180, selectRandom ["c_nestSmall","c_nestSmall","c_nestBig"]] call MCC_fnc_objectMapper;	//the nest compositions face their back at the given direction, so +180 points them at the attack
		private _grp = [_p, _defSide, _infGroups, _infUnits] call _spawnInf;
		if (!isNull _grp) then {[_grp, _p] call BIS_fnc_taskDefend};
		_strongpoints pushBack _p;
		if (_fortMarkers == 1) then {[_p, "mil_box", "Strongpoint"] call _marker};

		//Buildings right at the strongpoint get a few soldiers
		if (count (nearestObjects [_p, ["House"], 60]) > 0) then {[_p, 60, 0, 2, _faction, _defSide] call MCC_fnc_garrison};
	};
	_t = _t + _spacing;
	sleep 0.2;
};

//Sandbags and wire between strongpoints
if (_fortify) then {
	for "_k" from 0 to ((count _strongpoints) - 2) do {
		private _mid = ((_strongpoints select _k) vectorAdd (_strongpoints select (_k + 1))) vectorMultiply 0.5;
		{
			_x params ["_class", "_ahead", "_offsets"];
			{
				private _q = (_mid vectorAdd (_u vectorMultiply _x)) vectorAdd (_front vectorMultiply _ahead);
				if (!surfaceIsWater _q && {count (_q nearRoads 6) == 0} && {count (nearestTerrainObjects [_q, ["House","Building"], 6]) == 0}) then {
					private _o = createVehicle [_class, _q, [], 0, "CAN_COLLIDE"];
					_o setDir (_lineDir - 90);
					_o setVectorUp surfaceNormal _q;
					{_x addCuratorEditableObjects [[_o], false]} forEach allCurators;
				};
			} forEach _offsets;
		} forEach [["Land_BagFence_Long_F", 0, [-6, -3, 0, 3, 6]], ["Land_Razorwire_F", 25, [-8, 0, 8]]];
	};
};

//Roadblocks where roads cross the main line
private _roadblocks = [];
if (_fortify) then {
	for "_s" from 0 to _len step 25 do {
		private _p = [_s, 30] call _at;
		private _roads = _p nearRoads 20;
		if (count _roads > 0 && {count _roadblocks < 4} && {_roadblocks findIf {_x distance2D _p < 300} < 0}) then {
			private _spot = [_roads select 0] call MCC_fnc_roadblockSpot;
			if !(_spot isEqualTo []) then {
				private _rp = _spot select 0;
				private _rd = _spot select 1;
				//use the road direction closest to the front
				private _dir = if (abs (((_rd - _frontDir) + 540) mod 360 - 180) <= 90) then {_rd} else {_rd + 180};
				if ((_roadblocks findIf {_x distance2D _rp < 300}) < 0) then {
					[_rp, _dir, _faction, _defSide] call MCC_fnc_buildRoadblock;
					_roadblocks pushBack _rp;
					if (_fortMarkers == 1) then {[_rp, "mil_triangle", "Roadblock"] call _marker};
				};
			};
		};
	};
};

//------------------------------------------------------------ Obstacle belt: minefields ------------------------------------------------------------
private _minefields = 0;
if ([_mineOpt] call _pick) then {
	for "_s" from 60 to (_len - 60) step 160 do {
		private _p = [_s, -(70 + random 40)] call _at;
		if (!surfaceIsWater _p && {_strongpoints findIf {_x distance2D _p < 40} < 0}) then {
			private _kind = if (count (_p nearRoads 40) > 0) then {"at"} else {selectRandom ["ap","ap","apb"]};
			[_kind, "", _p, [30,30]] call MCC_fnc_mineSingle;
			_minefields = _minefields + 1;
			if (_mineMarkers == 1) then {[_p, "", "Minefield", "RECTANGLE", [30,30], 0] call _marker};
		};
		sleep 0.1;
	};
};

//------------------------------------------------------------ Band 2: vehicles and armour ------------------------------------------------------------
private _perKm = [1, 2, 3] select ((_diff max 0) min 2);
private _spawnVeh = {
	params ["_classes", "_count"];
	for "_k" from 1 to _count do {
		private _p = [[(_len * (_k - 0.5) / _count) + random 100 - 50, _mainDepth + random (_supportEnd - _mainDepth)] call _at, 80] call _land;
		if !(_p isEqualTo []) then {
			private _vc = selectRandom _classes;
			private _v = [[_p, _vc] call MCC_fnc_safeSpawnPos, _frontDir, _vc, _defSide] call MCC_fnc_spawnVehicle;
			private _grp = _v param [2, grpNull];
			if (!isNull _grp) then {
				[_grp] call _skill;
				{_x addCuratorEditableObjects [[_v select 0], true]} forEach allCurators;
				//Hold position. (They were GAIA NOFOLLOW groups in the lines zone; GAIA moved them all over the rear area.)
				_grp setBehaviour "AWARE";
				{doStop _x} forEach units _grp;
			};
		};
		sleep 0.3;
	};
};
if ([_vehOpt] call _pick && {count _cars > 0}) then {[_cars, (round (_perKm * _len / 1000)) max 1] call _spawnVeh};
if ([_armorOpt] call _pick && {count _armour > 0}) then {[_armour, (round (_perKm * _len / 2000)) max 1] call _spawnVeh};

//------------------------------------------------------------ Band 3: artillery and reserves ------------------------------------------------------------
if (_artillery > 0) then {
	{
		private _p = [[_len * _x, _supportEnd + (_depth - _supportEnd) * 0.5] call _at, 150] call _land;
		if !(_p isEqualTo []) then {
			[20, _p, 80, missionNamespace getVariable ["MCC_MWunitsArrayStatic",[]], 5, 10, _defSide, _artillery, _zoneNumber, _markers == 1] call MCC_fnc_MWSpawnStatic;
		};
	} forEach ([[0.5], [0.33, 0.66], [0.25, 0.5, 0.75]] select ((_depthIdx max 0) min 2));
};

private _reserves = (round ((count _strongpoints) * 0.3)) max 1;
for "_k" from 1 to _reserves do {
	private _p = [[_len * (_k - 0.5) / _reserves, _supportEnd + random (_depth - _supportEnd)] call _at, 100] call _land;
	if !(_p isEqualTo []) then {
		private _grp = [_p, _defSide, _infGroups, _infUnits] call _spawnInf;
		//Patrol 150 m around their own spot. (They were GAIA "MOVE" groups; GAIA sent them to far-off waypoints across the zone.)
		if (!isNull _grp) then {[_grp, _p, 150] call BIS_fnc_taskPatrol};
	};
	sleep 0.2;
};

//------------------------------------------------------------ Deep: fallback line ------------------------------------------------------------
private _fallback = 0;
if (_depthIdx == 2) then {
	private _t2 = _spacing;
	while {_t2 < _len} do {
		private _p = [[_t2, _depth * 0.6] call _at, 60] call _land;
		if !(_p isEqualTo []) then {
			[_p, 15, true] call MCC_fnc_hideTerrainObjectsArea;
			[_p, _frontDir + 180, "c_nestSmall"] call MCC_fnc_objectMapper;
			private _grp = [_p, _defSide, _infGroups, _infUnits] call _spawnInf;
			if (!isNull _grp) then {[_grp, _p] call BIS_fnc_taskDefend};
			_fallback = _fallback + 1;
			if (_fortMarkers == 1) then {[_p, "mil_box", "Fallback"] call _marker};
		};
		_t2 = _t2 + _spacing * 2;
		sleep 0.2;
	};
};

//------------------------------------------------------------ Optional attacking force ------------------------------------------------------------
private _attackers = [];
if (_attFaction != "") then {
	private _attSide = [[_attFaction] call MCC_fnc_factionSide] call BIS_fnc_sideType;
	if (_attSide == _defSide) exitWith {["Front Lines: the attacking faction is on the defenders' side - no attackers spawned"] call _say};
	[_attFaction] call MCC_fnc_createConfigs;
	private _aGroups = +(missionNamespace getVariable ["MCC_MWGroupArrayMen", []]);
	private _aUnits = ([[_attFaction, "soldier", "men"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry) apply {_x select 0};
	if (_aGroups isEqualTo [] && {_aUnits isEqualTo []}) exitWith {[format ["Front Lines: attacking faction %1 has no infantry", _attFaction]] call _say};

	private _count = (round ((count _strongpoints) * 0.7)) max 2;
	for "_k" from 1 to _count do {
		private _p = [[_len * (_k - 0.5) / _count, -(600 + random 300)] call _at, 100] call _land;
		if !(_p isEqualTo []) then {
			private _grp = [_p, _attSide, _aGroups, _aUnits] call _spawnInf;
			if (!isNull _grp) then {
				_grp setBehaviour "AWARE";
				_attackers pushBack _grp;
			};
		};
		sleep 0.2;
	};

	//When they advance: 0 = a player within 1.5 km of the line (at most 15 min), 1 = immediately, 2-7 = fixed delay
	[_attackers, _strongpoints, _C, _len, _attackStart] spawn {
		params ["_attackers", "_strongpoints", "_C", "_len", "_attackStart"];
		private _start = time;
		switch (true) do {
			case (_attackStart == 1): {};
			case (_attackStart >= 2): {
				private _delay = 60 * ([2,5,10,15,20,30] select ((_attackStart - 2) min 5));
				waitUntil {sleep 5; time - _start >= _delay};
			};
			default {
				waitUntil {sleep 5; (time - _start > 900) || {allPlayers findIf {alive _x && {_x distance2D _C < (_len / 2) + 1500}} >= 0}};
			};
		};
		{
			private _grp = _x;
			if (!isNull _grp && {count units _grp > 0}) then {
				private _target = [_strongpoints, leader _grp] call BIS_fnc_nearestPosition;
				private _wp = _grp addWaypoint [_target, 30];
				_wp setWaypointType "SAD";
				_wp setWaypointSpeed "NORMAL";
				_wp setWaypointFormation "WEDGE";
			};
		} forEach _attackers;
		["INFO", "MCC_fnc_FLGenerate", "front line attack started (%1 groups)", [count _attackers]] call MCC_fnc_log;
	};

	//Put the defenders group lists back (reinforcements and other MCC tools read them later)
	[_faction] call MCC_fnc_createConfigs;
};

//------------------------------------------------------------ Reinforcements ------------------------------------------------------------
//The Mission Generators reinforcements (MCC_fnc_MWreinforcement): they come in waves as the defenders are worn down
//(30 % / 60 % / 90 % losses), from behind the line.
if (_reinforcement in [1,2,3]) then {
	private _cond = [0.3];
	private _end = [0,0,0,0,0,0,0,1,1,1,2] call BIS_fnc_selectRandom;
	for "_k" from 1 to _end do {_cond set [_k, (_cond select (_k - 1)) + 0.3]};
	private _estimate = ((count _strongpoints) + _reserves + _fallback) * 6;
	[_reinforcement, _defSide, [_A, _len / 2, _depth / 2] call _at, [(_len / 2) + 50, _depth / 2, _lineDir - 90, true], _cond, _zoneNumber, _faction,
		(missionNamespace getVariable ["MCC_reinforcementWarning",true]), _estimate, _C getDir (_C vectorAdd (_back vectorMultiply 100)), _reinfWait == 0] spawn MCC_fnc_MWreinforcement;
};

//------------------------------------------------------------ Task ------------------------------------------------------------
if (_taskOpt == 1 && {count _strongpoints > 0}) then {
	private _owners = [east, west, resistance] select {[_x, _defSide] call BIS_fnc_sideIsEnemy};
	if (_owners isEqualTo []) then {_owners = [east, west, resistance] - [_defSide]};
	private _taskId = format ["MCC_FL_task_%1", ["MCC_FLTaskCounter",1] call BIS_fnc_counter];
	_taskIds pushBack _taskId;
	private _need = ceil ((count _strongpoints) * 0.8);
	[
		_owners, _taskId,
		[format ["Break through the enemy front line. Clear at least %1 of its %2 strongpoints (no enemy left within 75 m of them).", _need, count _strongpoints], "Break through the front line", ""],
		_C, "CREATED", 0, true, "attack"
	] call BIS_fnc_taskCreate;

	[_taskId, _strongpoints, _need, _defSide] spawn {
		params ["_taskId", "_strongpoints", "_need", "_defSide"];
		waitUntil {
			sleep 10;
			if !(_taskId call BIS_fnc_taskExists) exitWith {true};	//deleted
			private _cleared = {
				private _p = _x;
				(allUnits findIf {alive _x && {side group _x == _defSide} && {_x distance2D _p < 75}}) < 0
			} count _strongpoints;
			_cleared >= _need
		};
		if !(_taskId call BIS_fnc_taskExists) exitWith {};
		[_taskId, "SUCCEEDED"] call BIS_fnc_taskSetState;
		["INFO", "MCC_fnc_FLGenerate", "front line task %1 succeeded", [_taskId]] call MCC_fnc_log;
	};
};

["genEnd", ["front line finished"]] call MCC_fnc_perfLog;
MCC_FLGenerating = false;
[_registryId, format ["Front line %1 (%2)", mapGridPosition _C, _faction], _taskIds] spawn {
	params ["_id", "_name", "_tasks"];
	sleep 10;
	["finish", [_id, _name, _tasks]] call MCC_fnc_generatedMissions;
};
[format ["Front line done: %1 m long, %2 m deep. %3 strongpoints, %4 roadblocks, %5 minefields%6%7.",
	round _len, _depth, count _strongpoints, count _roadblocks, _minefields,
	if (_fallback > 0) then {format [", %1 fallback positions", _fallback]} else {""},
	(if (count _attackers > 0) then {format [", %1 attacking groups", count _attackers]} else {""}) + (if (_reinforcement in [1,2,3]) then {", reinforcements ready"} else {""})]] call _say;
