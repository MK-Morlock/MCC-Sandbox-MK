/*
	MCCMK_fnc_spawnStartRefresh - the Start box (aircraft) lists "On water" only for a class Floatary floats
	(MCCMK_fnc_canFloat): ["panel"] the Spawn panel (its Helicopter / Fixed-wing class chosen), ["3d"] the 3D Editor (its
	object chosen). If On water was chosen and the class can't float, Landed is chosen instead.
*/
params [["_where", "panel"]];
disableSerialization;
if (_where == "panel") then {
	private _d = findDisplay 2994;
	if (isNull _d) exitWith {};
	private _c = _d displayCtrl 3091;
	if (isNull _c) exitWith {};
	private _br = lbCurSel (_d displayCtrl 3010);
	if ((lbCurSel (_d displayCtrl 3012)) == 1 || {!(_br in [4, 5])}) exitWith {};
	private _list = missionNamespace getVariable [["U_GEN_HELICOPTER", "U_GEN_AIRPLANE"] select (_br == 5), []];
	private _row = call MCCMK_fnc_classRow;
	private _cls = if (_row >= 0 && {_row < count _list}) then {(_list select _row) param [1, ""]} else {""};
	private _can = [_cls] call MCCMK_fnc_canFloat;
	private _want = missionNamespace getVariable ["MCCMK_spawnStart", [0, 1] select (missionNamespace getVariable ["MCCMK_spawnLanded", false])];
	if (_want == 2 && {!_can}) then {_want = 1};
	if (((lbSize _c) == 3) isEqualTo _can && {(lbCurSel _c) == _want}) exitWith {};
	lbClear _c;
	{_c lbAdd _x} forEach (["Flying", "Landed"] + (if (_can) then {["On water"]} else {[]}));
	_c lbSetCurSel _want;
} else {
	private _d = uiNamespace getVariable ["MCC3D_Dialog", displayNull];
	if (isNull _d) exitWith {};
	private _c = _d displayCtrl 8036;
	if (isNull _c) exitWith {};
	private _cls = missionNamespace getVariable ["mcc_spawnname", ""];
	if !(_cls isEqualType "") then {_cls = ""};
	private _can = [_cls] call MCCMK_fnc_canFloat;
	private _want = missionNamespace getVariable ["MCC_3D_start", [0, 1] select (missionNamespace getVariable ["MCC_3D_landed", true])];
	if (_want == 2 && {!_can}) then {_want = 1};
	lbClear _c;
	{_c lbAdd _x} forEach (["Landed", "Flying"] + (if (_can) then {["On water"]} else {[]}));
	_c lbSetCurSel ([1, 0, 2] find _want);
};
