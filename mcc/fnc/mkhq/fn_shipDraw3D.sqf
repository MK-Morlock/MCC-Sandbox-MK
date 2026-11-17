params [["_pos", [0, 0], [[]]], ["_dir", 0, [0]], ["_t", 0, [0]], ["_col", [0.4, 1, 0.4, 1], [[]]]];
([_pos, _dir, _t, 40] call MCCMK_fnc_shipShape) params ["_corners", "_bowPt", "_guns"];
private _z = {params ["_p", ["_h", 1.5]]; ASLToAGL [_p select 0, _p select 1, _h]};
{drawLine3D [[_x] call _z, [_corners select ((_forEachIndex + 1) mod 4)] call _z, _col]} forEach _corners;
drawLine3D [[_pos] call _z, [_bowPt] call _z, _col];
private _red = [1, 0.12, 0.08, 1];
{
	_x params ["_wp", "_arc", "_name"];
	private _pts = if (_arc isEqualTo []) then {
		private _a = [];
		for "_d" from 0 to 360 step 15 do {_a pushBack (_wp getPos [40, _d])};
		_a
	} else {[_wp] + _arc + [_wp]};
	for "_i" from 0 to (count _pts - 2) do {
		drawLine3D [[_pts select _i] call _z, [_pts select (_i + 1)] call _z, _red];
		drawLine3D [[_pts select _i, 2.5] call _z, [_pts select (_i + 1), 2.5] call _z, _red];
	};
	drawIcon3D ["", [1, 1, 1, 1], [_wp, 12] call _z, 0, 0, 0, _name, 2, 0.04, "RobotoCondensedBold"];
} forEach _guns;
