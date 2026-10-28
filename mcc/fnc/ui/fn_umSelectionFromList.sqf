/*================================================================== MCC_fnc_umSelectionFromList ==================================================================
	MCC console unit list: MCC_selectedUnits = what is highlighted in the list right now, in the current mode
	(units in Units mode, groups in Groups mode). Used before HALO / Parachute and when switching Units / Groups.
	If nothing is highlighted the previous selection is kept (only what fits the current mode).
==============================================================================================================================================================================*/
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
private _rows = lbSelection (_d displayCtrl 3069);
private _names = if ((missionNamespace getVariable ["MCC_UMUnit", 0]) == 0) then {missionNamespace getVariable ["MCC_UMunitsNames", []]} else {missionNamespace getVariable ["UMgroupNames", []]};
private _wantGroup = (missionNamespace getVariable ["MCC_UMUnit", 0]) != 0;
if (count _rows > 0) then {
	MCC_selectedUnits = (_rows apply {_names param [_x, objNull]}) select {!isNull _x};
} else {
	MCC_selectedUnits = (missionNamespace getVariable ["MCC_selectedUnits", []]) select {!isNull _x && {(_x isEqualType grpNull) isEqualTo _wantGroup}};
};
