disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
if (isNil "MCCMK_adMem") then {MCCMK_adMem = createHashMap};
private _sideS = missionNamespace getVariable ["mcc_sidename", "west"];
private _sideNow = switch (toLower _sideS) do {case "east": {east}; case "guer": {resistance}; case "civ": {civilian}; default {west}};
private _facOnly = MCCMK_adMem getOrDefault ["facOnly", true];
private _heli = MCCMK_adMem getOrDefault ["heli", true];
private _plane = MCCMK_adMem getOrDefault ["plane", true];
private _smokeH = MCCMK_adMem getOrDefault ["smokeH", true];
private _smokeP = MCCMK_adMem getOrDefault ["smokeP", true];
private _smokeHV = MCCMK_adMem getOrDefault ["smokeHV", true];
private _smokePV = MCCMK_adMem getOrDefault ["smokePV", true];
if (!_heli && {!_plane}) then {_heli = true; _plane = true; MCCMK_adMem set ["heli", true]; MCCMK_adMem set ["plane", true]};
MCCMK_adSmokeHeli = _smokeH;
MCCMK_adSmokePlane = _smokeP;
MCCMK_adSmokeHeliVeh = _smokeHV;
MCCMK_adSmokePlaneVeh = _smokePV;
private _hts = [25, 50, 75, 100, 125, 150, 175, 200, 300, 400, 500];
{
	_x params ["_idc", "_key", "_var"];
	private _hc = _d displayCtrl _idc;
	private _h = MCCMK_adMem getOrDefault [_key, 75];
	if (lbSize _hc == 0) then {
		{private _i = _hc lbAdd format ["%1 m", _x]; _hc lbSetValue [_i, _x]} forEach _hts;
		_hc lbSetCurSel ((_hts find _h) max 0);
	};
	missionNamespace setVariable [_var, _h];
} forEach [[1044, "hHeli", "MCCMK_adHeightHeli"], [1045, "hPlane", "MCCMK_adHeightPlane"]];
{
	_x params ["_idc", "_on"];
	private _cb = _d displayCtrl _idc;
	if ((cbChecked _cb) isNotEqualTo _on) then {_cb cbSetChecked _on};
} forEach [[1039, _facOnly], [1041, _heli], [1042, _plane], [1046, _smokeH], [1047, _smokeP], [1048, _smokeHV], [1049, _smokePV]];
private _auto = MCCMK_adMem getOrDefault ["auto|" + toLower _sideS, ""];
if (_auto == "") then {_auto = [_sideS] call MCCMK_fnc_supplyAutoHeli; MCCMK_adMem set ["auto|" + toLower _sideS, _auto]};
private _all = [_sideNow] call MCCMK_fnc_supplyAircraft;
private _fnc_group = {
	private _n = getText (configFile >> "CfgFactionClasses" >> _this >> "displayName");
	private _i = _n find "(";
	if (_i > 0) then {_n = _n select [0, _i]};
	toLower (trim _n)
};
private _grp = (missionNamespace getVariable ["mcc_faction", ""]) call _fnc_group;
private _list = if (_facOnly && {_grp != ""}) then {_all select {((_x param [4, ""]) call _fnc_group) == _grp}} else {+_all};
if (count _list == 0) then {_list = +_all};
private _cfgA = configFile >> "CfgVehicles" >> _auto;
private _autoSling = !(_auto isKindOf "Plane") && {getNumber (_cfgA >> "slingLoadMaxCargoMass") > 0};
if ((_list findIf {(_x select 0) == _auto}) < 0 && {isClass _cfgA} && {isClass (_cfgA >> "VehicleTransport" >> "Carrier") || {_autoSling}}) then {
	_list pushBack [_auto, format ["%1 (%2)", getText (_cfgA >> "displayName"), getText (configFile >> "CfgFactionClasses" >> getText (_cfgA >> "faction") >> "displayName")], getText (_cfgA >> "picture"), _auto isKindOf "Plane", getText (_cfgA >> "faction"), _autoSling];
	_list = [_list, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy;
};
_list = _list select {[_heli, _plane] select (_x select 3)};
if ((missionNamespace getVariable ["MCC_airdropIsParachute", 0]) == 1) then {_list = _list select {_x param [5, false]}};
private _find = toLower (trim (ctrlText (_d displayCtrl 1040)));
if (_find != "") then {_list = _list select {((toLower (_x select 1)) find _find) >= 0}};
private _want = MCCMK_adMem getOrDefault ["air", ""];
private _c = _d displayCtrl 1038;
lbClear _c;
private _sel = -1;
private _selAuto = 0;
{
	_x params ["_cl", "_nm", "_pic"];
	private _i = _c lbAdd _nm;
	_c lbSetData [_i, _cl];
	_c lbSetPicture [_i, _pic];
	if (_cl == _want) then {_sel = _i};
	if (_cl == _auto) then {_selAuto = _i};
} forEach _list;
if (count _list > 0) then {_c lbSetCurSel ([[_sel, _selAuto] select (_sel < 0), 0] select (_find != ""))};
