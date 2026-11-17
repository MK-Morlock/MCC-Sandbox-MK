/*
	MCCMK_fnc_garageReselect - (client) after the garage, the class it was opened for chosen again in its panel's box:
	["spawn" / "evac" / "cas" / ..., class]. By the class a row holds, else by its name.
*/
params [["_where", ""], ["_cls", ""]];
disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d || {_cls == ""}) exitWith {};
private _dn = toLower getText (configFile >> "CfgVehicles" >> _cls >> "displayName");
private _pick = {
	params ["_idc"];
	private _c = _d displayCtrl _idc;
	if (isNull _c) exitWith {};
	private _r = -1;
	for "_i" from 0 to ((lbSize _c) - 1) do {if ((toLower (_c lbData _i)) == (toLower _cls)) exitWith {_r = _i}};
	if (_r < 0) then {for "_i" from 0 to ((lbSize _c) - 1) do {if ((toLower (_c lbText _i)) == _dn) exitWith {_r = _i}}};
	if (_r >= 0 && {(lbCurSel _c) != _r}) then {_c lbSetCurSel _r};
};
switch (true) do {
	case (_where == "evac"): {[41] call _pick};
	case (_where == "cas"): {[25] call _pick};
	case (_where == "airdrop"): {[1038] call _pick};
	case (_where == "para"): {[1054] call _pick};
	case (_where == "halo"): {[1055] call _pick};
	case ((_where find "convoy") == 0): {
		private _n = _where select [6];
		private _idc = if (_n == "HVT") then {56} else {49 + (parseNumber _n)};
		private _list = if (_n == "HVT") then {missionNamespace getVariable ["MCC_convoyHVTcar", []]} else {missionNamespace getVariable ["U_GEN_CAR", []]};
		private _i = _list findIf {((_x param [1, ""]) isEqualType "") && {(toLower (_x param [1, ""])) == (toLower _cls)}};
		if (_i >= 0) then {(_d displayCtrl _idc) lbSetCurSel _i};
	};
	default {[3011] call _pick};
};
