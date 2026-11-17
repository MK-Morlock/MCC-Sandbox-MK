/*
	MCCMK_fnc_iconWithWp - a group icon's colour, name, size and visibility with its WAYPOINT settings kept: [group,
	[colour, name, scale, visible]] -> the same with Arma's two waypoint settings added. A group icon has six settings; the
	last two say whether High Command draws the group's waypoint lines, and in what colour. Setting only the first four
	switched the waypoints off. Read from High Command's own record (MARTA_waypoint - "-1" in its colour means the icon's
	colour, as Arma's Military Symbols does it), else from the icon itself.
*/
params ["_g", "_p"];
private _mw = _g getVariable "MARTA_waypoint";
if (!isNil "_mw" && {_mw isEqualType []} && {(count _mw) >= 2}) exitWith {
	private _col = +(_mw select 1);
	{if (_x < 0) then {_col set [_forEachIndex, ((_p select 0) param [_forEachIndex, 1])]}} forEach _col;
	_p + [_mw select 0, _col]
};
private _cur = getGroupIconParams _g;
if ((count _cur) >= 6) exitWith {_p + (_cur select [4, 2])};
_p
