disableSerialization;
params [["_mode", 0, [0]]];
private _d = findDisplay 8000;
if (isNull _d) exitWith {};
private _edit = _d displayCtrl 8031;
private _combo = _d displayCtrl 8008;
if (_mode == 1) exitWith {
	private _orig = uiNamespace getVariable ["MCC3D_factionBeforeSearch", -1];
	uiNamespace setVariable ["MCC3D_factionSearchText", ""];
	uiNamespace setVariable ["MCC3D_factionSearchStamp", -1];
	uiNamespace setVariable ["MCC3D_factionBeforeSearch", -1];
	_edit ctrlSetText "";
	if (_orig >= 0 && {_orig != lbCurSel _combo}) then {_combo lbSetCurSel _orig};
};
private _txt = ctrlText _edit;
uiNamespace setVariable ["MCC3D_factionSearchText", _txt];
private _stamp = diag_tickTime;
uiNamespace setVariable ["MCC3D_factionSearchStamp", _stamp];
if (_txt == "") exitWith {};
if ((uiNamespace getVariable ["MCC3D_factionBeforeSearch", -1]) < 0) then {uiNamespace setVariable ["MCC3D_factionBeforeSearch", lbCurSel _combo]};
[_stamp, toLower _txt] spawn {
	params ["_stamp", "_txt"];
	uiSleep 0.7;
	if ((uiNamespace getVariable ["MCC3D_factionSearchStamp", -1]) != _stamp) exitWith {};
	disableSerialization;
	private _d = findDisplay 8000;
	if (isNull _d) exitWith {};
	private _combo = _d displayCtrl 8008;
	private _found = -1;
	for "_i" from 0 to ((lbSize _combo) - 1) do {
		if (((toLower (_combo lbText _i)) find _txt) == 0) exitWith {_found = _i};
	};
	if (_found < 0) then {
		for "_i" from 0 to ((lbSize _combo) - 1) do {
			if (((toLower (_combo lbText _i)) find _txt) >= 0) exitWith {_found = _i};
		};
	};
	if (_found >= 0 && {_found != lbCurSel _combo}) then {_combo lbSetCurSel _found};
};
