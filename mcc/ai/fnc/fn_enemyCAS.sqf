//======================================================MCC_fnc_enemyCAS================================================================================================
// Create CAS in zone while radio tower is available
// Example:[_tower] spawn MCC_fnc_enemyCAS;
// _tower 	OBJECT  while object alive
// Return - nothing
//=======================================================================================================================================================================
private _tower = objNull;
private "_sideEnemy";
private _factionEnemy = "";
private "_sidePlayer";
private _casArray = [];
private _heliArray = [];
private _spawnPos = [];
private "_casGroup";
private _IsCAS = false;
private "_vehicleClass";
private "_casType";
private _cas = [];
private "_casVehicle";
private "_casPilot";
private "_ClosestZone";
private _totalCASActive = 0;
private _tempArray = [];
_tower = _this param [0, objNull, [objNull]];
_sideEnemy = _this param [1, east];
_factionEnemy = _this param [2, "OPF_F", [""]];
_sidePlayer = _this param [3, west];

_totalCASActive = missionNamespace getVariable ["MCC_totalCASActive",0];
if (_totalCASActive > 0) exitWith {};
_totalCASActive = _totalCASActive +1;
missionNamespace setVariable ["MCC_totalCASActive",_totalCASActive];

//(MK) the faction's own armed planes and helicopters (MCCMK_fnc_poolOwn - its pools, or a sibling's), then - with the
// "Vanilla vehicle fallback" setting on (the default) - the side's vanilla ones; with none at all, no air attack
_casArray = ([_factionEnemy, "PlaneCAS"] call MCCMK_fnc_poolOwn) apply {[0, _x]};
_heliArray = ([_factionEnemy, "HeliArmed"] call MCCMK_fnc_poolOwn) apply {[0, _x]};

//No CAS to this faction
_IsCAS = (random 1 > 0.5 && (count _casArray > 0 || count _heliArray == 0));

if ((count _casArray == 0 && _IsCAS) || (count _heliArray == 0 && !_IsCAS)) exitWith {};

_spawnPos = [_tower, 5000, random 360] call BIS_fnc_relPos;
_casType = if (_IsCAS) then {(_casArray call bis_fnc_selectRandom)} else {(_heliArray call bis_fnc_selectRandom)};
_vehicleClass = _casType select 1;

_cas = [_spawnPos,([_spawnPos, _tower] call BIS_fnc_dirTo), _vehicleClass, _sideEnemy, true, true, _factionEnemy] call MCC_fnc_spawnVehicle;

_casVehicle = _cas select 0;
[_casVehicle, "enemy CAS"] call MCCMK_fnc_airTrack;	//(MK) debug: logged when destroyed or removed
_casPilot = driver _casVehicle;
_casGroup = _cas select 2;

_casVehicle allowCrewInImmobile TRUE;
_casVehicle lock 2;
{_x addCuratorEditableObjects [[_casVehicle],true]} forEach allCurators;


if (_IsCAS) then {
	//Cas
	//(MK) air cover over the tower that PATROLS rather than circling one spot (one attack order on the tower: with nothing
	// there it just orbited it): a search and destroy somewhere up to 3 km from the tower at 600-1000 m, renewed in the
	// loop below. Still shown every aircraft near (its air cover job).
	_casVehicle flyInHeight (600 + random 400);
	_casGroup setCombatMode "RED";
	_casGroup setBehaviour "COMBAT";
	_casGroup setSpeedMode "FULL";
	private _wp = _casGroup addWaypoint [_tower getPos [800 + random 2200, random 360], 0];
	_wp setWaypointType "SAD";
	_wp setWaypointCompletionRadius 500;

} else {
	//Heli
	//(MK) its own orders over the tower area, not GAIA's: handed to GAIA with only "move to the nearest zone", it reached
	// the zone with nothing to do and landed to wait (GAIA's wait order). Search and destroy, refreshed in the loop below
	// so it keeps hunting rather than finishing its order and going idle
	_casVehicle flyInHeight 120;
	_casGroup setCombatMode "RED";
	_casGroup setBehaviour "COMBAT";
	_casGroup setSpeedMode "FULL";
	private _wp = _casGroup addWaypoint [_tower getPos [random 300, random 360], 0];
	_wp setWaypointType "SAD";
	_wp setWaypointCompletionRadius 150;
};

[_casVehicle, _casGroup, _IsCAS, _sidePlayer, _tower, _spawnPos] spawn {
	params ["_casVehicle", "_casGroup", "_IsCAS", "_sidePlayer", "_tower", "_spawnPos"];
	["MCCNotificationBad",["CAS","Enemy CAS approaching",""]] remoteExec ["bis_fnc_showNotification", _sidePlayer, false];
	private _next = 0;
	//(MK) on station while it lives and the tower stands
	while {alive _casVehicle && {alive _tower}} do {
		_casVehicle setVehicleAmmo 1;
		_casVehicle setFuel 1;
		if (_IsCAS) then {
			{_casVehicle reveal [_x, 4]} count ((getPosATL _casVehicle) nearEntities [["Air"], 7500]);
			//(MK) the plane's patrol: a fresh search and destroy up to 3 km from the tower, at a new height, every 2 minutes
			// or when it's done with its order
			if (time > _next || {(currentWaypoint _casGroup) >= (count (waypoints _casGroup))}) then {
				_next = time + 120;
				for "_i" from (count (waypoints _casGroup)) - 1 to 0 step -1 do {deleteWaypoint [_casGroup, _i]};
				private _wp = _casGroup addWaypoint [_tower getPos [800 + random 2200, random 360], 0];
				_wp setWaypointType "SAD";
				_wp setWaypointCompletionRadius 500;
				_casGroup setCurrentWaypoint _wp;
				_casVehicle flyInHeight (600 + random 400);
			};
		} else {
			// the helicopter: a fresh search and destroy over the tower area every 90 s, or when it's done with its order
			if (time > _next || {(currentWaypoint _casGroup) >= (count (waypoints _casGroup))}) then {
				_next = time + 90;
				for "_i" from (count (waypoints _casGroup)) - 1 to 0 step -1 do {deleteWaypoint [_casGroup, _i]};
				private _wp = _casGroup addWaypoint [_tower getPos [random 400, random 360], 0];
				_wp setWaypointType "SAD";
				_wp setWaypointCompletionRadius 150;
				_casGroup setCurrentWaypoint _wp;
			};
		};
		sleep 15;
	};
	if (alive _casVehicle) then {
		//(MK) the tower is down - their radio link is gone: it breaks off and flies away the way it came, and is removed
		// once it's 3 km from every player (or after 3 minutes)
		["MCCNotificationGood",["CAS","Enemy CAS withdrawing",""]] remoteExec ["bis_fnc_showNotification", _sidePlayer, false];
		for "_i" from (count (waypoints _casGroup)) - 1 to 0 step -1 do {deleteWaypoint [_casGroup, _i]};
		_casGroup setBehaviour "CARELESS";
		_casGroup setCombatMode "BLUE";
		private _away = [getPosATL _casVehicle, _tower getDir _spawnPos] call MCCMK_fnc_mapEdgeExit;	//(MK) off the edge of the map
		private _wp = _casGroup addWaypoint [_away, 0];
		_wp setWaypointType "MOVE";
		_casGroup setCurrentWaypoint _wp;
		_casVehicle flyInHeight 300;
		private _t = time + 720;
		waitUntil {sleep 5; !alive _casVehicle || {time > _t} || {((((getPosATL _casVehicle) select 0) < 0) || {((getPosATL _casVehicle) select 1) < 0} || {((getPosATL _casVehicle) select 0) > worldSize} || {((getPosATL _casVehicle) select 1) > worldSize})}};
	} else {
		["MCCNotificationGood",["CAS","Enemy CAS down",""]] remoteExec ["bis_fnc_showNotification", _sidePlayer, false];
		sleep 30;
	};
	{if (!isNull _x) then {deleteVehicle _x}} forEach (units _casGroup);
	if (!isNull _casVehicle) then {deleteVehicle _casVehicle};
	missionNamespace setVariable ["MCC_totalCASActive", ((missionNamespace getVariable ["MCC_totalCASActive", 0]) - 1) max 0];
};