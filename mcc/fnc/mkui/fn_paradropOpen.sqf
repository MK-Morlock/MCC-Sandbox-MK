params [["_w", 0, [0]], ["_a", 3, [0]], ["_v", 0, [0]]];
if (isNil "MCCMK_pdMem") then {MCCMK_pdMem = createHashMap};
if (missionNamespace getVariable ["MCCMK_pdOpenBusy", false]) exitWith {};
private _key = ["para", "halo"] select _w;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
private _ids = [[1060, 1061, 1062], [1063, 1064, 1065]] select _w;
switch (_a) do {
	case 1: {MCCMK_pdMem set ["openMode" + _key, [0, 1] select (_v == 1)]};
	case 0: {MCCMK_pdMem set ["openMode" + _key, [1, 0] select (_v == 1)]};
	case 2: {if (_v >= 0 && {!isNull _d}) then {MCCMK_pdMem set ["openH" + _key, (_d displayCtrl (_ids select 1)) lbValue _v]}};
};
private _vals = if (_w == 0) then {
	private _dh = MCCMK_pdMem getOrDefault ["h", 300];
	[-1] + ([50, 75, 100, 125, 150, 175, 200, 250, 300, 350, 400, 450] select {_x <= _dh - 25})
} else {[75, 100, 125, 150, 175, 200]};
private _mode = MCCMK_pdMem getOrDefault ["openMode" + _key, 0];
private _want = MCCMK_pdMem getOrDefault ["openH" + _key, [100, 150] select _w];
if !(_want in _vals) then {_want = selectMax _vals};
MCCMK_pdMem set ["openH" + _key, _want];
missionNamespace setVariable [["MCCMK_pdOpenPara", "MCCMK_pdOpenHalo"] select _w, [_mode, _want]];
if (_a in [0, 1, 2]) then {["DEBUG", "paradrop", "%1 chute opening: %2%3", [["Paratrooper", "HALO"] select _w, ["Auto", "Manual"] select _mode, if (_mode == 1) then {format [" (AI open %1)", if (_want < 0) then {"on exit"} else {format ["at %1 m", _want]}]} else {""}]] call MCC_fnc_log};
if (isNull _d) exitWith {};
MCCMK_pdOpenBusy = true;
(_d displayCtrl (_ids select 0)) cbSetChecked (_mode == 1);
(_d displayCtrl (_ids select 2)) cbSetChecked (_mode == 0);
private _c = _d displayCtrl (_ids select 1);
lbClear _c;
{private _i = _c lbAdd (if (_x < 0) then {"On exit"} else {format ["%1 m", _x]}); _c lbSetValue [_i, _x]} forEach _vals;
_c lbSetCurSel ((_vals find _want) max 0);
_c ctrlEnable (_mode == 1);
MCCMK_pdOpenBusy = false;
