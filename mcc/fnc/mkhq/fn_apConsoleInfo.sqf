/*
	MCCMK_fnc_apConsoleInfo - the commander console's CAS panel, for an Air Patrol entry: the label shows its time on station
	and cost ("8 min - 350 ammo, 240 fuel"), and the button beside it its loadout - Mixed / Air / Ground, cycled by clicking,
	only what that aircraft can carry (remembered for the next call). Any other entry: "CAS Available", no button.
	["sel"] - the selection changed; ["cycle"] - the button
*/
disableSerialization;
params [["_mode", "sel", [""]]];
private _d = findDisplay 2993;
if (isNull _d) exitWith {};
private _list = _d displayCtrl 9100;
private _label = _d displayCtrl 9330;
private _btn = _d displayCtrl 9331;
private _arr = missionNamespace getVariable [format ["MCC_CASConsoleArray%1", playerSide], []];
private _e = _arr param [lbCurSel _list, []];
private _kind = (_e param [0, [""]]) param [0, ""];
private _cls = (_e param [1, [""]]) param [0, ""];
private _meta = if (_cls isEqualType "") then {missionNamespace getVariable [format ["MCCMK_ap_%1", _cls], []]} else {[]};
if (!(_kind isEqualType "") || {((toLower _kind) find "air patrol") != 0} || {_meta isEqualTo []}) exitWith {
	_label ctrlSetText "CAS Available";
	_btn ctrlShow false;
};
_meta params ["_type", "_aa", "_ag", "_min", "_am", "_fu"];
private _opts = [];
if (_aa && _ag) then {_opts pushBack "Mixed"};
if (_aa) then {_opts pushBack "Air"};
if (_ag) then {_opts pushBack "Ground"};
if (_opts isEqualTo []) then {_opts = ["Mixed"]};
private _lo = uiNamespace getVariable ["MCCMK_apLoadout", "Mixed"];
if (_mode == "cycle") then {_lo = _opts select (((_opts find _lo) + 1) mod (count _opts))};
if !(_lo in _opts) then {_lo = _opts select 0};
if (_mode == "cycle") then {uiNamespace setVariable ["MCCMK_apLoadout", _lo]};
_btn ctrlSetText _lo;
_btn ctrlShow true;
_label ctrlSetText format ["%1 min - %2 ammo, %3 fuel", _min, _am, _fu];
uiNamespace setVariable ["MCCMK_apLoadoutNow", _lo];
