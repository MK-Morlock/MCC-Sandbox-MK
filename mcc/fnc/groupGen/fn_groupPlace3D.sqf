params ["_pos", "_cfg", ["_loc", 0], "_side", ["_dir", 0, [0]], ["_height", 0, [0]], ["_beh", "hold", [""]], ["_cmd", false, [false]]];
if (!isServer) exitWith {};
private _grp = [_pos, _cfg, _loc, _side, false, false, "-"] call MCC_fnc_groupSpawn;
if (isNil "_grp" || {!(_grp isEqualType grpNull)} || {isNull _grp}) exitWith {};
private _cfgC = if (_cfg isEqualType "") then {call compile _cfg} else {_cfg};
private _rels = [];
for "_i" from 0 to ((count _cfgC) - 1) do {
	private _u = _cfgC select _i;
	if (isClass _u) then {_rels pushBack (getArray (_u >> "position"))};
};
private _units = units _grp;
{
	private _rel = _rels param [_forEachIndex, [0, 0, 0]];
	private _rx = ((cos _dir) * (_rel param [0, 0])) + ((sin _dir) * (_rel param [1, 0]));
	private _ry = ((cos _dir) * (_rel param [1, 0])) - ((sin _dir) * (_rel param [0, 0]));
	_x setPosATL [(_pos select 0) + _rx, (_pos select 1) + _ry, _height];
	_x setDir _dir;
} forEach _units;
_grp setFormDir _dir;
_grp deleteGroupWhenEmpty true;
[_grp, _beh, _cmd] call MCC_fnc_applyPlaceBehaviour;
if (count _units > 0) then {
	MCC_lastSpawn pushBack [_units select 0, _units select [1, (count _units) - 1]];
	publicVariable "MCC_lastSpawn";
};
