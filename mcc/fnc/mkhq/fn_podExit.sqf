// A Taru heads out to the map edge, by the shortest route that keeps clear of active mission areas and enemy-held
// territory (if it can), and is removed there - with whatever it's carrying. [taru, group]
params [["_h", objNull, [objNull]], ["_g", grpNull, [grpNull]]];
if (isNull _h) exitWith {};
private _p = getPosWorld _h;
private _side = side _g;
// (MK) the active mission areas (MCC zones, generated missions) - the enemy-held naval zones only exist while there are
// ships, so on their own the Taru avoided nothing - plus those naval zones when there are any. [centre, radius] each.
private _zones = ([0] call MCCMK_fnc_activeAOs) + (((missionNamespace getVariable ["MCCMK_navalZones", []]) select {[_side, _x select 3] call BIS_fnc_sideIsEnemy}) apply {[_x select 1, _x select 2]});
// (MK) a mission area near: first it turns AWAY from it (not back over it), then it picks its way out from there
// (MK) It keeps the height it's at, all the way out (a 50 m drop leaves at 50 m - the point of flying in low; a hovering
// Taru, after a winch drop or a pick-up, at 40 m at least). First it carries straight on - or, with a mission area near,
// peels off AWAY from it (a turn of up to 90 deg) - never a U-turn over the drop.
_h flyInHeight (((getPosATL _h) select 2) max 40);
_g setBehaviour "CARELESS";
_g setCombatMode "BLUE";
private _awayP = [_h, 1500] call MCCMK_fnc_turnAwayPoint;
private _first = if (_awayP isNotEqualTo []) then {_awayP} else {_h getPos [1500, getDir _h]};
_h doMove _first;
private _ta = time;
waitUntil {sleep 1; !alive _h || {(_h distance2D _first) < 400} || {(time - _ta) > 45}};
_p = getPosWorld _h;
private _hd = getDir _h;
private _routes = [];
// (MK) the way out: ahead of it (within 90 deg of its heading) - shortest of those that keeps clear of mission areas
for "_d" from 0 to 315 step 45 do {
	if ((abs ((((_d - _hd) + 540) mod 360) - 180)) > 90) then {continue};
	private _e = [_p, _d, 1500] call MCCMK_fnc_edgePos;
	private _len = _p distance2D _e;
	private _blocked = false;
	for "_s" from 500 to _len step 500 do {
		private _q = _p getPos [_s, _d];
		if ((_zones findIf {((_x select 0) distance2D _q) < ((_x select 1) + 700)}) >= 0) exitWith {_blocked = true};
	};
	_routes pushBack [[0, 1] select _blocked, _len, _e];
};
if (_routes isEqualTo []) then {_routes pushBack [0, 0, [_p, _hd, 1500] call MCCMK_fnc_edgePos]};	// (straight on)
_routes sort true;
private _exit = (_routes select 0) select 2;
_g setBehaviour "CARELESS";
_g setCombatMode "BLUE";
_h doMove _exit;
private _t = time;
waitUntil {sleep 3; !alive _h || {(_h distance2D _exit) < 1700} || {(time - _t) > 600} || {isNull (driver _h)}};
// (MK) only a Taru still flying is removed at the exit - one shot down stays a wreck, as in Arma
if (alive _h) then {{deleteVehicle _x} forEach ((attachedObjects _h) + (crew _h) + [_h]); deleteGroup _g};
