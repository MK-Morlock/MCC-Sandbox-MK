//===================================================================MCC_fnc_groupSpawn=========================================================================================
// Create a group on the server
//[_pos,_unitsArray,_loc, _side, _isEmpty, _cache] remoteExec ["MCC_fnc_groupSpawn", false, false];
//	<in>
//		_pos: Array		Position to spawn
//		_unitsArray		Array of units or Cfg path
//		_loc				Integer - 1 Headless Client
//		_side			side name or string
//		_isEmpty
//		_cache			automaticlly cache the group
//
//==============================================================================================================================================================================
//Made by Shay_Gman (c) 09.10

private _side = sideUnknown;
private _group = objNull;
private _isEmpty = false;
private _unitClass = "";
private _unitSim = "";
private _unit = objNull;
private _safePos = [];
private _waterSpawn = 0;
private _cache = nil;

params ["_pos", "_unitsArray", "_loc"];
if !(call MCC_fnc_secSenderOK) exitWith {};
_side		= if (typeName (_this select 3) == "STRING") then
				{
					switch (tolower (_this select 3)) do
					{
						case "guer":{resistance};
						case "civ":{civilian};
						default {call compile (_this select 3)};
					};
				}
				else
				{
					(_this select 3)
				};

_isEmpty	= _this select 4;
_cache		= if (count _this > 5) then { _this select 5};

mcc_isnewzone = false;
mcc_grouptype = "";
mcc_spawntype = "";
mcc_classtype = "";
mcc_spawnname = "";
mcc_spawnfaction ="";
mcc_resetmissionmaker = false;

if (surfaceIsWater _pos) then {_waterSpawn = 2} else {_waterSpawn = 0};

if ( ( (isServer) && ( (_loc == 0) || !(MCC_isHC) ) ) || ( (MCC_isLocalHC) && (_loc == 1) ) ) then
{
	if (_isEmpty) then
	{
		_group = (_unitsArray select 0) createVehicle _pos; [_group] call MCCMK_fnc_genTag;
		[_group] call MCCMK_fnc_garageApply;	//(MK) its class's garage paint and parts, if any
		_group setpos _pos;
		{_x addCuratorEditableObjects [[_group],false]} forEach allCurators;
	}
	else
	{
		//Cfg Group
		if (typeName _unitsArray == "STRING") exitWith
		{
			_group = [_pos, _side, (call compile _unitsArray)] call MCC_fnc_spawnGroup;
			_group setVariable ["mcc_gaia_cache",_cache, true];

		};

		if (typeName _unitsArray == "CONFIG") exitWith
		{
			_group = [_pos, _side, _unitsArray] call MCC_fnc_spawnGroup;
			_group setVariable ["mcc_gaia_cache",_cache, true];
		};

		//Array group workAround
		_group = creategroup _side; [_group] call MCCMK_fnc_genTag;
		for [{_x=0},{_x < (count _unitsArray)},{_x=_x+1}] do
		{
			_unitClass 	= _unitsArray select _x;
			_unitSim	= getText(configFile >> "CfgVehicles" >> _unitClass >> "simulation");

			switch (tolower _unitSim) do
			{
				case "soldier":
				{
					_unit = _group createunit [_unitClass,_pos,[],0,"none"]; [_unit] call MCCMK_fnc_genTag;
					{_x addCuratorEditableObjects [[_unit],false]} forEach allCurators;
				};
				default
				{
					//(MK) Start: Landed (the Spawn panel - param 8): an aircraft on the ground, engine off, at the nearest
					// spot where it fits (findEmptyPosition allows for its size), held until its first order
					private _startArg = _this param [8, false, [false, 0]];
					private _startN = if (_startArg isEqualType 0) then {_startArg} else {[0, 1] select _startArg};
					if !((toLower _unitSim) in ["airplanex", "helicopterrtd", "helicopterx"]) then {_startN = 0};
					private _landed = _startN > 0;
					//(MK) On water: where clicked, if that is water (else as Landed)
					if (_startN == 2 && {!surfaceIsWater _pos || {!([_unitClass] call MCCMK_fnc_canFloat)}}) then {_startN = 1};
					_safepos  = if (_startN == 2) then {_pos} else {if (_landed) then {
						private _e = _pos findEmptyPosition [0, 80, _unitClass];
						if (_e isEqualTo []) then {[_pos,1,50,2,_waterSpawn,50,0] call BIS_fnc_findSafePos} else {_e}
					} else {[_pos,1,50,2,_waterSpawn,50,0] call BIS_fnc_findSafePos}};
					_unit = [[_safepos select 0,_safepos select 1,0], 0, _unitClass, _group, true, true, "", _startN] call MCC_fnc_spawnVehicle;
					{_x addCuratorEditableObjects [[_unit select 0],true]} forEach allCurators;
					if ((count _this) > 6) then {[_unit select 0] call MCCMK_fnc_spawnAnchor};
					[_unit select 0] call MCCMK_fnc_garageApply;	//(MK) its class's garage paint and parts, if any
				};
			};
		};

		//Set skill
		{
			_x setSkill ["aimingspeed", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
			_x setSkill ["spotdistance", (missionNamespace getVariable ["MCC_AI_Spot",0.3])];
			_x setSkill ["aimingaccuracy", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
			_x setSkill ["aimingshake", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
			_x setSkill ["spottime", (missionNamespace getVariable ["MCC_AI_Spot",0.3])];
			_x setSkill ["commanding", (missionNamespace getVariable ["MCC_AI_Command",0.5])];
			_x setSkill ["general", (missionNamespace getVariable ["MCC_AI_Skill",0.5])];
		} foreach units _group;

		_group setVariable ["mcc_gaia_cache",_cache, true];
	};
};
private _beh = toLower (_this param [6, "-", [""]]);
if (!_isEmpty && {_beh != "-"} && {_group isEqualType grpNull} && {!isNull _group}) then {
	if (_this param [7, false, [false]]) then {_group setVariable ["MCC_canbecontrolled", true, true]};
	if (_beh == "bisd") then {[_group, getPos (leader _group)] call BIS_fnc_taskDefend};
	if (_beh == "bisp") then {[_group, getPos (leader _group), 100] call BIS_fnc_taskPatrol};
	["DEBUG", "spawn", "%1 placed with behaviour %2, commandable: %3", [_group, _beh, _this param [7, false, [false]]]] call MCC_fnc_log;
};
_group