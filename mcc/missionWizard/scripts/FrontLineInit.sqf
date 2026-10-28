/*
	Front Line Init (client): draw the line, click the attack side, then the server builds it (MCC_fnc_FLGenerate).
	MCC 4s author never finished this; the original stopped after the clicks and spawned nothing.
*/
#define MCC_MINIMAP 9000
#define FACTIONCOMBO 1001
#define MCC_FLDepthIDC 6030
#define MCC_FLTaskIDC 6031
#define MCC_FLAttackerIDC 6032
#define MCC_FLAttackStartIDC 6033
#define MCC_FLReinforcementIDC 6034

disableSerialization;
private _display = uiNamespace getVariable ["MCC_FLDialog", displayNull];
if (isNull _display) exitWith {};
private _debugCtrl = _display displayCtrl 0;
private _say = {_debugCtrl ctrlSetStructuredText parseText format ["<t size='0.9' color='#33CC00'>%1</t>", _this]; playSound "MCC_pop"};

if (missionNamespace getVariable ["MCC_FLGenerating", false]) exitWith {"A front line is already being generated" call _say};

//Read the settings now, the dialog closes before the server is done
private _faction = (U_FACTIONS param [lbCurSel (_display displayCtrl FACTIONCOMBO), []]) param [2, ""];
if (_faction == "") exitWith {"Select a faction first" call _say};
private _attIdx = lbCurSel (_display displayCtrl MCC_FLAttackerIDC);
private _attFaction = if (_attIdx > 0) then {(U_FACTIONS param [_attIdx - 1, []]) param [2, ""]} else {""};
private _opts = [
	profileNamespace getVariable ["MCC_MWDifficultyIndex",0],
	profileNamespace getVariable ["MCC_MWVehiclesIndex",2],
	profileNamespace getVariable ["MCC_MWArmorIndex",2],
	profileNamespace getVariable ["MCC_MWArtilleryIndex",3],
	profileNamespace getVariable ["MCC_MWIEDIndex",2],
	profileNamespace getVariable ["MCC_FLIEDmarkersTittleIndex",0],
	profileNamespace getVariable ["MCC_MWRoadBlockIndex",2],
	profileNamespace getVariable ["MCC_FLFortificationsmarkersCombo",0],
	profileNamespace getVariable ["MCC_MWDebugIndex",0],
	profileNamespace getVariable ["MCC_FLDepthIndex",1],
	profileNamespace getVariable ["MCC_FLTaskIndex",1],
	profileNamespace getVariable ["MCC_FLAttackStartIndex",0],
	profileNamespace getVariable ["MCC_FLReinforcementIndex",0],
	profileNamespace getVariable ["MCC_FLReinforcementWaitIndex",0]
];

//1. Draw the line (handled by the maps mouse scripts)
"Hold left click on the map and drag to draw the front line" call _say;
MCC_FLKeepLine = true;
MCC_FLLineMarker = "";
MCC_DrawLine = true;
waitUntil {!(missionNamespace getVariable ["MCC_DrawLine",false]) || {isNull _display}};
private _clearLine = {MCC_FLKeepLine = false; if (MCC_FLLineMarker != "") then {deleteMarkerLocal MCC_FLLineMarker; MCC_FLLineMarker = ""}};
if (isNull _display) exitWith {MCC_DrawLine = false; call _clearLine};
//Read the end point straight away. The mouse-up script stores MCC_pointB before it releases the drawing loop, so it is
//already set here - and reading it later could pick up the next click (the attack-side click also sets MCC_pointB).

private _lineStart = missionNamespace getVariable ["MCC_pointA",[0,0,0]];
private _lineEnd = missionNamespace getVariable ["MCC_pointB",[0,0,0]];
if (_lineStart distance2D _lineEnd < 100) exitWith {call _clearLine; "Line too short (100 m minimum)" call _say};

//2. Click the side the enemy will be attacked from
"Left click on the map on the side the attack comes from (the front of the line)" call _say;
MCC_FLDirPoint = [];
private _map = _display displayCtrl MCC_MINIMAP;
private _eh = _map ctrlAddEventHandler ["MouseButtonClick", {
	params ["_ctrl", "_button", "_x", "_y"];
	if (_button == 0) then {MCC_FLDirPoint = _ctrl ctrlMapScreenToWorld [_x, _y]};
}];
waitUntil {count MCC_FLDirPoint > 0 || {isNull _display}};
if (!isNull _map) then {_map ctrlRemoveEventHandler ["MouseButtonClick", _eh]};
call _clearLine;
if (count MCC_FLDirPoint == 0) exitWith {};

//3. Build it on the server
"Generating the front line - this can take a minute" call _say;
[_lineStart, _lineEnd, MCC_FLDirPoint, _faction, _opts, _attFaction, player] remoteExec ["MCC_fnc_FLGenerate", 2];
["INFO", "FrontLineInit", "front line requested: %1 -> %2, front %3, faction %4, attacker %5, options %6", [_lineStart, _lineEnd, MCC_FLDirPoint, _faction, _attFaction, _opts]] call MCC_fnc_log;
