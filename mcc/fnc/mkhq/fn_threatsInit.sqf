// Runs only while a ship exists: started at mission start if there's one, and again whenever a ship is spawned or
// bought (MCC_fnc_LHDspawn); it stops when the last ship is gone.
if (!isServer) exitWith {};
if (missionNamespace getVariable ["MCCMK_threatsRunning", false]) exitWith {};
if (((missionNamespace getVariable ["MCC_staticShips", []]) findIf {!isNull _x}) < 0) exitWith {};
MCCMK_threatsRunning = true;
[] spawn {
	sleep 20;
	if (isNil "MCCMK_navalBases") then {MCCMK_navalBases = []};
	if (isNil "MCCMK_navalZones") then {MCCMK_navalZones = []};
	if (isNil "MCCMK_mwAreas") then {MCCMK_mwAreas = []};
	["INFO", "naval", "enemy awareness running", []] call MCC_fnc_log;
	private _tileZones = [];
	private _tileNext = -1;
	while {((missionNamespace getVariable ["MCC_staticShips", []]) findIf {!isNull _x}) >= 0} do {
		sleep 30;
		private _lvl = missionNamespace getVariable ["MCCMK_navalThreats", 1];
		private _zones = [];
		if (missionNamespace getVariable ["MCCMK_campaignSetupDone", false]) then {
			private _cf = missionNamespace getVariable ["MCC_campaignEnemyFaction", ""];
			if (_cf != "") then {
				private _cs = missionNamespace getVariable ["MCC_campaignEnemySide", [east, west, independent, civilian] param [getNumber (configFile >> "CfgFactionClasses" >> _cf >> "side"), east]];
				private _col = ["ColorEAST", "ColorWEST", "ColorGUER", "ColorCIV"] param [[east, west, independent, civilian] find _cs, "ColorEAST"];
				// (the campaign tiles: re-read every 5 min - going through every map marker is costly)
				if (time > _tileNext) then {
					_tileNext = time + 300;
					_tileZones = (allMapMarkers select {((_x select [0, 18]) == "MCCCampaignMarker_") && {(markerColor _x) == _col}}) apply {[_x, markerPos _x, 300, _cs, _cf]};
				};
				_zones append _tileZones;
			};
		};
		{_x params ["_id", "_c", "_r", "_f", "_sd"]; _zones pushBack [_id, _c, _r, _sd, _f]} forEach MCCMK_mwAreas;
		MCCMK_navalZones = _zones;
		if (_lvl > 0) then {
			private _mult = [0, 0.7, 1, 1.4] param [_lvl, 1];
			{
				private _s = _x;
				if (!isNull _s && {!(_s getVariable ["MCCMK_sinking", false])}) then {
					private _name = _s getVariable ["MCC_LHDDisplayName", "Ship"];
					private _ss = _s getVariable ["MCC_side", sideUnknown];
					private _map = _s getVariable ["MCCMK_awareSides", createHashMap];
					_s setVariable ["MCCMK_awareSides", _map];
					private _lastPos = _s getVariable ["MCCMK_awarePos", getPosWorld _s];
					private _moved = (_lastPos distance2D _s) > 200;
					_s setVariable ["MCCMK_awarePos", getPosWorld _s];
					{
						private _sd = _x select 3;
						if ([_sd, _ss] call BIS_fnc_sideIsEnemy && {!((str _sd) in _map)}) then {_map set [str _sd, [0, getPosWorld _s, -1e6, 0, 0, 0, _sd]]};
					} forEach _zones;
					private _ws = (_s getVariable ["MCCMK_weapons", []]) select {!isNull _x && {alive _x}};
					private _deck = (allUnits + vehicles) select {(_x distance2D _s) < 150 && {((getPosASL _x) select 2) > 3} && {(side group _x) isEqualTo _ss}};
					private _targets = _ws + (_deck select [0, 12]);
					private _busy = 0;
					{_busy = _busy max (_x getVariable ["MCCMK_lastBusy", -1e6])} forEach _ws;
					private _add = _s getVariable ["MCCMK_awareAdd", 0];
					_s setVariable ["MCCMK_awareAdd", 0];
					private _top = 0;
					{
						private _e = _y;
						_e params ["_aw", "_lk", "_seen", "_reconNext", "_strikeNext", "_baseFail", "_sd"];
						private _was = _aw;
						if (_moved) then {_aw = _aw * 0.3};
						private _zs = (_zones select {(_x select 3) isEqualTo _sd}) apply {[(((_x select 1) distance2D _s) - (_x select 2)) max 0, _x]};
						_zs sort true;
						private _dist = if (_zs isEqualTo []) then {1e9} else {(_zs select 0) select 0};
						if (_dist > 8000) then {
							_aw = _aw - 0.1;
						} else {
							private _z = (_zs select 0) select 1;
							private _faction = _z select 4;
							private _seer = objNull;
							{
								private _g = _x;
								if ((side _g) isEqualTo _sd && {!isNull leader _g} && {alive leader _g} && {((leader _g) distance2D _s) < 8000} && {(_targets findIf {(_g knowsAbout _x) > 1.5}) >= 0}) exitWith {_seer = leader _g};
							} forEach allGroups;
							if (!isNull _seer) then {
								_aw = _aw + 25 * _mult;
								_seen = serverTime;
								_lk = getPosWorld _s;
								if ((vehicle _seer) isKindOf "Air") then {[_s, "An enemy aircraft passed close - we may have been spotted.", true] call MCCMK_fnc_navalContact};
							};
							if (_s getVariable ["MCCMK_radarOn", false]) then {_aw = _aw + 2 * _mult};
							if ((time - _busy) < 30) then {_aw = _aw + 3 * _mult};
							if (_dist < 5000) then {_aw = _aw + _mult};
							if ((serverTime - _seen) > 300) then {_aw = _aw - 1};
							_aw = _aw + _add * _mult;
							_aw = (_aw max 0) min 100;
							private _from = (getPos _s) getDir (_z select 1);
							if (_aw >= 30 && {_reconNext < serverTime}) then {
								_reconNext = serverTime + 900;
								[_s, "recon", _sd, _faction, _from, 1, _lk] spawn MCCMK_fnc_navalAir;
							};
							if (_aw >= 60) then {
								if ((MCCMK_navalBases findIf {!isNull _x && {(_x getVariable ["MCCMK_baseSide", sideUnknown]) isEqualTo _sd} && {((_x getVariable ["MCCMK_baseMoor", [0, 0, 0]]) distance2D _s) < 12000}}) < 0 && {count MCCMK_navalBases < 2} && {_baseFail < serverTime}) then {
									_baseFail = serverTime + 600;
									[_s, _sd, _faction, _from, _lvl, (_zones select {(_x select 3) isEqualTo _sd}) apply {[_x select 0, _x select 1, _x select 2]}] spawn MCCMK_fnc_navalBase;
								};
								if (_strikeNext < serverTime) then {
									private _delay = 300 + random 300;
									_strikeNext = serverTime + _delay + ([1800, 1800, 1500, 1200] param [_lvl, 1800]);
									["INFO", "naval", "%1 spotted by %2 - strike in %3 s", [_name, _sd, round _delay]] call MCC_fnc_log;
									[_s, _sd, _faction, _from, _lvl, _delay, _lk] spawn {
										params ["_s", "_sd", "_faction", "_from", "_lvl", "_delay", "_lk"];
										sleep _delay;
										if (isNull _s || {_s getVariable ["MCCMK_sinking", false]}) exitWith {};
										[_s, "strike", _sd, _faction, _from, [1, 1, 1 + floor random 2, 2] param [_lvl, 1], _lk] spawn MCCMK_fnc_navalAir;
										{if (!isNull _x && {_x getVariable ["MCCMK_baseReady", false]} && {(_x getVariable ["MCCMK_baseSide", sideUnknown]) isEqualTo _sd} && {((_x getVariable ["MCCMK_baseMoor", [0, 0, 0]]) distance2D _lk) < 12000}) then {_x setVariable ["MCCMK_attackPos", _lk]}} forEach MCCMK_navalBases;
									};
								};
							};
						};
						_aw = (_aw max 0) min 100;
						_map set [_x, [_aw, _lk, _seen, _reconNext, _strikeNext, _baseFail, _sd]];
						_top = _top max (if (_dist > 8000) then {_aw min 25} else {_aw});
						if ((floor (_aw / 10)) != (floor (_was / 10))) then {["INFO", "naval", "%1: %2 awareness %3%4", [_name, _sd, round _aw, ["", " (no enemy territory near - held)"] select (_dist > 8000)]] call MCC_fnc_log};
					} forEach _map;
					_s setVariable ["MCCMK_aware", _top];
				};
			} forEach (missionNamespace getVariable ["MCC_staticShips", []]);
		};
	};
	MCCMK_threatsRunning = false;
	["INFO", "naval", "no ships left - enemy awareness stopped", []] call MCC_fnc_log;
};
