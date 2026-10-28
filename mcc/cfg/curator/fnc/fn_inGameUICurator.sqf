//============================================================MCC_fnc_inGameUICurator====================================================================================
// setting MCC's UI
//===========================================================================================================================================================================
private "_pos";
private _module = objNull;
private _resualt = [];
_module = param [0, objNull, [objNull]];
if (isNull _module) exitWith {deleteVehicle _module};

//Not curator exit
if !(local _module) exitWith {};

_pos = getpos _module;

// The dialog opens on the CURRENT settings (it used to open with everything ticked, so pressing OK switched everything on)
private _ns = missionNamespace;
private _compassMode = _ns getVariable ["MCC_Settings_compassEnabled", [2, 0] select (_ns getVariable ["MCC_initCompassHUD", false])];
private _cam = player getVariable ["MCC_forceCameraMode", _ns getVariable ["MCC_Settings_forceCamera", 3]];
if !(_cam isEqualType 0) then {_cam = 3};

_resualt = ["UI Settings",[
						["3rd Person",["Disable","Only in Vehicles","Only in air Vehicles","Everyone"], "", (_cam max 0) min 3],
						["Compass HUD", _compassMode != 2],
						["Compass Show Squad Markers", _compassMode == 1],
						["Map Squads Markers", _ns getVariable ["MCC_groupMarkers", false]],
						["Map Units Markers", _ns getVariable ["MCC_indevidualMarkers", false]],
						["Name Tags", _ns getVariable ["MCC_nameTags", false]],
						["Name Tags Only When Pointing", _ns getVariable ["MCC_NameTags_direct", false]],
						["Suppression Effects", _ns getVariable ["MCC_suppressionOn", false]],
						["Fire Direction indicator",["Realistics","Arcade","Off"], "", _ns getVariable ["MCC_hitRadar", 0]],
						["Tickets", _ns getVariable ["MCC_UIModuleTickets", false]],
						["Tutorials", false],
						["Suppression Strength",["Minimal","Average","Maximum"], "Blur, red tint and screen shake strength", ((_ns getVariable ["MCC_suppressionLevel", 3]) - 1) max 0 min 2]
					  ]] call MCC_fnc_initDynamicDialog;

if (count _resualt == 0) exitWith {deleteVehicle _module};

//Start
_resualt remoteExec ["MCC_fnc_inGameUI", 0, true];
deleteVehicle _module;