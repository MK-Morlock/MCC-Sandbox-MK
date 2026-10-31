scriptName "Functions\spawning\fn_spawnGroup.sqf";
/*
	File: spawnGroup.sqf
	Author: Joris-Jan van 't Land, modified by Thomas Ryan

	Description:
	Function which handles the spawning of a dynamic group of characters.
	The composition of the group can be passed to the function.
	Alternatively a number can be passed and the function will spawn that
	amount of characters with a random type.

	Parameter(s):
	_this select 0: the group's starting position (Array)
	_this select 1: the group's side (Side)
	_this select 2: can be three different types:
		- list of character types (Array)
		- amount of characters (Number)
		- CfgGroups entry (Config)
	_this select 3: (optional) list of relative positions (Array)
	_this select 4: (optional) list of ranks (Array)
	_this select 5: (optional) skill range (Array)
	_this select 6: (optional) ammunition count range (Array)
	_this select 7: (optional) randomization controls (Array)
		0: amount of mandatory units (Number)
		1: spawn chance for the remaining units (Number)
	_this select 8: (optional) azimuth (Number)

	Returns:
	The group (Group)
*/

//Validate parameter count
if ((count _this) < 3) exitWith {debugLog "Log: [spawnGroup] Function requires at least 3 parameters!"; grpNull};

private _pos = [];
private _side = sideUnknown;
private _vehicles = [];
_pos = _this param [0, [], [[]]];
_side = _this param [1, sideUnknown];

private _chars = configNull;
private _charsType = "";
private _types = [];
_chars = _this param [2, [], [[], 0, configFile]];
_charsType = typeName _chars;
if (_charsType == (typeName [])) then
{
	_types = _chars;
}
else
{
	if (_charsType == (typeName 0)) then
	{
		//Only a count was given, so ask this function for a good composition.
		_types = [_side, _chars] call BIS_fnc_returnGroupComposition;
	}
	else
	{
		if (_charsType == (typeName configFile)) then
		{
			_types = [];
		};
	};
};

private _positions = _this param [3, [], [[]]];
private _ranks = _this param [4, [], [[]]];
private _skillRange = _this param [5, [], [[]]];
private _ammoRange = _this param [6, [], [[]]];
private _randomControls = _this param [7, [-1, 1], [[]]];

//Fetch the random controls.
private _minUnits = _randomControls select 0;
private _chance = _randomControls select 1;

private _azimuth = _this param [8, 0, [0]];

//Check parameter validity.
//TODO: Check for valid skill and ammo ranges?
if ((typeName _pos) != (typeName [])) exitWith {debugLog "Log: [spawnGroup] Position (0) should be an Array!"; grpNull};
if ((count _pos) < 2) exitWith {debugLog "Log: [spawnGroup] Position (0) should contain at least 2 elements!"; grpNull};
if ((typeName _side) != (typeName sideEnemy)) exitWith {debugLog "Log: [spawnGroup] Side (1) should be of type Side!"; grpNull};
if ((typeName _positions) != (typeName [])) exitWith {debugLog "Log: [spawnGroup] List of relative positions (3) should be an Array!"; grpNull};
if ((typeName _ranks) != (typeName [])) exitWith {debugLog "Log: [spawnGroup] List of ranks (4) should be an Array!"; grpNull};
if ((typeName _skillRange) != (typeName [])) exitWith {debugLog "Log: [spawnGroup] Skill range (5) should be an Array!"; grpNull};
if ((typeName _ammoRange) != (typeName [])) exitWith {debugLog "Log: [spawnGroup] Ammo range (6) should be an Array!"; grpNull};
if ((typeName _randomControls) != (typeName [])) exitWith {debugLog "Log: [spawnGroup] Random controls (7) should be an Array!"; grpNull};
if ((typeName _minUnits) != (typeName 0)) exitWith {debugLog "Log: [spawnGroup] Mandatory units (7 select 0) should be a Number!"; grpNull};
if ((typeName _chance) != (typeName 0)) exitWith {debugLog "Log: [spawnGroup] Spawn chance (7 select 1) should be a Number!"; grpNull};
if ((typeName _azimuth) != (typeName 0)) exitWith {debugLog "Log: [spawnGroup] Azimuth (8) should be a Number!"; grpNull};
if ((_minUnits != -1) && (_minUnits < 1)) exitWith {debugLog "Log: [spawnGroup] Mandatory units (7 select 0) should be at least 1!"; grpNull};
if ((_chance < 0) || (_chance > 1)) exitWith {debugLog "Log: [spawnGroup] Spawn chance (7 select 1) should be between 0 and 1!"; grpNull};
if (((count _positions) > 0) && ((count _types) != (count _positions))) exitWith {debugLog "Log: [spawnGroup] List of positions (3) should contain an equal amount of elements to the list of types (2)!"; grpNull};
if (((count _ranks) > 0) && ((count _types) != (count _ranks))) exitWith {debugLog "Log: [spawnGroup] List of ranks (4) should contain an equal amount of elements to the list of types (2)!"; grpNull};

//Convert a CfgGroups entry to types, positions and ranks.
if (_charsType == (typeName configFile)) then
{
	_ranks = [];
	_positions = [];

	for "_i" from 0 to ((count _chars) - 1) do
	{
		private _item = _chars select _i;

		if (isClass _item) then
		{
			if (getText(_item >> "vehicle") == "" || {!isClass (configFile >> "CfgVehicles" >> getText(_item >> "vehicle"))}) then {
				["WARN", "fn_spawnGroup", "group %1: unit entry %2 has unknown vehicle '%3' - skipped", [configName _chars, configName _item, getText(_item >> "vehicle")]] call MCC_fnc_log;
				continue;
			};
			_types = _types + [getText(_item >> "vehicle")];
			_ranks = _ranks + [getText(_item >> "rank")];
			_positions = _positions + [getArray(_item >> "position")];
		};
	};
};

private _grp = createGroup _side;

//Create the units according to the selected types.
for "_i" from 0 to ((count _types) - 1) do
{
	//See if this unit should be skipped.
	private _skip = false;
	if (_minUnits != -1) then
	{
		//Has the mandatory minimum been reached?
		if (_i > (_minUnits - 1)) then
		{
			//Has the spawn chance been satisfied?
			if ((random 1) > _chance) then {_skip = true};
		};
	};

	if (!_skip) then
	{
		private _unit = objNull;
		private _type = "";
		_type = _types select _i;
		_vehicles = [];

		//If given, use relative position.
		private _itemPos = [];
		if ((count _positions) > 0) then
		{
			private _relPos = _positions param [_i, []];
			if !(_relPos isEqualTypeArray [0,0] || {_relPos isEqualTypeArray [0,0,0]}) then {_relPos = [(_i mod 4) * 3, floor (_i / 4) * -3]};	// group entry without a usable position[]
			_itemPos = [(_pos select 0) + (_relPos select 0), (_pos select 1) + (_relPos select 1)];
		}
		else
		{
			_itemPos = _pos;
		};

		//Is this a character or vehicle?
		if (getNumber(configFile >> "CfgVehicles" >> _type >> "isMan") == 1) then
		{
			_unit = _grp createUnit [_type, _itemPos, [], 0, "NONE"];
			if ((((units _grp) - [_unit]) findIf {(_x distance2D _unit) < 1.5}) >= 0) then {
				private _free = (getPosATL _unit) findEmptyPosition [1.5, 12, _type];
				if (count _free > 0) then {_unit setPosATL _free};
			};
			if ((count ([getPosATL _unit, 0, 1, 2] call MCC_fnc_landSpot)) == 0) then {
				private _good = [_pos, 30, 25, 2] call MCC_fnc_landSpot;
				if (count _good > 0) then {
					private _free = _good findEmptyPosition [0, 8, _type];
					_unit setPosATL (if (count _free > 0) then {_free} else {_good});
				};
			};
			_unit setDir _azimuth;
		}
		else
		{
			if (_type isKindOf "LandVehicle") then {
				private _clear = [_itemPos, _type] call MCC_fnc_clearVehicleSpot;
				if (_clear isEqualTo []) then {_clear = [_pos, _type, 80] call MCC_fnc_clearVehicleSpot};
				if (_clear isEqualTo []) then {
					private _road = [_pos, _type] call MCC_fnc_roadsideSpot;
					if (count _road > 0) then {_itemPos = _road};
					["DEBUG", "MCC_fnc_spawnGroup", "no clear spot for %1 near %2 - placed at %3", [_type, mapGridPosition _pos, mapGridPosition _itemPos]] call MCC_fnc_log;
				} else {
					_itemPos = _clear;
					if !([_itemPos, _type] call MCC_fnc_vehicleCanDriveOut) then {
						private _road = [_pos, _type] call MCC_fnc_roadsideSpot;
						if (count _road > 0) then {
							["DEBUG", "MCC_fnc_spawnGroup", "%1 could not drive out from %2 - moved to the roadside at %3", [_type, mapGridPosition _itemPos, mapGridPosition _road]] call MCC_fnc_log;
							_itemPos = _road;
						};
					};
				};
			};
			if (_itemPos isEqualTo []) then {continue};
			_unit = ([_itemPos, _azimuth, _type, _grp] call MCC_fnc_spawnVehicle) select 0;
			_vehicles set [count _vehicles, _unit];
		};

		//Curator
		{_x addCuratorEditableObjects [[_unit],false]} forEach allCurators;

		//If given, set the unit's rank.
		if ((count _ranks) > 0 && {(_ranks param [_i, ""]) != ""}) then
		{
			[_unit,_ranks select _i] call bis_fnc_setRank;
		};

		//If a range was given, set a random skill.
		if ((count _skillRange) > 0) then
		{
			private _minSkill = _skillRange select 0;
			private _maxSkill = _skillRange select 1;
			private _diff = _maxSkill - _minSkill;

			_unit setUnitAbility (_minSkill + (random _diff));
		};

		//If a range was given, set a random ammo count.
		if ((count _ammoRange) > 0) then
		{
			private _minAmmo = _ammoRange select 0;
			private _maxAmmo = _ammoRange select 1;
			private _diff = _maxAmmo - _minAmmo;

			_unit setVehicleAmmo (_minAmmo + (random _diff));
		};
	};
};
/*
aa= _grp;
bb = _vehicles;
//Assigne to vehicle
if (count _vehicles > 0) then
{
	private ["_vehicle","_unit"];
	{
		_vehicle = _x;
		{
			_unit = _x;
			if (_vehicle emptyPositions "commander" >0) then
			{
				_unit assignAsCommander _vehicle;
			}
			else
			{
				if (_vehicle emptyPositions "gunner" >0) then
				{
					_unit assignAsGunner _vehicle;
				}
				else
				{
					if (_vehicle emptyPositions "cargo" >0) then
					{
						_unit assignAsCargo _vehicle;
					};
				};
			};
		} foreach units _grp;
	} foreach _vehicles;
};
/*

/*
//--- Sort group members by ranks (the same as 2D editor does it)
private ["_newGrp"];
_newGrp = createGroup _side;
while {count units _grp > 0} do {
	private ["_maxRank","_unit"];
	_maxRank = -1;
	_unit = objnull;
	{
		_rank = rankid _x;
		if (_rank > _maxRank || (_rank == _maxRank && (group effectivecommander vehicle _unit == _newGrp) && effectivecommander vehicle _x == _x)) then {_maxRank = _rank; _unit = _x;};
	} foreach units _grp;
	[_unit] joinsilent _newGrp;
};
_newGrp selectleader (units _newGrp select 0);
deletegroup _grp;
*/
_grp
