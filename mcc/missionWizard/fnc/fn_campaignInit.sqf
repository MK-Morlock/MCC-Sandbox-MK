/*======================================================MCC_fnc_campaignInit===========================================================================================
	Init campaign - SERVER ONLY
	_sidePlayer			SIDE - player side
	_factionPlayer		STRNG - faction player- defult "BLU_F"
	_sideEnemy			SIDE - enemy side
	_factionEnemy		STRING - faction enemy default "OPF_F"
	_factionCiv			STRING - faction civilians
	_missionMax			INTEGER - max amount of missions before mission over
	_difficulty			INTEGER - difficulty between 10-40 default is 20
	_sidePlayer2		SIDE - Side of the rival players faction
	_tickets			INTEGER - starting respawn tickets for each side
	_missionRotation	INTEGER - max missions in the same area
	_tileSize			INTEGER - Size of the tile while portfiling the map
	_loadDB				INTEGER  - Should we load the last saved data base
	_preciseMarkers		BOOLEAN  (index 13) objective markers on the objective (true) or offset area markers (false, default)
	_tileTransparency	NUMBER   (index 14) campaign tile overlay transparency 0-1: 0 = normal (default), 1 = hidden
	_keepOverStorage	BOOLEAN  (index 15) keep resources over the storage limit at mission end (default false = cut, original)
	_playMusic			INTEGER  0 - Play cinematic
  								 1 - Intro Only - Default
								 2 - None
//=====================================================================================================================================================================*/
private "_sidePlayer";
private "_sideEnemy";
private _factionCiv = "";
private _locations = [];
private "_pos";
private _temploc = [];
private "_AOlocation";
private _missionDone = 0;
private _missionMax = 0;
private _AOSize = 0;
private _factionPlayer = "";
private _difficulty = 0;
private "_totalPlayers";
private "_sidePlayer2";
private _tickets = 0;
private _missionRotation = 0;
private "_basePos";
private _tileSize = 0;
private "_reconMission";
private _loadDb = false;
private _playMusic = 0;

//wait for MCC
waitUntil {!isnil "MCC_initDone"};
waitUntil {MCC_initDone};

_sidePlayer	= param [0, west];
_factionPlayer	= param [1, "BLU_F"];
_sideEnemy	= param [2, east];
_factionEnemy = param [3, "OPF_F"];
_factionCiv	= param [4, "CIV_F"];
_missionMax  = param [5, 10];
_difficulty  = param [6, 20];
//Numbers can arrive as text from Eden attributes
{
	if (count _this > _x && {(_this select _x) isEqualType ""}) then {_this set [_x, parseNumber (_this select _x)]};
} forEach [5, 6, 8, 9, 10, 12, 16];
if (_missionMax isEqualType "") then {_missionMax = parseNumber _missionMax};
if (_difficulty isEqualType "") then {_difficulty = parseNumber _difficulty};
_sidePlayer2=  param [7, sideLogic];
_tickets = param [8, 100];
_missionRotation = param [9, 1,[0]];
_tileSize = param [10, 400,[0]];
_loadDb = param [11, false,[false]];
_playMusic = param [12, 1,[0]];
private _campaignPreciseMarkers = param [13, false, [false]];	// Campaign init module "Objective Markers": false = Area, true = Precise
// Campaign init module "Map Overlay Transparency" (0-1): tiles keep working (territory, spawn chance, DB), only how
// strongly they are drawn changes. 0 = normal, 1 = hidden. (A bool from older saves: true = hidden.)
private _tileTransparency = param [14, 0, [0, false]];
if (_tileTransparency isEqualType false) then {_tileTransparency = [0, 1] select _tileTransparency};
missionNamespace setVariable ["MCC_campaignTileTransparency", (_tileTransparency max 0) min 1];
// Campaign init module "Resources Over Storage Limit": false = cut to the limit at mission end (original), true = keep (hourly 10% loss)
missionNamespace setVariable ["MCC_campaignKeepOverStorage", param [15, false, [false]]];

//Campaign module "Players (enemy scaling)": 0 = count the real players, otherwise at least this many
private _playersOverride = param [16, 0, [0]];
_totalPlayers = ((playersNumber _sidePlayer)+1) max _playersOverride;
_AOSize = 300;

if (!isServer) exitWith {if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC_fnc_campaignInit : Error not running on server"}};

//Warn when nobody plays on the side the campaign is set up for: tasks and their markers go to that side only
[_sidePlayer, _factionPlayer] spawn {
	params ["_sidePlayer", "_factionPlayer"];
	sleep 5;
	private _sides = ((allPlayers - entities "HeadlessClient_F") apply {side group _x});
	if (count _sides > 0 && {!(_sidePlayer in _sides)}) then {
		private _msg = format ["MCC Campaign: it is set up for %1 players (faction %2), but the players are %3. Tasks and task markers are given to %1. Set Players Faction in the Campaign module to your faction.", _sidePlayer, _factionPlayer, _sides arrayIntersect _sides];
		["WARN", "MCC_fnc_campaignInit", _msg] call MCC_fnc_log;
		_msg remoteExec ["hint", 0];
	};
};

//Set campaign var
missionNamespace setVariable ["MCC_isCampaignRuning",true];
publicVariable "MCC_isCampaignRuning";

//Wait for mission start
waitUntil {time > 3};

missionNamespace setVariable ["MCC_campaignEnemyFaction",_factionEnemy];
publicVariable "MCC_campaignEnemyFaction";

//Time Multuplier
if (timeMultiplier < 12) then {setTimeMultiplier 12};

//Load stuff from DB
if (_loadDb) then {
	["MCC_campaign",true,true,true,true,true,true,true,true,true] call MCC_fnc_loadServer;
};

//Add tickets to the sides
if (_tickets > 0) then {
	{
		[_x,_tickets] call BIS_fnc_respawnTickets;
	} forEach [_sidePlayer,_sidePlayer2];
};

["genStart", ["campaign setup"]] call MCC_fnc_perfLog;
//Asset preset of the campaign enemy faction (console Assets page; applied where the preset is saved)
["apply", [_factionEnemy]] remoteExec ["MCC_fnc_assetsData", 0];	//performance log: campaign start-up stages
//Build the faction's unitsArrays and send it to the server.
_check = [_factionEnemy, _sideEnemy] call MCC_fnc_MWCreateUnitsArray;
waituntil {_check};

[_factionEnemy] call MCC_fnc_createConfigs;

["genStage", ["enemy unit lists and group configs"]] call MCC_fnc_perfLog;
//Search the map for locations
private _worldPath = configNull;
private _mapSize = 0;
private _mapCenter = [];

if (isnil "MCC_worldArea") then {
	_worldPath = configfile >> "cfgworlds" >> worldname;
	_mapSize = getnumber (_worldPath >> "mapSize");
	if (_mapSize == 0) then {_mapSize = worldSize};	// modded terrains often lack mapSize (was a fixed 10 km guess)

	_mapSize = _mapSize / 2;
	_mapCenter = [_mapSize,_mapSize];

	MCC_worldArea = createtrigger ["emptydetector",_mapCenter];
	MCC_worldArea settriggerarea [_mapSize,_mapSize,0,true];
};

//Build Locations
_locations = [];

//Any user defined locations?
{
	if (markerType _x == "Empty") then {
		if (["ao",_x] call bis_fnc_inString) then {_locations pushBack [getMarkerPos _x, markerText _x]};
	};
} forEach allMapMarkers;

//If no user defined locations lets find map locations.
if (count _locations == 0) then {
	_pos = getpos MCC_worldArea;
	{
		_temploc = [_pos,15000,_x] call MCC_fnc_MWbuildLocations;
		{
			if (((missionNamespace getVariable ["MCC_START_WEST",[0,0,0]]) distance (getpos (_x select 0)) >700) &&
				((missionNamespace getVariable ["MCC_START_EAST",[0,0,0]]) distance (getpos (_x select 0)) >700) &&
				((missionNamespace getVariable ["MCC_START_GUER",[0,0,0]]) distance (getpos (_x select 0)) >700)) then {

				_locations pushBack [getpos (_x select 0), _x select 1];
			};

		} forEach _temploc;
	} forEach ["city","mil","nature"]; //,"mil","hill","nature","marine"
};

//Still no location go bruth force
if (count _locations == 0) then {
	for "_i" from 1 to 100  do {
		_temploc = [[getpos MCC_worldArea, MCC_worldArea], "ground", ["water"],{}] call BIS_fnc_randomPos;
		_locations pushBack [_temploc, ""];
	};
};

["genStage", ["find locations"]] call MCC_fnc_perfLog;
//init map markers
[_sideEnemy,_tileSize,0.2,_locations,400,0.4,_loadDb] call MCC_fnc_campaignInitMap;

["genStage", ["map tiles (campaignInitMap)"]] call MCC_fnc_perfLog;
//Mark the starting bases
{
	_basePos = switch (_x) do
				{
					case east: {missionNamespace getVariable ["MCC_START_EAST",[0,0,0]]};
					case west: {missionNamespace getVariable ["MCC_START_WEST",[0,0,0]]};
					case resistance: {missionNamespace getVariable ["MCC_START_GUER",[0,0,0]]};
					default	{[0,0,0]};
				};
	if !(_basePos isEqualTo [0,0,0]) then {
		[_basePos,1000,_x,0.2] call MCC_fnc_campaignPaintMarkers;
	};
} forEach [_sidePlayer,_sidePlayer2];

["genStage", ["paint start bases"]] call MCC_fnc_perfLog;
//Spawn enemy ambient patrols
[500,18,_factionEnemy] spawn MCC_fnc_campaignSpawnAIInit;


//Pick first location
_missionDone = 0;

/*
//Mark all the locations as hot spots
{
	[(_x select 0),400,_sideEnemy,0.4,[_sidePlayer,_sidePlayer2]] spawn MCC_fnc_campaignPaintMarkers;
	sleep 0.1;
} forEach _locations;
*/

["genEnd", ["campaign setup finished (hot spots are painted in the background)", false]] call MCC_fnc_perfLog; missionNamespace setVariable ["MCCMK_campaignSetupDone", true]; [_factionEnemy] spawn MCCMK_fnc_preloadFaction;
//main mission loop
private "_AOlocationPos";
private "_AOlocationName";
private "_index";
private _goodLocation = false;

//Sort locations by distance from the players base
_basePos = switch (_sidePlayer) do
			{
				case east: {missionNamespace getVariable ["MCC_START_EAST",[0,0,0]]};
				case west: {missionNamespace getVariable ["MCC_START_WEST",[0,0,0]]};
				case resistance: {missionNamespace getVariable ["MCC_START_GUER",[0,0,0]]};
				default	{[0,0,0]};
			};
_locations = [_locations,[_basePos],{_input0 distance (_x select 0)},"ASCEND"] call BIS_fnc_sortBy;

//Start the campaign missions?
if (_missionMax == 0) exitWith {
	["sidetickets"] call  BIS_fnc_endMissionServer;
};

//Save DB every 20 minutes
["MCC_campaign",1200,true] spawn MCC_fnc_saveServer;


//Missions Rotation: how many missions are played in one area before the campaign moves on (it was read but never used)
_missionRotation = (round _missionRotation) max 1;
private _areaMissions = 0;		//missions played so far in the current area
_AOlocation = [];

while {(count _locations > 0 || {_areaMissions > 0}) &&	_missionDone <= _missionMax} do {

	//update borders
	{
		[_x, 0.4] call MCC_fnc_campaignTileSetAlpha;
	} forEach ([_sideEnemy] call MCC_fnc_campaignGetBorders);

	//Find mission location - or stay in the current area until its set of missions is done
	_goodLocation = false;
	_reconMission = random 1 <= 0.2;

	if (_areaMissions > 0 && {_areaMissions < _missionRotation} && {count _AOlocation > 0}) then {
		_goodLocation = true;
		_reconMission = false;
		["INFO", "MCC_fnc_campaignInit", "mission %1 of %2 in %3", [_areaMissions + 1, _missionRotation, _AOlocationName]] call MCC_fnc_log;
	} else {
		_areaMissions = 0;
	};

	while {count _locations > 0 && !_goodLocation} do {
		//_index = floor random count _locations;
		_index = if (_reconMission) then {floor random count _locations} else {0} ;
		_AOlocation = _locations select _index;
		_AOlocationPos = _AOlocation select 0;
		_AOlocationName = _AOlocation select 1;
		_locations set [_index,-1];
		_locations = _locations - [-1];

		_goodLocation = ([_AOlocationPos] call MCC_fnc_campaignGetNearestTile) select 1 == _sideEnemy;

		sleep 0.5;
	};



	//No locations? mission won
	if (count _locations == 0 && !_goodLocation) exitWith {
		//Mission won outro
		["everyonewon"] remoteExec ["BIS_fnc_endMissionServer", 2, false]
	};

	private "_totalEnemyUnits";
	private _isCQB = objNull;
	private _isCiv = false;
	private "_animals";
	private _vehicles = false;
	private _armor = false;
	private "_artillery";
	private "_isRoadblocks";
	private "_isIED";
	private "_isAS";
	private "_isSB";
	private "_reinforcement";
	private "_obj1";
	private _obj2 = "";
	private "_obj3";
	private _weatherChange = 0;
	private _preciseMarkers = _campaignPreciseMarkers;
	_aoPos = getMarkerpos _AOlocationName;
	_totalEnemyUnits = (_totalPlayers/2)*_difficulty;	//original MCC formula
	_isCQB =  (count (nearestObjects  [_aoPos,["House","Ruins","Church","FuelStation","Strategic"],200])) > 2;
	_isCiv = false;
	_animals = random 1 > 0.5;
	_vehicles = (random 100 < (_difficulty)*2) && (_missionDone >= 3); //No vehicles in the first 3 missions
	_armor = (random 100 < (_difficulty)) && (_missionDone >= 4); //No armor in the first 4 missions;
	_artillery = if ((random 100 < (_difficulty)*2) && (_missionDone >= 3)) then {[1,1,1,1,2] call BIS_fnc_selectRandom} else {0}; //No armor in the first 3 missions;
	_isRoadblocks = random 1 > 0.5;
	_isIED = random 1 > 0.7;
	_isAS = random 1 > (missionNamespace getvariable [format ["MCC_civRelations_%1",_sidePlayer],0.5]);
	_isSB = random 1 > (missionNamespace getvariable [format ["MCC_civRelations_%1",_sidePlayer],0.5]);
	_reinforcement =if (random 100 < (_difficulty)*2 || _reconMission) then {[1,1,1,1,2] call BIS_fnc_selectRandom} else {0};
	_obj1 = if (_reconMission) then {["Destroy Vehicle","Destroy AA","Destroy Artillery","Destroy Weapon Cache","Destroy Fuel Depot","Secure HVT","Kill HVT","Acquire Intel","Download Intel"] call BIS_fnc_selectRandom} else {["Destroy Vehicle","Destroy AA","Destroy Artillery","Destroy Weapon Cache","Destroy Fuel Depot","Secure HVT","Kill HVT","Acquire Intel","Download Intel","Capture Area","Capture Area","Capture Area","Capture Area","Capture Area","Capture Area","Capture Area","Capture Area","Disarm IED"] call BIS_fnc_selectRandom};

	_obj2 = if (random 80 < _difficulty) then {"Destroy Radar/Radio"} else {"None"};
	_obj3 = if (random 80 < _difficulty) then {["Destroy Vehicle","Destroy AA","Destroy Artillery","Destroy Weapon Cache","Destroy Fuel Depot","Secure HVT","Kill HVT","Acquire Intel","Disarm IED"] call BIS_fnc_selectRandom} else {"None"};

	_weatherChange = 0;
	_preciseMarkers = _campaignPreciseMarkers;

	sleep 1;
	[
		[_AOlocation, _totalEnemyUnits,  100, _AOSize, _weatherChange, _preciseMarkers, _playMusic],
		[_sideEnemy, _factionEnemy, _sidePlayer, _factionPlayer, _factionCiv],
		[_obj1, _obj2, _obj3],
		[_isCQB, _isCiv, _armor, _vehicles, _reconMission, _isIED, _isAS, _isSB, _isRoadblocks, _animals],
		[_reinforcement, _artillery]
	] spawn MCC_fnc_MWinitMission;


	//Wait untill mission wizard mission is runing
	waitUntil {missionNamespace getVariable ["MCC_MWMissionRuning",false]};

	//CAS
	if (_obj2 == "Destroy Radar/Radio") then {
		private _tower = _AOlocationPos nearObjects [(missionNamespace getVariable ["MCC_MWRadio",["Land_TTowerBig_2_F"]]) select 0, (_AOSize*2.5)];
		if (count _tower > 0) then {
			_tower = _tower select 0;
			[_tower,_sideEnemy, _factionEnemy, _sidePlayer]spawn {
				params ["_tower","_sideEnemy","_factionEnemy","_sidePlayer"];

				sleep (60 + (random 120));
				if (alive _tower) then {
					while {(alive _tower)} do {
						[_tower,_sideEnemy, _factionEnemy, _sidePlayer] call MCC_fnc_enemyCAS;
						sleep (480 + (random 480));
					};
				};
			};
		};
	};

	//If night mission remove NV from AI and add falshlight to build atmoshphere
	if (sunOrMoon < 1) then {
		private "_nearObjects";
		private "_unit";
		_nearObjects = _AOlocationPos nearObjects ["Man", _AOSize*4];

		{
			_unit = _x;
			if !(isPlayer _unit) then {
				{
					_unit unassignItem _x;
					_unit removeItem _x;
				} foreach ["NVGoggles","NVGoggles_OPFOR","NVGoggles_INDEP"];

				if !("acc_flashlight" in primaryWeaponItems _x) then {
							_x addPrimaryWeaponItem "acc_flashlight";
				};
				_x enablegunlights "forceOn";
			};
		} foreach _nearObjects;
	};

	//Wait for mission end
	private _ticketsStart = [];
	private _activeObjectivesSide1 = false;
	private _activeObjectivesSide2 = false;
	private _failedObjectivesSide1 = false;
	private _failedObjectivesSide2 = false;

	_ticketsStart = [_sidePlayer] call BIS_fnc_respawnTickets;

	//Wait untill mission is complete
	waitUntil {!(missionNamespace getVariable ["MCC_MWMissionRuning",true])};

	//Get the objectives
	private _objectives = (allMissionObjects "MCC_ModuleObjective_FCurator") select {(_x getvariable ["MCC_customTask",false])};

	_activeObjectivesSide1 = _objectives select {_sidePlayer in (_x getvariable ["RscAttributeOwners",[]])};
	_activeObjectivesSide2 = _objectives select {_sidePlayer2 in (_x getvariable ["RscAttributeOwners",[]])};

	_failedObjectivesSide1 = _activeObjectivesSide1 select {(_x getvariable ["RscAttributeTaskState",""]) != "Succeeded"};
	_failedObjectivesSide2 = _activeObjectivesSide2 select {(_x getvariable ["RscAttributeTaskState",""]) != "Succeeded"};

	sleep 2;
	_ticketsEnd = [_sidePlayer] call BIS_fnc_respawnTickets;
	_sumTickets = _ticketsStart - _ticketsEnd;

	if (_sidePlayer != sideLogic) then {
		["Main",count _activeObjectivesSide1,count _failedObjectivesSide1,_sidePlayer,_totalPlayers,_difficulty,60,[0.2,0.4,0.2,0.15,0.05],_sumTickets] spawn MCC_fnc_missionDone;
	};

	if (_sidePlayer2 != sideLogic) then {
		["Main",count  _activeObjectivesSide2,count _failedObjectivesSide2,_sidePlayer2,_totalPlayers,_difficulty,60,[0.2,0.4,0.2,0.15,0.05]] spawn MCC_fnc_missionDone;
	};

	//delete all objectives
	{deleteVehicle _x} forEach (allMissionObjects "MCC_ModuleObjective_FCurator");

	//if we have another side give him some credit
	/*
	if (_sidePlayer2 != sideLogic) then {
		["side",_activeObjectivesSide2,_failedObjectivesSide2,_sidePlayer2,_totalPlayers,_difficulty,40,[0.2,0.4,0.2,0.15,0.05],_sumTickets] call MCC_fnc_missionDone;
	};
	*/

	//clean up
	[_AOlocationPos,_AOSize*2] spawn {
		params [["_AOlocationPos",[0,0,0],[[],objNull]],
				["_AOSize",200,[0]]
			   ];

		while {{_x distance2D _AOlocationPos < _AOSize} count (allPlayers - entities "HeadlessClient_F") > 0} do {sleep 10};
		[_AOlocationPos,_AOSize,0] call MCC_fnc_deleteBrush
	};

	/*
	//Mark area as captured
	if !(_reconMission) then {
		//if main mission capture it
		[_AOlocationPos,_AOSize*3,_sidePlayer,0.2,[]] spawn MCC_fnc_campaignPaintMarkers;
	} else {
		//if recon mission then increase influance
		private _markerColor = switch (_sidePlayer) do
								{
									case west: {"ColorWEST"};
									case resistance: {"ColorGUER"};
									case east: {"ColorEAST"};
									default	{""};
								};
		{
			_x setMarkerColor _markerColor;
			[_x, 0.2] call MCC_fnc_campaignTileSetAlpha;
		} foreach ([_sideEnemy] call MCC_fnc_campaignGetBorders);
	};
	*/

	_areaMissions = _areaMissions + 1;

	//Expand the borders only when the area's set of missions is done
	if (!_reconMission && {_areaMissions >= _missionRotation}) then {
		//Expend borders
		private _markerColor = switch (_sidePlayer) do
								{
									case west: {"ColorWEST"};
									case resistance: {"ColorGUER"};
									case east: {"ColorEAST"};
									default	{""};
								};
		{
			_x setMarkerColor _markerColor;
			[_x, 0.2] call MCC_fnc_campaignTileSetAlpha;
		} foreach ([_sideEnemy,false] call MCC_fnc_campaignGetBorders);
	};


	_missionDone = _missionDone + 1;
	_difficulty = (_difficulty * 1.1) min 60;

	sleep 5;
};

//Mission won outro
["sidetickets"] call  BIS_fnc_endMissionServer;
