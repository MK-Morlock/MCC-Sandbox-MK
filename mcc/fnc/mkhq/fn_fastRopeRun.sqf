/*
	MCCMK_fnc_fastRopeRun - (server) a helicopter's fast-rope at a point, as the Evac's (MCC_fnc_evacMove, "Fast-Rope"):
	a precise hover 18 m over it, doors open, two ropes, the men slide down (MCC_fnc_fastRopeLocal), the ropes are dropped,
	and it leaves off the edge of the map - removed once beyond it (12 minutes at most).
	[helicopter, point, the men, a point in the direction it leaves]
*/
params [["_heli", objNull], ["_pos", [0, 0, 0]], ["_men", []], ["_away", [0, 0, 0]]];
if (!isServer || {!alive _heli}) exitWith {};
private _ropes = switch (typeOf _heli) do {
	case "B_Heli_Light_01_F": {[[0.6, 0.5, 0], [-0.8, 0.5, 0]]};
	case "B_Heli_Transport_01_F": {[[-1.11, 2.5, 0], [1.11, 2.5, 0]]};
	case "I_Heli_Transport_02_F": {[[1, -5, 0], [-1, -5, 0]]};
	case "O_Heli_Attack_02_F": {[[1.35, 1.35, 0], [-1.45, 1.35, 0]]};
	case "O_Heli_Transport_04_covered_F";
	case "B_Heli_Transport_03_F": {[[1, -4, -1], [-1, -4, -1]]};
	default {[[1.3, 1.3, 0], [-1.3, 1.3, 0]]};
};
//(MK) the Evac's fast-rope (MCC_fnc_evacMove, "Fast-Rope"), as it is: it arrives over the point (the last waypoint, 10 m -
// MCCMK_fnc_fastRopeInsert), a short precise hover 20 m over it, settled, doors open, two ropes, the men down at the Evac's
// spacing, and the ropes lowered away. Only kept from before: the ropes go once every man is ON THE GROUND (the Evac waits
// at most 10 s + 3).
//(MK) "Fast Rope Pos" (MCCMK_fnc_heliRopePos): its approach to a waypoint 90 m past the point, then
// carried over it and held, at the waypoint's Hover height (55 m ropes: 50 m at most). Not the rescue boat's hover.
[_heli, [_pos select 0, _pos select 1, 0], ((missionNamespace getVariable ["MCCMK_wpHover", 20]) max 5) min 50] call MCCMK_fnc_heliRopePos;
//(MK) the ropes go as soon as it's within 1 m of the dot and slow (the doors opened on the way in) - no further wait
if (!alive _heli || {!alive (driver _heli)}) exitWith {};
//(MK) "Rope animation" Harness: Advanced Rappelling's descent (a rope per man, swinging; players hold S); else MCC's own
if !([_heli, _men] call MCCMK_fnc_ropeDescend) then {
	private _actual = [];
	{_actual pushBack (ropeCreate [_heli, _x, 55, [10]]); sleep 0.5} forEach _ropes;
	sleep 1;
	//(MK) down in SEAT order, as the Evac's fast-rope (its passenger and firing-from-vehicle seats, in the helicopter's own order)
	private _seated = [];
	{
		_x params ["_u", "_role", "", "", ["_ffv", false]];
		if ((_u in _men) && {((toLower _role) == "cargo") || {((toLower _role) == "turret") && {_ffv}}}) then {_seated pushBack _u};
	} forEach (fullCrew _heli);
	_men = _seated + (_men - _seated);
	{
		if (alive _x && {vehicle _x == _heli}) then {
			[_x, _actual select (_forEachIndex mod 2)] remoteExec ["MCC_fnc_fastRopeLocal", _x, false];
			sleep (1 + ((random 6) / 10));
		};
	} forEach _men;
	private _t = time + 90;
	waitUntil {sleep 1; !alive _heli || {time > _t} || {(_men findIf {alive _x && {(vehicle _x == _heli) || {!isNull (attachedTo _x)} || {((getPosATL _x) select 2) > 1.5}}}) < 0}};
	sleep 3;
	{
		private _ap = _ropes select _forEachIndex;
		private _zc = -22;
		while {_zc > -50} do {_x attachTo [_heli, [_ap select 0, _ap select 1, _zc]]; _zc = _zc - 2; sleep 0.1};
		deleteVehicle _x;
	} forEach _actual;
};
[_heli, false] call MCCMK_fnc_heliDoorsAll;
["INFO", "MCCMK_fnc_fastRopeRun", "%1: %2 men fast-roped at %3", [typeOf _heli, {!alive _x || {vehicle _x != _heli}} count _men, mapGridPosition _pos]] call MCC_fnc_log;
// away, then gone once far from every player
if (!alive _heli) exitWith {};
[_heli] remoteExec ["MCCMK_fnc_heliRopeHold", _heli];	//(MK) the hold let go
private _g = group (driver _heli);
for "_w" from (count waypoints _g) - 1 to 0 step -1 do {deleteWaypoint [_g, _w]};
_heli flyInHeight 80;
(group (driver _heli)) setSpeedMode "FULL";
// off the edge of the map 
private _out = [getPosATL _heli, _pos getDir _away] call MCCMK_fnc_mapEdgeExit;
private _w = _g addWaypoint [_out, 0];
_w setWaypointType "MOVE";
_w setWaypointBehaviour "CARELESS";
_w setWaypointSpeed "FULL";
//(MK) and as a direct order too: nothing left standing from the hover can keep it there
_heli doMove _out;
private _t0 = time;
private _off = {params ["_p"]; (_p select 0) < 0 || {(_p select 1) < 0} || {(_p select 0) > worldSize} || {(_p select 1) > worldSize}};
waitUntil {sleep 5; !alive _heli || {time > _t0 + 720} || {[getPosATL _heli] call _off}};
if (!alive _heli) exitWith {};
{if (!isPlayer _x) then {deleteVehicle _x}} forEach (crew _heli);
if (((crew _heli) findIf {isPlayer _x}) < 0) then {deleteVehicle _heli; deleteGroup _g};
