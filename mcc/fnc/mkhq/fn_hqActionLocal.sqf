params [["_obj", objNull, [objNull]], ["_radius", 10, [0]]];
if (!hasInterface || {isNull _obj}) exitWith {};
private _menu = (call MCCMK_fnc_aceMode)	/*(MK) "MCC actions with ACE": 2 ACE only, 0 both, 1 scroll only*/;
private _ace = !isNil "ace_interact_menu_fnc_createAction";
if (_ace && {_menu in [0, 2]}) then {
	private _a = ["MCCMK_makeHQ", "Make HQ", "", {[_target getVariable ["MCCMK_hqTarget", _target], false] call MCCMK_fnc_makeHQConfirm}, {[_target getVariable ["MCCMK_hqTarget", _target], _player] call MCCMK_fnc_makeHQCan}, {}, [], [0, 0, 0], _radius] call ace_interact_menu_fnc_createAction;
	[_obj, 0, [], _a] call ace_interact_menu_fnc_addActionToObject;
};
if (!_ace || {_menu in [0, 1]}) then {
	_obj addAction ["<t color='#99FF00'>Make HQ</t>", {[(_this select 0) getVariable ["MCCMK_hqTarget", _this select 0], false] call MCCMK_fnc_makeHQConfirm}, [], 1.4, false, true, "", "[_target getVariable ['MCCMK_hqTarget', _target], _this] call MCCMK_fnc_makeHQCan", _radius];
};
