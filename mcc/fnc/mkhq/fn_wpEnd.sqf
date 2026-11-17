params [["_g", grpNull]];
if (isNull _g) exitWith {[0, 0]};
private _plan = _g getVariable ["MCCMK_wpPlan", []];
if (_plan isNotEqualTo []) exitWith {private _p = (_plan select ((count _plan) - 1)) select 0; [_p select 0, _p select 1]};
private _l = getPosATL (leader _g);
private _r = [_l select 0, _l select 1];
private _w = waypoints _g;
for "_i" from ((count _w) - 1) to (currentWaypoint _g) step -1 do {
	private _p = waypointPosition (_w select _i);
	if ((_p distance2D [0, 0]) > 50) exitWith {_r = [_p select 0, _p select 1]};
};
_r
