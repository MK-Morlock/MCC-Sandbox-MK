disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
if (isNil "MCCMK_casMem") then {MCCMK_casMem = createHashMap};
private _sideS = missionNamespace getVariable ["mcc_sidename", "west"];
private _sideNow = switch (toLower _sideS) do {case "east": {east}; case "guer": {resistance}; case "civ": {civilian}; default {west}};
private _facOnly = MCCMK_casMem getOrDefault ["facOnly", true];
private _heli = MCCMK_casMem getOrDefault ["heli", true];
private _plane = MCCMK_casMem getOrDefault ["plane", true];
if (!_heli && {!_plane}) then {_heli = true; _plane = true; MCCMK_casMem set ["heli", true]; MCCMK_casMem set ["plane", true]};
{
	_x params ["_idc", "_on"];
	private _cb = _d displayCtrl _idc;
	if ((cbChecked _cb) isNotEqualTo _on) then {_cb cbSetChecked _on};
} forEach [[1070, _facOnly], [1071, _heli], [1072, _plane]];
private _all = [_sideNow] call MCCMK_fnc_casAircraft;
private _fnc_group = {
	private _n = getText (configFile >> "CfgFactionClasses" >> _this >> "displayName");
	private _i = _n find "(";
	if (_i > 0) then {_n = _n select [0, _i]};
	toLower (trim _n)
};
private _grp = (missionNamespace getVariable ["mcc_faction", ""]) call _fnc_group;
private _list = if (_facOnly && {_grp != ""}) then {_all select {((_x param [4, ""]) call _fnc_group) == _grp}} else {+_all};
if (count _list == 0) then {_list = +_all};
_list = _list select {[_heli, _plane] select (_x select 3)};
private _find = toLower (trim (ctrlText (_d displayCtrl 1073)));
if (_find != "") then {_list = _list select {((toLower (_x select 1)) find _find) >= 0}};
private _want = MCCMK_casMem getOrDefault ["air", ""];
private _c = _d displayCtrl 25;
lbClear _c;
private _sel = 0;
{
	_x params ["_cl", "_nm", "_pic"];
	private _i = _c lbAdd _nm;
	_c lbSetData [_i, _cl];
	_c lbSetPicture [_i, _pic];
	if (_cl == _want) then {_sel = _i};
} forEach _list;
if (count _list == 0) then {private _i = _c lbAdd "None available"; _c lbSetData [_i, ""]};
_c lbSetCurSel _sel;
[_d, _sel] call MCC_fnc_casFillTypes;
