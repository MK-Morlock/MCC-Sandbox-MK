disableSerialization;
params [["_mode", "fill", [""]], ["_zn", -1, [0]]];
private _lists = ([uiNamespace getVariable ["MCC_MWDialog", displayNull], uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull]] select {!isNull _x}) apply {_x displayCtrl 1023};
_lists = _lists select {!isNull _x};
if (_mode == "number") exitWith {
	if (_lists isEqualTo []) then {-1} else {
		private _c = _lists select 0;
		if (lbCurSel _c < 0) then {-1} else {_c lbValue (lbCurSel _c)}
	}
};
if (_lists isEqualTo []) exitWith {};
{
	private _c = _x;
	private _fnc_rowOf = {
		params ["_n"]; private _r = -1;
		for "_i" from 0 to (lbSize _c - 1) do {if ((_c lbValue _i) == _n) exitWith {_r = _i}};
		_r
	};
	if (_mode == "select") then {
		private _r = [_zn] call _fnc_rowOf;
		if (_r >= 0) then {MCC_zoneListProg = [_c lbValue _r, diag_tickTime]; _c lbSetCurSel _r};
	} else {
		lbClear _c;
		private _pos = missionNamespace getVariable ["mcc_zone_pos", []];
		{
			private _p = _pos param [_x, []];
			if !(_p isEqualTo [-5000,-5000,0]) then {
				private _r = _c lbAdd str _x;
				_c lbSetValue [_r, _x];
			};
		} forEach (missionNamespace getVariable ["MCC_zones_numbers", []]);
		private _want = (missionNamespace getVariable ["MCC_zone_index", 0]) + 1;
		private _r = [_want] call _fnc_rowOf;
		if (_r < 0 && {lbSize _c > 0}) then {_r = 0};
		if (_r >= 0) then {MCC_zoneListProg = [_c lbValue _r, diag_tickTime]; _c lbSetCurSel _r};
	};
} forEach _lists;
