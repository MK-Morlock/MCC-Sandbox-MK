//==================================================================MCC_fnc_missionSettings===========================================================================
// module
// Example: [] call MCC_fnc_missionSettings;
// _group1 = group, the group name
//================================================================================================================================================================
private _module = param [0, objNull, [objNull]];
if (isNull _module) exitWith {deleteVehicle _module};

// Module values can arrive as strings ("1") or booleans when a mission sets them from script,
// even though the attributes are declared NUMBER/BOOL. Read them defensively.
private _fnc_num = {
	params ["_key", "_default"];
	private _v = _module getVariable [_key, _default];
	if (_v isEqualType "") then {_v = parseNumber _v};
	if (_v isEqualType true) then {_v = [0, 1] select _v};
	if !(_v isEqualType 0) then {_v = _default};
	_v
};
private _fnc_bool = {
	params ["_key", "_default"];
	private _v = _module getVariable [_key, _default];
	if (_v isEqualType "") then {_v = (toLower _v) in ["true", "1"]};
	if (_v isEqualType 0) then {_v = _v != 0};
	if !(_v isEqualType true) then {_v = _default};
	_v
};

if (_module isKindOf "MCC_Module_settings") exitWith {
	//T2T
	private _var 	= (["t2t",0] call _fnc_num);
	missionNamespace setVariable ["MCC_t2tIndex",_var];
	if (MCC_t2tIndex isEqualTo 0) then {MCC_teleportToTeam = false};

	//Save gear
	_var 	= (["saveGear",1] call _fnc_num);
	missionNamespace setVariable ["MCC_saveGearIndex",_var];
	MCC_saveGear = (_var isEqualTo 1);

	//Messeges
	_var 	= (["messages",1] call _fnc_num);
	missionNamespace setVariable ["MCC_MessagesIndex",_var];
	MCC_Chat = (_var isEqualTo 1);

	//Sync
	_var 	= (["sync",1] call _fnc_num);
	MCC_syncOn = (_var isEqualTo 1);

	//Artillery computer
	_var 	= (["artilleryComputer",1] call _fnc_num);
	missionNamespace setVariable ["MCC_artilleryComputerIndex",_var];
	_var spawn {
		waitUntil {time > 10};
		enableEngineArtillery (_this isEqualTo 1);
	};

	//Time Excel
	_var 	= (["timeAccel",0] call _fnc_num);
	if (_var > 0) then	{
		_var spawn {
			waitUntil {time > 10};
			setTimeMultiplier _this;
		};
	};

	//Delete players body
	_var 	= (["deleteBody",1] call _fnc_num);
	missionNamespace setVariable ["mcc_deletePlayerBodyIndex",_var];
	MCC_deletePlayersBody = (_var isEqualTo 1);

	//Respawn Menu
	_var 	= (["respawnMenu",1] call _fnc_num);
	MCC_openRespawnMenu = (_var isEqualTo 1);

	//Respawn Cinematic
	MCC_respawnCinematic = (((["respawnCinematic",1] call _fnc_num)) == 1);

	//Respawn on Leader
	missionNameSpace setVariable ["MCC_respawnOnGroupLeader",((["respawnOnGroupLeader",1] call _fnc_num)) ==1];

	//SQL PDA
	_var 	= (["sqlPDA",1] call _fnc_num);
	MCC_allowsqlPDA = (_var isEqualTo 1);

	//Commander Console
	_var 	= (["commanderConsole",1] call _fnc_num);
	MCC_allowConsole = (_var isEqualTo 1);

	//Commander Console Show units without GPS
	_var 	= (["commanderConsoleShowGPS",1] call _fnc_num);
	MCC_ConsoleOnlyShowUnitsWithGPS = if (_var == 0) then {true} else {false};

	//Commander Console Show friendly WP
	_var 	= (["commanderConsoleWP",1] call _fnc_num);
	MCC_ConsoleDrawWP = (_var isEqualTo 1);
	MCC_ConsolePlayersCanSeeWPonMap = (_var isEqualTo 1);

	//Commander Console Can command AI
	_var 	= (["commanderConsoleAI",1] call _fnc_num);
	MCC_ConsoleCanCommandAI = (_var isEqualTo 1);

	//Logistics
	_var 	= (["logistics",1] call _fnc_num);
	MCC_allowlogistics =(_var isEqualTo 1);

	//Allow RTS
	_var 	= (["allowRTS",0] call _fnc_num);
	MCC_allowRTS = (_var isEqualTo 1);

	//Purchable airDrops
	MCC_defaultSupplyDropsEnabled = (["defaultSupplyDropsEnabled",false] call _fnc_bool);

	//Purchable CAS
	MCC_defaultCASEnabled = (["defaultCASEnabled",false] call _fnc_bool);

	//Disable Curator Edit
	MCC_CuratorEditDisabled = (["CuratorEditDisabled",false] call _fnc_bool);

	//Armed Civilians Weapons
	MCC_armedCivilansWeapons = [_module getvariable ["armedCiviliansWeapons",""], '["hgun_P07_F","hgun_Rook40_F","hgun_ACPC2_F","hgun_Pistol_heavy_01_F","hgun_Pistol_heavy_02_F","SMG_01_F","SMG_02_F","hgun_PDW2000_F"]', "armedCiviliansWeapons (module)"] call MCC_fnc_parseSetting;
};

//Not curator exit
if !(local _module) exitWith {};

_resualt = ["Settings MCC",[
 						["Teleport 2 Team",["Disabled","JIP Only","After Respawn","Always"]],
 						["Save Gear",(missionNamespace getVariable ["MCC_saveGear",true])],
 						["MCC Messages",(missionNamespace getVariable ["MCC_Chat",true])],
 						["Delete Players' Bodies",(missionNamespace getVariable ["MCC_deletePlayersBody",false])],
 						["Respawn Dialog",(missionNamespace getVariable ["MCC_openRespawnMenu",true])],
 						["Respawn On Leader",(missionNamespace getVariable ["MCC_respawnOnGroupLeader",true])],
 						["Respawn Cinematic",(missionNamespace getVariable ["MCC_respawnCinematic",true])],
 						["Squad Leader PDA",(missionNamespace getVariable ["MCC_allowsqlPDA",true])],
 						["(CS) Commander Console",(missionNamespace getVariable ["MCC_allowConsole",true])],
 						["(CS) Show groups with GPS only",(missionNamespace getVariable ["MCC_ConsoleOnlyShowUnitsWithGPS",true])],
 						["(CS) Show friendly WP",(missionNamespace getVariable ["MCC_ConsolePlayersCanSeeWPonMap",true])],
 						["(CS) Can command AI",(missionNamespace getVariable ["MCC_ConsoleCanCommandAI",true])],
 						["Squad Dialog",(missionNamespace getVariable ["MCC_allowSquadDialog",true])],
 						["Logistics",(missionNamespace getVariable ["MCC_allowlogistics",true])],
 						["Real Time Strategy",(missionNamespace getVariable ["MCC_allowRTS",true])],
 						["Purchasable Supply Drops",(missionNamespace getVariable ["MCC_defaultSupplyDropsEnabled",true])],
 						["Purchasable CAS",(missionNamespace getVariable ["MCC_defaultCASEnabled",true])],
 						["Disable Zeus Edit",(missionNamespace getVariable ["MCC_CuratorEditDisabled",false])],
 						["Reduce Tickets on Respawn",(missionNamespace getVariable ["MCC_reduceTicketsOnDeath",true])],
 						["Artillery Computer",true],
 						["Time Acceleration",20],
 						["Resistance Hostile To",["All","East","West"]]
 					  ]] call MCC_fnc_initDynamicDialog;

if (count _resualt == 0) exitWith {deleteVehicle _module};

{
	missionNamespace setVariable [_x,_resualt select _foreachindex];
	publicvariable _x;
} forEach ["MCC_t2tIndex",
           "MCC_saveGear",
           "MCC_Chat",
           "MCC_deletePlayersBody",
           "MCC_openRespawnMenu",
           "MCC_respawnOnGroupLeader",
           "MCC_respawnCinematic",
           "MCC_allowsqlPDA",
           "MCC_allowConsole",
           "MCC_ConsoleOnlyShowUnitsWithGPS",
           "MCC_ConsolePlayersCanSeeWPonMap",
           "MCC_ConsoleCanCommandAI",
           "MCC_allowSquadDialog",
           "MCC_allowlogistics",
           "MCC_allowRTS",
           "MCC_defaultSupplyDropsEnabled",
           "MCC_defaultCASEnabled",
           "MCC_CuratorEditDisabled",
           "MCC_reduceTicketsOnDeath"
           ];

(_resualt select 19) remoteExec ["enableEngineArtillery",0];
(_resualt select 20) remoteExec ["setTimeMultiplier",2];

//Resistance Hostility
switch (_resualt select 21) do {

	//East
	case 1:
	{
		[resistance,[east, 0]] remoteExec ["setfriend",2];
		[resistance,[west, 0.8]] remoteExec ["setfriend",2];
		[east,[resistance, 0]] remoteExec ["setfriend",2];
		[west,[resistance, 0.8]] remoteExec ["setfriend",2];
	};

	//West
	case 2:
	{
		[resistance,[east, 0.8]] remoteExec ["setfriend",2];
		[resistance,[west, 0]] remoteExec ["setfriend",2];
		[east,[resistance, 0.8]] remoteExec ["setfriend",2];
		[west,[resistance, 0]] remoteExec ["setfriend",2];
	};

	//All
	default
	{
		[resistance,[east, 0.8]] remoteExec ["setfriend",2];
		[resistance,[west, 0]] remoteExec ["setfriend",2];
		[east,[resistance, 0.8]] remoteExec ["setfriend",2];
		[west,[resistance, 0]] remoteExec ["setfriend",2];
	};
};

deleteVehicle _module;