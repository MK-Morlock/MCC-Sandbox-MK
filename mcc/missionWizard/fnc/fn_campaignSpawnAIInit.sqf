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
_enemySide 		= ([_enemyFaction] call MCC_fnc_factionSide) call BIS_fnc_sideType;

if (!isServer) exitWith {};

//Build the faction unit lists for the patrols in one go (performance log: campaign patrols).
//It used to call MCC_fnc_makeUnitsArray 14 times (7 types x 2), each scanning every unit and vehicle of every loaded
//mod - slow with many factions. Same rules as before (public classes, the faction, no karts, no VR men, infantry from
//the Men categories only), so the patrols pick from the same units. Format per entry: [class, [name, picture]].
private _t0 = diag_tickTime;
private _lists = createHashMapFromArray [["soldier",[]],["car",[]],["motorcycle",[]],["tank",[]],["helicopter",[]],["airplane",[]],["ship",[]]];
private _simMap = createHashMapFromArray [
	["soldier","soldier"],["soldierx","soldier"],["car","car"],["carx","car"],["motorcycle","motorcycle"],["motorcyclex","motorcycle"],
	["tank","tank"],["tankx","tank"],["helicopter","helicopter"],["helicopterx","helicopter"],["airplane","airplane"],["airplanex","airplane"],
	["ship","ship"],["shipx","ship"]
];
private _factionLower = toLower _enemyFaction;
private _cfgAll = configFile >> "CfgVehicles";
private _scanned = 0;
private _contentMode = (missionNamespace getVariable ["MCC_MWContentModes", createHashMap]) getOrDefault [_factionLower, 2];
private _cacheKey = format ["MCC_campaignPatrolLists3_%1_%2", _factionLower, _contentMode];
private _cached = uiNamespace getVariable [_cacheKey, []];
if (count _cached > 0) then {
	//Built earlier in this game session (the config cannot change while the game runs)
	{_lists set [_x select 0, +(_x select 1)]} forEach _cached;
} else {
	//Let the engine pick the faction classes in one call. Walking all classes one by one from a script took 28 s with
	//89,200 classes loaded and held the frame rate at 2-7 FPS the whole time.
	private _cond = if (_factionLower == "all") then {"getNumber (_x >> 'scope') == 2"} else {
		format ["getNumber (_x >> 'scope') == 2 && {toLower getText (_x >> 'faction') == '%1'}", _factionLower]
	};
	private _classes = _cond configClasses _cfgAll;
	private _listsAll = createHashMapFromArray ((keys _lists) apply {[_x, []]});
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
			|| {_type != "soldier" && {(configName _cfg) isKindOf "Car"} && {[configName _cfg] call MCC_fnc_isUtilityVehicle}}
			|| {_type == "soldier" && {(["virtual", "uav_ai", "uavai", "dummy"] findIf {((_lc find _x) >= 0) || {(_dnl find _x) >= 0}}) >= 0}};
		if (_type != "" && {!_invisibleTarget} && {!(toLower getText (_cfg >> "DLC") in ["kart"])}) then {
			private _cat = toLower ([_cfg] call MCC_fnc_unitCategory);
			if (!("vr" in _cat) && {_type != "soldier" || {_cat == "men"}}) then {
				(_listsAll get _type) pushBack [configName _cfg, [getText (_cfg >> "displayName"), getText (_cfg >> "picture")]];
				if ([_cfg, _enemyFaction, _contentMode] call MCC_fnc_contentAllowed) then {
					(_lists get _type) pushBack [configName _cfg, [getText (_cfg >> "displayName"), getText (_cfg >> "picture")]];
				};
			};
		};
	} forEach _classes;
	{
		if (((_lists get _x) isEqualTo []) && {!((_listsAll get _x) isEqualTo [])}) then {
			_lists set [_x, _listsAll get _x];
			["INFO", "fn_campaignSpawnAIInit", "%1: no %2 patrols left with the content filter - using all content", [_enemyFaction, _x]] call MCC_fnc_log;
		};
	} forEach (keys _lists);
	uiNamespace setVariable [_cacheKey, (keys _lists) apply {[_x, +(_lists get _x)]}];
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
					_units = [_unitsArray, 4 + floor random 7] call MCCMK_fnc_buildSquad;
					_spawnPos = [_spawnPos] call MCC_fnc_safeSpawnPos;
					_grp = [_spawnPos, _enemySide, _units] call MCC_fnc_spawnGroup;
				} else {
					private _cls = [_unitsArray, "patrol"] call MCCMK_fnc_pickVehicle;
					if (_cls == "") then {_cls = (_unitsArray call BIS_fnc_selectRandom) select 0};
					_spawnPos = [_spawnPos, _cls] call MCC_fnc_safeSpawnPos;
					_grp = ([_spawnPos, 200, _cls, _enemySide] call MCC_fnc_spawnVehicle) select 2;
					private _c = configFile >> "CfgVehicles" >> _cls;
					private _odd = ((toLower getText (_c >> "displayName")) find "invisible") >= 0 || {((toLower _cls) find "target") >= 0} || {getText (_c >> "model") in ["", "\A3\Weapons_f\empty", "\A3\Weapons_F\empty.p3d"]};
					[["INFO", "WARN"] select _odd, "fn_campaignSpawnAIInit", "patrol %1: %2 (%3) model %4 at %5, %6 m from %7%8", [_simu, _cls, getText (_c >> "displayName"), getText (_c >> "model"), mapGridPosition _spawnPos, round (_spawnPos distance2D _player), name _player, ["", " - INVISIBLE / TARGET?"] select _odd]] call MCC_fnc_log;
				};

				_grp setVariable ["GAIA_ZONE_INTEND",[([_spawnPos,1500] call MCC_fnc_campaignGetNearestTile) select 0, ["MOVE","NOFOLLOW"]call BIS_fnc_selectRandom], true];
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

