/*
	MCCMK_fnc_factionBoxClick - a faction clicked in the MCC console's faction box becomes the console's faction (the drop-down
	at the top, 8008), as if picked there - ready for spawning, supports and so on. If the console's search or side buttons
	have it filtered out of the drop-down, the search is cleared (then the side shown set to All) so it can be chosen.
	[display, faction] (a row's click area in the faction panel)
*/
disableSerialization;
params [["_d", displayNull, [displayNull]], ["_f", "", [""]]];
if (isNull _d || {_f == ""}) exitWith {};
private _idx = (missionNamespace getVariable ["U_FACTIONS", []]) findIf {(_x param [2, ""]) == _f};
if (_idx < 0) exitWith {["That faction isn't in MCC's faction list."] call MCCMK_fnc_hint};
private _combo = _d displayCtrl 8008;
if (isNull _combo) exitWith {};
private _find = {
	private _r = -1;
	for "_i" from 0 to (lbSize _combo) - 1 do {if ((_combo lbData _i) == str _idx) exitWith {_r = _i}};
	_r
};
private _r = call _find;
if (_r < 0) then {
	// filtered out by the console's search text: clear it
	private _s = _d displayCtrl 9240;
	if (!isNull _s) then {_s ctrlSetText ""};
	uiNamespace setVariable ["MCCMK_factionText_2994", ""];
	uiNamespace setVariable ["MCCMK_factionTextRaw_2994", ""];
	["apply", "", 2994] call MCCMK_fnc_factionFilter;
	_r = call _find;
};
if (_r < 0) then {
	// filtered out by the side buttons: show all sides
	["side", "ALL", 2994] call MCCMK_fnc_factionFilter;
	_r = call _find;
};
if (_r >= 0 && {(lbCurSel _combo) != _r}) then {_combo lbSetCurSel _r};
