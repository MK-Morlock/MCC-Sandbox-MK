params [["_mode", "", [""]], ["_args", []]];
if (!isServer) exitWith {};
if !((missionNamespace getVariable ["MCC_perfLog", false]) && {missionNamespace getVariable ["MCC_debug", false]}) exitWith {};

if (isNil "MCC_perfWrite") then {
	MCC_perfWrite = {
		params ["_src", "_msg", ["_fmt", []]];
		diag_log text format ["MCC [PERF] %1 | %2 | t=%3", _src, format ([_msg] + _fmt), time toFixed 1];
	};
};

private _counts = {
	[count allUnits, count allGroups, count vehicles, count (allMissionObjects "")]
};

private _snapshot = {
	params [["_withObjects", true]];
	private _players = (allPlayers - entities "HeadlessClient_F") select {alive _x};
	if (_players isEqualTo [] && {!isNull player}) then {_players = [player]};
	private _ref = _players param [0, objNull];
	private _near = if (isNull _ref) then {[]} else {(allUnits - allPlayers) select {_x distance _ref < 1500}};
	private _combat = {behaviour _x == "COMBAT"} count _near;
	private _moving = {speed _x > 1} count _near;
	private _awake = {simulationEnabled _x} count _near;
	private _gaia = {count (_x getVariable ["GAIA_ZONE_INTEND", []]) > 0} count allGroups;
	format ["fps %1 (min %2) | units %3 groups %4 vehicles %5 objects %6 | AI near %7 (awake %8, combat %9, moving %10) | GAIA groups %11 | scripts %12",
		round diag_fps, round diag_fpsMin, count allUnits, count allGroups, count vehicles, if (_withObjects) then {count (allMissionObjects "")} else {"-"},
		count _near, _awake, _combat, _moving, _gaia, diag_activeScripts]
};

switch (_mode) do {
	case "genStart": {
		_args params [["_label", "generation"]];
		private _c = call _counts;
		missionNamespace setVariable ["MCC_perfGen", [diag_tickTime, diag_tickTime, _c, _label, 1000]];
		["generation", "%1: START | %2", [_label, [true] call _snapshot]] call MCC_perfWrite;

		[] spawn {
			MCC_perfGenWorst = 1000; MCC_perfGenSlow = 0;
			while {count (missionNamespace getVariable ["MCC_perfGen", []]) > 0} do {
				MCC_perfGenWorst = MCC_perfGenWorst min diag_fpsMin;
				if (diag_fps < 15) then {MCC_perfGenSlow = MCC_perfGenSlow + 0.25};
				uiSleep 0.25;
			};
		};
	};

	case "genStage": {
		_args params [["_stage", "stage"]];
		private _g = missionNamespace getVariable ["MCC_perfGen", []];
		if (_g isEqualTo []) exitWith {};
		_g params ["_t0", "_tLast", "_c0", "_label"];
		private _c = call _counts;
		["generation", "%1: %2 took %3 s (total %4 s) | created +%5 units +%6 groups +%7 vehicles +%8 objects | worst fps so far %9 | %10",
			[_label, _stage, (diag_tickTime - _tLast) toFixed 2, (diag_tickTime - _t0) toFixed 1,
			(_c select 0) - (_c0 select 0), (_c select 1) - (_c0 select 1), (_c select 2) - (_c0 select 2), (_c select 3) - (_c0 select 3),
			round (missionNamespace getVariable ["MCC_perfGenWorst", 0]), [true] call _snapshot]] call MCC_perfWrite;
		_g set [1, diag_tickTime];
	};

	case "genEnd": {
		_args params [["_stage", "generator finished"], ["_follow", true]];
		["genStage", [_stage]] call MCC_fnc_perfLog;
		if (!_follow) exitWith {
			private _g = missionNamespace getVariable ["MCC_perfGen", []];
			if (count _g > 0) then {["generation", "%1: DONE | total %2 s | worst fps %3", [_g select 3, (diag_tickTime - (_g select 0)) toFixed 1, round (missionNamespace getVariable ["MCC_perfGenWorst", 0])]] call MCC_perfWrite};
			missionNamespace setVariable ["MCC_perfGen", []];
		};
		[] spawn {
			private _g = missionNamespace getVariable ["MCC_perfGen", []];
			if (_g isEqualTo []) exitWith {};
			private _last = count allUnits;
			for "_i" from 1 to 9 do {
				uiSleep 10;
				private _now = count allUnits;
				["genStage", [format ["+%1 s after the generator (units +%2 in the last 10 s)", _i * 10, _now - _last]]] call MCC_fnc_perfLog;
				_last = _now;
			};
			private _label = _g select 3;
			["generation", "%1: DONE | total %2 s | worst fps %3 | %4 s under 15 fps", [_label, (diag_tickTime - (_g select 0)) toFixed 1, round (missionNamespace getVariable ["MCC_perfGenWorst", 0]), missionNamespace getVariable ["MCC_perfGenSlow", 0]]] call MCC_perfWrite;
			missionNamespace setVariable ["MCC_perfGen", []];
		};
	};

	case "monitor": {
		if (missionNamespace getVariable ["MCC_perfMonitorRunning", false]) exitWith {};
		MCC_perfMonitorRunning = true;
		[_snapshot] spawn {
			params ["_snapshot"];
			private _bands = [3000, 2000, 1500, 1000, 750, 500, 250];
			private _lastBand = -1;
			private _lastLow = -100;
			private _lastUnits = count allUnits;
			while {missionNamespace getVariable ["MCC_perfLog", false]} do {
				uiSleep 2;
				private _players = (allPlayers - entities "HeadlessClient_F") select {alive _x};
				if (_players isEqualTo [] && {!isNull player}) then {_players = [player]};

				private _targets = ((allMissionObjects "MCC_ModuleObjective_FCurator") select {!((toLower (_x getVariable ["RscAttributeTaskState", ""])) in ["succeeded", "failed", "canceled"])}) apply {getPos _x};
				{
					private _info = missionNamespace getVariable [format ["MCC_missionsInfo_%1", _x], []];
					if (count _info > 0 && {(_info select 0) isEqualType []} && {count (_info select 0) >= 2}) then {_targets pushBack (_info select 0)};
				} forEach [west, east, resistance];
				private _dist = 1e9;
				{
					private _p = _x;
					{_dist = _dist min (_p distance2D _x)} forEach _targets;
				} forEach _players;

				private _band = _bands findIf {_dist > _x};
				if (_band == -1) then {_band = count _bands};
				if (_dist < 1e9 && {_band != _lastBand}) then {
					private _txt = if (_band >= count _bands) then {format ["within %1 m", _bands select (count _bands - 1)]} else {format ["%1 m (band > %2 m)", round _dist, _bands select _band]};
					["approach", "nearest player to objective %1 | %2", [_txt, [false] call _snapshot]] call MCC_perfWrite;
					_lastBand = _band;
				};

				if (time < 60 && {time - (missionNamespace getVariable ["MCC_perfStartupLast", -10]) >= 4}) then {
					MCC_perfStartupLast = time;
					private _byFile = createHashMap;
					{
						private _f = _x param [1, "?"];
						_byFile set [_f, (_byFile getOrDefault [_f, 0]) + 1];
					} forEach diag_activeSQFScripts;
					private _top = (keys _byFile) apply {[_byFile get _x, _x]};
					_top sort false;
					_top = (_top select [0, 8]) apply {format ["%1x %2", _x select 0, _x select 1]};
					["startup", "%1 | markers %2 | top scripts %3", [[false] call _snapshot, count allMapMarkers, _top]] call MCC_perfWrite;
				};

				if (diag_fps < 25 && {time - _lastLow > 5}) then {
					private _byFile = createHashMap;
					{
						private _f = _x param [1, "?"];
						_byFile set [_f, (_byFile getOrDefault [_f, 0]) + 1];
					} forEach diag_activeSQFScripts;
					private _top = (keys _byFile) apply {[_byFile get _x, _x]};
					_top sort false;
					_top = (_top select [0, 5]) apply {format ["%1x %2", _x select 0, _x select 1]};
					private _ref = (allPlayers - entities "HeadlessClient_F") param [0, player];
					private _fires = count (_ref nearObjects ["#particlesource", 500]);
					["lowFPS", "%1 m from objective | %2 | particle sources within 500 m %3 | top scripts %4", [if (_dist < 1e9) then {round _dist} else {"-"}, [false] call _snapshot, _fires, _top]] call MCC_perfWrite;
					_lastLow = time;
				};

				private _now = count allUnits;
				if (_now - _lastUnits >= 6 && {count (missionNamespace getVariable ["MCC_perfGen", []]) == 0}) then {
					["spawn", "+%1 units in 2 s | %2", [_now - _lastUnits, [false] call _snapshot]] call MCC_perfWrite;
				};
				_lastUnits = _now;
			};
			MCC_perfMonitorRunning = false;
		};
	};
};
