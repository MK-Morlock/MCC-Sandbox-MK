/*
	MCCMK_fnc_garageButton - (client) a Garage button in the MCC console: [which, Ctrl held?]. The class chosen in that
	panel's box: "spawn", "evac", "cas", "airdrop", "para", "halo", "convoy1" to "convoy5", "convoyHVT". Ctrl + click: that
	class back to its own look. The garage reopens the panel it was opened from afterwards (MCCMK_fnc_garageOpen).
*/
params [["_where", "spawn"], ["_ctrl", false]];
disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d && {_where != "3d"}) exitWith {};
private _cls = "";
private _fromData = {params ["_idc"]; private _c = _d displayCtrl _idc; if (isNull _c || {(lbCurSel _c) < 0}) then {""} else {_c lbData (lbCurSel _c)}};
switch (true) do {
	//(MK) the 3D Editor: the vehicle chosen to place
	case (_where == "3d"): {_cls = if ((missionNamespace getVariable ["mcc_spawntype", ""]) == "VEHICLE") then {missionNamespace getVariable ["mcc_spawnname", ""]} else {""}};
	case (_where == "evac"): {_cls = [41] call _fromData};
	case (_where == "cas"): {_cls = [25] call _fromData};
	case (_where == "airdrop"): {_cls = [1038] call _fromData};
	case (_where == "para"): {_cls = [1054] call _fromData};
	case (_where == "halo"): {_cls = [1055] call _fromData};
	case ((_where find "convoy") == 0): {
		private _n = _where select [6];
		private _idc = if (_n == "HVT") then {56} else {49 + (parseNumber _n)};
		private _list = if (_n == "HVT") then {missionNamespace getVariable ["MCC_convoyHVTcar", []]} else {missionNamespace getVariable ["U_GEN_CAR", []]};
		private _i = lbCurSel (_d displayCtrl _idc);
		if (_i >= 0 && {_i < count _list}) then {_cls = (_list select _i) param [1, ""]};
	};
	default {
		private _br = lbCurSel (_d displayCtrl 3010);
		if ((lbCurSel (_d displayCtrl 3012)) == 1 || {_br in [0, 7]} || {_br < 0}) exitWith {};
		private _list = missionNamespace getVariable [["U_GEN_SOLDIER", "U_GEN_CAR", "U_GEN_TANK", "U_GEN_MOTORCYCLE", "U_GEN_HELICOPTER", "U_GEN_AIRPLANE", "U_GEN_SHIP", "U_AMMO"] select _br, []];
		private _row = call MCCMK_fnc_classRow;
		if (_row >= 0 && {_row < count _list}) then {_cls = (_list select _row) param [1, ""]};
	};
};
if !(_cls isEqualType "") then {_cls = ""};
if (_cls == "") exitWith {["Garage: choose a vehicle first"] call MCCMK_fnc_hint};
private _name = getText (configFile >> "CfgVehicles" >> _cls >> "displayName");
if (_ctrl) exitWith {
	private _store = profileNamespace getVariable ["MCCMK_garage", createHashMap];
	if (_store isEqualType createHashMap) then {_store deleteAt (toLower _cls); profileNamespace setVariable ["MCCMK_garage", _store]; saveProfileNamespace};
	[[[toLower _cls, []]]] remoteExec ["MCCMK_fnc_garageSync", 2];
	[format ["Garage: %1 back to its own look", _name]] call MCCMK_fnc_hint;
};
//(MK) from the 3D Editor: the garage, then the editor's own camera and menu back as they were
if (_where == "3d") exitWith {[_cls] spawn MCCMK_fnc_garage3D};
// the panel open now (its button number in the console - MCC's controlsHandle), to come back to
private _panels = [501,502,503,504,500,505,506,507,508,509,511,512,513,514,515,516,517,518,521];
private _panel = _panels findIf {ctrlShown (_d displayCtrl _x)};
[_cls, _panel, _where] spawn MCCMK_fnc_garageOpen;
