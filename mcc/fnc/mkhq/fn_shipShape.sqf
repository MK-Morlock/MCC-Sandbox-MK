params [["_pos", [0, 0], [[]]], ["_dir", 0, [0]], ["_t", 0, [0]], ["_r", 40, [0]]];
([_t] call MCCMK_fnc_shipCfg) params ["", "", "", "_half"];
private _bowOff = [180, 180, 0, 0] select ((_t max 0) min 3);
private _baseRot = [0, 0, 0, 180] select ((_t max 0) min 3);
private _rot = {
	params ["_l", "_h"];
	[(_pos select 0) + (_l select 0) * (cos _h) + (_l select 1) * (sin _h), (_pos select 1) - (_l select 0) * (sin _h) + (_l select 1) * (cos _h)]
};
private _corners = [[1, 1], [1, -1], [-1, -1], [-1, 1]] apply {[[(_x select 0) * (_half select 0), (_x select 1) * (_half select 1)], _dir] call _rot};
private _bow = _dir + _bowOff;
private _bowPt = _pos getPos [(_half select 1) * 1.25, _bow];
private _names = createHashMapFromArray [["B_Ship_Gun_01_F", "Gun"], ["B_Ship_MRLS_01_F", "VLS"], ["B_AAA_System_01_F", "AAA"], ["B_SAM_System_01_F", "SAM"], ["B_SAM_System_02_F", "SAM"]];
private _guns = ([_t] call MCCMK_fnc_shipWeapons) apply {
	_x params ["_cls", "_off", "_rel"];
	private _wp = [_off, _dir + _baseRot] call _rot;
	private _face = _dir + _baseRot + _rel;
	([_cls] call MCCMK_fnc_shipTraverse) params ["_mn", "_mx"];
	private _arc = if ((_mx - _mn) >= 359) then {[]} else {
		private _pts = [];
		for "_a" from _mn to _mx step (((_mx - _mn) / 12) max 1) do {_pts pushBack (_wp getPos [_r, _face - _a])};
		_pts
	};
	[_wp, _arc, _names getOrDefault [_cls, "Weapon"]]
};
[_corners, _bowPt, _guns, _half, _bow]
