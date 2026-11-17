//==================================================================MCC_fnc_reinforcement===============================================================================================
//Contorol the paratroop reinforcement spawn
// Example:[_endPos,_side,_size,_zoneMarker,_faction,_startPosDir] spawn MCC_fnc_reinforcement;
// <IN>
//	_endPos:					Array- position.
//	_side:					String or side, side to call "West","East","Resistance"
//	_size:					Integer, 	0 -"small
//								1 - medium
//								2 - large
//	_zoneMarker				String, Zone number the reinforcement's cargo will patrol that zone.
//	_faction					String, Faction name.
//	_startPosDir				Array, spawn and de-spawn location for the reinforcement.
//===========================================================================================================================================================================
private _unitsArray = [];
private "_size";
private "_zoneMarker";
private "_faction";
private "_startPosDir";
private _vehiclesArray = [];
private _groupVehicles = grpNull;
private _limit = [];
private _counter = 0;
private "_vehicleClass";
private "_nearRoads";
private _vehicle = [];
private _vehiclesTypesArray = [];
private _cargoyGroupArray = [];
params ["_endPos", "_side"];
_size 					=  if (TypeName  (_this select 2) == "STRING") then {call compile (_this select 2)} else {(_this select 2)};
_zoneMarker 			=  if (TypeName  (_this select 3) == "STRING") then {(_this select 3)} else {str (_this select 3)};
_faction				= _this select 4;
_startPosDir			= _this select 5;
private _mwZone = param [6, "", [""]];
private _requester = param [7, objNull, [objNull]];	//(MK) who ordered it (the console): told if it can't come	//(MK) a generated mission's QRF: its zone (the mission's cleanup removes it all)

if (TypeName _side == "STRING") then
{
	switch (toUpper _side) do
	{
		case "WEST": {_side = west};
		case "EAST": {_side = east};
		case "GUER": {_side = resistance};
		case "CIV": {_side = civilian};
	};
};

//(MK) the faction's infantry pool (MCCMK_fnc_pools: its own content, then official DLC, then all; none: a sibling
// faction's - never a vanilla soldier)
_unitsArray = ([_faction, "InfMen"] call MCCMK_fnc_pool) apply {[_x]};	// ordinary soldiers, as the original
if ( (count _unitsArray) == 0 ) exitWith { if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["MCC Warning: no suitable reinforcement group found for %1", _this]}; systemchat format ["Error: no suitable reinforcement group for this Faction"]; };

//(MK) its trucks, cars and APCs from the faction's pools (MCCMK_fnc_pools: own content, then official DLC, then all;
// none: a sibling faction's; none at all: the side's vanilla vehicle) - crewed and filled by its own soldiers
_vehiclesTypesArray = ([_faction, "Truck"] call MCCMK_fnc_pool) + ([_faction, "Car"] call MCCMK_fnc_pool) + ([_faction, "APC"] call MCCMK_fnc_pool);
_vehiclesTypesArray = (_vehiclesTypesArray arrayIntersect _vehiclesTypesArray) apply {[_x]};

if ( (count _vehiclesTypesArray) == 0 ) exitWith { if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["MCC Warning: no suitable reinforcement group found for %1", _this]}; systemchat format ["Error: no suitable reinforcement group for this Faction"]; };

//Find a road: (MK) the original start - the road nearest the start given (a mission's QRF: on a road already) -
//searched up to 2 km instead of 500 m; none at all: whoever ordered it is told why, and nothing spawns
_nearRoads = objNull;
{
	if (isNull _nearRoads) then {
		private _rr = [_startPosDir, _x] call MCC_fnc_nearestRoad;
		if (count _rr > 0) then {_nearRoads = _rr select 0};
	};
} forEach [500, 1000, 2000];
if (isNull _nearRoads) exitWith {
	["INFO", "MCC_fnc_reinforcement", "no road within 2 km of %1 for a motorised reinforcement - not sent", [mapGridPosition _startPosDir]] call MCC_fnc_log;
	if (!isNull _requester && {isPlayer _requester}) then {["No road near that point for a motorised reinforcement.\nPick another spot or use an aerial one."] remoteExec ["MCCMK_fnc_hint", _requester]};
};
_startPosDir = getposAtl _nearRoads;

//Let's build the group and vehicles
_groupVehicles = creategroup _side;

_size = _size - 9;
_limit = [2,3,4] select _size;
_counter = 1;
_vehiclesArray = [];

while {_counter <=_limit} do
{
	_vehicleClass = [_vehiclesTypesArray, "transport", 4] call MCCMK_fnc_pickVehicle;
	private _fitTransport = _vehicleClass != "";
	if (!_fitTransport) then {_vehicleClass = (_vehiclesTypesArray call BIS_fnc_selectRandom) select 0};

	if (_fitTransport || {(getNumber (configfile >> "CfgVehicles" >> _vehicleClass >> "transportSoldier") > 2) || (count (configfile >> "CfgVehicles" >> _vehicleClass >> "Turrets") >0)}) then
	{
		_isFlat = [_startPosDir, _vehicleClass] call MCC_fnc_safeSpawnPos;
		_vehicle = [_isFlat , ([_isFlat, _endPos] call BIS_fnc_dirTo), _vehicleClass, _groupVehicles, true, true, _faction] call MCC_fnc_spawnVehicle;	//(MK) the faction's crew
		_vehiclesArray set [count _vehiclesArray, (_vehicle select 0)];
		_counter = _counter + 1;

		//Curator
		{_x addCuratorEditableObjects [[(_vehicle select 0)],true]} forEach allCurators;
	};
};
sleep 0.5;
_groupVehicles setFormation "COLUMN";

_cargoyGroupArray = [];
{
	[_x, _faction]  call MCC_fnc_populateVehicle;	//(MK) the faction's soldiers, whatever the vehicle
} foreach _vehiclesArray;
if (_mwZone != "") then {	//(MK) the mission's cleanup removes them, vehicles included, empty or not
	{
		_x setVariable ["MCC_MWReinforceZone", _mwZone];
		{(group _x) setVariable ["MCC_MWReinforceZone", _mwZone]} forEach (crew _x);
	} forEach _vehiclesArray;
	_groupVehicles setVariable ["MCC_MWReinforceZone", _mwZone];
};

sleep 1;

//Find a road near destination
_nearRoads = ([_endPos,500] call MCC_fnc_nearestRoad) call BIS_fnc_selectRandom;

//Add WP
private "_wpPos";
private "_car1";
private "_car";
private _transportCars = [];
private _transportCarsGroup = grpNull;
if (isnull  _nearRoads) then
{
	_wpPos = _endPos;
}
else
{
	_wpPos = getposAtl _nearRoads;
};

_wp = _groupVehicles addWaypoint [_wpPos, 30];
_wp setWaypointType "MOVE";
_wp setWaypointCompletionRadius 500;
_wp setwaypointCombatMode "YELLOW";
_wp setWaypointFormation "COLUMN";
_wp setWaypointBehaviour "SAFE";
_wp setWaypointSpeed "FULL";

_car1 = vehicle leader _groupVehicles;
waitUntil {sleep 5; (!(canMove _car1) || (currentCommand _car1 == "") || (_car1 distance _wpPos) < 250); };

//Stop WP
[2,_wpPos,[0,"NO CHANGE","NO CHANGE","UNCHANGED","UNCHANGED","", {},0],[_groupVehicles]] call MCC_fnc_manageWp;
sleep 3;

private _transportCars = [];
private _transportCarsGroup = createGroup _side;
if (_mwZone != "") then {_transportCarsGroup setVariable ["MCC_MWReinforceZone", _mwZone]};	//(MK) the mission's cleanup

{
	if !( isNil "_x" ) then
	{
		_car = _x;

		//If transport car
		if ((count (configfile >> "CfgVehicles" >> typeOF _car >> "Turrets")  == 0)) then {
			_transportCars pushBack _car;
			[_car] joinSilent _transportCarsGroup;
		};

		waitUntil { (currentCommand _car == "") };
		{
			if ( !( (_x == driver _car) || (_x == gunner _car) || (_x == commander _car) ) && ( alive _x ) ) then
			{
				if !(group _x in _cargoyGroupArray) then {_cargoyGroupArray set [count _cargoyGroupArray, group _x]};
				unassignVehicle _x;
				_x action ["getOut", _car];
				sleep 0.6;
			};
		} foreach crew _car;

	};
} foreach _vehiclesArray;

_vehiclesArray = _vehiclesArray - _transportCars;

{
	_x setVariable ["GAIA_ZONE_INTEND",[_zoneMarker,"MOVE"], true];
} foreach _cargoyGroupArray;

sleep 10;

_groupVehicles setVariable ["GAIA_ZONE_INTEND",[_zoneMarker,"MOVE"], true];
_transportCarsGroup setVariable ["GAIA_ZONE_INTEND",[_zoneMarker,"MOVE"], true];