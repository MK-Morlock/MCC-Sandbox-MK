params [["_tIdx", -1, [0]]];
disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
private _fac = missionNamespace getVariable ["MCCMK_evacFaction", faction player];
if (_tIdx >= 0) then {missionNamespace setVariable ["MCCMK_evacType", _tIdx]};
private _t = ((if (_tIdx >= 0) then {_tIdx} else {missionNamespace getVariable ["MCCMK_evacType", (lbCurSel (_d displayCtrl 40)) max 0]}) max 0) min 3;
private _arr = (missionNamespace getVariable [format ["MCC_faction_%1_%2", _fac, ["U_GEN_HELICOPTER", "U_GEN_CAR", "U_GEN_TANK", "U_GEN_SHIP"] select _t], []]) select {getNumber (configFile >> "CfgVehicles" >> (_x select 1) >> "isUav") != 1};
// The Taru as an evac helicopter, for every side: the bench (8 seats) and the transport pod (16), in the livery set for
// the side (Taru livery setting), unless the faction has them already.
if (_t == 0) then {
	private _fSide = [east, west, resistance, civilian] param [getNumber (configFile >> "CfgFactionClasses" >> _fac >> "side"), west];
	private _sl = ["B", "O", "I"] param [[west, east, resistance] find _fSide, "B"];
	private _blk = ["", "_black"] select ((missionNamespace getVariable [format ["MCC_taruLivery%1", _sl], [1, 0, 0] select ((["B", "O", "I"] find _sl) max 0)]) == 1);
	{
		_x params ["_cls", "_nm"];
		if (isClass (configFile >> "CfgVehicles" >> _cls) && {(_arr findIf {(_x select 1) == _cls}) < 0}) then {
			_arr pushBack ["helicopter", _cls, str _fSide, [_nm, getText (configFile >> "CfgVehicles" >> _cls >> "picture")]];
		};
	} forEach [[format ["O_Heli_Transport_04_bench%1_F", _blk], "Mi-290 Taru (Bench, 8 seats)"], [format ["O_Heli_Transport_04_covered%1_F", _blk], "Mi-290 Taru (Transport pod, 16 seats)"]];
};
if (isNil "MCCMK_evacSeats") then {MCCMK_evacSeats = createHashMap};
_arr = _arr select {
	private _cl = _x select 1;
	private _n = MCCMK_evacSeats getOrDefault [_cl, -1];
	if (_n < 0) then {_n = [_cl, "allCargo"] call MCC_fnc_crewCount; MCCMK_evacSeats set [_cl, _n]};
	_n >= 1
};
private _c = _d displayCtrl 41;
if !(_c getVariable ["MCC_evacClassEH", false]) then {
	_c setVariable ["MCC_evacClassEH", true];
	_c ctrlAddEventHandler ["LBSelChanged", {
		params ["_cc", "_i"];
		private _cl = if (_i >= 0) then {_cc lbData _i} else {""};
		if (_cl != "") then {missionNamespace setVariable ["MCCMK_evacClassLast", _cl]};
		((ctrlParent _cc) displayCtrl 46) ctrlSetText (if (_cl == "") then {""} else {format ["Seats: %1", (missionNamespace getVariable ["MCCMK_evacSeats", createHashMap]) getOrDefault [_cl, 0]]});
		[ctrlParent _cc] call MCCMK_fnc_evacTaruCheck;
	}];
};
// A Taru's passengers sit in its pod / on its bench: no fast-rope or helocasting, and no hover for the enclosed pod.
private _ins = _d displayCtrl 43;
if !(_ins getVariable ["MCCMK_taruEH", false]) then {
	_ins setVariable ["MCCMK_taruEH", true];
	_ins ctrlAddEventHandler ["LBSelChanged", {[ctrlParent (_this select 0)] call MCCMK_fnc_evacTaruCheck}];
};
private _last = missionNamespace getVariable ["MCCMK_evacClassLast", ""];
["DEBUG", "evac", "Class list refilled: type %1 (asked %2), faction %3, %4 vehicles", [["Helicopters", "Vehicles", "Tracked", "Ships"] select _t, _tIdx, _fac, count _arr]] call MCC_fnc_log;
lbClear _c;
private _sel = 0;
if (count _arr == 0) then {
	private _i = _c lbAdd "None available";
	_c lbSetData [_i, ""];
} else {
	{
		private _i = _c lbAdd ((_x select 3) select 0);
		_c lbSetPicture [_i, (_x select 3) select 1];
		_c lbSetData [_i, _x select 1];
		if ((_x select 1) == _last) then {_sel = _i};
	} forEach _arr;
};
_c lbSetCurSel _sel;
private _scl = _c lbData _sel;
(_d displayCtrl 46) ctrlSetText (if (_scl == "") then {""} else {format ["Seats: %1", MCCMK_evacSeats getOrDefault [_scl, 0]]});
(_d displayCtrl 44) ctrlShow (_t == 0);
private _ic = _d displayCtrl 43;
lbClear _ic;
{_ic lbAdd _x} forEach (if (_t == 0) then {["Free Landing (engine on)", "Free Landing (engine off)", "Hover", "Helocasting(Water)", "Smoke Signal", "Fast-Rope", "Precise Landing", "Water landing (engine on)", "Water landing (engine off)"]} else {["Move (engine on)", "Move (engine off)"]});
_ic lbSetCurSel 0;
