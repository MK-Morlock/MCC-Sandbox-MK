// Evac menu: a Taru's passengers ride in its pod or on its bench, so fast-rope (5) and helocasting (3) aren't
// possible, nor hover (2) for the enclosed transport pod - those switch to free landing. [evac menu display]
params [["_d", displayNull, [displayNull]]];
if (isNull _d) exitWith {};
private _cls = toLower ((_d displayCtrl 41) lbData (lbCurSel (_d displayCtrl 41)));
if ((_cls find "heli_transport_04") < 0) exitWith {};
private _c = _d displayCtrl 43;
private _i = lbCurSel _c;
private _bad = [3, 5] + ([[], [2]] select ((_cls find "covered") >= 0));
if (_i in _bad) then {
	_c lbSetCurSel 0;
	["The Taru carries its passengers in its pod or on its bench - it lands to drop them off."] call MCCMK_fnc_hint;
};
