params [["_pos", [0, 0, 0], [[]]], ["_dir", 0, [0]], ["_bb", [[0, 0, 0], [0, 0, 0]], [[]]], ["_ignore", [], [[]]]];
private _fnc_box = {
	params ["_c", "_d", "_h"];
	private _s = sin _d;
	private _co = cos _d;
	[[1, 1], [1, -1], [-1, -1], [-1, 1]] apply {
		private _mx = (_x select 0) * (_h select 0);
		private _my = (_x select 1) * (_h select 1);
		[(_c select 0) + _mx * _co + _my * _s, (_c select 1) - _mx * _s + _my * _co]
	}
};
private _fnc_axes = {params ["_d"]; [[sin _d, cos _d], [cos _d, -(sin _d)]]};
private _fnc_overlap = {
	params ["_a", "_b", "_axes"];
	private _sep = false;
	{
		private _ax = _x;
		private _pa = _a apply {(_x select 0) * (_ax select 0) + (_x select 1) * (_ax select 1)};
		private _pb = _b apply {(_x select 0) * (_ax select 0) + (_x select 1) * (_ax select 1)};
		if ((selectMax _pa) < (selectMin _pb) || {(selectMax _pb) < (selectMin _pa)}) exitWith {_sep = true};
	} forEach _axes;
	!_sep
};
private _h = [((((_bb select 1) select 0) - ((_bb select 0) select 0)) / 2) + 0.5, ((((_bb select 1) select 1) - ((_bb select 0) select 1)) / 2) + 0.5];
private _mine = [_pos, _dir, _h] call _fnc_box;
private _blocker = objNull;
{
	private _o = _x;
	if !(_o in _ignore || {_o getVariable ["MCC_isLHD", false]}) then {
		if ((abs (((getPosASL _o) select 2) - (_pos select 2))) < 8) then {
			private _ob = boundingBoxReal _o;
			private _oh = [(((_ob select 1) select 0) - ((_ob select 0) select 0)) / 2, (((_ob select 1) select 1) - ((_ob select 0) select 1)) / 2];
			private _oc = _o modelToWorldWorld [(((_ob select 1) select 0) + ((_ob select 0) select 0)) / 2, (((_ob select 1) select 1) + ((_ob select 0) select 1)) / 2, 0];
			private _theirs = [_oc, getDir _o, _oh] call _fnc_box;
			if ([_mine, _theirs, ([_dir] call _fnc_axes) + ([getDir _o] call _fnc_axes)] call _fnc_overlap) exitWith {_blocker = _o};
		};
	};
	if (!isNull _blocker) exitWith {};
} forEach (nearestObjects [ASLToAGL _pos, ["Land", "Air", "Ship"], (vectorMagnitude [_h select 0, _h select 1, 0]) + 30]);
_blocker
