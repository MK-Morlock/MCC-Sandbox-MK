/*================================================================== MCC_fnc_umAutoSelect ==================================================================
	After spawning from the Spawn panel (map click): find the new group, show it in the unit list next to the camera and
	select it, so it is on the camera straight away and HALO / Parachute / Teleport... can be pressed at once.
		Groups spawned  -> the list switches to Groups, the new group is selected
		Units spawned   -> the list switches to Units, the new unit(s) selected
	The group is found as a new group (not there before the click) whose leader is within 150 m of the click.
	<IN>	0: ARRAY  map click position
			1: BOOL   true = a group was spawned, false = single unit(s)
			2: ARRAY  allGroups before the spawn
==============================================================================================================================================================================*/
#define MCC_UM_LIST 3069
disableSerialization;
params ["_pos", ["_isGroup", false], ["_before", []]];
private _end = time + 8;
private _new = [];
waitUntil {
	sleep 0.25;
	_new = (allGroups - _before) select {!isNull (leader _x) && {alive (leader _x)} && {((leader _x) distance2D _pos) < 150}};
	(count _new > 0) || {time > _end}
};
if (_new isEqualTo []) exitWith {};
sleep 0.5;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};

MCC_GroupGenGroupSelected = _new;
MCC_UMUnit = [0, 1] select _isGroup;
(_d displayCtrl 9134) lbSetCurSel MCC_UMUnit;
[9134, MCC_UMUnit] call MCC_fnc_umToolboxHighlight;

MCC_UMFocus = false;
[] call MCC_fnc_groupGenUMRefresh;
private _list = _d displayCtrl MCC_UM_LIST;
if (lbSize _list == 0) exitWith {};
private _rows = if (_isGroup) then {[0]} else {[0 max 0] + ((lbSize _list) call {private _r = []; for "_i" from 1 to (_this - 1) do {_r pushBack _i}; _r})};
{_list lbSetSelected [_x, true]} forEach _rows;
MCC_selectedUnits = if (_isGroup) then {[UMgroupNames select 0]} else {_rows apply {MCC_UMunitsNames select _x}};
ctrlSetFocus _list;
[4, [_list, 0]] execVM format ["%1mcc\general_scripts\unitManage\um.sqf", MCC_path];	//camera on it
["INFO", "fn_umAutoSelect", "spawned %1 %2 selected in the unit list (%3 rows)", [["unit(s)", "group"] select _isGroup, _new select 0, count _rows]] call MCC_fnc_log;
