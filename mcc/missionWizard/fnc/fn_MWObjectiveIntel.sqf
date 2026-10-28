/*======================================================MCC_fnc_MWObjectiveIntel==========================================================================================Create a pick intel objective
// Example:[_objPos,_isCQB,_side,_faction] call MCC_fnc_MWObjectiveIntel;
// _objPos = position, objectice position
//_isCQB = Boolean, true - for CQB areay false if it doesn't matters.
//_side = enemy side
//_faction = enemy Faction
// Return - nothing
//===============================================================================================================================================================*/
private _objType = "";
private _spawnPos = [];
private _time = 0;
private _object = objNull;
private _dummyObject = "";
private _init = "";
private _range = 0;
private _selectedBuilding = [];
private _building = objNull;
private _buildingPos = nil;
private _taskType = "";
private _foundBuilding = false;

params [
	["_objPos", [0,0,0], [[]]],
	["_isCQB", false, [false]],
	["_side", sideUnknown, [sideUnknown]],
	["_faction", "", [""]],
	["_preciseMarkers", false, [false]],
	["_sidePlayer", west, [sideLogic,""]],
	["_isDownloadIntel", false, [false]]
];
_taskType = if (_isDownloadIntel) then {"downloadIntel"} else {"pick_intel"};
_foundBuilding = false;

_objType = if (_isDownloadIntel) then {"Land_DataTerminal_01_F"} else {
	 (missionNamespace getVariable ["MCC_MWIntelObjects",["Land_File2_F","Land_FilePhotos_F","Land_Laptop_unfolded_F","Land_SatellitePhone_F","Land_Suitcase_F"]]) call BIS_fnc_selectRandom
};


//If not CQB spawn some POI
if !(_isCQB) then {

	//Clear area
	[_objPos,50,true] call MCC_fnc_hideTerrainObjectsArea;

	_objPos = [_objPos] call MCC_fnc_buildRandomComposition;
};

//Lets spawn some body guards
_range = if (_isCQB) then {30} else {60};
[_objPos,_range,0,4,_faction, _side] remoteExec ["MCC_fnc_garrison",2];

//Lets find out if we have a building close by
_selectedBuilding = ([_objPos, 100] call MCC_fnc_MWFindbuildingPos) call BIS_fnc_selectRandom;
_building = _selectedBuilding select 0;
_buildingPos = _selectedBuilding select 1;

_spawnPos = _objPos;

if (!(isnil "_buildingPos") &&
    (_isCQB || (! _isCQB && (_building distance2D _objPos) <= 50))
    ) then {

	_time = time;
	_spawnPos	= _building buildingPos (floor random _buildingPos);

	while {((count (nearestObjects [_spawnPos, ["Man"], 1])) > 0) && {time < _time + 5}} do {
		_spawnPos	= _building buildingPos (floor random _buildingPos);
		sleep 0.1;
	};

	if ((count (nearestObjects [_spawnPos, ["Man"], 1])) > 0) then {
		["WARN", "fn_MWObjectiveIntel", "no free building position for the intel near %1 - placed at the objective instead", [mapGridPosition _objPos]] call MCC_fnc_log;
		_spawnPos = _objPos;
	} else {
		_foundBuilding = true;
	};
};


if (_isDownloadIntel) then {
	_object = _objType createvehicle _spawnPos;
	if !(_foundBuilding) then {
		private _e = _spawnPos findEmptyPosition [2,40,_objType];
		if (count _e > 0) then {_spawnPos = _e};
	};

	_object setPos _spawnPos;
	_object setVariable ["MCC_intelItem",true,true];

} else {
	//Spawn the intel
	_dummyObject = "Land_WoodenTable_small_F" createvehicle _spawnPos;
	_dummyObject enablesimulation false;

	{_x addCuratorEditableObjects [[_dummyObject],false]} forEach allCurators;

	if !(_foundBuilding) then {
		private _e = _spawnPos findEmptyPosition [2,40,"Land_WoodenTable_small_F"];
		if (count _e > 0) then {_spawnPos = _e};
	};

	_dummyObject setPos _spawnPos;

	_object = _objType createvehicle _spawnPos;
	_object setPos (_dummyObject modelToWorld [0,0,0.43]);
	_object setdir (getdir _dummyObject);
	_object enablesimulation false;
};

missionNamespace setVariable ["MCC_MWObjectiveItems", ((missionNamespace getVariable ["MCC_MWObjectiveItems", []]) select {!isNull _x}) + ([_object, _dummyObject] select {_x isEqualType objNull && {!isNull _x}})];

//Pick Item
_init = '_this call MCC_fnc_pickItem';
[[netID _object,_object], _init] remoteExec ["MCC_fnc_setVehicleInit",0,_object];

{_x addCuratorEditableObjects [[_object],false]} forEach allCurators;

//Start Briefings
[_object, getpos _object,_taskType,_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;






