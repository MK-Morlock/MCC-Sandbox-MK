/*==========================================================MCC_fnc_curatorRTSBuilding====================================================================================
// Instantly construct RTS Building
========================================================================================================================================================================*/
private _module = objNull;
private _resualt = [];
_module = param [0, objNull, [objNull]];
if (isNull _module) exitWith {deleteVehicle _module};

//did we get here from the 2d editor?
if ((_module getVariable ["building", _module getVariable ["MCC_Module_RTSBuildingsCurator_building", true]]) isEqualType "") exitWith {

	if (isServer) then {
		private _bld = _module getVariable ["building", _module getVariable ["MCC_Module_RTSBuildingsCurator_building", "MCC_rts_storage1"]];
		if (_bld == "") then {_bld = "MCC_rts_storage1"};
		private _sid = _module getVariable ["side", _module getVariable ["MCC_Module_RTSBuildingsCurator_side", 1]];
		if (_sid isEqualType "") then {_sid = if (_sid == "") then {1} else {parseNumber _sid}};
		[getpos _module, getDir _module, _bld, 0, [_sid] call BIS_fnc_sideType] spawn MCC_fnc_construct_base;
	};
};

//Not curator exit
if (!(local _module) || isnull curatorcamera) exitWith {};

private _path = configNull;
private _buildingsCfg = [];
private _buildingsDisplay = [];
private "_class";
private "_index";

_path = if (isClass(missionConfigFile >> "cfgRTSBuildings")) then {
		(missionConfigFile >> "cfgRTSBuildings")
	} else {
		(configFile >> "cfgRTSBuildings")
	};

_buildingsCfg =[];
_buildingsDisplay =[];

//Go through configs
for "_i" from 0 to (count _path - 1) do	{
	_class = _path select _i;
	if (isClass _class) then {

		//We don't want any HQ near
		if (getText (_class >> "constType") != "hq") then {
			_buildingsCfg pushBack (configName _class);
			_buildingsDisplay pushBack (getText (_class >> "displayName"));
		};
	};
};

_resualt = ["(RTS)Buildings",[
						["Building",_buildingsDisplay],
						["Side", ["East","West","Resistance"],"",1]
					  ]] call MCC_fnc_initDynamicDialog;

if (count _resualt == 0) exitWith {};

_index = _resualt select 0;

[getpos _module, getDir _module, (_buildingsCfg select _index),0,((_resualt select 1) call BIS_fnc_sideType)] remoteExec ["MCC_fnc_construct_base",2];

deleteVehicle _module;