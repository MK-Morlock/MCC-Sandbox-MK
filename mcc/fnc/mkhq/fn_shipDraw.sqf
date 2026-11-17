params ["_c", ["_pos", [0, 0], [[]]], ["_dir", 0, [0]], ["_t", 0, [0]], ["_col", [0.4, 1, 0.4, 1], [[]]]];
([_pos, _dir, _t, 40] call MCCMK_fnc_shipShape) params ["_corners", "_bowPt", "_guns", "_half"];
private _fill = "#(rgb,8,8,3)color(1,1,1,1)";
_c drawRectangle [_pos, _half select 0, _half select 1, _dir, [_col select 0, _col select 1, _col select 2, 0.28], _fill];
{_c drawLine [_x, _corners select ((_forEachIndex + 1) mod 4), [0, 0, 0, 0.9]]} forEach _corners;
_c drawRectangle [_pos, (_half select 0) + 1.5, (_half select 1) + 1.5, _dir, _col, ""];
_c drawRectangle [_pos, (_half select 0) + 3, (_half select 1) + 3, _dir, [0, 0, 0, 0.7], ""];
_c drawArrow [_pos, _bowPt, _col];
private _red = [1, 0.12, 0.08, 0.95];
{
	_x params ["_wp", "_arc", "_name"];
	if (_arc isEqualTo []) then {
		_c drawEllipse [_wp, 40, 40, 0, [1, 0.12, 0.08, 0.22], _fill];
		_c drawEllipse [_wp, 40, 40, 0, _red, ""];
	} else {
		{_c drawLine [_wp, _x, [1, 0.12, 0.08, 0.6]]} forEach _arc;
		for "_i" from 0 to (count _arc - 2) do {_c drawLine [_arc select _i, _arc select (_i + 1), _red]};
	};
	_c drawIcon ["#(argb,8,8,3)color(0,0,0,0)", [1, 1, 1, 1], _wp, 1, 1, 0, _name, 2, 0.035, "RobotoCondensedBold", "center"];
} forEach _guns;
