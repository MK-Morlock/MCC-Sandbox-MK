//=====================================MCC_fnc_MWObjectiveHVT=========================================================================================================
// Create an HVT objective
// Example:[_objPos,_isCQB,_hostageRescue] call MCC_fnc_MWObjectiveHVT;
// _objPos = position, objectice position
//_isCQB = Boolean, true - for CQB areay false if it doesn't matters.
//_hostageRescue = Boolean, true - catch him alive, False - kill him
// Return - nothing
//===============================================================================================================================================================
#define	MCC_UNTIE_ICON "\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa"

private _buildingPos = nil;
private _spawnPos = [];
private _unitsArray = [];
private _type = [];
private _group = grpNull;
private _unit = objNull;
private _building = objNull;
private _unitPlaced = false;
private _time = 0;
private _walking = false;
private _selectedBuilding = [];
private _fnc_findHVTClass = {};

params [
	["_objPos", [0,0,0], [[]]],
	["_isCQB", false, [false]],
	["_hostageRescue", false, [false]],
	["_side", sideUnknown, [sideUnknown]],
	["_faction", "", [""]],
	["_sidePlayer", west, [west]],
	["_factionPlayer", "", [""]],
	["_preciseMarkers", false, [false]]
];

MCC_MWcreateHostage =
{
	private _group = grpNull;
	private _unit = objNull;
	private _init = "";
	private _rank = [];
	params [
		["_side", sideUnknown, [sideUnknown]],
		["_spawnPos", [0,0,0], [[]]],
		["_type", "", [""]]
	];

	_group = creategroup _side;
	_rank = ["PRIVATE","CORPORAL","SERGEANT","LIEUTENANT"] select (floor random 3);
	_unit = _group createUnit [_type, _spawnPos,[],0.5,"NONE"];
	waituntil {alive _unit};
	_unit setPos _spawnPos;
	_unit setrank _rank;
	MCC_tempName = format ["MCC_objectUnits_%1", ["MCC_objectUnitsCounter",1] call bis_fnc_counter];

	//Spawn Hostage
	_null = _unit execVM format ["%1mcc\general_scripts\hostages\create_hostage.sqf", MCC_path];
	_unit setvariable ["vehicleinit",(_unit getvariable ["vehicleinit",""]) + format ["_this execVM ""%1mcc\general_scripts\hostages\create_hostage.sqf"";", MCC_path]];
	{_x addCuratorEditableObjects [[_unit],false]} forEach allCurators;
	_unit;
};

_fnc_findHVTClass = {
	params ["_faction","_side","_random",["_filterOfficers",false]];

	private _unitsArray = [];
	private _HVTClasses = [];
	private _hvtClass = "";

	_hvtClass = "";

	//Random unit or from MCC_MWHVT variable
	if (_random) then {
		_unitsArray	= [[[_faction ,"soldier"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry, _faction] call MCC_fnc_contentFilterList;
		while {_hvtClass == ""} do {_hvtClass = (_unitsArray call BIS_fnc_selectRandom) select 0};

	} else {
		_HVTClasses = missionNamespace getVariable ["MCC_MWHVT",["B_officer_F","O_officer_F","I_officer_F","C_Nikos"]];

		//An officer of the faction (or its mod) first - the HVT was always a vanilla officer. Only while the HVT list is
		//still the default one: a list set by the mission maker (CBA setting or module) is used as it is.
		//A list chosen on the console Assets page: one of its entries at random
		if (missionNamespace getVariable ["MCC_assetCustom_MCC_MWHVT", false]) then {_hvtClass = selectRandom _HVTClasses};

		if (_hvtClass == "" && {_HVTClasses isEqualTo ["B_officer_F","O_officer_F","I_officer_F","C_Nikos"]}) then {
			private _officers = [_faction, "officer"] call MCC_fnc_factionVehicles;
			if (_filterOfficers) then {_officers = [_officers, _faction] call MCC_fnc_contentFilterList};
			if (count _officers > 0) then {_hvtClass = selectRandom _officers};
		};

		//Find the right side HVT
		if (_hvtClass == "") then {
			{
				if (([(getNumber(configFile >> "cfgVehicles" >> _x >> "side"))] call BIS_fnc_sideType) == _side) exitWith {
					_hvtClass = _x;
				};
			} forEach _HVTClasses;
		};

		//Can't find - select random
		if (_hvtClass == "") then {
			_unitsArray	= [[[_faction ,"soldier"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry, _faction] call MCC_fnc_contentFilterList;
			while {_hvtClass == ""} do {_hvtClass = (_unitsArray call BIS_fnc_selectRandom) select 0};
		};
	};

	_hvtClass
};

if (_isCQB) then {

	_selectedBuilding = ([_objPos, 100] call MCC_fnc_MWFindbuildingPos) call BIS_fnc_selectRandom;
	_building = _selectedBuilding select 0;
	_buildingPos = _selectedBuilding select 1;
 	if (isnil "_buildingPos") exitWith {debuglog "MCC MW - MWObjectiveHVT - No building pos found"};

	_unitPlaced = false;
	_time = time;

	 while {!_unitPlaced && (time <= (_time + 5))} do {
		_spawnPos	= _building buildingPos (floor random _buildingPos);

		//No other unit in the spawn position?
		if ((count (nearestObjects [_spawnPos, ["Man"], 1])<1) && {!surfaceIsWater _spawnPos}) then {
			if (_hostageRescue) then {

				//find Hostage class
				_type = [_factionPlayer, _sidePlayer, false, true] call _fnc_findHVTClass;

				_unit = [_sidePlayer,_spawnPos,_type] call MCC_MWcreateHostage;
				waituntil {alive _unit};

				[_unit, getpos _unit,"Secure_HVT",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
			missionNamespace setVariable ["MCC_MWObjectiveItems", ((missionNamespace getVariable ["MCC_MWObjectiveItems", []]) select {!isNull _x}) + [_unit]];

			} else {

				//find HVT class
				_type = [_faction, _side, false] call _fnc_findHVTClass;
				_unit = [_spawnPos, _type, _sidePlayer,"Armed Civilian",random 360,true] call MCC_fnc_ACSingle;
_unit setVariable ["MCC_homeSide", _side, true];
				waituntil {alive _unit};

				[_unit, getpos _unit,"Kill_HVT",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
			missionNamespace setVariable ["MCC_MWObjectiveItems", ((missionNamespace getVariable ["MCC_MWObjectiveItems", []]) select {!isNull _x}) + [_unit]];
			};

			_unitPlaced = true;

			//Lets spawn some body guards
			[getpos _unit,30,0,2,_faction, _side] remoteExec ["MCC_fnc_garrison", 2,false];
		};
	};
};

if (_isCQB && !_unitPlaced) then {
	["WARN", "fn_MWObjectiveHVT", "no free building position for the CQB HVT near %1 - placed in the open instead", [mapGridPosition _objPos]] call MCC_fnc_log;
};

if (!_unitPlaced) then {

	//Clear area

	//Open area
	_objPos = [_objPos] call MCC_fnc_buildRandomComposition;
	[_objPos,30,0,4,_faction, _side] remoteExec ["MCC_fnc_garrison",2];
	[_objPos, 30, 4, _faction, _side] remoteExec ["MCC_fnc_MWcampGuards", 2];

	_group = creategroup _side;

	private _fnc_insidePos = {
		private _res = [];
		private _blds = (nearestObjects [_objPos, ["House", "Building"], 35]) select {((_x call MCC_fnc_buildingPosCount) > 0) && {!(_x call MCC_fnc_isWaterStructure)}};
		{
			private _b = _x;
			private _idx = [];
			for "_k" from 0 to ((_b call MCC_fnc_buildingPosCount) - 1) do {_idx pushBack _k};
			{
				private _bp = _b buildingPos _x;
				if ((count _bp > 1) && {!surfaceIsWater _bp} && {(count (nearestObjects [_bp, ["Man"], 1])) == 0}) exitWith {_res = _bp};
			} forEach (_idx call BIS_fnc_arrayShuffle);
			if (count _res > 0) exitWith {};
		} forEach (_blds call BIS_fnc_arrayShuffle);
		_res
	};

	if (_hostageRescue) then {
		//find Hostage class
		_type = [_factionPlayer, _sidePlayer, false, true] call _fnc_findHVTClass;

		//Find an empry spot
		_spawnPos = call _fnc_insidePos;
		if (count _spawnPos == 0) then {_spawnPos = [_objPos, 60, 30, 3] call MCC_fnc_landSpot};
		if (count _spawnPos == 0) then {_spawnPos = _objPos findEmptyPosition [0,100,_type]};
		if (count _spawnPos == 0) then {_spawnPos = +_objPos};
		_unit = [_sidePlayer,_spawnPos,_type] call MCC_MWcreateHostage;

		//Start Briefings
		waituntil {alive _unit};

		[_unit, getpos _unit,"Secure_HVT",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
			missionNamespace setVariable ["MCC_MWObjectiveItems", ((missionNamespace getVariable ["MCC_MWObjectiveItems", []]) select {!isNull _x}) + [_unit]];
		//Static Patrol
		_walking = false;

	} else {

		//find HVT class
		_type = [_faction, _side, false] call _fnc_findHVTClass;

		//walking HVT?
		_walking = if (random 1 < 0.5) then {true} else {false};

		//Find an empry spot
		_spawnPos = if (_walking) then {[]} else {call _fnc_insidePos};
		if (count _spawnPos == 0) then {_spawnPos = [_objPos, _type, 44] call MCC_fnc_clearVehicleSpot};
		if (count _spawnPos == 0) then {_spawnPos = [_objPos, 60, 30, 3] call MCC_fnc_landSpot};
		if (count _spawnPos == 0) then {_spawnPos = _objPos findEmptyPosition [0,100,_type]};
		if (count _spawnPos == 0) then {_spawnPos = +_objPos};

		if (_walking) then {
			_unit = _group createUnit [_type ,_spawnPos,[],0.5,"NONE"];
			waituntil {alive _unit};

			//Add to zeus
			{["BIS_fnc_spawn", [[_x,_unit],{(_this select 0) addCuratorEditableObjects [[_this select 1],true];}], _x, false] call MCC_fnc_secRemote} forEach allCurators;

			MCC_tempName = format ["MCC_objectUnits_%1", ["MCC_objectUnitsCounter",1] call bis_fnc_counter];
			_init = FORMAT [";%1 = _this;",MCC_tempName];

			["MCC_fnc_setVehicleInit", [[netid _unit,_unit], _init], 0, true] call MCC_fnc_secRemote;

		} else {
			_unit = [_spawnPos, _type, _sidePlayer,"Armed Civilian",random 360,true] call MCC_fnc_ACSingle;
_unit setVariable ["MCC_homeSide", _side, true];
			_unit setPos _spawnPos;
		};

		[_unit, getpos _unit,"Kill_HVT",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;
			missionNamespace setVariable ["MCC_MWObjectiveItems", ((missionNamespace getVariable ["MCC_MWObjectiveItems", []]) select {!isNull _x}) + [_unit]];
	};

	//Lets spawn some body guards
	_unitsArray 	= [[[_faction ,"soldier"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry, _faction] call MCC_fnc_contentFilterList;
	private _guardsNumber = floor random 5;
	if (count _unitsArray == 0) then {_guardsNumber = 0};

	for [{_i=0},{_i< _guardsNumber},{_i=_i+1}] do {

		_type = _unitsArray select floor (random ((count _unitsArray) min 4));
		_spawnPos = [getPos _unit, _type select 0, 32] call MCC_fnc_clearVehicleSpot;
		if (count _spawnPos == 0) then {_spawnPos = (getpos _unit) findEmptyPosition [0,100,(_type select 0)]};
		if (count _spawnPos == 0) then {_spawnPos = getpos _unit};
		_unit = _group createUnit [_type select 0,_spawnPos,[],0.5,"NONE"];
		waituntil {alive _unit};

		//Add to zeus
		{["BIS_fnc_spawn", [[_x,_unit],{(_this select 0) addCuratorEditableObjects [[_this select 1],true];}], _x, false] call MCC_fnc_secRemote} forEach allCurators;
	};

	_group setFormDir (round(random 360));

	if (_walking) then {
		[_group, _spawnPos, 150] call BIS_fnc_taskPatrol;
	} else {
		[_group, _spawnPos] call bis_fnc_taskDefend;
	};
};