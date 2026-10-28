/*===================================================================MCC_fnc_startLocations===============================================================================
  Teleport the player when start location has been found
  Example: []  call MCC_fnc_startLocations;
  <IN>	Nothing
  <OUT>	Nothing
=================================================================================================================================================================*/
private _playerSideNr = [];
private _null = [];
private _startLocationName = "";
private _cpActivated = false;
private _respawnDialog = false;
private _markerName = "";
private "_pos";
private _respawnName = "";
private _openDialog = {};

if (!local player || missionNameSpace getVariable ["MCC_startLocationsRuning", false]) exitWith {};

waituntil {alive player && !(IsNull (findDisplay 46))};

_playerSideNr =  [playerSide] call BIS_fnc_sideID;
missionNameSpace setVariable ["MCC_startLocationsRuning", true];

while {count ([player] call MCC_fnc_respawnObjects) < 1} do {sleep 1};

_startLocations = [player] call MCC_fnc_respawnObjects;

missionNameSpace setVariable ["MCC_startLocationsRuning", false];

//Is role selection on
_cpActivated = missionNamespace getVariable ["CP_activated",false];

//Respawn menu on
_respawnDialog = missionNamespace getVariable ["MCC_openRespawnMenu",true];

//Black Screen on mission startup
if (!_cpActivated && _respawnDialog) then {
	_openDialog = {(_x getVariable ["teleport",0]) != 0} count _startLocations > 0;

	if (_openDialog) then {
    waituntil {!dialog};

		cutText ["","BLACK",0.1];
		sleep 3;

		player setVariable ["cpReady",false,true];
		playerDeploy = false;
		sleep 0.1;

		_ok = createDialog ("CP_RESPAWNPANEL" call MCC_fnc_dialogName);
		if !(_ok) exitWith { hint "createDialog failed"; if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log  "CP: create respawn Dialog failed"};};

		waituntil {playerDeploy};
		closedialog 0;
		waituntil {!dialog};
		//Respawning

		player setVariable ["cpReady",true,true];
	};
};

if (_cpActivated) then {
    0 spawn {
        _null=[] execVM MCC_path + "mcc\roleSelection\scripts\player_init.sqf"
    };
};


//--- Update markers---
//Player side
switch (_playerSideNr) do {
    case 0: {
      _startLocationName = "MCC_START_EAST";
      _markerName = "MCC_StartMarkerE";
      _respawnName = "RESPAWN_EAST";
    };

    case 1: {
      _startLocationName = "MCC_START_WEST";
      _markerName = "MCC_StartMarkerW";
      _respawnName = "RESPAWN_WEST";
    };

   case 2: {
      _startLocationName = "MCC_START_GUER";
      _markerName = "MCC_StartMarkerG";
      _respawnName = "RESPAWN_GUERRILA";
    };

    default {
      _startLocationName = "MCC_START_CIV";
      _markerName = "MCC_StartMarkerC";
      _respawnName = "RESPAWN_CIVILIANS";
    };
};

// Only mark a start / base respawn when MCC actually has a start location for this side.
// This used to fall back to "position player" and (re)create a local RESPAWN_<SIDE> marker there every time the player
// respawned. The Respawn EH fires while the new unit is still at the death position (e.g. before the BI respawn menu
// moves it), so the menu and BASE respawn got a "respawn_west" position where the player had died. It also deleted the
// missions own respawn_<side> marker (locally) and replaced it.
_pos = missionNamespace getVariable [_startLocationName, []];
if !(_pos isEqualType [] && {count _pos >= 2} && {!(_pos isEqualTo [0,0,0])}) exitWith {
	if (missionNamespace getVariable [format ["MCC_ownRespawnMarker_%1", _respawnName], false]) then {
		deleteMarkerLocal _respawnName;
		missionNamespace setVariable [format ["MCC_ownRespawnMarker_%1", _respawnName], false];
	};
	if (!isnil _markerName) then {deleteMarkerLocal _markerName};
};

if (!isnil _markerName) then {deleteMarkerLocal _markerName};
missionNamespace setVariable [_markerName,createMarkerLocal [_markerName, _pos]];
_markerName setMarkerShapeLocal "ICON";
_markerName setMarkerTypeLocal  "mil_start";
_markerName setMarkerColorLocal "ColorGreen";

//create the respawn location at the start location - unless the mission has its own respawn_<side> marker
if ((getMarkerPos _respawnName) isEqualTo [0,0,0] || {missionNamespace getVariable [format ["MCC_ownRespawnMarker_%1", _respawnName], false]}) then {
	deleteMarkerLocal _respawnName;
	createMarkerLocal [_respawnName, _pos];
	_respawnName setMarkerShapeLocal "ICON";
	_respawnName setMarkerTypeLocal  "mil_objective";
	_respawnName setMarkerColorLocal "ColorRed";
	missionNamespace setVariable [format ["MCC_ownRespawnMarker_%1", _respawnName], true];
};
