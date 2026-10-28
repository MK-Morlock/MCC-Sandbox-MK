//===================================================================MCC_fnc_trapSingle=============================================================================
// Create an IED
//Example:[pos,IEDkind,IEDVolume,IEDExplosionType,IEDDisarmTime,IEDJammable,IEDTriggerType,IEDdistance,IEDside,IEDMarkerName,IEDDir,_groupArray,_ambushSide] remoteExec ['MCC_fnc_trapSingle', true, false];
// Params:
// 	pos: array, trap position
// 	IEDkind: string, any oject's vehicleClass
// 	IEDVolume: stirng, explosion radius - "small","medium","large"
//	IEDExplosionType: number, explosion type: 0-deadly, 1 - disabling (will cripple vehicles and soldiers but will not kill) 2 - Fake, will not or lightly wound soldiers.
//	IEDDisarmTime: number, time in second it will take to disarm the IED
//	IEDJammable: boolean, true - if jammer vheicle (defined in MCC_IEDJammerVehicles) can jame this IED false if not
//	IEDTriggerType: number, 0- Proximity, will explode if unit from the targer side will move faster then a slow crouch, 1- radio will explode if unit from the targer side will get close to it, if assigned to spotter the spotter must be alive, 2- manual detontion, only mission maker
//	IEDdistance: number, minimum distance which target unit have to get close to the IED to set it off
//	IEDside: side, [west, east, resistance, civilian]
//	IEDMarkerName: string, custom marker name for the IED
// 	IEDDir: number, direction of the IED
// 	_groupArray: Boolean, spawn an ambush
//	_ambushSide: side, ambush side
//========================================================================================================================================================================

//Made by Shay_Gman (c) 09.10
private _IEDDisarmTime = 0;
private _IEDJammable = true;
private _IEDTriggerType = 0;
private _trapdistance = 0;
private _iedside = [];
private _iedMarkerName = "";
private _fakeIed = objNull;
private _iedDir = 0;
private _init = "";
private _time = 0;
private _range = 0;
private _ambushPos = [];
private _groupDir = [];
private _ambush = [];
private _playersSides = [];
disableSerialization;

if (!isServer) exitWIth {};

params ["_pos", "_trapkind", "_trapvolume", "_IEDExplosionType"];
_IEDDisarmTime 		= MCC_IEDDisarmTimeArray select (_this select 4);
_IEDJammable 		= _this select 5;
_IEDTriggerType 	= _this select 6;
_trapdistance 		= _this select 7;
_iedside 			= _this select 8;
_iedMarkerName 		= _this select 9;
_iedDir 			= _this select 10;
_groupArray			= _this select 11;
if (isnil "_groupArray") then {_groupArray = false};
_ambushSide 		= if (_groupArray) then { _this select 12} else {east};

_init = "";

_playersSides = [west,east,resistance] - [_ambushSide];

//Ammo?
_fakeIed = _trapkind createVehicle _pos;
_fakeIed setpos _pos;
_fakeIed setdir _iedDir;
_fakeIed setVariable ["isIED",true,true];
_fakeIed setvariable ["vehicleinit",format ["_null =[_this,'%1',%2,%3,%4,%5,%6,'%7'] remoteExec ['MCC_fnc_createIED', 2, false];",_trapvolume,_IEDExplosionType,_IEDDisarmTime,_IEDJammable,_IEDTriggerType,_trapdistance,_iedside]];
{_x addCuratorEditableObjects [[_fakeIed],false]} forEach allCurators;

[_fakeIed,_trapvolume,_IEDExplosionType,_IEDDisarmTime,_IEDJammable,_IEDTriggerType,_trapdistance,_iedside] remoteExec ["MCC_fnc_createIED",2];

//Spawn AMBUSH
private _ambushFaction = _this param [13, "", [""]];
if (_groupArray) then {
	//Ambush Group: a recon team 50 % of the time if the faction has any, otherwise an infantry group (original MCC)
	private _recon = missionNamespace getVariable ["MCC_MWGroupArrayMenRecon", []];
	private _men = missionNamespace getVariable ["MCC_MWGroupArrayMen", []];
	_groupArray = if (count _recon > 0) then {
		if (random 1 > 0.5) then {_recon} else {_men};
	} else {
		_men
	};
	if (count _groupArray == 0) then {_groupArray = _recon};

	//Choose group
	_groupName = if (count _groupArray > 0) then {(_groupArray call BIS_fnc_selectRandom) select 2} else {""};

	//No preset infantry group: 4-6 of the faction's armed ground soldiers
	if (_groupName == "" && {_ambushFaction != ""}) then {
		private _units = ([[_ambushFaction, "soldier"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry) apply {if (_x isEqualType "") then {_x} else {_x param [0, ""]}};
		private _bad = ["pilot", "crew", "diver", "frogman", "survivor", "unarmed", "story", "uav_ai"];
		_units = _units select {
			private _cfg = configFile >> "CfgVehicles" >> _x;
			private _names = toLower (_x + " " + getText (_cfg >> "displayName"));
			(_bad findIf {(_names find _x) >= 0}) < 0 && {count ((getArray (_cfg >> "weapons")) - ["Throw", "Put"]) > 0}
		};
		if (count _units > 0) then {
			private _classes = [];
			for "_i" from 1 to (4 + floor random 3) do {_classes pushBack (selectRandom _units)};
			_groupName = str _classes;
			["INFO", "MCC_fnc_trapSingle", "IED ambush: faction %1 has no infantry group - using %2 of its armed soldiers", [_ambushFaction, count _classes]] call MCC_fnc_log;
		};
	};
	if (_groupName == "") exitWith {
		["WARN", "MCC_fnc_trapSingle", "IED ambush skipped: no infantry group and no armed soldiers for faction '%1'", [_ambushFaction]] call MCC_fnc_log;
	};

	//Find an ambush position
	_time = time + 3;
	_range = 200;
	_ambushPos = [_pos, _range,100] call BIS_fnc_findOverwatch;
	while {isOnRoad _ambushPos && (time < _time)} do {
		_range = _range + 50;
		_ambushPos = [_pos, _range,100] call BIS_fnc_findOverwatch;
	};

	//Dir
	_groupDir = [_ambushPos, _pos] call BIS_fnc_dirTo;

	//spawn the ambush group
	_ambush = [_ambushPos,_groupName,_ambushSide,[""],_groupDir,_pos,0,_iedside] call MCC_fnc_ambushSingle;

	private _waitAmbush = time + 10;
	waituntil {sleep 0.2; (!isNil "_ambush" && {_ambush isEqualType objNull} && {alive _ambush}) || {time > _waitAmbush}};
	if (isNil "_ambush" || {!(_ambush isEqualType objNull)} || {!alive _ambush}) exitWith {
		["WARN", "MCC_fnc_trapSingle", "IED ambush did not appear within 10 s (group %1) - skipped", [_groupName]] call MCC_fnc_log;
	};

	sleep 2;
	//Sync the IED and the ambush group
	[_ambushPos , _pos] remoteExec ["MCC_fnc_iedSync", 2, false];
};

_fakeIed