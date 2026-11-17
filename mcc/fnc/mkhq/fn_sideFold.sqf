disableSerialization;
params [["_mode", "init", [""]], ["_i", -1, [0]]];
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
private _secs = [[9400, 9405, [9410, 9411, 9412]], [9401, 9406, [9413, 9414, 620, 9415, 9416, 9417]], [9402, 9407, [9418, 9419, 9420, 9421, 9422, 9423, 9424, 9425]], [9403, 9408, [9426, 9427, 9428, 9429]], [9404, 9409, [9430, 9431, 520, 9140, 9432, 9433]]];
private _open = +(profileNamespace getVariable ["MCCMK_sideOpen", [false, false, false, false, false]]);
if !(_open isEqualTypeArray [false, false, false, false, false]) then {_open = [false, false, false, false, false]};
if (_mode == "toggle" && {_i >= 0} && {_i < 5}) then {_open set [_i, !(_open select _i)]};
profileNamespace setVariable ["MCCMK_sideOpen", _open];
private _y = 0.006 * safezoneH;
{
	_x params ["_h", "_hb", "_btns"];
	{
		private _c = _d displayCtrl _x;
		_c ctrlSetPosition [(ctrlPosition _c) select 0, _y];
		_c ctrlCommit 0;
	} forEach [_h, _hb];
	_y = _y + 0.019 * safezoneH;
	private _on = _open select _forEachIndex;
	{
		private _c = _d displayCtrl _x;
		_c ctrlShow _on;
		if (_on) then {
			_c ctrlSetPosition [(ctrlPosition _c) select 0, _y];
			_c ctrlCommit 0;
			_y = _y + 0.0236 * safezoneH;
		};
	} forEach _btns;
	_y = _y + ([0.006, 0.0039] select _on) * safezoneH;
} forEach _secs;
