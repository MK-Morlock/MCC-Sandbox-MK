/*================================================MCC_fnc_MWObjectiveDisable===============================================================================================
// Create a diable IED objective for Mission Wizard
// Example:[_objPos,_isCQB,_side,_faction] call MCC_fnc_MWObjectiveDisable;
// _objPos = position, objectice position
//_isCQB = Boolean, true - for CQB areay false if it doesn't matters.
//_side = enemy side
//_faction = enemy Faction
// Return - nothing
//==================================================================================================================================================================*/
#define	MCC_BIG_IEDDEVICE	"Land_Device_disassembled_F"
#define	MCC_SMALL_IEDDEVICE	"Land_PressureWasher_01_F"
#define	MCC_SMALL_IEDDEVICE_TABLE	"Land_WoodenTable_small_F"

private _range = 0;
private _object = [];
private _objectType = "";
private _name = "";
private _time = 0;
private _selectedBuilding = [];
private _unitPlaced = false;
private _buildingPos = nil;
private _spawnPos = [];
private _spawndir = 0;

params [
	["_objPos", [0,0,0], [[]]],
	["_isCQB", false, [false]],
	["_side", sideUnknown, [sideUnknown]],
	["_faction", "", [""]],
	["_sidePlayer", west, [west]],
	["_preciseMarkers", false, [false]]
];

//Create the ied.

_name = format ["MCCMWIEDObject_%1", ["MCCMWIEDObject_",1] call bis_fnc_counter];

if (_isCQB) then {
	_objectType = MCC_SMALL_IEDDEVICE;

	_selectedBuilding = ([_objPos, 100] call MCC_fnc_MWFindbuildingPos) call BIS_fnc_selectRandom;
	_building = _selectedBuilding select 0;
	_buildingPos = _selectedBuilding select 1;
 	if (isnil "_buildingPos") exitWith {debuglog "MCC MW - MWObjectiveHVT - No building pos found"};

	_unitPlaced = false;
	_time = time;
	 while {!_unitPlaced && (time <= (_time + 5))} do {
		_spawnPos	= _building buildingPos (floor random _buildingPos);

		//No other unit in the spawn position?
		if (count (nearestObjects [_spawnPos, ["Man"], 1])<1) then {
			//Spawn the intel
			_dummyObject = MCC_SMALL_IEDDEVICE_TABLE createvehicle _spawnPos;
			_dummyObject setPos _spawnPos;
			_object = [_objPos,_objectType,"large",0,8,false,4,15,_sidePlayer,_name,random 360,true,_side,_faction] call MCC_fnc_trapSingle;
			_object setPos (_dummyObject modelToWorld [0,0,0.43]);
			_object setdir (getdir _dummyObject);
			_unitPlaced = true;

			//Lets spawn some body guards
			[getpos _object,30,0,2,_faction, _side] remoteExec ["MCC_fnc_garrison", 2,false];
		};
	};
};

if (_isCQB && !_unitPlaced) then {
	["WARN", "fn_MWObjectiveDisable", "no free building position for the CQB IED near %1 - placed in the open instead", [mapGridPosition _objPos]] call MCC_fnc_log;
};

if (!_unitPlaced) then {
	//Not CQB
	//Find an empry spot
	_objectType = MCC_BIG_IEDDEVICE;
	_range = 50;
	_spawnPos = [_objPos,1,_range,10,0,0.5,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;

	//If we haven't find it in first time increase by 50;
	while {str _spawnPos == "[-500,-500,0]"} do	{
		_range = _range + 50;
		_spawnPos = [_objPos,1,_range,10,0,0.5,0,[],[[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
		sleep 0.1;
	};

	//Clear area
	[_spawnPos,30,true] call MCC_fnc_hideTerrainObjectsArea;

	_dummyObject =[_spawnPos, random 360, "c_nestBig"] call MCC_fnc_objectMapper;
	_spawnPos = getpos _dummyObject;
	_spawndir = getdir _dummyObject;


	//Create the object
	_object = [_spawnPos,_objectType,"large",0,8,false,4,15,_sidePlayer,_name,_spawndir,true,_side,_faction] call MCC_fnc_trapSingle;
	_object setdir random 360;
};

if (_object isEqualType objNull && {!isNull _object}) then {
	[_object, missionNamespace getVariable ["MCC_MWIEDDisarmMode", 0]] spawn {
		params ["_ied", "_mode"];
		private _t = time + 30;
		waitUntil {sleep 0.5; !isNull (_ied getVariable ["realIed", objNull]) || {time > _t} || {isNull _ied}};
		private _real = _ied getVariable ["realIed", objNull];
		if (isNull _real) exitWith {["WARN", "fn_MWObjectiveDisable", "IED at %1 has no helper after 30 s - left as the bomb-defuse type", [getPos _ied]] call MCC_fnc_log};

		_real setVariable ["MCC_MWIEDMode", _mode, true];
		if (_mode != 2) then {_real setVariable ["MCC_isIEDMiniGame", false, true]};	//no bomb-defuse panel

		if (_mode == 0) then {
			_real setVariable ["MCC_IEDtype", "mwHold", true];	//the MCC interaction key leaves it alone
			[
				_ied,
				"Disarm IED",
				"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_hack_ca.paa",
				"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_hack_ca.paa",
				"(alive _target) && {(_this distance _target) < 4} && {((_target getVariable ['realIed', objNull]) getVariable ['armed', false])}",
				"(alive _target) && {(_this distance _target) < 4}",
				{},
				{},
				{
					params ["_target", "_caller"];
					private _real = _target getVariable ["realIed", objNull];
					if (!isNull _real && {_real getVariable ["armed", false]}) then {
						_real setVariable ["armed", false, true];
						[format ["%1 disarmed the IED", name _caller]] remoteExec ["systemChat", 0];
					};
				},
				{},
				[],
				10,
				10,
				true,
				false
			] remoteExec ["BIS_fnc_holdActionAdd", 0, _ied];
		};
		["INFO", "fn_MWObjectiveDisable", "IED at %1: disarm method %2", [mapGridPosition _ied, ["safe disarm (hold)", "MCC interaction key", "bomb manual", "place charge"] param [_mode, _mode]]] call MCC_fnc_log;
	};
};

//Lets create an ambush
_groupArray = if (count MCC_MWGroupArrayMenRecon > 0) then {
	if (random 1 > 0.5) then {MCC_MWGroupArrayMenRecon} else {MCC_MWGroupArrayMen};
} else {
	MCC_MWGroupArrayMen
};

missionNamespace setVariable ["MCC_MWObjectiveItems", ((missionNamespace getVariable ["MCC_MWObjectiveItems", []]) select {!isNull _x}) + (([_object] + (if (isNil "_dummyObject") then {[]} else {[_dummyObject]})) select {_x isEqualType objNull && {!isNull _x}})];

{_x addCuratorEditableObjects [[_object],false]} forEach allCurators;

[_object, getpos _object,"disableIED",_preciseMarkers,_side,400,_sidePlayer] call MCC_fnc_MWCreateTask;