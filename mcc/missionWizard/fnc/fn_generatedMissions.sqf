params [["_mode", "", [""]], ["_args", []]];
if (!isServer) exitWith {[_mode, _args] remoteExec ["MCC_fnc_generatedMissions", 2]};

private _registry = missionNamespace getVariable "MCC_generatedMissions";
if (isNil "_registry") then {_registry = createHashMap; missionNamespace setVariable ["MCC_generatedMissions", _registry]};

private _isPlayerThing = {
	params ["_o"];
	if (_o isEqualType grpNull) exitWith {(units _o) findIf {isPlayer _x} >= 0};
	isPlayer _o || {(crew _o) findIf {isPlayer _x} >= 0} || {(units group _o) findIf {isPlayer _x} >= 0 && {_o isKindOf "CAManBase"}}
};
//(MK) what is MARKED as a mission's (MCCMK_fnc_genTag): its groups (marked, or holding a marked unit, or crewing a marked
// vehicle), its objects and mines, and its markers. Only this is ever removed with the mission - never anything else that
// happened to be created while it was being generated (anchors, a player's spawn, Zeus, another system's units).
private _marked = {
	params ["_id"];
	private _is = {(_this getVariable ["MCCMK_genId", ""]) isEqualTo _id};
	private _objs = (allMissionObjects "") select {_x call _is};
	private _mines = allMines select {_x call _is};
	private _veh = _objs select {_x isKindOf "AllVehicles" && {!(_x isKindOf "CAManBase")}};
	private _grps = allGroups select {(_x call _is) || {((units _x) findIf {_x call _is}) >= 0} || {((units _x) findIf {(vehicle _x) in _veh}) >= 0}};
	private _mk = ((missionNamespace getVariable ["MCCMK_genMarkers", createHashMap]) getOrDefault [_id, []]) select {(markerShape _x) != ""};
	[_grps, _objs, _mines, _mk]
};
private _publish = {
	//(MK) also its centre, objective tasks, groups and starting soldiers, and when it was made - for the console's Missions tab
	MCC_generatedMissionsList = (values _registry select {_x getOrDefault ["done", false]}) apply {[_x get "id", _x get "name", _x get "timeText", _x getOrDefault ["center", []], _x getOrDefault ["taskIds", []], _x getOrDefault ["groups", []], _x getOrDefault ["men0", 0], _x getOrDefault ["created", 0]]};
	publicVariable "MCC_generatedMissionsList";
};

switch (_mode) do {
	case "start": {
		_args params ["_id"];
		_registry set [_id, createHashMapFromArray [
			["id", _id],
			["snapGroups", allGroups],
			["snapObjects", allMissionObjects ""],
			["snapMarkers", allMapMarkers],
			["snapMines", allMines],
			["snapZones", +(missionNamespace getVariable ["MCC_zones_numbers", []])],
			["snapHidden", +(missionNamespace getVariable ["MCC_MWHiddenTerrain", []])]
		]];
	};

	case "finish": {
		_args params ["_id", ["_name", ""], ["_tasks", []], ["_center", [], [[]]], ["_pSide", sideUnknown, [west]]];
		private _r = _registry getOrDefault [_id, createHashMap];
		if (count _r == 0) exitWith {};
		//(MK) the mission's own, as marked when created (MCCMK_fnc_genTag) - not "everything new in the world", which
		//would take in whatever else is created meanwhile (anchors and their ropes, a player's spawn)
		([_id] call _marked) params ["_mGroups", "_mObjs", "_mMines", "_mMarkers"];
		private _groups = _mGroups select {!([_x] call _isPlayerThing)};
		private _objects = _mObjs select {!([_x] call _isPlayerThing)};
		// what was new in the world but not marked: left alone, and logged (with debug on, the types) - if something of the
		// mission's is left behind after a delete, this shows which path didn't mark it
		private _newG = (allGroups - (_r get "snapGroups")) - _groups;
		private _newO = ((allMissionObjects "") - (_r get "snapObjects")) - _objects - _mMines;
		_newO = _newO select {!(_x isKindOf "CAManBase") || {!((group _x) in _groups)}};
		if (count _newG > 0 || {count _newO > 0}) then {
			["INFO", "MCC_fnc_generatedMissions", "%1: %2 groups and %3 objects created while it was generating are not the mission's - left alone", [_id, count _newG, count _newO]] call MCC_fnc_log;
			if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_generatedMissions", "%1: not the mission's: %2", [_id, ((_newO select [0, 25]) apply {typeOf _x}) + ((_newG select [0, 10]) apply {str _x})]] call MCC_fnc_log};
		};
		//(MK) Anchors' own objects are never the mission's. Everything created between "start" and "finish" counts as
		// the mission's, and Anchors had just anchored the boats at mission start - its hidden rope helpers
		// (B_Quadbike_01_F, the "invisible quad bikes under the ground" in this list), anchors and end pads. Found from
		// every ANC_ variable on every ship (the anchor, its end pad, the rope, the helper) and the helpers' own mark.
		private _ancObjs = [];
		{
			private _sh = _x;
			{
				private _av = _sh getVariable [_x, objNull];
				if (_av isEqualType objNull && {!isNull _av}) then {_ancObjs pushBack _av};
			} forEach ((allVariables _sh) select {(toLower (_x select [0, 4])) == "anc_"});
		} forEach (vehicles select {_x isKindOf "Ship"});
		_objects = _objects select {!(_x in _ancObjs) && {!(_x getVariable ["ANC_isHelper", false])}};
		_r set ["groups", _groups];
		_r set ["men0", call {private _n = 0; {_n = _n + ({alive _x} count units _x)} forEach _groups; _n}];
		_r set ["created", time];
		//(MK) estimate against result (the generator's group estimate learns from the last five), and a typical mission's
		// rival groups for the console's Forces bars
		private _es = _r getOrDefault ["eSide", sideUnknown];
		if !(_es isEqualTo sideUnknown) then {
			private _aR = {(side _x) isEqualTo _es} count _groups;
			private _aC = {(side _x) isEqualTo civilian} count _groups;
			private _h = missionNamespace getVariable ["MCCMK_genHistory", []];
			_h pushBack [_r getOrDefault ["estR", 0], _aR, _r getOrDefault ["estC", 0], _aC];
			if (count _h > 5) then {_h deleteAt 0};
			missionNamespace setVariable ["MCCMK_genHistory", _h];
			MCCMK_genTypical = (selectMax (_h apply {_x select 1})) max 40;
			publicVariable "MCCMK_genTypical";
			["INFO", "MCC_fnc_generatedMissions", "%1: groups estimated %2 rival / %3 civilian (before correction), created %4 / %5", [_id, _r getOrDefault ["estR", 0], _r getOrDefault ["estC", 0], _aR, _aC]] call MCC_fnc_log;
		};
		_r set ["objects", _objects];
		_r set ["markers", _mMarkers];
		_r set ["mines", _mMines];
		_r set ["zones", ((missionNamespace getVariable ["MCC_zones_numbers", []]) - (_r get "snapZones")) apply {str _x}];
		_r set ["tasks", _tasks];
		_r set ["hidden", (missionNamespace getVariable ["MCC_MWHiddenTerrain", []]) - (_r getOrDefault ["snapHidden", []])];
		_r deleteAt "snapHidden";
		{_r deleteAt _x} forEach ["snapGroups", "snapObjects", "snapMarkers", "snapMines", "snapZones"];
		_r set ["name", [_name, _id] select (_name == "")];
		_r set ["timeText", [daytime, "HH:MM"] call BIS_fnc_timeToString];
		_r set ["done", true];
		private _tids = [];
		{
			private _tn = _x getVariable ["taskName", ""];
			if (_tn isEqualType []) then {_tids pushBackUnique (_tn select 0)};
		} forEach (_objects select {typeOf _x == "MCC_ModuleObjective_FCurator"});
		if (_tids isEqualTo []) then {_tids = +_tasks};
		_r set ["taskIds", _tids];
		if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_generatedMissions", "%1: %2 objective tasks to watch for the automatic cleanup %3", [_id, count _tids, _tids]] call MCC_fnc_log};
		private _zs = _r get "zones";
		private _live = _objects select {!isNull _x};
		_r set ["center", if (count _zs > 0) then {getMarkerPos (_zs select 0)} else {
			if (_live isEqualTo []) then {[]} else {private _s = [0, 0, 0]; {_s = _s vectorAdd (getPosATL _x)} forEach _live; _s vectorMultiply (1 / (count _live))}
		}];
		{_x setVariable ["MCC_MWid", _id]; if (({alive _x} count (crew _x)) > 0) then {_x setVariable ["MCC_hadCrew", true]}} forEach (_live select {_x isKindOf "AllVehicles"});
		{{_x setVariable ["MCC_MWid", _id]; if (vehicle _x != _x) then {(vehicle _x) setVariable ["MCC_MWid", _id]; (vehicle _x) setVariable ["MCC_hadCrew", true]}} forEach units _x} forEach _groups;
		if (isNil "MCC_autoCleanupRunning") then {MCC_autoCleanupRunning = true; [] spawn MCC_fnc_MWAutoCleanup};
		call _publish;
		["INFO", "MCC_fnc_generatedMissions", "recorded %1 (%2): %3 groups, %4 objects, %5 markers, %6 mines, zones %7", [_id, _r get "name", count _groups, count _objects, count (_r get "markers"), count (_r get "mines"), _r get "zones"]] call MCC_fnc_log;
		private _veh = _objects select {(_x isKindOf "LandVehicle") || {_x isKindOf "Air"} || {_x isKindOf "Ship"}};
		{{if (vehicle _x != _x) then {_veh pushBackUnique (vehicle _x)}} forEach units _x} forEach _groups;
		{
			private _c = configOf _x;
			private _odd = ((toLower getText (_c >> "displayName")) find "invisible") >= 0 || {((toLower typeOf _x) find "target") >= 0}
				|| {getText (_c >> "model") in ["", "\A3\Weapons_f\empty", "\A3\Weapons_F\empty.p3d"]} || {isObjectHidden _x};
			[["INFO", "WARN"] select _odd, "MCC_fnc_generatedMissions", "%1 vehicle: %2 (%3) model %4 side %5 at %6 height %7 m crew %8%9", [_id, typeOf _x, getText (_c >> "displayName"), getText (_c >> "model"), side _x, mapGridPosition _x, round ((getPosATL _x) select 2), (crew _x) apply {typeOf _x}, ["", " - INVISIBLE / TARGET?"] select _odd]] call MCC_fnc_log;
		} forEach _veh;
	};

	case "addObjects": {
		_args params [["_anchor", objNull, [objNull]], ["_objects", [], [[]]]];
		private _found = false;
		{
			private _r = _y;
			if ((_r getOrDefault ["done", false]) && {_anchor in (_r getOrDefault ["objects", []])}) exitWith {
				_r set ["objects", (_r get "objects") + _objects];
				_found = true;
				["INFO", "MCC_fnc_generatedMissions", "added %1 objects to %2 (%3)", [count _objects, _x, _r get "name"]] call MCC_fnc_log;
			};
		} forEach _registry;
		if (!_found) then {["WARN", "MCC_fnc_generatedMissions", "addObjects: no recorded mission has %1 - %2 objects not added", [_anchor, count _objects]] call MCC_fnc_log};
	};

	case "delete": {
		_args params ["_id"];
		private _ids = if (_id == "ALL") then {keys _registry} else {[_id]};
		{
			private _r = _registry getOrDefault [_x, createHashMap];
			if (count _r > 0 && {_r getOrDefault ["done", false]}) then {
				missionNamespace setVariable [format ["MCC_missionDeleted_%1", _x], true, true];
				private _zones = _r getOrDefault ["zones", []];
				//(MK) and anything marked as this mission's since it was recorded (an ambush, a camp, reinforcements created later)
				([_x] call _marked) params ["_lGroups", "_lObjs", "_lMines", "_lMarkers"];
				_r set ["objects", ((_r getOrDefault ["objects", []]) + _lObjs) select {!isNull _x}];
				_r set ["mines", ((_r getOrDefault ["mines", []]) + _lMines) select {!isNull _x}];
				_r set ["markers", (_r getOrDefault ["markers", []]) + (_lMarkers - (_r getOrDefault ["markers", []]))];
				private _groups = (_r getOrDefault ["groups", []]) + _lGroups + (allGroups select {((_x getVariable ["MCC_MWReinforcement", false]) && {((_x getVariable ["GAIA_ZONE_INTEND", []]) param [0, ""]) in _zones}) || {((_x getVariable ["MCC_MWReinforceZone", ""]) in _zones)}});
				// (MK) the mission's QRF vehicles, marked when they spawned - empty ones too (not one a player is in or seized)
				{deleteVehicle _x} forEach (vehicles select {((_x getVariable ["MCC_MWReinforceZone", ""]) in _zones) && {((crew _x) findIf {isPlayer _x}) < 0} && {!(_x getVariable ["MCC_seized", false])}});
				_groups = (_groups arrayIntersect _groups) select {!isNull _x && {!([_x] call _isPlayerThing)}};
				private _n = 0;
				{
					private _grp = _x;
					{
						private _v = vehicle _x;
						if (_v != _x && {(crew _v) findIf {isPlayer _x} < 0} && {!(_v getVariable ["MCC_seized", false])}) then {deleteVehicle _v};
						deleteVehicle _x;
						_n = _n + 1;
					} forEach units _grp;
					deleteGroup _grp;
				} forEach _groups;
				{if (!isNull _x && {!([_x] call _isPlayerThing)} && {!(_x getVariable ["MCC_seized", false])}) then {deleteVehicle _x}} forEach ((_r getOrDefault ["objects", []]) + (_r getOrDefault ["mines", []]));
				{deleteMarker _x} forEach (_r getOrDefault ["markers", []]);
				private _hid = _r getOrDefault ["hidden", []];
				if (count _hid > 0) then {
					private _others = [];
					{
						if !(_x in _ids) then {_others append ((_registry getOrDefault [_x, createHashMap]) getOrDefault ["hidden", []])};
					} forEach (keys _registry);
					private _builtOver = {
						params ["_h"];
						private _br = (((boundingBoxReal _h) select 2) * 0.5) max 2;
						((nearestObjects [getPos _h, [], _br]) findIf {(getObjectType _x) == 8 && {_x != _h} && {!isObjectHidden _x} && {!(_x isKindOf "AllVehicles")} && {!(_x isKindOf "Logic")} && {!(_x isKindOf "EmptyDetector")} && {!(_x isKindOf "WeaponHolder")} && {!(_x isKindOf "WeaponHolderSimulated")}}) >= 0
					};
					private _keptHidden = 0;
					{
						if (!isNull _x && {!(_x in _others)}) then {
							if ([_x] call _builtOver) then {_keptHidden = _keptHidden + 1} else {_x hideObjectGlobal false; _x allowDamage true};
						};
					} forEach _hid;
					if (_keptHidden > 0) then {["DEBUG", "MCC_fnc_generatedMissions", "%1: %2 map objects stay hidden - something has been built in their place", [_x, _keptHidden]] call MCC_fnc_log};
					MCC_MWHiddenTerrain = (missionNamespace getVariable ["MCC_MWHiddenTerrain", []]) - _hid;
				};

				{
					private _zn = parseNumber _x;
					if (_zn > 0 && {!isNil "mcc_zone_pos"} && {!isNil "mcc_zone_size"}) then {
						mcc_zone_pos set [_zn, [-5000,-5000,0]];
						mcc_zone_size set [_zn, [1,1]];
						deleteMarker _x;
						deleteMarker format ["LABEL_%1", _x];
						["call", [[_x], {params ["_m"]; deleteMarkerLocal _m; deleteMarkerLocal format ["LABEL_%1", _m]}], 0, false] call MCC_fnc_secRemote;
					};
				} forEach _zones;
				if (!isNil "mcc_zone_pos") then {publicVariable "mcc_zone_pos"; publicVariable "mcc_zone_size"};
				MCC_zones_numbers = (missionNamespace getVariable ["MCC_zones_numbers", []]) - (_zones apply {parseNumber _x});
				publicVariable "MCC_zones_numbers";
				{if (_x call BIS_fnc_taskExists) then {_x call BIS_fnc_deleteTask}} forEach (_r getOrDefault ["tasks", []]);
				["INFO", "MCC_fnc_generatedMissions", "deleted %1 (%2): %3 units, %4 groups", [_x, _r get "name", _n, count _groups]] call MCC_fnc_log;
				_registry deleteAt _x;
				private _gm = missionNamespace getVariable ["MCCMK_genMarkers", createHashMap];
				if (_gm isEqualType createHashMap) then {_gm deleteAt _x};
			};
		} forEach _ids;
		call _publish;
	};
};
