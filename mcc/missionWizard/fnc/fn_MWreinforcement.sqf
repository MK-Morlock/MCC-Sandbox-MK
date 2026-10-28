//======================================================MCC_fnc_MWreinforcement=========================================================================================================
// Create a reinforcment type
// Example:[_reinforcement,_side, _missionCenterTriggerPos,_missionCenterTriggerArea,_cond] call MCC_fnc_MWreinforcement;
//
//	<IN>
//	_reinforcement: 			Integer, 1 - Aerial, 2 - Motorized, 3 - Mixed
// 	_side: 					side, reinforcment's side
// 	_missionCenterTriggerPos: 	Array, Center Position
//	_missionCenterTriggerArea	Trigger Area as in  [H, W, angle, rectangle (boolead)].
// 	_cond: 					Array of conditions when the number of units at the start are less in precentage then the number in condition a reinforcment will occur.
//
// 	<OUT>
//			Nothing
//========================================================================================================================================================================================
private _trigger = objNull;
private _tlist = 0;
private _found = false;
private _ar = [];
private _size = 0;
private _strDir = "";
private _command = "";
private _para = [];
private _check = [];

params [
	["_reinforcement", 0, [0]],
	["_side", sideUnknown, [sideUnknown]],
	["_missionCenterTriggerPos", [0,0,0], [[]]],
	["_missionCenterTriggerArea", [], [[]]],
	["_cond", [], [[]]],
	["_zoneNumber", 0, [0, ""]],
	["_faction", "", [""]],
	["_warning", true, [true]],
	["_totalEnemyUnits", 0, [0]],
	["_fromDir", -1, [0]],	//optional: reinforcements come from this direction (+-45 deg) instead of anywhere (Front Lines: from behind the line)
	["_waitForPlayers", true, [true]]	//optional: false = do not wait for a player to come near first (AI vs AI with no player nearby)
];


if !(isServer || isDedicated) exitWith {};

if (isnil "mcc_mwunitsarraycar") then
{
	//Build the faction's unitsArrays and send it to the server.
	_check = [_faction, _side] call MCC_fnc_MWCreateUnitsArray;
	waituntil {_check};
};

if (typeName _side == "STRING") then
{
	_side = switch (_side) do
			{
				case "WEST":{west};
				case "EAST":{east};
				case "GUER":{resistance};
				case "CIV":{civilian};
				default {east};
			};
};

//Size: 0 - small, 1 - medium, 2 - large
_size = 0;
if (_totalEnemyUnits > 40) then {_size = 1};
if (_totalEnemyUnits > 60) then {_size = 2};

_trigger = createTrigger ["emptydetector",_missionCenterTriggerPos];
_trigger settriggerarea _missionCenterTriggerArea;
_trigger setTriggerActivation [str _side, "PRESENT", true];
sleep 5;

//Wait untill player is nearby to work with cache and delayed spawn
if (_waitForPlayers && {!isNil "GAIA_fnc_isNearPlayer"}) then {
	while {!([getposAtl _trigger,((missionNamespace getVariable ["GAIA_CACHE_STAGE_1",1000])/2)] call GAIA_fnc_isNearPlayer)} do {sleep 10};
};

_tlist = (_side countSide (list _trigger)) max 1;

private _dir = 0;
private _distance = false;
private _newPos = nil;
private _rfc = 0;

for "_i" from 0 to (count _cond) step 1 do
{
	//Create Zone
	_found = false;

	_rfc = if (_reinforcement == 3) then {[1,2] call BIS_fnc_selectRandom} else {_reinforcement};
	if (_rfc == 2 && (count MCC_MWunitsArrayCar) <= 0) then {_rfc = 1};

	while {!_found} do
	{
		_dir = if (_fromDir >= 0) then {_fromDir - 45 + random 90} else {floor random 360};
		_distance = (floor (random 1000)) + (if (_rfc == 0) then {2000} else {1000});
		_newPos = [_missionCenterTriggerPos, _distance, _dir] call BIS_fnc_relPos;
		_newPos = getposATL ((_newPos nearRoads 200) select 0);
		if (!isNil "_newPos") then
		{
			_found = true;
			{
				if (isPlayer _x && (_x distance _newPos < 1000)) then {_found = false};
			} forEach allUnits;
		};
	};

	while {(1-(_side countSide (list _trigger))/_tlist) < (_cond select _i)} do {sleep 10};

	switch (_rfc) do
	{
		case 1: 	//Aerial
		{
			//Size
			switch (_size) do
			{
				case 0:
				{
					_para = [0,0,1,3,3,4,6,6,7] call BIS_fnc_selectRandom;
				};

				case 1:
				{
					_para = [1,1,2,4,4,5,7,7,8] call BIS_fnc_selectRandom;
				};

				case 2:
				{
					_para = [1,2,2,4,5,5,7,8,8] call BIS_fnc_selectRandom;
				};
			};

			if (_warning) then
			{
				//Lets give the player some hint about movment
				_dir 	= [_missionCenterTriggerPos, _newPos] call BIS_fnc_dirTo;
				_strDir = "HQ: Enemy aerial QRF is moving in from the " + ([_dir] call MCC_fnc_dirToString);	//small, near the top, as on the squad screen (MCC_fnc_rsMessage)
				_command = format ['["%1",6] spawn MCC_fnc_rsMessage;',_strDir];
				[2,compile _command] remoteExec ["MCC_fnc_globalExecute", 0, false];
			};
		};

		case 2: 	//Motorized
		{
			_para = _size + 9;
			if (_warning) then
			{
				//Lets give the player some hint about movment
				_dir 	= [_missionCenterTriggerPos, _newPos] call BIS_fnc_dirTo;
				_strDir = "HQ: Enemy motorized QRF is moving in from the " + ([_dir] call MCC_fnc_dirToString);	//small, near the top, as on the squad screen (MCC_fnc_rsMessage)
				_command = format ['["%1",6] spawn MCC_fnc_rsMessage;',_strDir];
				[2,compile _command] remoteExec ["MCC_fnc_globalExecute", 0, false];
			};

		};
	};

	//spawn
	_ar =	[ "Reinforcement"
				, _para
				, false
				, true
				, _para
				, _faction
				, _zoneNumber
				, "NOTHING"
				, str _zoneNumber
				, "MOVE"
				, _missionCenterTriggerPos
				, [_missionCenterTriggerArea select 0,_missionCenterTriggerArea select 1]
				, _missionCenterTriggerArea select 0
				, str _side
				, MCC_server
				, 0
				, false
				, false
				, mcc_missionmaker
				, "default"
				, 0
				, _newPos
				, 0 //(mcc_zonetype select 0 ) select 1
				, 0 //(mcc_zonetypenr select 0 ) select 1
				, 0
				, _newPos
				, false
				, false
				];

	_ar remoteExec ["mcc_setup", 2, false];
};

//Clean up
deleteVehicle _trigger;
