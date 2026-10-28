disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
if (!(missionNamespace getVariable ["MCC_faction_initilized_units", false]) && {!isNil "mcc_make_array_units"}) then {call mcc_make_array_units};
private _keys = ["U_GEN_HELICOPTER", "U_GEN_CAR", "U_GEN_TANK", "U_GEN_SHIP"];
private _facs = [];
{
	private _f = configName _x;
	if (_keys findIf {count (missionNamespace getVariable [format ["MCC_faction_%1_%2", _f, _x], []]) > 0} >= 0) then {
		private _n = getText (_x >> "displayName");
		_facs pushBack [if (_n == "") then {_f} else {_n}, _f];
	};
} forEach ("true" configClasses (configFile >> "CfgFactionClasses"));
private _names = _facs apply {_x select 0};
{
	private _n = _x select 0;
	if (({_x == _n} count _names) > 1) then {
		_x set [0, format ["%1 (%2)", _n, ["EAST", "WEST", "INDEP", "CIV"] param [getNumber (configFile >> "CfgFactionClasses" >> (_x select 1) >> "side"), "?"]]];
	};
} forEach _facs;
_facs sort true;
private _q = toLower (ctrlText (_d displayCtrl 47));
if (_q != "") then {_facs = _facs select {((toLower (_x select 0)) find _q) >= 0 || {((toLower (_x select 1)) find _q) >= 0}}};
private _want = missionNamespace getVariable ["MCCMK_evacFaction", if ((call MCC_fnc_evacSide) isEqualTo (side group player)) then {faction player} else {missionNamespace getVariable ["mcc_faction", faction player]}];
if (_facs findIf {(_x select 1) == _want} < 0) then {_want = if (_q == "") then {faction player} else {(_facs param [0, ["", ""]]) select 1}};
private _c = _d displayCtrl 45;
lbClear _c;
private _sel = 0;
{
	private _i = _c lbAdd (_x select 0);
	_c lbSetData [_i, _x select 1];
	if ((_x select 1) == _want) then {_sel = _i};
} forEach _facs;
if (count _facs == 0) exitWith {private _i = _c lbAdd "No matching faction"; _c lbSetData [_i, ""]; _c lbSetCurSel _i};
missionNamespace setVariable ["MCCMK_evacFaction", _c lbData _sel];
_c lbSetCurSel _sel;
