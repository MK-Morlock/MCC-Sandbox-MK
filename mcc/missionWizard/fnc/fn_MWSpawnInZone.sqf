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

_previusZone = format ["%1", mcc_active_zone];
_previusZone setMarkerColorLocal "colorBlack";
_previusZone setMarkerBrushLocal "Solid";

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
		_safe_pos     =[_p_mcc_zone_markposition,1,_p_maxrange,2,0,100,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
	};

	case "WATER":
	{
		_safe_pos     =[_p_mcc_zone_markposition,1,_p_maxrange,2,2,100,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
	};

	default
	{
		_safe_pos     =[_p_mcc_zone_markposition,1,_p_maxrange,2,0,100,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
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
				_safe_pos = [_p_mcc_zone_markposition,1,_p_maxrange,2,0,100,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
			};
			["INFO", "fn_MWSpawnInZone", "spawn spot was on a building - no open ground nearby, searched the zone again %1 time(s) for %2: %3", [_tries, _spawnname, _safe_pos]] call MCC_fnc_log;
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
