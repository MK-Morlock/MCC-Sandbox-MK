params [["_list", [], [[]]], ["_faction", "", [""]], ["_mode", -1, [0]]];
if (_mode < 0) then {_mode = (missionNamespace getVariable ["MCC_MWContentModes", createHashMap]) getOrDefault [toLower _faction, 2]};
if (_mode >= 2 || {_list isEqualTo []}) exitWith {_list};
private _out = _list select {[if (_x isEqualType "") then {_x} else {_x select 0}, _faction, _mode] call MCC_fnc_contentAllowed};
if (_out isEqualTo []) exitWith {
	["INFO", "MCC_fnc_contentFilterList", "%1: nothing left with the content filter - using all content", [_faction]] call MCC_fnc_log;
	_list
};
_out
