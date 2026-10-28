disableSerialization;
params [["_title", "", [""]], ["_secs", 5, [0]], ["_desc", "", [""]], ["_iconPic", "", [""]], ["_col", [0.8, 0.13, 0.14, 1], [[]]]];
private _gw = ((safezoneW / safezoneH) min 1.2) / 40;
private _gh = (((safezoneW / safezoneH) min 1.2) / 1.2) / 25;
private _w = 12 * _gw;
private _h = 3 * _gh;
private _x = profileNamespace getVariable ["IGUI_GRID_NOTIFICATION_X", 0.5 - 6 * _gw];
private _y = safezoneY + safezoneH * 0.033;
private _red = _col;
private _icon = if (_iconPic == "") then {"\a3\Ui_f\data\GUI\Cfg\Notifications\tridentEnemy_ca.paa"} else {_iconPic};
private _html = _red call BIS_fnc_colorRGBAtoHTML;
private _igui = [profileNamespace getVariable ["IGUI_BCG_RGB_R", 0], profileNamespace getVariable ["IGUI_BCG_RGB_G", 1], profileNamespace getVariable ["IGUI_BCG_RGB_B", 1], 0.7];
private _group = controlNull;
private _parent = displayNull;
private _shown = false;
private _fnc_build = {
	params ["_d", "_animate"];
	private _g = _d ctrlCreate ["RscControlsGroupNoScrollbars", -1];
	private _t = _d ctrlCreate ["RscText", -1, _g];
	_t ctrlSetPosition [0, 0, _w, 0.8 * _gh];
	_t ctrlSetBackgroundColor [0, 0, 0, 0.7];
	_t ctrlSetTextColor [1, 1, 1, 1];
	_t ctrlSetFont "RobotoCondensed";
	_t ctrlSetFontHeight (0.8 * _gh);
	_t ctrlSetText (toUpper _title);
	_t ctrlCommit 0;
	private _pb = _d ctrlCreate ["RscText", -1, _g];
	_pb ctrlSetPosition [0, 0.9 * _gh, 2 * _gw, 2 * _gh];
	_pb ctrlSetBackgroundColor _igui;
	_pb ctrlCommit 0;
	private _pic = _d ctrlCreate ["RscPictureKeepAspect", -1, _g];
	_pic ctrlSetPosition [0.1 * _gw, 1 * _gh, 1.8 * _gw, 1.8 * _gh];
	_pic ctrlSetText _icon;
	_pic ctrlSetTextColor _red;
	_pic ctrlCommit 0;
	private _db = _d ctrlCreate ["RscText", -1, _g];
	_db ctrlSetPosition [2.1 * _gw, 0.9 * _gh, 9.9 * _gw, 2 * _gh];
	_db ctrlSetBackgroundColor _igui;
	_db ctrlCommit 0;
	private _ds = _d ctrlCreate ["RscStructuredText", -1, _g];
	_ds ctrlSetPosition [2.1 * _gw, 0.9 * _gh, 9.9 * _gw, 2 * _gh];
	_ds ctrlSetStructuredText parseText format ["<t size='0.8' align='center' color='%1'>%2</t>", _html, _desc];
	_ds ctrlCommit 0;
	private _th = (ctrlTextHeight _ds) min (2 * _gh);
	_ds ctrlSetPosition [2.1 * _gw, 0.9 * _gh + (2 * _gh - _th) / 2, 9.9 * _gw, _th];
	_ds ctrlCommit 0;
	if (_animate) then {
		_g ctrlSetPosition [_x + _w / 2, _y, 0, 0.8 * _gh];
		_g ctrlCommit 0;
		_g ctrlSetPosition [_x, _y, _w, 0.8 * _gh];
		_g ctrlCommit 0.2;
	} else {
		_g ctrlSetPosition [_x, _y, _w, _h];
		_g ctrlCommit 0;
	};
	_g
};
private _end = time + _secs;
while {time < _end} do {
	private _d = displayNull;
	{
		private _c = findDisplay _x;
		if (isNull _d && {!isNull _c}) then {_d = _c};
	} forEach [2993, 5000, 5010];
	if (!isNull _d && {isNull _group || {!(_parent isEqualTo _d)}}) then {
		if (!isNull _group) then {ctrlDelete _group};
		private _first = !_shown;
		_group = [_d, _first] call _fnc_build;
		_parent = _d;
		if (_first) then {
			playSound ["communicationMenuItemAdded", true];
			[_group, _x, _y, _w, _h, _gh] spawn {
				disableSerialization;
				params ["_g", "_x", "_y", "_w", "_h", "_gh"];
				sleep 0.2;
				if (!isNull _g) then {_g ctrlSetPosition [_x, _y, _w, _h]; _g ctrlCommit 0.2};
			};
		};
		_shown = true;
	};
	if (!_shown && {time > (_end - _secs + 1.5)}) exitWith {};
	sleep 0.1;
};
if (!isNull _group) then {
	_group ctrlSetPosition [_x, _y, _w, 0.8 * _gh];
	_group ctrlCommit 0.2;
	sleep 0.2;
	if (!isNull _group) then {
		_group ctrlSetPosition [_x + _w / 2, _y, 0, 0.8 * _gh];
		_group ctrlCommit 0.2;
	};
	sleep 0.2;
	ctrlDelete _group;
};
if (!_shown) then {
	if (_iconPic == "") then {["MCCNotificationBad", [_title, _desc, ""]] call BIS_fnc_showNotification} else {["MCCNotifications", [format ["%1 %2", _title, _desc], _icon, ""]] call BIS_fnc_showNotification};
};
