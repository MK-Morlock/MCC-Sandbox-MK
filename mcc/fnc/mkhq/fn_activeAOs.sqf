/*
	MCCMK_fnc_activeAOs - the active mission areas an aircraft should keep clear of after a drop: the MCC zones
	(generated missions and the mission maker's own) and the generated missions' areas. [centre, radius] each.
	[margin (m, added to each radius)]
*/
params [["_margin", 500, [0]]];
private _out = [];
{
	private _m = str _x;
	private _c = getMarkerPos _m;
	if !(_c isEqualTo [0, 0, 0]) then {
		private _sz = getMarkerSize _m;
		_out pushBack [_c, ((_sz select 0) max (_sz select 1)) + _margin];
	};
} forEach (missionNamespace getVariable ["MCC_zones_numbers", []]);
{
	_x params ["", ["_c", []], ["_r", 0]];
	if (count _c > 1) then {_out pushBack [_c, _r + _margin]};
} forEach (missionNamespace getVariable ["MCCMK_mwAreas", []]);
_out
