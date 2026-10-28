params [["_list", [], [[]]]];
if (_list isEqualTo []) exitWith {[]};

private _bad = ["pilot", "crew", "diver", "frogman", "survivor", "unarmed", "story", "uav_ai"];
private _out = _list select {
	private _class = if (_x isEqualType "") then {_x} else {_x param [0, ""]};
	private _cfg = configFile >> "CfgVehicles" >> _class;
	private _names = toLower (_class + " " + getText (_cfg >> "displayName"));
	(_bad findIf {(_names find _x) >= 0}) < 0
};
if (_out isEqualTo []) exitWith {+_list};
_out
