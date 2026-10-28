//============================================================MCC_fnc_ambientInit=====================================================================================
// Spawn selected units around the player
// _isCiv:				BOOLEAN - units running around?
// _isCar:				BOOLEAN - Will have driving cars around
// _isParkedCar:		BOOLEAN - Will have parked cars around
// _isLocked			BOOLEAN - Will the parked cars will allways be locked
// _civSpawnDistance	INTEGER - Spawn distance around the players
// _civSpawnDistance	INTEGER - max units spawned around the player
// _factionCiv			STRING - the units' faction
// _factionCivCar		STRING - the units' cars faction
//==================================================================================================================================================================
private _spawnCenters = [];
private _isCiv = false;
private "_player";
private _civArray = [];
private _civCount = 0;
private _civSpawnDistance = 0;
private _maxCivSpawn = 0;
private _factionCiv = "";
private _unitsArray = [];
private _vehiclesArray = [];
private _isCar = false;
private _carCount = 0;
private _carArray = [];
private _isParkedCar = false;
private _isLocked = false;
private "_civRelations";
private _factionCivCar = "";
_isCiv =  param [0, true, [true]];
_isCar = param [1, true, [true]];
_isParkedCar = param [2, true, [true]];
_isLocked  = param [3, false, [true]];
_civSpawnDistance = param [4, 250, [250]];
_maxCivSpawn = param [5, 4, [4]];
_factionCiv	= param [6, "CIV_F", [""]];
_factionCivCar = param [7, "CIV_F", [""]];

// Only one ambient-civilians loop runs: starting it again (placing the module again) replaces the previous settings.
// With civilians, driving cars and parked cars all unticked it stops and removes every ambient civilian and car.
private _runId = (missionNamespace getVariable ["MCC_ambientRunId", 0]) + 1;
missionNamespace setVariable ["MCC_ambientRunId", _runId];

private _fnc_clear = {
	params ["_var", "_isVehicle"];
	{
		if (!isNull _x) then {
			if (_isVehicle) then {{deleteVehicle _x} forEach crew _x};
			private _grp = group _x;
			deleteVehicle _x;
			if (!isNull _grp && {count units _grp == 0}) then {deleteGroup _grp};
		};
	} forEach (missionNamespace getVariable [_var, []]);
	missionNamespace setVariable [_var, [], true];
};
if (!_isCiv) then {["MCC_ambientCivilians", false] call _fnc_clear};
if (!_isCar) then {["MCC_ambientCars", true] call _fnc_clear};
if (!_isParkedCar) then {["MCC_ambientParkedCars", true] call _fnc_clear};

if (!_isCiv && !_isCar && !_isParkedCar) exitWith {
	["INFO", "MCC_fnc_ambientInit", "ambient civilians stopped and removed", []] call MCC_fnc_log;
};
["INFO", "MCC_fnc_ambientInit", "ambient civilians started: civilians %1, driving cars %2, parked cars %3, distance %4, max %5, faction %6 / %7", [_isCiv, _isCar, _isParkedCar, _civSpawnDistance, _maxCivSpawn, _factionCiv, _factionCivCar]] call MCC_fnc_log;

//Let's build the faction unit's array
_unitsArray 	= [_factionCiv,"soldier","men"] call MCC_fnc_makeUnitsArray;
if(count _unitsArray < 4) then {
	_unitsArray = [_factionCiv,"soldier"] call MCC_fnc_makeUnitsArray;
};

//Let's build the faction vehicles's array
_vehiclesArray	= [_factionCivCar,"carx","car"] call MCC_fnc_makeUnitsArray;
if(count _vehiclesArray < 4) then {
	_vehiclesArray = [_factionCivCar,"carx"] call MCC_fnc_makeUnitsArray;
};

//Scared civi AI beahvior
MCC_fnc_ambientCivilianFiredNearEH = {
	params ["_civ","_shooter"];
	private _runAwayPos = [];
	if ((_civ getVariable ["MCC_ambientCiviliansIsScared",false]) || !(_civ == driver vehicle _civ)) exitWith {};

	_civ setVariable ["MCC_ambientCiviliansIsScared",true];
	if (!(lineIntersects [ eyePos _civ, getPosASL _shooter, _civ, _shooter]) &&
	    vehicle _civ == _civ
	   ) then {
		_runAwayPos = [_shooter, (50 + random 200),([_shooter,_civ] call BIS_fnc_dirTo)] call BIS_fnc_relPos;

		_civ setSpeedMode "FULL";
		_civ setBehaviour "COMBAT";

		if (vehicle _civ == _civ ) then {
			_civ playMoveNow (switch (round (random 2)) do {
				case 0:{"ApanPpneMstpSnonWnonDnon_G01"};
				default {"ApanPknlMsprSnonWnonDf"};
			});
		};

		//Give WP
		[1,_runAwayPos,[0,"RED","NO CHANGE","FULL","COMBAT","true", "",0],[group _civ]] spawn MCC_fnc_manageWp;
	};
};

while {(missionNamespace getVariable ["MCC_ambientRunId", 0]) == _runId} do {
	_spawnCenters = if (isMultiplayer) then {playableUnits} else {[player]};

	//Do we have units going around?
	{
		_player = _x;

		//Gets the civilian reaction
		_civRelations = (missionNamespace getvariable [format ["MCC_civRelations_%1",side _player],param [8, 0.9, [0]]]);

		if (isPlayer _player) then {
			if (_isCiv) then {
				[_spawnCenters,_civSpawnDistance,"MCC_ambientCivilians"] call MCC_fnc_ambientDeleteCiv;
				_civCount = 0;
				_civArray = missionNamespace getVariable ["MCC_ambientCivilians",[]];
				{
					if (_x distance _player < _civSpawnDistance) then {
						_civCount = _civCount + 1;
					};
				} forEach _civArray;

				if (_civCount < _maxCivSpawn) then {
					[getpos _player, (_maxCivSpawn -_civCount),_factionCiv,_civSpawnDistance,_unitsArray, side _player,_civRelations] call MCC_fnc_ambientSpawnCiv;
				};
			};

			//Do we have traffic going around?
			if (_isCar) then {
				[_spawnCenters,_civSpawnDistance*2] call MCC_fnc_ambientDeleteCar;

					_carCount = 0;
					_carArray = missionNamespace getVariable ["MCC_ambientCars",[]];
					{
						if (_x distance _player < _civSpawnDistance*2) then {
							_carCount = _carCount + 1;
						};
					} forEach _carArray;

					if (_carCount < _maxCivSpawn/2) then {
						[getpos _player, (_maxCivSpawn/2 -_carCount),_factionCiv,_civSpawnDistance*2,_vehiclesArray] call MCC_fnc_ambientSpawnCar;
					};
			};

			//Do we have parked cars going around?
			if (_isParkedCar) then {
				[_spawnCenters,_civSpawnDistance] call MCC_fnc_ambientDeleteCarParked;

				_carCount = 0;
				_carArray = missionNamespace getVariable ["MCC_ambientParkedCars",[]];
				{
					if (_x distance _player < _civSpawnDistance) then {
						_carCount = _carCount + 1;
					};
				} forEach _carArray;

				if (_carCount < _maxCivSpawn) then {
					[getpos _player, (_maxCivSpawn -_carCount),_civSpawnDistance,_vehiclesArray,_isLocked, side _player,_civRelations] call MCC_fnc_ambientSpawnCarParked;
				};
			};
		};
	} forEach _spawnCenters;

	sleep 5;
};

