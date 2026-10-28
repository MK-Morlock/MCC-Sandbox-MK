disableSerialization;
params [["_disp", displayNull, [displayNull]]];
if (isNull _disp) exitWith {};
private _sides = ([] call MCC_fnc_getActiveSides) select {([_x] call BIS_fnc_respawnTickets) > 0};
private _h = 0.05 * safezoneH;
private _w = (_h / pixelH) * pixelW;
private _gap = 0.004 * safezoneW;
private _n = count _sides;
private _x0 = safezoneX + (safezoneW / 2) - ((_n * _w) + ((_n - 1) max 0) * _gap) / 2;
for "_i" from 0 to 2 do {
	private _txt = _disp displayCtrl (20 + _i);
	private _pic = _disp displayCtrl (23 + _i);
	if (_i < _n) then {
		private _side = _sides select _i;
		private _icon = getText (configFile >> "CfgFactionClasses" >> (_side call BIS_fnc_playerSideFaction) >> "icon");
		if (_icon == "") then {_icon = (_side call BIS_fnc_sideColor) call BIS_fnc_colorRGBAtoTexture};
		private _pos = [_x0 + _i * (_w + _gap), safezoneY + 0.008 * safezoneH, _w, _h];
		_pic ctrlSetText _icon;
		_pic ctrlSetPosition _pos;
		_pic ctrlCommit 0;
		_pic ctrlShow true;
		_txt ctrlSetText str ([_side] call BIS_fnc_respawnTickets);
		_txt ctrlSetPosition _pos;
		_txt ctrlCommit 0;
		_txt ctrlShow true;
	} else {
		_pic ctrlShow false;
		_txt ctrlShow false;
	};
};
