//======================================================MCC_fnc_MWSpawnInZone=========================================================================================================
// Create a pick intel objective
// Example:[_zoneNumber,_spawnType,_classtype,_spawnwithcrew,_spawnname,_spawnfaction,_spawnbehavior,_spawndisplayname] call MCC_fnc_MWSpawnInZone;
// Return - handler
//========================================================================================================================================================================================
private _previusZone = "";
private _safe_pos = [];
private _p_mcc_zone_markposition = [];
private _p_maxrange = 0;
private _ar = [];

params [
	["_zoneNumber", 0, [0, ""]],
	["_spawnType", "", [""]],
	["_classtype", "", [""]],
	["_spawnwithcrew", false, [false]],
	["_spawnname", "", [""]],
	["_spawnfaction", "", [""]],
	["_spawnbehavior", "", [""]],
	["_spawndisplayname", "", [""]],
	["_side", sideUnknown, [sideUnknown]]
];


//time to request something so lets number it
mcc_request= (missionNamespace getVariable ["mcc_request",0])+1;
publicVariable "mcc_request";

// What ever we do, we need a good position
_p_mcc_zone_markposition = (mcc_zone_pos select (_zoneNumber));
_p_maxrange				 = ((mcc_zone_size select (_zoneNumber)) select 1);
// BIS_fnc_findSafePos divides by this value internally (Zero divisor if it's 0) - its own
// docs use -1 to mean "use the world's default safePositionRadius", so fall back to that
// rather than passing through a zone size of 0 (e.g. a zone that hasn't been sized yet).
if (_p_maxrange <= 0) then {_p_maxrange = -1};


private _spread = missionNamespace getVariable ["MCC_MWSpreadActive", 1];
private _landPickRaw = {
	private _p = [-500,-500,0];
	if (_spread != 1) then {
		for "_t" from 1 to 12 do {
			private _r = _p_maxrange * (if (_spread == 2) then {sqrt (random 1)} else {(random 1) ^ 2});
			private _s = [_p_mcc_zone_markposition getPos [_r, random 360], 0, 40, 2, 0, 100, 0, [], [[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
			if !(_s isEqualTo [-500,-500,0]) exitWith {_p = _s};
		};
	};
	if (_p isEqualTo [-500,-500,0]) then {_p = [_p_mcc_zone_markposition,1,_p_maxrange,2,0,100,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos};
	_p
};
private _landPick = {
	private _p = [-500,-500,0];
	for "_t" from 1 to 10 do {
		_p = call _landPickRaw;
		if ((_p isEqualTo [-500,-500,0]) || {count ([_p, 0, 1] call MCC_fnc_landSpot) > 0}) exitWith {};
	};
	_p
};
switch (_classtype) do
{
	case "AIR":
	{
		if !_spawnwithcrew then
		{_safe_pos     =[_p_mcc_zone_markposition,1,_p_maxrange,2,0,100,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos; }
		else
		{_safe_pos     =[_p_mcc_zone_markposition ,1,_p_maxrange,2,1,10,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;};
	};

	case "Reinforcement":
	{
		_safe_pos     =[_p_mcc_zone_markposition,1,_p_maxrange,2,0,100,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
	};

	case "DIVER":
	{
		_safe_pos     =[_p_mcc_zone_markposition,1,_p_maxrange,2,1,100,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
	};

	case "LAND":
	{
		_safe_pos     = call _landPick;
	};

	case "WATER":
	{
		_safe_pos     =[_p_mcc_zone_markposition,1,_p_maxrange,2,2,100,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
	};

	default
	{
		_safe_pos     = call _landPick;
	};
};

if !(_classtype in ["WATER", "DIVER"] || {_classtype == "AIR" && {_spawnwithcrew}}) then {
	private _tries = 0;
	if (!(_safe_pos isEqualTo [-500,-500,0]) && {[_safe_pos] call MCC_fnc_posOnBuilding}) then {
		private _near = [_safe_pos, _p_mcc_zone_markposition, _p_maxrange] call MCC_fnc_openSpotNear;
		if (count _near > 0) then {
			["INFO", "fn_MWSpawnInZone", "spawn spot was on a building - moved to open ground nearby for %1: %2", [_spawnname, _near]] call MCC_fnc_log;
			_safe_pos = _near;
		} else {
			while {_tries < 12 && {!(_safe_pos isEqualTo [-500,-500,0])} && {[_safe_pos] call MCC_fnc_posOnBuilding}} do {
				_tries = _tries + 1;
				_safe_pos = call _landPick;
			};
			["INFO", "fn_MWSpawnInZone", "spawn spot was on a building - no open ground nearby, searched the zone again %1 time(s) for %2: %3", [_tries, _spawnname, _safe_pos]] call MCC_fnc_log;
		};
	};
};

if (!(_classtype in ["WATER", "DIVER", "AIR"]) && {_safe_pos isEqualTo [-500,-500,0]}) then {
	private _fb = [_p_mcc_zone_markposition, _p_maxrange, format ["zone %1 spawn", _zoneNumber], true] call MCC_fnc_fallbackSpot;
	if !(_fb isEqualTo []) then {_safe_pos = _fb};
};
if (!(_classtype in ["WATER", "DIVER", "AIR"]) && {!(_safe_pos isEqualTo [-500,-500,0])}) then {
	if (isNil "MCC_MWRecentSpawns") then {MCC_MWRecentSpawns = []};
	MCC_MWRecentSpawns = MCC_MWRecentSpawns select {(time - (_x select 1)) < 300};
	private _tries = 0;
	while {_tries < 10 && {(MCC_MWRecentSpawns findIf {((_x select 0) distance2D _safe_pos) < 20}) >= 0}} do {
		_tries = _tries + 1;
		private _alt = call _landPick;
		if (!(_alt isEqualTo [-500,-500,0]) && {!([_alt] call MCC_fnc_posOnBuilding)}) then {_safe_pos = _alt};
	};
	MCC_MWRecentSpawns pushBack [_safe_pos, time];
};

if (!(_safe_pos isEqualTo [-500,-500,0]) && {isClass (configFile >> "CfgVehicles" >> _spawnname)} && {_spawnname isKindOf "LandVehicle"}) then {
	private _clear = [_safe_pos, _spawnname] call MCC_fnc_clearVehicleSpot;
	if (count _clear > 0) then {_safe_pos = _clear} else {["INFO", "fn_MWSpawnInZone", "no clear vehicle spot near %1 for %2 - using the original spot", [_safe_pos, _spawnname]] call MCC_fnc_log};
	private _driveOut = [_safe_pos, _spawnname, _p_mcc_zone_markposition] call MCC_fnc_vehicleCanDriveOut;
	for "_t" from 1 to 4 do {
		if (_driveOut) exitWith {};
		private _alt = call _landPick;
		if !(_alt isEqualTo [-500,-500,0]) then {
			private _c = [_alt, _spawnname] call MCC_fnc_clearVehicleSpot;
			if (count _c > 0 && {[_c, _spawnname, _p_mcc_zone_markposition] call MCC_fnc_vehicleCanDriveOut}) then {_safe_pos = _c; _driveOut = true};
		};
	};
	if (!_driveOut) then {
		private _road = [_p_mcc_zone_markposition, _spawnname] call MCC_fnc_roadsideSpot;
		if (_road isEqualTo []) then {_road = [_safe_pos, _spawnname] call MCC_fnc_roadsideSpot};
		if (count _road > 0) then {
			["DEBUG", "fn_MWSpawnInZone", "%1 could not drive out from %2 - moved to the roadside at %3", [_spawnname, mapGridPosition _safe_pos, mapGridPosition _road]] call MCC_fnc_log;
			_safe_pos = _road;
		} else {
			["DEBUG", "fn_MWSpawnInZone", "%1 could not drive out from %2 and there is no road nearby - kept there", [_spawnname, mapGridPosition _safe_pos]] call MCC_fnc_log;
		};
	};
};

_ar =	[ 		  _spawnType
				, _classtype
				, false
				, _spawnwithcrew
				, _spawnname
				, _spawnfaction
				, _zoneNumber
				, 'NOTHING'
				, str _zoneNumber
				, _spawnbehavior
				, (mcc_zone_pos select (_zoneNumber))
				, (mcc_zone_size select (_zoneNumber))
				, ((mcc_zone_size select (_zoneNumber)) select 1)
				, _side
				, objNull
				, mcc_request
				, false
				, false
				, "server"
				, 'default'
				, 1
				, [0,0,0]
				, 0 //(mcc_zonetype select 0 ) select 1
				, 0 //(mcc_zonetypenr select 0 ) select 1
				, 0
				, _safe_pos
				, false
				, false
				];

// Send data over the network, or when on server, execute directly
if ( (isServer) && ( (mcc_hc == 0) || !(MCC_isHC) ) ) then {
	_ar remoteExec ["mcc_setup", 2, false];
	if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log "MCC: attempting to spawn"};

} else {
	if ( ( mcc_hc == 0 ) || !(MCC_isHC) ) then	{
		_ar remoteExec ["mcc_setup", 2, false];
	};

	if (( mcc_hc == 1 ) && (MCC_isHC)) then	{

		_ar remoteExec ["mcc_setup_hc", MCC_ownerHC, false];
	};
};
if (canSuspend) then {sleep (missionNamespace getVariable ["MCC_spawnPacing", 0.5])};
