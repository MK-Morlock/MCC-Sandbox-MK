private _goggles = "";
private _headgear = "";
private _uniform = "";
private _uniformItems = [];
private _vest = "";
private _magazines = [];
private _primMag = [];
private _secmMag = [];
private _handMag = [];
private _assigneditems = [];
private _vestItems = [];
private _handgunWeapon = "";
private _backpack = "";
private _primaryWeapon = "";
private _secondaryWeapon = "";
private _null = [];
private _killer = objNull;

params ["_unit"];
_killer = if (count _this > 1) then {_this select 1} else {objnull};


//Delete utility placed by the player
{deleteVehicle _x} foreach (player getVariable ["MCC_utilityActiveCharges",[]]);

if (missionNamespace getvariable ["MCC_saveGear",false]) then {
	_goggles = goggles _unit; 			//Can't  save gear after killed EH
	_headgear = headgear _unit;
	_uniform = uniform _unit;
	_vest = vest _unit;
	_backpack = backpack _unit;

	_primMag = missionNamespace getVariable ["MCC_save_primaryWeaponMagazine",[]];
	_secmMag = missionNamespace getVariable ["MCC_save_secondaryWeaponMagazine",[]];
	_handMag = missionNamespace getVariable ["MCC_save_handgunMagazine",[]];
	_items = items _unit;
	_assigneditems = assigneditems _unit;

	_uniformItems = uniformItems _unit;
	_vestItems = vestItems _unit;

	_primaryWeapon = missionNamespace getVariable ["MCC_save_primaryWeapon",""];
	_secondaryWeapon =  missionNamespace getVariable ["MCC_save_secondaryWeapon",""];
	_handgunWeapon =  missionNamespace getVariable ["MCC_save_handgunWeapon",""];
	_magazines =  missionNamespace getVariable ["MCC_save_magazines", []];
};

WaitUntil {alive player};

//Reduce tickets
if (([playerSide] call BIS_fnc_respawnTickets > 0) && (missionNamespace getVariable ["MCC_reduceTicketsOnDeath",true])) then {
	[playerSide,-1] call BIS_fnc_respawnTickets
};

//Mark it zero again
player addRating (-1 * (rating player));

//handle MCC medic stuff
player setVariable ["MCC_medicUnconscious",false,true];
player setVariable ["MCC_medicBleeding",0,true];
player setvariable ["MCC_medicRemainBlood",(missionNamespace getvariable ["MCC_medicBleedingTime",200])];
player setCaptive false;

//Fatigue / stamina - re-apply the current choice either way (a respawned unit starts with stamina on)
player enableStamina !(missionNamespace getVariable ["MCC_disableFatigue",false]);

//Delete dead body
if (missionNameSpace getVariable ["MCC_deletePlayersBody",false]) then {deleteVehicle _unit};

_null = ["zeusAdd", [[player], false, false]] remoteExec ["MCC_fnc_secAction", 2, false];

if (missionNamespace getvariable ["MCC_saveGear",false]) then {
	[	_goggles,
		_headgear,
		_uniform,
		_vest,
		_backpack,
		missionNamespace getVariable ["MCC_save_Backpack",[]],
		_primMag,
		_secmMag,
		_handMag,
		_assigneditems,
		_uniformItems,
		_vestItems,
		_primaryWeapon,
		_secondaryWeapon,
		_handgunWeapon,
		missionNamespace getVariable ["MCC_save_primaryWeaponItems",[]],
		missionNamespace getVariable ["MCC_save_secondaryWeaponItems",[]],
		missionNamespace getVariable ["MCC_save_handgunitems",[]]
	] call MCC_fnc_loadGear;
};

//Handle add - action
[] call MCC_fnc_handleAddaction;

//if lost curator for some reason
if (((missionNamespace getvariable ["mcc_missionmaker",""])== name player) && (player != getAssignedCuratorUnit MCC_curator)) then {
	player remoteExec ["MCC_fnc_assignCurator", 2, false];
};

if (isnil "MCC_TRAINING") then {
	//------------T2T---------------------------------
	if ((missionNamespace getVariable ["MCC_t2tIndex",0]) > 1) then {MCC_teleportToTeam = true};
};

