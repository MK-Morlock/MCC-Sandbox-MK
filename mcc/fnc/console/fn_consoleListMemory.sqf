params [["_ctrl", controlNull, [controlNull]], ["_key", "", [""]], ["_save", false, [false]]];
if (isNull _ctrl || {_key == ""}) exitWith {};
if (_save) exitWith {
	private _i = lbCurSel _ctrl;
	if (_i >= 0) then {profileNamespace setVariable [_key, _ctrl lbText _i]};
};
private _want = profileNamespace getVariable [_key, ""];
private _sel = 0;
for "_i" from 0 to ((lbSize _ctrl) - 1) do {
	if ((_ctrl lbText _i) == _want) exitWith {_sel = _i};
};
_ctrl lbSetCurSel _sel;
