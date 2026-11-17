/*
	MCCMK_fnc_classRow - the Spawn panel's chosen Class row, as its place in the full list (the list can be narrowed by the
	class search; each row carries its original place as its value). -1 when nothing is chosen.
*/
disableSerialization;
private _c = (findDisplay 2994) displayCtrl 3011;
private _r = lbCurSel _c;
if (_r < 0) exitWith {-1};
if (_c getVariable ["MCCMK_classValues", false]) then {_c lbValue _r} else {_r}
