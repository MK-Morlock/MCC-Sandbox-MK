/*================================================================== MCC_fnc_umModeSwitch ==================================================================
	MCC console unit list: Units / Groups switched. The selection follows instead of a stale highlight being left on a
	row (which then did not match what HALO etc. acted on): selected units -> their groups, selected groups -> all their
	units. The list is rebuilt at once and those rows highlighted.
	<IN>	0: NUMBER new mode (0 Units, 1 Groups)
==============================================================================================================================================================================*/
params [["_mode", 0]];
[] call MCC_fnc_umSelectionFromList;
private _old = (missionNamespace getVariable ["MCC_selectedUnits", []]) select {!isNull _x};
MCC_UMUnit = _mode;
MCC_selectedUnits = if (_mode == 0) then {
	private _u = []; {if (_x isEqualType grpNull) then {_u append (units _x)} else {_u pushBackUnique _x}} forEach _old; _u
} else {
	private _g = []; {_g pushBackUnique (if (_x isEqualType grpNull) then {_x} else {group _x})} forEach _old; _g
};
MCC_UMFocus = false;
[] call MCC_fnc_groupGenUMRefresh;
