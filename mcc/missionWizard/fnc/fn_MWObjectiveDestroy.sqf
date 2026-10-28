/*====================================================MCC_fnc_MWObjectiveDestroy====================================================================================
// Create a Destroy objective
// Example:[_objPos,_isCQB,_side,_faction] call MCC_fnc_MWObjectiveDestroy;
// _objPos = position, objectice position
//_isCQB = Boolean, true - for CQB areay false if it doesn't matters.
//_side = enemy side
//_faction = enemy Faction
// Return - nothing
//===========================================================================================================================================================*/
private _type = "";
private _objType = "";
private _typeSize = "";
private _spawnPos = [];
private _object = objNull;
private _dummyObject = [];
private _spawndir = nil;
private _init = "";
private _range = 0;
private _vehiclesArray = [];
private _vehiclesArrayFlitered = configNull;

params [
	["_objPos", [0,0,0], [[]]],
	["_isCQB", false, [false]],
	["_side", sideUnknown, [sideUnknown]],
	["_faction", "", [""]],
	["_preciseMarkers", false, [false]],
	["_destroyType", "", [""]],
	["_campaignMission", false, [false]],
	["_sidePlayer", west, [west]]
];

_objType = switch (_destroyType) do
			{
				case "Destroy Vehicle": {["tanks","air"] call BIS_fnc_selectRandom};
				case "Destroy AA": {"aa"};
				case "Destroy Artillery": {"artillery"};
				case "Destroy Weapon Cache": {"cache"};
				case "Destroy Fuel Depot": {"fuel"};
				case "Destroy Radar/Radio": {if (_campaignMission) then {"radio"} else {["radar","radio"] call BIS_fnc_selectRandom}};
			};


//What do we spawn
_vehiclesArray = switch _objType do
	{
		case "fuel":{missionNamespace getVariable ["MCC_MWFuelTanks",["Land_dp_smallTank_F","Land_ReservoirTank_V1_F","Land_dp_bigTank_F"]]};
		case "radio":{missionNamespace getVariable ["MCC_MWRadio",["Land_TTowerBig_2_F"]]};
		case "tanks":{missionNamespace getVariable ["MCC_MWTanks",["B_MBT_01_cannon_F","O_MBT_02_cannon_F"]]};
		case "aa":{missionNamespace getVariable ["MCC_MWAA",["B_APC_Tracked_01_AA_F","O_APC_Tracked_02_AA_F","I_APC_Wheeled_03_cannon_F"]]};
		case "artillery": {missionNamespace getVariable ["MCC_MWArtillery",["B_MBT_01_arty_F","B_MBT_01_mlrs_F","O_MBT_02_arty_F","O_Mortar_01_F","I_Mortar_01_F"]]};
		case "air":{missionNamespace getVariable ["MCC_MWAir",["O_Heli_Attack_02_F","O_Heli_Attack_02_black_F","O_UAV_02_F","O_UAV_02_CAS_F","B_Heli_Attack_01_F","I_Plane_Fighter_03_CAS_F","I_Plane_Fighter_03_AA_F"]]};
		case "cache":{missionNamespace getVariable ["MCC_MWcache",["Box_East_AmmoVeh_F"]]};
		case "radar":{missionNamespace getVariable ["MCC_MWradar",["Land_Radar_Small_F"]]};
		default	{missionNamespace getVariable ["MCC_MWFuelTanks",["Land_dp_smallTank_F","Land_ReservoirTank_V1_F","Land_dp_bigTank_F"]]};
	};

//The enemy faction own tank, AA, artillery or aircraft first (MCC_fnc_factionVehicles); the lists above only when
//the faction has none of that type
//A list chosen on the console Assets page is used as it is (MCC_assetCustom_<variable>)
private _listVar = switch (_objType) do {
	case "fuel": {"MCC_MWFuelTanks"}; case "radio": {"MCC_MWRadio"}; case "tanks": {"MCC_MWTanks"}; case "aa": {"MCC_MWAA"};
	case "artillery": {"MCC_MWArtillery"}; case "air": {"MCC_MWAir"}; case "cache": {"MCC_MWcache"}; case "radar": {"MCC_MWradar"};
	default {"MCC_MWFuelTanks"};
};
private _customList = missionNamespace getVariable ["MCC_assetCustom_" + _listVar, false];
private _factionRole = switch (_objType) do {case "tanks": {"tank"}; case "aa": {"aa"}; case "artillery": {"artillery"}; case "air": {"air"}; default {""}};
private _factionOwn = if (_factionRole == "" || _customList) then {[]} else {[_faction, _factionRole] call MCC_fnc_factionVehicles};
if (count _factionOwn > 0) then {_vehiclesArray = _factionOwn};

//Find the objects from the enemy side
_vehiclesArrayFlitered = if (_customList) then {+_vehiclesArray} else {_vehiclesArray select {([(getNumber (configFile >> "cfgVehicles" >> _x >> "side"))] call BIS_fnc_sideType) isEqualTo _side}};

//Couldn't find any object just select all
if (count _vehiclesArrayFlitered <= 0) then {
	_vehiclesArrayFlitered = _vehiclesArray;
};

//Select random vehicle
_type = _vehiclesArrayFlitered call BIS_fnc_selectRandom;

//How big is it
_typeSize = switch _objType do
				{
					case "tanks":
					{
						"Land_dp_bigTank_F"
					};

					case "aa":
					{
						"Land_dp_bigTank_F"
					};

					case "artillery":
					{
						"Land_dp_bigTank_F"
					};

					case "air":
					{
						"Land_TentHangar_V1_F"
					};

					case "cache":
					{
						"Land_dp_smallTank_F"
					};

					default
					{
						"Land_dp_smallTank_F"
					};
				};

//Find an empry spot
_range = 50;
_spawnPos = [_objPos,1,_range,10,0,10,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;

//If we haven't find it in first time increase by 50;
while {str _spawnPos == "[-500,-500,0]" || isOnRoad _spawnPos} do
{
	_range = _range+ 50;
	_spawnPos = [_objPos,1,_range,10,0,10,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
	//_spawnPos = _objPos findEmptyPosition [0,200,_typeSize];
};

//Clear area
[_spawnPos,30,true] call MCC_fnc_hideTerrainObjectsArea;

//Case we are dealing with a vehicle
if (_objType in ["tanks","aa","artillery"]) then
{
	_dummyObject =[_spawnPos, random 360, "c_nestBig"] call MCC_fnc_objectMapper;
	_spawnPos = getpos _dummyObject;
	_spawndir = getdir _dummyObject;
};

//Case we are dealing with ammo cache
if (_objType == "cache") then
{
	_dummyObject = [_spawnPos, random 360, "c_nestSmall"] call MCC_fnc_objectMapper;
	_spawnPos = getpos _dummyObject;
	_spawndir = getdir _dummyObject;
};

//Case we are dealing with a Air
if (_objType == "air") then
{
	_dummyObject =[_spawnPos, random 360, "c_hanger"] call MCC_fnc_objectMapper;
	_spawnPos = getpos _dummyObject;
	_spawndir = getdir _dummyObject;
};


 if (isnil "_spawndir") then {_spawndir = random 360};

sleep 1;

//Create the object
if (_objType in ["artillery","aa"]) then {
	_object = ([_spawnPos,_spawndir,_type,_side] call MCC_fnc_spawnVehicle) select 0;
} else {
	if (_objType == "air") then {
		_object = createVehicle [_type, _spawnPos, [], 0, "CAN_COLLIDE"];
		_object allowDamage false;
		_object setDir _spawndir;
		_object setPos _spawnPos;
		_object setVelocity [0,0,0];
		[_object, _spawnPos, _spawndir] spawn {
			params ["_object", "_spawnPos", "_spawndir"];
			sleep 15;
			if (isNull _object) exitWith {};
			private _moved = (_object distance2D _spawnPos) > 2;
			if ((damage _object) > 0 || _moved) then {
				["INFO", "fn_MWObjectiveDestroy", "air objective %1 was damaged (%2) or moved (%3 m) while settling - repaired and put back", [typeOf _object, damage _object, round (_object distance2D _spawnPos)]] call MCC_fnc_log;
				_object setDamage 0;
				_object setVelocity [0,0,0];
				_object setDir _spawndir;
				_object setPos _spawnPos;
				{_object setHitPointDamage [_x, 0]} forEach ((getAllHitPointsDamage _object) param [0, []]);
			};
			sleep 5;
			_object allowDamage true;
		};
	} else {
		_object = _type createvehicle _spawnPos;
		_object setpos _spawnPos;
		_object setdir _spawndir;
	};
};

//destroy only with satchel
if (_objType in ["tanks","aa","artillery","air"]) then {
		_init = '_this setVehicleLock "LOCKED";';
	_init = '_this setVehicleLock "LOCKED";';
	[[netID _object,_object], _init, false] remoteExec ["MCC_fnc_setVehicleInit", 2, false];

	if (_objType isEqualTo "artillery") then {[0,_object] spawn MCC_fnc_amb_Art};
	if (_objType isEqualTo "aa") then {[2,_object] spawn MCC_fnc_amb_Art};
};


if (isNull _object) then {
	["WARN", "fn_MWObjectiveDestroy", "%1 objective: could not create %2 at %3", [_objType, _type, _spawnPos]] call MCC_fnc_log;
} else {
	// Check the objective is still standing shortly after spawning
	[_object, _objType, _type, _spawnPos] spawn {
		params ["_object", "_objType", "_type", "_spawnPos"];
		sleep 15;
		switch (true) do {
			case (isNull _object): {["WARN", "fn_MWObjectiveDestroy", "%1 objective %2 spawned at %3 was deleted within 15 s", [_objType, _type, _spawnPos]] call MCC_fnc_log};
			case (!alive _object): {["WARN", "fn_MWObjectiveDestroy", "%1 objective %2 at %3 was destroyed within 15 s of spawning", [_objType, _type, getPos _object]] call MCC_fnc_log};
		};
	};
};

if (_objType in ["fuel","radar","radio"] && {!isNull _object}) then {
	private _cfg = configFile >> "CfgVehicles" >> _type;
	["INFO", "fn_MWObjectiveDestroy", "DESTROY TEST %1 objective %2 at %3: armor %4, destrType %5, damage now %6", [_objType, _type, mapGridPosition _object, getNumber (_cfg >> "armor"), getText (_cfg >> "destrType"), damage _object]] call MCC_fnc_log;
	_object addEventHandler ["Dammaged", {
		params ["_obj", "", "_damage"];
		["INFO", "fn_MWObjectiveDestroy", "DESTROY TEST %1 hit: total damage %2 (hit part %3), alive %4", [typeOf _obj, damage _obj, _damage, alive _obj]] call MCC_fnc_log;
	}];
	_object addEventHandler ["Killed", {
		params ["_obj", "_killer"];
		["INFO", "fn_MWObjectiveDestroy", "DESTROY TEST %1 destroyed (killer %2) - task completes", [typeOf _obj, _killer]] call MCC_fnc_log;
	}];
};

//Cache props take no damage in Arma 3 - make the cache destroyable so the task can complete
if (_objType == "cache" && {!isNull _object}) then {[_object] call MCC_fnc_MWCacheDestructible};

//Add to curator
{_x addCuratorEditableObjects [[_object],true]} forEach allCurators;

//Start Briefings
switch _objType do
{
	case "tanks":
	{
		[_object, getpos _object, "destroy_tanks",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "aa":
	{
		[_object, getpos _object,"destroy_aa",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "artillery":
	{
		[_object, getpos _object,"destroy_artillery",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "air":
	{
		[_object, getpos _object,"destroy_tanks",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "cache":
	{
		[_object, getpos _object,"destroy_cache",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "fuel":
	{
		[_object, getpos _object,"destroy_fuel",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "radio":
	{
		[_object, getpos _object,"destroy_radio",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	case "radar":
	{
		[_object, getpos _object,"destroy_radar",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};

	default
	{
		[_object, getpos _object,"destroy_cache",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
	};
};