//============================================================MCC_fnc_curatorGarrisonUnits====================================================================================
// "Garrison units in the selected buildings
//===========================================================================================================================================================================
private "_pos";
private _module = objNull;
private _factionArray = [];
private _resualt = [];
_module = _this param [0, objNull, [objNull]];
if (isNull _module) exitWith {};

//Not curator exit
if (!(local _module) || isnull curatorcamera) exitWith {};

_pos = getpos _module;

_factionArray = [];
{
	_factionArray pushBack (format ["%1(%2)",_x select 0,_x select 1]);
} forEach U_FACTIONS;

 _resualt = ["Garrison Buildings",[
 						["Faction",_factionArray],
 						["Radius",500],
 						["Population Intensity",10,"0-10: chance each building position gets a soldier (10 = about one in three)",5],
 						["Parked Cars",true],
 						["Cars Always Locked ",false],
 						["One Group Per House",true]
 					  ]] call MCC_fnc_initDynamicDialog;

if (count _resualt == 0) exitWith {deleteVehicle _module};

private "_faction";
private _side = [];
private "_radius";
private "_spawnVehicles";
private "_locked";
private "_intanse";
private "_groupUnits";
private _side = [];
_faction = (U_FACTIONS select (_resualt select 0)) select 2;
_radius = _resualt select 1;
_intanse = _resualt select 2;	//0-10 (the slider used to go 0-1, so ~3 % of building positions got a soldier while vehicles still spawned)
_spawnVehicles = _resualt select 3;
_locked = _resualt select 4;
_groupUnits = _resualt select 5;
_side = [([_faction] call MCC_fnc_factionSide)] call BIS_fnc_sideType;

//Start ambient civilians
[_pos, _radius, _spawnVehicles, _intanse, _faction, _side, _groupUnits, _locked] remoteExec ["MCC_fnc_garrison", 2, false];
deleteVehicle _module;