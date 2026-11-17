params [["_list", [], [[]]], ["_faction", "", [""]], ["_mode", -1, [0]]];
if (_mode < 0) then {_mode = (missionNamespace getVariable ["MCC_MWContentModes", createHashMap]) getOrDefault [toLower _faction, 2]};
if (_mode >= 2 || {_list isEqualTo []}) exitWith {_list};
private _out = _list select {[if (_x isEqualType "") then {_x} else {_x select 0}, _faction, _mode] call MCC_fnc_contentAllowed};
if (_out isEqualTo []) exitWith {
	// nothing from the faction's own source: official DLC next, mods only as a last resort
	private _dlc = if (_mode < 1) then {_list select {[if (_x isEqualType "") then {_x} else {_x select 0}, _faction, 1] call MCC_fnc_contentAllowed}} else {[]};
	if (_dlc isNotEqualTo []) exitWith {
		["INFO", "MCC_fnc_contentFilterList", "%1: nothing from its own content - using official DLC too", [_faction]] call MCC_fnc_log;
		_dlc
	};
	["INFO", "MCC_fnc_contentFilterList", "%1: nothing left with the content filter - using all content", [_faction]] call MCC_fnc_log;
	_list
};
_out
