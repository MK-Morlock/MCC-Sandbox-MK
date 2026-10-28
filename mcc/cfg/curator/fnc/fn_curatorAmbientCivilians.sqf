//============================================================MCC_fnc_curatorAmbientCivilians====================================================================================
// handles the add ambient civilians module
//===========================================================================================================================================================================
private "_pos";
private _module = objNull;
private _factionArray = [];
private _resualt = [];
private _civRelations = 0;
private _civRelationsIgnore = false;
_module = param [0, objNull, [objNull]];
if (isNull _module) exitWith {deleteVehicle _module};

//did we get here from the 2d editor?
if (typeName (_module getVariable ["isCiv",true]) == typeName 0) exitWith {

	if (isServer) then {
		private _isCiv = (_module getVariable ["isCiv",1])==1;
		private _isCar = (_module getVariable ["isCar",1])==1;
		private _isParkedCar = (_module getVariable ["isParkedCar",1])==1;
		private _isLocked = (_module getVariable ["isLocked",1])==1;
		private _civSpawnDistance = 250;
		private _maxCivSpawn = 4;
		private _factionCiv = _module getVariable ["factionCiv","CIV_F"];
		private _factionCivCar = _module getVariable ["factionCivCar","CIV_F"];
		_civRelations = _module getVariable ["civRelations",0.5];
		if (_civRelations > 1) then {_civRelations = _civRelations / 10};
		if (_civRelations <= 0) then {_civRelations = 0.2};
		_civRelationsIgnore = missionNamespace setVariable ["MCC_civRelationsIgnore",((_module getVariable ["civRelationsIgnore",0])==1)];
		publicVariable "MCC_civRelationsIgnore";

		//Start ambient civilians
		[_isCiv,_isCar,_isParkedCar,_isLocked,_civSpawnDistance,_maxCivSpawn,_factionCiv,_factionCivCar,_civRelations] spawn MCC_fnc_ambientInit;
	};
};

//Not curator exit
if (!(local _module) || isnull curatorcamera) exitWith {};

_pos = getpos _module;

_factionArray = [];
{
	_factionArray pushBack (_x select 0);
} forEach U_FACTIONS;

 _resualt = ["Ambient Civilians (place again to change - untick the first three to stop and remove them)",[
 						["Ambient Civilians",true],
 						["Ambient Driving Cars",true],
 						["Ambient Parked Cars",true],
 						["Parked cars will always be locked ",false],
 						["Spawn distance around the players",500],
 						["max units spawned around the player",8],
 						["Faction",_factionArray],
 						["Car's Faction",_factionArray],
 						["Civilians Reaction to players",["bad (IED & Suicide Bombers)","average","above average","good"]],
 						["Civilians Always Friendly ",false]
 					  ]] call MCC_fnc_initDynamicDialog;

if (count _resualt == 0) exitWith {deleteVehicle _module};

_resualt set [6,(U_FACTIONS select (_resualt select 6)) select 2];
_resualt set [7,(U_FACTIONS select (_resualt select 7)) select 2];
_resualt set [8,[0.2,0.5,0.7,0.95] select (_resualt select 8)];

missionNamespace setVariable ["MCC_civRelationsIgnore",(_resualt select 9)];
publicVariable "MCC_civRelationsIgnore";

//Start ambient civilians
_resualt remoteExec ["MCC_fnc_ambientInit",2];
deleteVehicle _module;