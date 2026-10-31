private _unitsArray = [];
private _vehiclesArray = [];
private _group = grpNull;
private "_unitsCount";
private "_vehiclesCount";
private _buildingsArray = objNull;
private "_buildingscount";
private "_spawnPos";
private _unit = objNull;
private "_type";
private _vehiclesNumber = 0;
private "_roads";
private "_road";
private _vehicle = objNull;
private _groupUnits = false;

disableSerialization;

params ["_center", "_radius", "_action", "_intanse", "_faction", "_side"];
_groupUnits 	= if (count _this >6) then {true} else {false};

_unitsArray 	= [[_faction,"soldier"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry;		//Let's build the faction unit's array
_vehiclesArray	= [_faction,"carx"] call MCC_fnc_makeUnitsArray;		//Let's build the faction vehicles's array
_buildingsArray	= nearestObjects  [_center,["House","Ruins","Church","FuelStation","Strategic"],_radius];	//Let's find the buildings in the area
_buildingsArray = _buildingsArray select {!(_x call MCC_fnc_isWaterStructure)};

_unitsCount		= count _unitsArray;
_vehiclesCount	= count _vehiclesArray;
_buildingscount	= count _buildingsArray;

switch (toLower _side) do	{
	case "west": {_side =  west};
	case "east": {_side =  east};
	case "guer": {_side =  resistance};
	case "civ": {_side =  civilian};
	};
		
if (_action == 0 || _action == 1) then	{	//Garisson
	if (_buildingscount < 1) exitwith {hint "No buildings found"};	//No available buildings? stop the script!
	if (_groupUnits) then {_group = creategroup _side}; 
	{
		_buildingPos = _x call MCC_fnc_buildingPosCount;
		if (_buildingPos > 0) then	{	//If the building have an interrior positions
			for [{_i=0},{_i<_buildingPos},{_i=_i+1}] do {
				_spawnPos	= _x buildingPos _i; 
				if (random 10 < _intanse/2) then	{	//Let's roll the dice 
					if (count (nearestObjects [_spawnPos, ["Man"], 1])<1) then	{ 	//No other unit in the spawn position?
						_type = _unitsArray select round (random 4); 
						if !(_groupUnits) then {_group = creategroup _side}; 
						_unit = _group createUnit [_type select 0,_spawnPos,[],0.5,"NONE"];
						sleep 0.5;
						_unit setBehaviour "SAFE";
						_unit setUnitPos "UP";
						_unit setpos _spawnPos;
						_unit setpos _spawnPos;
						_group setFormDir (round(random 360));
					};
				}
			};
		};
	} foreach _buildingsArray;
};

if (_action == 1) then	{	//vehicles
	_vehiclesNumber=round((_buildingscount*_intanse)/20);
	_roads = _center nearRoads _radius;
		hint format ["car: %1",_roads];
	   
	  for "_i" from 1 to _vehiclesNumber do
	  {        
		_road = _roads select floor(random (count _roads));
		_spawnPos = getpos _road;
		_type = _vehiclesArray select (floor (random (_vehiclesCount)));
		_vehicle= (_type select 0) createVehicle _spawnPos;
		_vehicle setDir (direction _road)+ 90;
		_spawnPos = _vehicle modelToWorld [3,0,0];
		
		//Make sure the vehicle is not in a wall on the road side
		_spawnPos = _spawnPos findEmptyPosition [0.1,10];
		_vehicle setpos _spawnPos;
		};
};