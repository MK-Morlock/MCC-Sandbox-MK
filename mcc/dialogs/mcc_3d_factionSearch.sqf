// The 3D editor's faction search: narrows the faction list to names containing the text, as the MCC console's does
// (MCCMK_fnc_factionFilter). Reset clears it. [mode: 0 typed, 1 reset]
disableSerialization;
params [["_mode", 0, [0]]];
private _d = findDisplay 8000;
if (isNull _d) exitWith {};
private _edit = _d displayCtrl 8031;
if (_mode == 1) exitWith {
	_edit ctrlSetText "";
	["text", "", 8000] call MCCMK_fnc_factionFilter;
};
["text", ctrlText _edit, 8000] call MCCMK_fnc_factionFilter;
