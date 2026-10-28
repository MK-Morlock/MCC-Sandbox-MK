disableSerialization;
params [["_d", displayNull, [displayNull]], ["_lvl", 0, [0]]];
if (isNull _d) exitWith {};
{if (!isNull _x) then {ctrlDelete _x}} forEach (uiNamespace getVariable ["MCCMK_acReticle", []]);
private _vx = 0.219271 * safezoneW + safezoneX;
private _vy = 0.225107 * safezoneH + safezoneY;
private _vw = 0.561458 * safezoneW;
private _vh = 0.472816 * safezoneH;
private _cx = _vx + _vw / 2;
private _cy = _vy + _vh / 2;
private _sy = 0.92 * (_vh / 2) / 512;
private _sx = _sy * pixelW / pixelH;
private _t = 2 * pixelW;
private _th = 2 * pixelH;
private _col = [1, 1, 1, 0.92];
private _made = [];
private _fnc_bar = {
	params ["_x0", "_y0", "_x1", "_y1"];
	private _w = ((abs (_x1 - _x0)) * _sx) max _t;
	private _h = ((abs (_y1 - _y0)) * _sy) max _th;
	private _px = _cx + ((_x0 min _x1) * _sx) - (if (_x0 == _x1) then {_t / 2} else {0});
	private _py = _cy + ((_y0 min _y1) * _sy) - (if (_y0 == _y1) then {_th / 2} else {0});
	private _c = _d ctrlCreate ["RscText", -1];
	_c ctrlSetPosition [_px, _py, _w, _h];
	_c ctrlSetBackgroundColor _col;
	_c ctrlCommit 0;
	_made pushBack _c;
};
private _hx = [507, 507, 760] select (_lvl max 0 min 2);
[0, -508, 0, -128] call _fnc_bar;
[0, 128, 0, 512] call _fnc_bar;
[-32, -508, 32, -508] call _fnc_bar;
[-32, -255, 32, -255] call _fnc_bar;
[-32, 255, 32, 255] call _fnc_bar;
[-32, 512, 32, 512] call _fnc_bar;
[-_hx, 0, -128, 0] call _fnc_bar;
[128, 0, _hx, 0] call _fnc_bar;
{
	[_x, -32, _x, 32] call _fnc_bar;
	[-_x, -32, -_x, 32] call _fnc_bar;
} forEach ([[253, 507], [253, 507], [253, 507, 760]] select (_lvl max 0 min 2));
{
	[_x - 1, -1, _x + 1, 1] call _fnc_bar;
} forEach [-63, 0, 63];
if (_lvl == 0) then {
	{
		_x params ["_ox", "_oy"];
		[_ox - 20, _oy, _ox + 20, _oy] call _fnc_bar;
		[_ox, _oy - 20, _ox, _oy + 20] call _fnc_bar;
	} forEach [[-370, -280], [370, -280], [-370, 280], [370, 280]];
};
if (_lvl == 1) then {
	{
		_x params ["_sgx", "_sgy"];
		private _ox = 205 * _sgx;
		private _oy = 155 * _sgy;
		[_ox, _oy, _ox - _sgx * 18, _oy] call _fnc_bar;
		[_ox, _oy, _ox, _oy - _sgy * 20] call _fnc_bar;
	} forEach [[-1, -1], [1, -1], [-1, 1], [1, 1]];
};
uiNamespace setVariable ["MCCMK_acReticle", _made];
