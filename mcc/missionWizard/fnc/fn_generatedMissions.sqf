params [["_mode", "", [""]], ["_args", []]];
if (!isServer) exitWith {[_mode, _args] remoteExec ["MCC_fnc_generatedMissions", 2]};

private _registry = missionNamespace getVariable "MCC_generatedMissions";
if (isNil "_registry") then {_registry = createHashMap; missionNamespace setVariable ["MCC_generatedMissions", _registry]};

private _isPlayerThing = {
	params ["_o"];
	if (_o isEqualType grpNull) exitWith {(units _o) findIf {isPlayer _x} >= 0};
	isPlayer _o || {(crew _o) findIf {isPlayer _x} >= 0} || {(units group _o) findIf {isPlayer _x} >= 0 && {_o isKindOf "CAManBase"}}
};
private _publish = {
	MCC_generatedMissionsList = (values _registry select {_x getOrDefault ["done", false]}) apply {[_x get "id", _x get "name", _x get "timeText"]};
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
			["snapZones", +(missionNamespace getVariable ["MCC_zones_numbers", []])]
		]];
	};

	case "finish": {
		_args params ["_id", ["_name", ""], ["_tasks", []]];
		private _r = _registry getOrDefault [_id, createHashMap];
		if (count _r == 0) exitWith {};
		private _groups = (allGroups - (_r get "snapGroups")) select {!([_x] call _isPlayerThing)};
		private _objects = ((allMissionObjects "") - (_r get "snapObjects")) select {!([_x] call _isPlayerThing)};
		_r set ["groups", _groups];
		_r set ["objects", _objects];
		_r set ["markers", allMapMarkers - (_r get "snapMarkers")];
		_r set ["mines", allMines - (_r get "snapMines")];
		_r set ["zones", ((missionNamespace getVariable ["MCC_zones_numbers", []]) - (_r get "snapZones")) apply {str _x}];
		_r set ["tasks", _tasks];
		{_r deleteAt _x} forEach ["snapGroups", "snapObjects", "snapMarkers", "snapMines", "snapZones"];
		_r set ["name", [_name, _id] select (_name == "")];
		_r set ["timeText", [daytime, "HH:MM"] call BIS_fnc_timeToString];
		_r set ["done", true];
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
				private _groups = (_r getOrDefault ["groups", []]) + (allGroups select {((_x getVariable ["GAIA_ZONE_INTEND", []]) param [0, ""]) in _zones});
				_groups = (_groups arrayIntersect _groups) select {!isNull _x && {!([_x] call _isPlayerThing)}};
				private _n = 0;
				{
					private _grp = _x;
					{
						private _v = vehicle _x;
						if (_v != _x && {(crew _v) findIf {isPlayer _x} < 0}) then {deleteVehicle _v};
						deleteVehicle _x;
						_n = _n + 1;
					} forEach units _grp;
					deleteGroup _grp;
				} forEach _groups;
				{if (!isNull _x && {!([_x] call _isPlayerThing)}) then {deleteVehicle _x}} forEach ((_r getOrDefault ["objects", []]) + (_r getOrDefault ["mines", []]));
				{deleteMarker _x} forEach (_r getOrDefault ["markers", []]);

				{
					private _zn = parseNumber _x;
					if (_zn > 0 && {!isNil "mcc_zone_pos"} && {!isNil "mcc_zone_size"}) then {
						mcc_zone_pos set [_zn, [-5000,-5000,0]];
						mcc_zone_size set [_zn, [1,1]];
						deleteMarker _x;
						deleteMarker format ["LABEL_%1", _x];
						[[_x], {params ["_m"]; deleteMarkerLocal _m; deleteMarkerLocal format ["LABEL_%1", _m]}] remoteExec ["call", 0];
					};
				} forEach _zones;
				if (!isNil "mcc_zone_pos") then {publicVariable "mcc_zone_pos"; publicVariable "mcc_zone_size"};
				{if (_x call BIS_fnc_taskExists) then {_x call BIS_fnc_deleteTask}} forEach (_r getOrDefault ["tasks", []]);
				["INFO", "MCC_fnc_generatedMissions", "deleted %1 (%2): %3 units, %4 groups", [_x, _r get "name", _n, count _groups]] call MCC_fnc_log;
				_registry deleteAt _x;
			};
		} forEach _ids;
		call _publish;
	};
};
