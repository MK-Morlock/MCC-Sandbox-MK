/*
	MCCMK_fnc_heliLeave - (server; waits) a helicopter that's done flies off the map and returns when it's past the edge
	(12 minutes at most): [helicopter]. To the NEAREST edge, by a route round the mission areas (MCCMK_fnc_safeRoute). Any
	hold let go, engine on, its old waypoints gone and a real waypoint given at each leg (landed with its engine off, a
	plain move order left it sitting there).
*/
params [["_h", objNull]];
if (isNull _h || {!alive _h}) exitWith {};
[_h] remoteExec ["MCCMK_fnc_heliHold", _h];
private _p = getPos _h;
private _d = [_p select 0, worldSize - (_p select 0), _p select 1, worldSize - (_p select 1)];
private _dir = [270, 90, 180, 0] select (_d find (selectMin _d));
private _out = [_p, _dir] call MCCMK_fnc_mapEdgeExit;
private _g = group (driver _h);
for "_w" from ((count (waypoints _g)) - 1) to 0 step -1 do {deleteWaypoint [_g, _w]};
_h engineOn true;
_h land "NONE";
_h limitSpeed 1000;
_h flyInHeight 80;
_g setBehaviour "CARELESS";
_g setSpeedMode "FULL";
["INFO", "heliLeave", "%1 leaving from %2 by the %3 edge", [typeOf _h, mapGridPosition _p, ["west", "east", "south", "north"] select (_d find (selectMin _d))]] call MCC_fnc_log;
private _to = time + 720;
private _off = {private _q = getPos _h; (_q select 0) < 0 || {(_q select 1) < 0} || {(_q select 0) > worldSize} || {(_q select 1) > worldSize}};
{
	private _wpPos = _x;
	private _wp = _g addWaypoint [_wpPos, 0];
	_wp setWaypointType "MOVE";
	_g setCurrentWaypoint _wp;
	_h doMove _wpPos;
	waitUntil {sleep 2; !alive _h || {time > _to} || {call _off} || {(_h distance2D _wpPos) < 300}};
} forEach (([_p, _out] call MCCMK_fnc_safeRoute) + [_out]);
waitUntil {sleep 3; !alive _h || {time > _to} || {call _off}};
["INFO", "heliLeave", "%1 off the map (%2)", [typeOf _h, ["timed out", "past the edge"] select (call _off)]] call MCC_fnc_log;
