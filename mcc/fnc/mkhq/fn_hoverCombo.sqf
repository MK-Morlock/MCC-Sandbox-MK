/*
	MCCMK_fnc_hoverCombo - (client) the Evac panels' "Hover height": [display, the Flight Height list's idc, show it?,
	a plain Hover?]. For the hover insertions (Hover, Fast-Rope, Precise Landing, Rope extraction) the Flight Height box is
	split in two - the travelling height on the left, the hover height on the right (5-50 m; 75 and 100 m too for a plain
	Hover; 20 m to start with, the last one chosen after that). For the others the Flight Height box has its full width
	again. The choice goes to everyone as MCCMK_evacHover (MCC_fnc_evacMove reads it).
*/
params [["_d", displayNull], ["_flyIdc", 9101], ["_show", false], ["_plain", false]];
if (isNull _d) exitWith {};
private _fly = _d displayCtrl _flyIdc;
if (isNull _fly) exitWith {};
private _hc = _d displayCtrl 9211;
if (isNull _hc) then {
	private _grp = ctrlParentControlsGroup _fly;
	_hc = if (isNull _grp) then {_d ctrlCreate ["RscCombo", 9211]} else {_d ctrlCreate ["RscCombo", 9211, _grp]};
	_fly setVariable ["MCCMK_flyPos", ctrlPosition _fly];
	_hc ctrlSetTooltip "Hover height - above the ground, or the top of whatever is on\nthe spot";
	_hc ctrlSetFontHeight (ctrlFontHeight _fly);
	_hc ctrlAddEventHandler ["LBSelChanged", {
		params ["_c", "_i"];
		if (_i >= 0) then {
			profileNamespace setVariable ["MCCMK_evacHoverVal", _c lbValue _i];
			missionNamespace setVariable ["MCCMK_evacHover", _c lbValue _i, true];
		};
	}];
};
(_fly getVariable ["MCCMK_flyPos", ctrlPosition _fly]) params ["_x0", "_y0", "_w0", "_h0"];
if (_show) then {
	_fly ctrlSetPosition [_x0, _y0, _w0 * 0.48, _h0];
	_hc ctrlSetPosition [_x0 + (_w0 * 0.52), _y0, _w0 * 0.48, _h0];
	private _vals = [5, 10, 15, 20, 25, 30, 40, 50] + ([[], [75, 100]] select _plain);
	private _want = profileNamespace getVariable ["MCCMK_evacHoverVal", 20];
	lbClear _hc;
	private _sel = 3;
	{
		private _i = _hc lbAdd format ["Hover %1m", _x];
		_hc lbSetValue [_i, _x];
		if (_x <= _want) then {_sel = _i};
	} forEach _vals;
	_hc lbSetCurSel _sel;
	missionNamespace setVariable ["MCCMK_evacHover", _hc lbValue _sel, true];
} else {
	_fly ctrlSetPosition [_x0, _y0, _w0, _h0];
};
{_x ctrlCommit 0} forEach [_fly, _hc];
_hc ctrlShow _show;
