/*
	MCCMK_fnc_factionFilter - narrows a faction list (the MCC console's, display 2994, or the 3D editor's, 8000) by side
	(the console's side buttons, remembered in the profile) and by search text (any part of the name). Each row carries
	its faction's number in U_FACTIONS (lbData), which faction.sqf reads, so the chosen faction is never changed by the
	list being narrowed. [mode: "side" / "text" / "apply", value, display]
*/
disableSerialization;
params [["_mode", "apply", [""]], ["_val", "", [""]], ["_disp", 2994, [0]]];
private _tKey = format ["MCCMK_factionText_%1", _disp];
if (_mode == "cycle") then {
	private _order = ["ALL", "WEST", "EAST", "GUER", "CIV"];
	_val = _order select ((((_order find (profileNamespace getVariable ["MCCMK_factionSide", "ALL"])) max 0) + 1) mod 5);
	_mode = "side";
};
if (_mode == "side") then {profileNamespace setVariable ["MCCMK_factionSide", _val]; _mode = "apply"};
if (_mode == "text") exitWith {
	uiNamespace setVariable [_tKey, toLower _val];
	uiNamespace setVariable [format ["MCCMK_factionTextRaw_%1", _disp], _val];	// as typed, put back if the console reloads
	private _stamp = diag_tickTime;
	uiNamespace setVariable [_tKey + "_s", _stamp];
	[_stamp, _tKey, _disp] spawn {
		params ["_stamp", "_tKey", "_disp"];
		uiSleep 0.4;
		if ((uiNamespace getVariable [_tKey + "_s", -1]) != _stamp) exitWith {};
		["apply", "", _disp] call MCCMK_fnc_factionFilter;
	};
};
private _d = findDisplay _disp;
if (isNull _d) exitWith {};
private _c = _d displayCtrl 8008;
if (isNull _c) exitWith {};
private _side = if (_disp == 2994) then {profileNamespace getVariable ["MCCMK_factionSide", "ALL"]} else {"ALL"};
private _txt = uiNamespace getVariable [_tKey, ""];
uiNamespace setVariable ["MCCMK_factionFilling", true];
lbClear _c;
private _sel = -1;
private _cur = missionNamespace getVariable ["MCC_faction_index", 0];
private _all = missionNamespace getVariable ["U_FACTIONS", []];
private _match = {
	params ["_name", "_sn"];
	(_side == "ALL" || {(toUpper _sn) == _side}) && {_txt == "" || {((toLower _name) find _txt) >= 0}}
};
private _rows = [];
{
	_x params [["_name", ""], ["_sn", ""]];
	if ([_name, _sn] call _match) then {_rows pushBack _forEachIndex};
} forEach _all;
// nothing matches: the current faction stays shown, so the list isn't empty
if (_rows isEqualTo []) then {_rows = [_cur]};
{
	(_all select _x) params [["_name", ""], ["_sn", ""]];
	private _i = _c lbAdd format ["%1(%2)", _name, _sn];
	_c lbSetData [_i, str _x];
	if (_x == _cur) then {_sel = _i};
} forEach _rows;
// typing jumps to the first match (unless the current faction is a match)
if (_sel < 0) then {_sel = 0};
_c lbSetCurSel _sel;
uiNamespace setVariable ["MCCMK_factionFilling", false];
if (_disp == 2994) then {
	private _look = [["ALL", "All", [0.88, 0.89, 0.90, 1]], ["WEST", "West", [0.44, 0.63, 0.85, 1]], ["EAST", "East", [0.82, 0.42, 0.37, 1]], ["GUER", "Ind", [0.56, 0.75, 0.42, 1]], ["CIV", "Civ", [0.66, 0.55, 0.82, 1]]];
	(_look select (((_look findIf {(_x select 0) == _side}) max 0))) params ["", "_name", "_col"];
	private _lbl = _d displayCtrl 9251;
	_lbl ctrlSetText _name;
	_lbl ctrlSetTextColor _col;
};
