/*
	MCCMK_fnc_evacLandingIndex - (client) the Evac insertion chosen in a list, as the number the Evac goes by, read from its
	TEXT: [list idc] -> 0 Free Landing (engine on), 1 (engine off), 2 Hover, 3 Helocasting, 4 Smoke Signal, 5 Fast-Rope,
	6 Precise Landing, 7 Paradrop, 8 RTB, 9 Rope extraction, 10 Water landing (engine on), 11 Water landing (engine off).
	(The lists differ between the consoles and the vehicle types - their positions don't match these numbers.)
*/
params [["_idc", 43]];
private _t = lbText [_idc, lbCurSel _idc];
private _i = ["Free Landing (engine on)", "Free Landing (engine off)", "Hover", "Helocasting(Water)", "Smoke Signal", "Fast-Rope", "Precise Landing", "Paradrop", "RTB", "Rope extraction", "Water landing (engine on)", "Water landing (engine off)"] find _t;
if (_i < 0) then {lbCurSel _idc} else {_i}
