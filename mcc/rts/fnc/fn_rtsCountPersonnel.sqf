params [["_side", sideUnknown, [sideUnknown]], ["_rtsUnits", false, [false]]];
private _mode = missionNamespace getVariable ["MCC_rtsPersonnelMode", 0];
{
	side _x == _side && {
		isPlayer _x
		|| {group _x getVariable ["MCC_canbecontrolled", false]}
		|| {_rtsUnits && {_x getVariable ["MCC_isRTSunit", false]}}
		|| {_mode >= 1 && {isPlayer leader group _x}}
		|| {_mode >= 2}
	}
} count allUnits
