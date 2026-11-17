/*======================================================MCC_fnc_campaignSpawnAIInit=======================================================================================
// Spawn selected units around the player
// Example: [_spawnDistance,_maxSpawn,_faction] spawn MCC_fnc_campaignSpawnAIInit;
// _spawnDistance		INTEGER - Spawn distance around the players
// _maxSpawn			INTEGER - max groups spawned around the players
// _faction				STRING - the units' faction
//==================================================================================================================================================================*/
private _spawnCenters = [];
private "_player";
private _spawnpos = [];
private _enemyFaction = "";
private _spawnDistance = 0;
private _maxSpawn = 0;
private _enemySide = configNull;
private _unitsArray = [];
private _spawnPos = [];
private "_roads";
private "_simu";
private "_unit";
private "_maxGroupAmount";
private _units = [];
private _grp = [];
private "_tile";
_spawnDistance 	= param [0, 250, [250]];
_maxSpawn 		= param [1, 12, [12]];
_enemyFaction	= param [2, "OPF_F", [""]];
_enemySide 		= if ((toLower _enemyFaction) == toLower (missionNamespace getVariable ["MCC_campaignEnemyFaction", ""]) && {!isNil "MCC_campaignEnemySide"}) then {MCC_campaignEnemySide} else {([_enemyFaction] call MCC_fnc_factionSide) call BIS_fnc_sideType};

if (!isServer) exitWith {};

//Build the faction unit lists for the patrols in one go: one config scan for all 7 types (MCC_fnc_makeUnitsArray
//per type scans every unit and vehicle of every loaded mod each time). Same rules as MCC_fnc_makeUnitsArray (public
//classes, the faction, no karts, no VR men, infantry from
//the Men categories only), so the patrols pick from the same units. Format per entry: [class, [name, picture]].
private _t0 = diag_tickTime;
private _lists = createHashMapFromArray [["soldier",[]],["car",[]],["motorcycle",[]],["tank",[]],["helicopter",[]],["airplane",[]],["ship",[]]];
private _simMap = createHashMapFromArray [
	["soldier","soldier"],["soldierx","soldier"],["car","car"],["carx","car"],["motorcycle","motorcycle"],["motorcyclex","motorcycle"],
	["tank","tank"],["tankx","tank"],["helicopter","helicopter"],["helicopterx","helicopter"],["helicopterrtd","helicopter"],["airplane","airplane"],["airplanex","airplane"],
	["ship","ship"],["shipx","ship"]
];
private _factionLower = toLower _enemyFaction;
private _cfgAll = configFile >> "CfgVehicles";
private _scanned = 0;
private _contentMode = (missionNamespace getVariable ["MCC_MWContentModes", createHashMap]) getOrDefault [_factionLower, 2];
private _cacheKey = format ["MCC_campaignPatrolLists6_%1_%2", _factionLower, _contentMode];	//(MK) 6: no flying drones
private _cached = uiNamespace getVariable [_cacheKey, []];
if (_factionLower != "all") then {
	//(MK) from the faction's pools (MCCMK_fnc_pools - MCC MK's single faction filter: the framework's sorting and rules,
	// its own content, then official DLC, then all, then a sibling faction's, then - with the "Vanilla vehicle fallback"
	// setting on (the default) - the side's vanilla vehicle (MCCMK_fnc_poolOwn); off, a faction with no tanks has no tank patrols
	private _mk = {params ["_cls"]; [_cls, [getText (_cfgAll >> _cls >> "displayName"), getText (_cfgAll >> _cls >> "picture")]]};
	private _get = {params ["_kinds"]; private _l = []; {_l append ([_enemyFaction, _x] call MCCMK_fnc_poolOwn)} forEach _kinds; (_l arrayIntersect _l) apply {[_x] call _mk}};
	{_lists set [_x select 0, [_x select 1] call _get]} forEach [
		["soldier", ["InfMen"]], ["car", ["Car"]], ["motorcycle", ["Motorcycle"]], ["tank", ["Tank", "APC", "AA"]],
		["helicopter", ["HeliArmed"]], ["airplane", ["PlaneCAS"]], ["ship", ["Ship"]]
	];
} else {
	if (count _cached > 0) then {
		//Built earlier in this game session (the config cannot change while the game runs)
		{_lists set [_x select 0, +(_x select 1)]} forEach _cached;
	} else {
		//Let the engine pick the faction classes in one call. Walking all classes one by one from a script takes many
		//seconds with a large mod set.
		private _cond = if (_factionLower == "all") then {"getNumber (_x >> 'scope') == 2"} else {
			format ["getNumber (_x >> 'scope') == 2 && {toLower getText (_x >> 'faction') == '%1'}", _factionLower]
		};
		private _classes = _cond configClasses _cfgAll;
		private _listsAll = createHashMapFromArray ((keys _lists) apply {[_x, []]});
		private _listsDLC = createHashMapFromArray ((keys _lists) apply {[_x, []]});
		_scanned = count _classes;
		{
			private _cfg = _x;
			private _type = _simMap getOrDefault [toLower getText (_cfg >> "simulation"), ""];
			private _lc = toLower configName _cfg;
			private _mdl = toLower getText (_cfg >> "model");
			private _dnr = getText (_cfg >> "displayName");
			private _dnl = toLower (if ((_dnr select [0, 1]) == "$") then {localize (_dnr select [1])} else {_dnr});
			private _invisibleTarget = ((_dnl find "invisible") >= 0) || {(_mdl find "invisible") >= 0}
				|| {(["invisibletarget", "targetsoldier", "target_vehicle", "targetvehicle"] findIf {(_lc find _x) >= 0}) >= 0}
				|| {_mdl in ["", "\a3\weapons_f\empty", "\a3\weapons_f\empty.p3d"]}
				|| {((_lc select [((count _lc) - 5) max 0]) == "_base") || {(_lc find "_base_") >= 0}}
				|| {(_mdl find "pod_heli_transport_04") >= 0} || {(configName _cfg) isKindOf "Slingload_base_F"}
				|| {(["radar_system", "sam_system"] findIf {(_mdl find _x) >= 0}) >= 0}
				|| {_type != "soldier" && {getNumber (_cfg >> "hasDriver") == 0} && {getNumber (_cfg >> "isUav") != 1}}
				|| {getNumber (_cfg >> "isUav") == 1 && {(configName _cfg) isKindOf "Air"}}	//(MK) no flying drones as patrols (operators launch those)
				|| {_type != "soldier" && {(configName _cfg) isKindOf "Car"} && {[configName _cfg] call MCC_fnc_isUtilityVehicle}}
				|| {_type == "soldier" && {(["virtual", "uav_ai", "uavai", "dummy"] findIf {((_lc find _x) >= 0) || {(_dnl find _x) >= 0}}) >= 0}};
			if (_type != "" && {!_invisibleTarget} && {!(toLower getText (_cfg >> "DLC") in ["kart"])}) then {
				private _cat = toLower ([_cfg] call MCC_fnc_unitCategory);
				if (!("vr" in _cat) && {_type != "soldier" || {_cat == "men"}}) then {
					(_listsAll get _type) pushBack [configName _cfg, [getText (_cfg >> "displayName"), getText (_cfg >> "picture")]];
					if ([_cfg, _enemyFaction, _contentMode] call MCC_fnc_contentAllowed) then {
						(_lists get _type) pushBack [configName _cfg, [getText (_cfg >> "displayName"), getText (_cfg >> "picture")]];
					};
					if (_contentMode < 1 && {[_cfg, _enemyFaction, 1] call MCC_fnc_contentAllowed}) then {
						(_listsDLC get _type) pushBack [configName _cfg, [getText (_cfg >> "displayName"), getText (_cfg >> "picture")]];
					};
				};
			};
		} forEach _classes;
		{
			// nothing from the faction's own content: official DLC next, mods only as a last resort
			if (((_lists get _x) isEqualTo []) && {!((_listsDLC get _x) isEqualTo [])}) then {
				_lists set [_x, _listsDLC get _x];
				["INFO", "fn_campaignSpawnAIInit", "%1: no %2 patrols from its own content - using official DLC too", [_enemyFaction, _x]] call MCC_fnc_log;
			};
			if (((_lists get _x) isEqualTo []) && {!((_listsAll get _x) isEqualTo [])}) then {
				_lists set [_x, _listsAll get _x];
				["INFO", "fn_campaignSpawnAIInit", "%1: no %2 patrols left with the content filter - using all content", [_enemyFaction, _x]] call MCC_fnc_log;
			};
		} forEach (keys _lists);
		uiNamespace setVariable [_cacheKey, (keys _lists) apply {[_x, +(_lists get _x)]}];
	};
};
{
	missionNamespace setVariable [format ["MCC_campaignSpawnAIInit_%1", _x], _lists get _x];
} forEach (keys _lists);
private _countsTxt = (keys _lists) apply {format ["%1 %2", _x, count (_lists get _x)]};
private _msg = format ["campaign patrols: unit lists built in %1 s (%2) | %3", (diag_tickTime - _t0) toFixed 2, if (count _cached > 0) then {"from this session cache"} else {format ["%1 faction classes", _scanned]}, _countsTxt joinString ", "];
if (isNil "MCC_perfWrite") then {if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log text ("MCC [PERF] " + _msg)}} else {["campaign", _msg] call MCC_perfWrite};
{
	private _l = _lists get _x;
	if (count _l > 0) then {["INFO", "fn_campaignSpawnAIInit", "patrol %1 list: %2", [_x, (_l apply {format ["%1 (%2)", _x select 0, (_x select 1) select 0]}) joinString ", "]] call MCC_fnc_log};
} forEach ["airplane", "helicopter"];

while {true} do {
	//Lets find a random player
	_spawnCenters = if (isMultiplayer) then {playableUnits} else {[player]};

	//If the player is not on enemy tile or not alive remove him from the list
	for "_i" from 0 to (count _spawnCenters)-1 step 1 do {
		_player = _spawnCenters select _i;
		if 	(
		    	!alive _player ||
		    	captive _player ||
		    	!isTouchingGround _player ||
		    	([_player,600] call MCC_fnc_campaignGetNearestTile) select 1 != _enemySide &&
		       	{([position _player,str _x] call GAIA_fnc_IsInMarker)} count ([(missionNamespace getVariable ["MCC_zones_numbers",[]]), { _x <1000}] call BIS_fnc_conditionalSelect) <= 0
			) then {
			_spawnCenters set [_i,-1];
		};
	};

	_spawnCenters = _spawnCenters - [-1];
	_maxGroupAmount = (((count _spawnCenters)max 1)*2) min _maxSpawn;

	_player	= _spawnCenters call BIS_fnc_selectRandom;

	//Do we need to spawn more AI group?
	if 	(
	     	count _spawnCenters > 0 &&
	     	{({(_x getVariable ["MCC_MW_AMBIENT",false])} count allgroups) < _maxGroupAmount} &&
	     	{(missionNamespace getvariable [format ["campaignRep_%1",side _player],50]) > random 100}
	    ) then {

		_spawnPos = [getpos _player, _spawnDistance, random 360] call BIS_fnc_relPos;
		_spawnPos =(_spawnPos) findEmptyPosition [10,150];
		_tile = ([_spawnPos,600] call MCC_fnc_campaignGetNearestTile) select 0;

		//We have an enemy tile nearby spawn by the intense of the tile
		if 	(
		     	//We found a tile
		    	_tile != "" &&

		    	//the darker the tile the more chance he have to spawn enemies
		    	random 1 < ([_tile] call MCC_fnc_campaignTileAlpha) &&

		    	//Don't spawn on a released tile
		    	([_spawnPos,600] call MCC_fnc_campaignGetNearestTile) select 1 == _enemySide &&

		    	//We don't spawn enemies in MCC zones
		    	{([_spawnPos,str _x] call GAIA_fnc_IsInMarker)} count ([(missionNamespace getVariable ["MCC_zones_numbers",[]]), { _x <1000}] call BIS_fnc_conditionalSelect) <= 0
		    ) then {

			//Land or water
			if (surfaceIsWater _spawnPos) then {
				_simu = [["helicopter", "airplane", "ship"],[0.01,0.01,1]] call BIS_fnc_selectRandomWeighted;
			} else {

				_simu = [["soldier", "car", "tank"],[1,0.4,0.01]] call BIS_fnc_selectRandomWeighted;
			};

			//Try to spawn them on roads
			if (!(isOnRoad _spawnPos) and (_simu in ["soldier", "car","motorcycle","tank"])) then {
				_roads = _spawnPos nearRoads 250;

				if (count(_roads)>0) then {
					_spawnPos = position(_roads call BIS_fnc_selectRandom);
				};
			};

			_unitsArray = missionNamespace getVariable [format ["MCC_campaignSpawnAIInit_%1",_simu],[]];

			if (count _unitsArray > 0) then {

				//Spawn units
				if (_simu == "soldier") then {
					//(MK) the faction's own ready-made groups, like the generated missions (a recon, sniper or support team one
					// time in five) - or, by the setting or with no groups, a squad of its ordinary soldiers (the original)
					private _gReg = missionNamespace getVariable ["MCC_MWGroupArrayMen", []];
					private _gSpec = (missionNamespace getVariable ["MCC_MWGroupArrayMenRecon", []]) + (missionNamespace getVariable ["MCC_MWGroupArrayMenSniper", []]) + (missionNamespace getVariable ["MCC_MWGroupArrayMenSupport", []]);
					_spawnPos = [_spawnPos] call MCC_fnc_safeSpawnPos;
					if ((missionNamespace getVariable ["MCCMK_campaignPatrolInf", 0]) == 0 && {_gReg isNotEqualTo []}) then {
						if (random 1 < 0.2 && {_gSpec isNotEqualTo []}) then {
							// a recon, sniper or support team, at its own size (a sniper team is two)
							_grp = [_spawnPos, _enemySide, call compile ((selectRandom _gSpec) select 2)] call MCC_fnc_spawnGroup;
						} else {
							// the original's strength: a target of 4-10 soldiers - the faction's group closest to it, and if that's
							// still 2 or more short, more groups to make it up (general infantry first - fireteams, rifle squads,
							// patrols, sentries - so it's topped up with riflemen, not a second AA team); up to 2 more groups
							private _target = 4 + floor random 7;
							private _near = {
								params ["_list", "_want"];
								private _best = [];
								private _bd = 1e9;
								{
									private _d = abs ((_x select 1) - _want);
									if (_d < _bd || {_d == _bd && {random 1 < 0.5}}) then {_bd = _d; _best = _x};
								} forEach _list;
								_best
							};
							private _g = [_gReg, _target] call _near;
							_grp = [_spawnPos, _enemySide, call compile (_g select 2)] call MCC_fnc_spawnGroup;
							private _placed = _g select 1;
							private _gen = _gReg select {private _n = toLower (_x select 0); (["fire team", "fireteam", "rifle", "squad", "patrol", "sentry", "section"] findIf {(_n find _x) >= 0}) >= 0 && {(["weapons", " at ", "(at)", "anti", " aa", "(aa)", "mortar", "sniper"] findIf {(_n find _x) >= 0}) < 0}};
							if (_gen isEqualTo []) then {_gen = _gReg};
							private _extra = 0;
							while {(_target - _placed) >= 2 && {_extra < 2} && {!isNull _grp}} do {
								private _fit = _gen select {(_x select 1) <= ((_target - _placed) + 1)};
								if (_fit isEqualTo []) exitWith {};
								private _g2 = [_fit, _target - _placed] call _near;
								private _add = [_spawnPos getPos [8, random 360], _enemySide, call compile (_g2 select 2)] call MCC_fnc_spawnGroup;
								if (!isNull _add) then {(units _add) joinSilent _grp; deleteGroup _add};
								_placed = _placed + (_g2 select 1);
								_extra = _extra + 1;
							};
						};
					} else {
						_units = [_unitsArray, 4 + floor random 7] call MCCMK_fnc_buildSquad;
						_grp = [_spawnPos, _enemySide, _units] call MCC_fnc_spawnGroup;
					};
				} else {
					private _cls = [_unitsArray, "patrol"] call MCCMK_fnc_pickVehicle;
					if (_cls == "") then {_cls = (_unitsArray call BIS_fnc_selectRandom) select 0};
					//(MK) a boat patrol is always an armed boat: another armed one from the list, else the side's armed speedboat
					if (_simu == "ship" && {!([_cls] call MCCMK_fnc_isArmedBoat)}) then {
						private _armed = [_enemyFaction, "ShipArmed"] call MCCMK_fnc_poolOwn;	//(MK) the faction's own armed boats (or a sibling's)
						_cls = if (_armed isNotEqualTo []) then {selectRandom _armed} else {[_enemySide] call MCCMK_fnc_armedBoatFallback};
					};
					if (_cls == "") then {_grp = grpNull} else {	//(MK) none to send (the vanilla fallback off): no patrol
					_spawnPos = [_spawnPos, _cls] call MCC_fnc_safeSpawnPos;
					private _sv = [_spawnPos, 200, _cls, _enemySide, true, true, _enemyFaction] call MCC_fnc_spawnVehicle;	//(MK) the enemy faction's crew
					_grp = _sv select 2;
					[_sv select 0, "campaign patrol"] call MCCMK_fnc_airTrack;	//(MK) debug (aircraft only)
					private _c = configFile >> "CfgVehicles" >> _cls;
					private _odd = ((toLower getText (_c >> "displayName")) find "invisible") >= 0 || {((toLower _cls) find "target") >= 0} || {getText (_c >> "model") in ["", "\A3\Weapons_f\empty", "\A3\Weapons_F\empty.p3d"]};
					[["INFO", "WARN"] select _odd, "fn_campaignSpawnAIInit", "patrol %1: %2 (%3) model %4 at %5, %6 m from %7%8", [_simu, _cls, getText (_c >> "displayName"), getText (_c >> "model"), mapGridPosition _spawnPos, round (_spawnPos distance2D _player), name _player, ["", " - INVISIBLE / TARGET?"] select _odd]] call MCC_fnc_log;
					};
				};

				//(MK) a boat patrols the coast with MCCMK_fnc_boatPatrol rather than GAIA,
				// which ran boats aground; everything else is given to GAIA
				if (_simu == "ship" && {!isNull _grp} && {!isNull (vehicle leader _grp)} && {(vehicle leader _grp) isKindOf "Ship"}) then {
					[[_spawnPos, _enemySide, [vehicle leader _grp], ""], (if (isNil "_MCCMK_gen") then {""} else {_MCCMK_gen})] spawn {private _MCCMK_gen = _this select 1; (_this select 0) call MCCMK_fnc_boatPatrol};
				} else {
					_grp setVariable ["GAIA_ZONE_INTEND",[([_spawnPos,1500] call MCC_fnc_campaignGetNearestTile) select 0, ["MOVE","NOFOLLOW"]call BIS_fnc_selectRandom], true];
				};
				_grp setVariable ["MCC_MW_AMBIENT",true, false];
			};
		};
	};


	sleep 600;

	//Delete stuff
	{
		private _delete = true;
		private _grp    = _x;
		if (_grp getVariable ["MCC_MW_AMBIENT",false]) then {
			{
				_unit = _x;
				if (({(_x distance _unit < _spawnDistance*2) || !(lineintersects [eyepos _x,getposasl _unit,_x,_unit])} count _spawnCenters)>0)  exitWith {_delete = false;};
			} forEach (units _grp);

			if _delete then {
				//Delete all
				{deleteVehicle _x; sleep 0.3} foreach ([_grp] call  BIS_fnc_groupVehicles);
				{ deleteVehicle _x;sleep 0.3} forEach units _grp;
				deletegroup _grp;
			};
		};
	} forEach allgroups;
};

