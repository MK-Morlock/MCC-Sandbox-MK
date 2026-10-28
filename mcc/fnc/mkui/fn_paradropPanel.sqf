disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
if (isNil "MCCMK_pdMem") then {MCCMK_pdMem = createHashMap};
private _facOnly = MCCMK_pdMem getOrDefault ["facOnly", true];
private _heli = MCCMK_pdMem getOrDefault ["heli", true];
private _plane = MCCMK_pdMem getOrDefault ["plane", true];
if (!_heli && {!_plane}) then {_heli = true; _plane = true; MCCMK_pdMem set ["heli", true]; MCCMK_pdMem set ["plane", true]};
{
	_x params ["_idc", "_on"];
	private _cb = _d displayCtrl _idc;
	if ((cbChecked _cb) isNotEqualTo _on) then {_cb cbSetChecked _on};
} forEach [[1050, _facOnly], [1051, _heli], [1052, _plane]];
private _sideS = missionNamespace getVariable ["mcc_sidename", "west"];
private _sideNow = switch (toLower _sideS) do {case "east": {east}; case "guer": {resistance}; case "civ": {civilian}; default {west}};
private _key = format ["MCCMK_pdAir_%1", _sideNow];
private _all = missionNamespace getVariable [_key, []];
if (count _all == 0) then {
	private _sn = [east, west, resistance, civilian] find _sideNow;
	{
		private _cl = configName _x;
		private _isPlane = _cl isKindOf "Plane";
		if ((_isPlane || {_cl isKindOf "Helicopter"}) && {getNumber (_x >> "isUav") == 0} && {getText (_x >> "editorSubcategory") != "MCC_EdSubcat_TaruPodMod"}) then {
			private _seats = [_cl, "allCargo"] call MCC_fnc_crewCount;
			if (!isNil "_seats" && {_seats >= 4}) then {
				_all pushBack [_cl, format ["%1 (%2)", getText (_x >> "displayName"), getText (configFile >> "CfgFactionClasses" >> getText (_x >> "faction") >> "displayName")], getText (_x >> "picture"), _isPlane, getText (_x >> "faction"), _seats];
			};
		};
	} forEach (format ["getNumber (_x >> 'scope') == 2 && {getNumber (_x >> 'side') == %1}", _sn] configClasses (configFile >> "CfgVehicles"));
	_all = [_all, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy;
	missionNamespace setVariable [_key, _all];
};
private _fnc_group = {
	private _n = getText (configFile >> "CfgFactionClasses" >> _this >> "displayName");
	private _i = _n find "(";
	if (_i > 0) then {_n = _n select [0, _i]};
	toLower (trim _n)
};
private _grp = (missionNamespace getVariable ["mcc_faction", ""]) call _fnc_group;
private _mine = _all select {((_x select 4) call _fnc_group) == _grp};
private _base = if (_facOnly && {count _mine > 0}) then {+_mine} else {+_all};
private _find = toLower (trim (ctrlText (_d displayCtrl 1053)));
if (_find != "") then {_base = _base select {((toLower (_x select 1)) find _find) >= 0}};
{
	_x params ["_idc", "_memKey", "_onlyPlanes", "_seatIdc"];
	private _list = _base select {if (_onlyPlanes) then {_x select 3} else {[_heli, _plane] select (_x select 3)}};
	private _want = MCCMK_pdMem getOrDefault [_memKey, ""];
	if (_want != "" && {(_list findIf {(_x select 0) == _want}) < 0}) then {
		private _e = _all select {(_x select 0) == _want};
		if (count _e > 0) then {_list pushBack (_e select 0); _list = [_list, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy};
	};
	private _c = _d displayCtrl _idc;
	lbClear _c;
	private _i0 = _c lbAdd "Automatic";
	_c lbSetData [_i0, ""];
	_c lbSetValue [_i0, -1];
	private _sel = 0;
	{
		_x params ["_cl", "_nm", "_pic"];
		private _i = _c lbAdd _nm;
		_c lbSetData [_i, _cl];
		_c lbSetValue [_i, _x select 5];
		_c lbSetPicture [_i, _pic];
		if (_cl == _want) then {_sel = _i};
	} forEach _list;
	_c lbSetCurSel _sel;
	missionNamespace setVariable [["MCCMK_pdAirPara", "MCCMK_pdAirHalo"] select (_idc == 1055), _c lbData _sel];
	(_d displayCtrl _seatIdc) ctrlSetText (if (_sel == 0) then {"Seats: as needed"} else {format ["Seats: %1", _c lbValue _sel]});
} forEach [[1054, "para", false, 1056], [1055, "halo", true, 1057]];
private _hc = _d displayCtrl 1058;
private _hts = [50, 75, 100, 125, 150, 175, 200, 250, 300, 350, 400, 500];
private _h = MCCMK_pdMem getOrDefault ["h", 300];
if !(_h in _hts) then {_h = 300; MCCMK_pdMem set ["h", 300]};
if (lbSize _hc == 0) then {
	{private _i = _hc lbAdd format ["%1 m", _x]; _hc lbSetValue [_i, _x]} forEach _hts;
	_hc lbSetCurSel ((_hts find _h) max 0);
};
MCCMK_pdHeight = _h;
[0] call MCCMK_fnc_paradropOpen;
[1] call MCCMK_fnc_paradropOpen;
