/*================================================================== MCC_fnc_assetsSyncConsole ==================================================================
	After the Assets page closes. If the faction was changed on the page, the MCC console is redrawn for it, the same way
	the console does it when its own faction list changes, so its spawn lists (unit types, groups, classes) show the new
	faction straight away. If not, nothing changes.
==============================================================================================================================================================*/
disableSerialization;
sleep 0.1;
private _console = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _console) exitWith {};
private _now = missionNamespace getVariable ["MCC_faction_index", 0];
if (_now == (uiNamespace getVariable ["MCC_assetsStartFaction", _now])) exitWith {};

//Redraw the console (as mcc_faction_choice.sqf does after a faction change in the console)
while {dialog} do {closeDialog 0};
sleep 0.05;
[nil, nil, nil, nil, 0] execVM (MCC_path + "mcc\Dialogs\mcc_PopupMenu.sqf");
