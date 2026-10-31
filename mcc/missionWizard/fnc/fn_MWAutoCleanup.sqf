if (!isServer) exitWith {};
private _people = {
	private _p = [];
	{_p append ((units group _x) select {alive _x})} forEach (allPlayers - (entities "HeadlessClient_F"));
	_p arrayIntersect _p
};
private _watched = {
	params ["_o", "_ppl"];
	private _end = (getPosASL _o) vectorAdd [0, 0, 1];
	(_ppl findIf {
		private _d = _x distance _o;
		(_d < 50) || {(_d < (viewDistance max 500)) && {private _rd = _x getRelDir _o; (_rd < 70) || {_rd > 290}} && {([_x, "VIEW", _o] checkVisibility [eyePos _x, _end]) > 0}}
	}) >= 0
};
private _seen = {
	params ["_posASL", "_ppl", "_dist"];
	(_ppl findIf {
		private _d = _x distance2D _posASL;
		(_d < _dist) || {(_d < (viewDistance max 500)) && {([_x, "VIEW"] checkVisibility [eyePos _x, _posASL]) > 0}}
	}) >= 0
};
private _forget = {
	params ["_v"];
	_v setVariable ["MCC_seized", true, true];
	_v setVariable ["MCC_MWid", ""];
	{_y set ["objects", (_y getOrDefault ["objects", []]) - [_v]]} forEach (missionNamespace getVariable ["MCC_generatedMissions", createHashMap]);
	if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_MWAutoCleanup", "%1 at %2 seized by the players - kept", [typeOf _v, mapGridPosition _v]] call MCC_fnc_log};
};

while {true} do {
	sleep 30;
	private _reg = missionNamespace getVariable ["MCC_generatedMissions", createHashMap];
	private _ppl = call _people;
	private _bodiesT = (missionNamespace getVariable ["MCC_cleanupBodies", 20]) * 60;
	private _wrecksT = (missionNamespace getVariable ["MCC_cleanupWrecks", 60]) * 60;
	private _dist = missionNamespace getVariable ["MCC_cleanupDistance", 1000];
	private _wait = (missionNamespace getVariable ["MCC_cleanupWait", 5]) * 60;
	private _backstop = (missionNamespace getVariable ["MCC_cleanupBackstop", 60]) * 60;
	private _removed = [0, 0];
	private _objTargets = ((allMissionObjects "MCC_ModuleObjective_FCurator") apply {_x getVariable ["AttachObject_object", objNull]}) + (missionNamespace getVariable ["MCC_MWObjectiveItems", []]);

	{
		private _id = _x;
		private _r = _y;
		if (_r getOrDefault ["done", false]) then {
			private _zones = _r getOrDefault ["zones", []];
			{
				private _g = _x;
				if ((_g getVariable ["MCC_MWReinforcement", false]) && {(((_g getVariable ["GAIA_ZONE_INTEND", []]) param [0, ""]) in _zones)} && {((units _g) findIf {isPlayer _x}) < 0}) then {
					{_x setVariable ["MCC_MWid", _id]; if (vehicle _x != _x) then {(vehicle _x) setVariable ["MCC_MWid", _id]; (vehicle _x) setVariable ["MCC_hadCrew", true]}} forEach (units _g);
					(_r get "groups") pushBackUnique _g;
				};
			} forEach allGroups;
		};
	} forEach _reg;

	{
		private _e = _x;
		if !(_e isKindOf "CAManBase") then {
			if (alive _e && {((crew _e) findIf {_x in _ppl}) >= 0}) exitWith {[_e] call _forget};
			private _since = -1;
			if (!alive _e) then {
				_since = _e getVariable ["MCC_wreckSince", -1];
				if (_since < 0) then {_since = time; _e setVariable ["MCC_wreckSince", _since]};
			} else {
				if (({alive _x} count (crew _e)) > 0) then {
					_e setVariable ["MCC_hadCrew", true];
					_e setVariable ["MCC_crewGroup", group ((crew _e select {alive _x}) select 0)];
					_e setVariable ["MCC_emptySince", -1];
				} else {
					private _cg = _e getVariable ["MCC_crewGroup", grpNull];
					if ((_e getVariable ["MCC_hadCrew", false]) && {isNull _cg || {((units _cg) findIf {alive _x}) < 0}}) then {
						_since = _e getVariable ["MCC_emptySince", -1];
						if (_since < 0) then {_since = time; _e setVariable ["MCC_emptySince", _since]};
					};
				};
			};
			if (_since >= 0 && {_wrecksT > 0} && {(time - _since) >= _wrecksT} && {!([_e, _ppl] call _watched)}) then {
				{if (!alive _x) then {deleteVehicle _x}} forEach (crew _e);
				deleteVehicle _e;
				_removed set [1, (_removed select 1) + 1];
			};
		} else {
			if (!alive _e) then {
				private _since = _e getVariable ["MCC_deadSince", -1];
				if (_since < 0) then {_since = time; _e setVariable ["MCC_deadSince", _since]};
				if (_bodiesT > 0 && {(time - _since) >= _bodiesT} && {!([_e, _ppl] call _watched)}) then {
					{deleteVehicle _x} forEach (nearestObjects [_e, ["WeaponHolderSimulated"], 3]);
					deleteVehicle _e;
					_removed set [0, (_removed select 0) + 1];
				};
			};
		};
	} forEach ((allDeadMen + vehicles) select {!(_x getVariable ["MCC_seized", false]) && {(_x getVariable ["MCC_MWid", ""]) != ""} && {!(_x in _objTargets)}});

	private _toDelete = [];
	{
		private _id = _x;
		private _r = _y;
		private _tids = _r getOrDefault ["taskIds", []];
		if ((_r getOrDefault ["done", false]) && {count _tids > 0}) then {
			private _fin = _r getOrDefault ["finishedAt", -1];
			if (_fin < 0 && {(_tids findIf {(_x call BIS_fnc_taskExists) && {!((toUpper (_x call BIS_fnc_taskState)) in ["SUCCEEDED", "FAILED", "CANCELED", "CANCELLED"])}}) < 0}) then {
				_fin = time;
				_r set ["finishedAt", _fin];
				if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_MWAutoCleanup", "%1 (%2) finished - waiting for the players to move on", [_id, _r get "name"]] call MCC_fnc_log};
			};
			if (_fin >= 0 && {missionNamespace getVariable ["MCC_cleanupMissions", true]}) then {
				private _ctr = _r getOrDefault ["center", []];
				private _points = ((_r get "groups") select {!isNull _x && {alive leader _x}}) apply {eyePos (leader _x)};
				if (count _ctr >= 2) then {_points pushBack ((AGLToASL [_ctr select 0, _ctr select 1, 0]) vectorAdd [0, 0, 2])};
				if ((_points findIf {[_x, _ppl, _dist] call _seen}) >= 0) then {
					_r set ["clearSince", -1];
				} else {
					if ((_r getOrDefault ["clearSince", -1]) < 0) then {_r set ["clearSince", time]};
				};
				private _cs = _r getOrDefault ["clearSince", -1];
				if (_cs >= 0 && {(time - _cs) >= _wait}) then {
					_toDelete pushBack _id;
				} else {
					if (_backstop > 0 && {(time - _fin) >= _backstop}) then {
						{
							private _g = _x;
							if (!isNull _g && {((units _g) findIf {isPlayer _x}) < 0}) then {
								{
									if !([_x, _ppl] call _watched) then {
										private _v = vehicle _x;
										if (_v != _x && {!(_v getVariable ["MCC_seized", false])} && {((crew _v) findIf {_x in _ppl}) < 0}) then {deleteVehicle _v};
										deleteVehicle _x;
									};
								} forEach (units _g);
							};
						} forEach (_r get "groups");
						{
							if (!isNull _x && {!(_x getVariable ["MCC_seized", false])} && {!([_x, _ppl] call _watched)}) then {deleteVehicle _x};
						} forEach (_r getOrDefault ["objects", []]);
						private _left = ((_r getOrDefault ["objects", []]) select {!isNull _x && {!(_x getVariable ["MCC_seized", false])}}) + ((_r get "groups") select {!isNull _x && {count (units _x) > 0} && {((units _x) findIf {isPlayer _x}) < 0}});
						if (_left isEqualTo [] && {((_r getOrDefault ["hidden", []]) findIf {!isNull _x && {[_x, _ppl] call _watched}}) < 0}) then {_toDelete pushBack _id};
					};
				};
			};
		};
	} forEach _reg;

	{
		if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_MWAutoCleanup", "cleaning up finished mission %1", [_x]] call MCC_fnc_log};
		["delete", [_x]] call MCC_fnc_generatedMissions;
	} forEach _toDelete;
	if ((_removed select 0) + (_removed select 1) > 0 && {missionNamespace getVariable ["MCC_debug", false]}) then {
		["DEBUG", "MCC_fnc_MWAutoCleanup", "removed %1 bodies and %2 wrecks/empty vehicles", _removed] call MCC_fnc_log;
	};
};
