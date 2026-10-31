params [["_mode", "strike", [""]], ["_a", [0,0,0], [[]]], ["_b", [0,0,0], [[]]], ["_old", [], [[]]], ["_extra", 0, [0]]];
{deleteMarkerLocal _x} forEach _old;
if (isNil "MCCMK_lineN") then {MCCMK_lineN = 0};
private _out = [];
private _cap = [5000, 300] select (_mode in ["strike", "supply"]);
private _dir = _a getDir _b;
private _len = (_a distance2D _b) min _cap;
private _end = _a getPos [_len, _dir];
private _fnc_seg = {
	params ["_p", "_q", "_w", "_col"];
	private _l = _p distance2D _q;
	if (_l < 0.5) exitWith {};
	MCCMK_lineN = MCCMK_lineN + 1;
	private _m = format ["mccmk_line_%1", MCCMK_lineN];
	createMarkerLocal [_m, [((_p select 0) + (_q select 0)) / 2, ((_p select 1) + (_q select 1)) / 2]];
	_m setMarkerShapeLocal "RECTANGLE";
	_m setMarkerBrushLocal "SolidFull";
	_m setMarkerSizeLocal [_w, _l / 2];
	_m setMarkerDirLocal (_p getDir _q);
	_m setMarkerColorLocal _col;
	_out pushBack _m;
};
private _fnc_arrow = {
	if (_len < 1) exitWith {};
	MCCMK_lineN = MCCMK_lineN + 1;
	private _m = format ["mccmk_line_%1", MCCMK_lineN];
	createMarkerLocal [_m, _end];
	_m setMarkerShapeLocal "ICON";
	_m setMarkerTypeLocal "mil_arrow2";
	_m setMarkerDirLocal _dir;
	_m setMarkerColorLocal "ColorRed";
	_m setMarkerSizeLocal [0.7, 0.7];
	_out pushBack _m;
};
private _fnc_dot = {
	MCCMK_lineN = MCCMK_lineN + 1;
	private _m = format ["mccmk_line_%1", MCCMK_lineN];
	createMarkerLocal [_m, _this];
	_m setMarkerShapeLocal "ICON";
	_m setMarkerTypeLocal "mil_dot";
	_m setMarkerColorLocal "ColorGreen";
	_m setMarkerSizeLocal [0.9, 0.9];
	_out pushBack _m;
};
switch (_mode) do {
	case "strike": {[_a, _end, _extra, "ColorRed"] call _fnc_seg; call _fnc_arrow};
	case "para": {
		[_a, _end, 8, "ColorRed"] call _fnc_seg;
		call _fnc_arrow;
		(_a getPos [_len / 2, _dir]) call _fnc_dot;
	};
	case "drop";
	case "supply": {
		[_a, _end, 8, "ColorRed"] call _fnc_seg;
		call _fnc_arrow;
		_a call _fnc_dot;
	};
	case "pods": {
		[_a, _end, 8, "ColorRed"] call _fnc_seg;
		call _fnc_arrow;
		private _n = _extra max 1;
		for "_i" from 0 to (_n - 1) do {
			private _off = if (_n == 1) then {0} else {_i * ((_len max 30) / (_n - 1))};
			MCCMK_lineN = MCCMK_lineN + 1;
			private _m = format ["mccmk_line_%1", MCCMK_lineN];
			createMarkerLocal [_m, _a getPos [_off, _dir]];
			_m setMarkerShapeLocal "ICON";
			_m setMarkerTypeLocal "mil_dot";
			_m setMarkerColorLocal "ColorGreen";
			_m setMarkerSizeLocal [0.9, 0.9];
			_out pushBack _m;
		};
	};
};
_out
