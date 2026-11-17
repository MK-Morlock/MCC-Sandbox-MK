/*
	MCCMK_fnc_mwFactionSearch - the Mission Generator's rival faction search: after a short pause in typing, the Rival Faction
	drop-down (1001) changes to the first faction whose name contains the text (any part, any case). The list itself isn't
	narrowed - the drop-down picks factions by row - so the chosen faction is always right. [text, display]
*/
disableSerialization;
params [["_txt", "", [""]], ["_d", displayNull, [displayNull]]];
private _stamp = diag_tickTime;
uiNamespace setVariable ["MCCMK_mwSearchStamp", _stamp];
[_txt, _d, _stamp] spawn {
	disableSerialization;
	params ["_txt", "_d", "_stamp"];
	uiSleep 0.4;
	if ((uiNamespace getVariable ["MCCMK_mwSearchStamp", -1]) != _stamp || {isNull _d}) exitWith {};
	private _t = toLower _txt;
	if (_t == "") exitWith {};
	private _c = _d displayCtrl 1001;
	if (isNull _c) exitWith {};
	private _hit = -1;
	for "_i" from 0 to (lbSize _c) - 1 do {
		if (((toLower (_c lbText _i)) find _t) >= 0) exitWith {_hit = _i};
	};
	if (_hit >= 0 && {(lbCurSel _c) != _hit}) then {_c lbSetCurSel _hit};
};
