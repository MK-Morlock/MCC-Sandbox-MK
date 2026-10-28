//===================================================================MCC_fnc_garrison======================================================================================
//Populate soldiers inside empty houses
//Example:[center,radius,action,intanse,faction,side,_groupUnits] remoteExec ["MCC_fnc_garrison", true, false];
// Params:
// 	center: array, center of the town to garrison.
//	radius: number,radius in meters units will garrison buildings.
//	action:  number, 0 - do not spawn empty vehicles 1 - spawn empty vehicles.
//	intanse:  number, probability of a garrison units between 0-10 the higher the number more units will show
//	faction: units will garrison from the same faction.
//	side: side, [west, east, resistance, civilian]
//	_groupUnits (optional) if broadcast will build all units in the same group
//=========================================================================================

private _center = [];
private _radius = 0;
private _spawnVehicles = false;
private _intanse = 0;
private _faction = "";
private _unitsArray = [];
private _vehiclesArray = [];
private _group = grpNull;
private _unitsCount = 0;
private _vehiclesCount = 0;
private _buildingsArray = objNull;
private _buildingscount = 0;
private _side = nil;
private _spawnPos = [];
private _unit = objNull;
private _type = "";
private _vehiclesNumber = 0;
private _roads = [];
private _road = objNull;
private _vehicle = objNull;
private _groupUnits = false;
private _locked = false;
private _roadPos = [];

disableSerialization;

_center			= _this param [0, []];
_radius			= _this param [1, 100];
_spawnVehicles 	= if (typeName (_this select 2) == typeName 0) then {(_this select 2)==1} else {_this select 2};
_intanse		= _this param [3, 5];
_faction		= _this param [4, "CIV_F"];
_side			= _this param [5, civilian];
_groupUnits 	= _this param [6, false];
_locked			= _this param [7, false];

_unitsArray 	= [[_faction,"soldier","men"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry;	//no pilots / crews / divers (a fighter pilot stood in a building)		//Let's build the faction unit's array
if(count _unitsArray < 4) then {
	_unitsArray = [[_faction,"soldier"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry;
};

_vehiclesArray	= [_faction,"carx","car"] call MCC_fnc_makeUnitsArray;		//Let's build the faction vehicles's array
if(count _vehiclesArray < 4) then {
	_vehiclesArray = [_faction,"carx"] call MCC_fnc_makeUnitsArray;
};

_buildingsArray	= nearestObjects  [_center,["House","Ruins","Church","FuelStation","Strategic"],_radius];	//Let's find the buildings in the area

_unitsCount		= count _unitsArray;
_vehiclesCount	= count _vehiclesArray;
_buildingscount	= count _buildingsArray;


if (typeName _side == "STRING") then {
	switch (toLower _side) do
	{
		case "west": {_side =  west};
		case "east": {_side =  east};
		case "guer": {_side =  resistance};
		case "civ": {_side =  civilian};
	};
};

if (isnil "_side") exitWith {};
if (count _unitsArray == 0) exitWith {
	["WARN", "MCC_fnc_garrison", "faction %1 has no soldiers to garrison with", [_faction]] call MCC_fnc_log;
};

if (_buildingscount < 1) exitwith {hint "No buildings found"};	//No available buildings? stop the script!
{
	_buildingPos = _x call MCC_fnc_buildingPosCount;
	if (_buildingPos > 0) then
	{	//If the building have an interrior positions
		if (_groupUnits) then {_group = creategroup _side};

		for [{_i=0},{_i<_buildingPos},{_i=_i+1}] do
		{
			_spawnPos	= _x buildingPos _i;

			//Let's roll the dice
			if (random 30 < _intanse) then {
				//No other unit in the spawn position?
				if (count (nearestObjects [_spawnPos, ["Man"], 1])<1) then {
					// (was "_unitsArray select round (random 4)": only the first 5 types, and nothing at all - plus a
					//  script error - when the faction had fewer than 5)
					_type = selectRandom _unitsArray;
					if !(_groupUnits) then {_group = creategroup _side};
					_unit = _group createUnit [_type select 0,_spawnPos,[],0.5,"NONE"];
					if (isNull _unit) then {continue};
					waituntil {alive _unit || isNull _unit};
					_unit setpos _spawnPos;

					//Put it on safe
					_group setBehaviour "SAFE";
					//_group setSpeedMode "LIMITED";

					//Lets make a happy walker
					if (random 1 < 0.2) then {
						[_group,_radius] spawn MCC_fnc_garrisonBehavior;
					} else {
						//Make them stand
						{
							_x setUnitPos "UP";
							_x setdir round(random 360);
						} foreach units _group;

					};

					//Cache
					_group setVariable ["mcc_gaia_cache",mcc_caching];

					//Curator
					{_x addCuratorEditableObjects [[_unit],false]} forEach allCurators;
					//_unit setVariable ["vehicleinit",";_this setpos (getpos_this);"];

				};
			}
		};
	};
} foreach _buildingsArray;

//vehicles
if (_spawnVehicles) then	{
	private _roadConnectedTo = [];
	private _connectedRoad = nil;
	private _dir = nil;

	_vehiclesNumber=round((_buildingscount*_intanse)/12);
	if (_vehiclesNumber > 8) then {_vehiclesNumber = 8};

	_roads = _center nearRoads _radius;
	if (count _roads < 5) exitWith {};

	for "_i" from 1 to _vehiclesNumber do {
		if (count _roads <= 0) exitWith {};

		_road = _roads call BIS_fnc_selectRandom;
		_roads = _roads - [_road];

		_roadConnectedTo 	= roadsConnectedTo _road;
		_connectedRoad 		= _roadConnectedTo select 0;

		if (!isnil "_connectedRoad") then {
			_dir = [_road, _connectedRoad] call BIS_fnc_DirTo;
			if (isnil "_dir") then {_dir = getdir _road};
			_roadPos = if (random 1 > 0.5) then {_road modelToWorld [6,0,0]} else {_road modelToWorld [-6,0,0]};

			//Why the hell we have karts in a milsim?!
			_type = "";
			while {_type in ["","C_Kart_01_Blu_F","C_Kart_01_F","C_Kart_01_F_Base","C_Kart_01_Fuel_F","C_Kart_01_Red_F","C_Kart_01_Vrana_F"]} do {
				_type = (_vehiclesArray select (floor (random (_vehiclesCount)))) select 0;
				sleep 0.1;
			};

			_spawnPos = [];
			_radius = 5;
			//Make sure the vehicle is not in a wall on the road side
			while {_spawnPos isEqualTo []} do {
				_spawnPos = _roadPos findEmptyPosition [0.1,_radius, _type];
				_radius = _radius +5;
				sleep 0.1;
			};

			_vehicle= _type createVehicle _spawnPos;
			waituntil {alive _vehicle};
			_vehicle allowDamage false;
			_vehicle setpos _spawnPos;
			_vehicle setDir _dir;

			if (_locked || random 1 > 0.5) then {
				_vehicle setVehicleLock "LOCKED";
			};

			sleep 0.1;

			if (!isTouchingGround _vehicle || !alive _vehicle) then {
				deleteVehicle _vehicle;
			} else {
				_vehicle allowDamage true;

				//Curator
				{_x addCuratorEditableObjects [[_vehicle],false]} forEach allCurators;
			};
		};
	};
};