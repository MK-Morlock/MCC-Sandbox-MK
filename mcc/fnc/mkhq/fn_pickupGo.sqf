/*
	MCCMK_fnc_pickupGo - (server) the leader's decision at a Pickup LZ (MCCMK_fnc_taruPickup): "go" (Take off, from aboard)
	and "send" (Send helicopters, staying behind) - every Taru with anyone in its pod flies round the mission areas to the
	line-up point and makes the drop (MCC_fnc_realParadrop with the loaded Tarus); "cancel" - they all leave. Empty Tarus
	fly away and are removed 4.5 km from every player. [what, pickup id]
*/
params [["_what", "go"], ["_id", ""]];
private _st = missionNamespace getVariable [format ["MCCMK_pickup_%1", _id], createHashMap];
if (!isServer || {(_st getOrDefault ["state", ""]) != "wait"}) exitWith {};
private _tarus = (_st get "tarus") select {alive (_x select 0)};
// 2. a cancel with anyone aboard is refused (the Tarus would fly off with them) - they get out first
private _aboard = {params ["_e"]; ((crew (_e select 1)) + (if (isNil "MCCMK_fltAttached") then {[]} else {crew ([_e select 0] call MCCMK_fltAttached)})) select {alive _x && {group _x != group (driver (_e select 0))}}};	// passengers, not its crew (MK: and anyone in a boat in its bay)
if (_what == "cancel" && {(_tarus findIf {([_x] call _aboard) isNotEqualTo []}) >= 0}) exitWith {
	["Pickup not cancelled - everyone must get out of the pods first"] remoteExec ["MCCMK_fnc_hint", leader (_st get "grp")];
	["INFO", "MCCMK_fnc_pickupGo", "pickup %1: cancel refused - men aboard", [_id]] call MCC_fnc_log;
};
_st set ["state", _what];
private _side = side (_st get "grp");
["end", _id] remoteExec ["MCCMK_fnc_pickupClient", _side];
private _leave = {	// one not needed: off the edge of the map, removed once beyond it (12 minutes at most)
	params ["_t", "_pod", "_pad", "_to"];
	if (!isNull _pad) then {deleteVehicle _pad};
	if (!alive _t) exitWith {};
	{if (alive _x && {group _x != group (driver _t)}) then {_x remoteExec ["moveOut", _x]}} forEach (crew _pod);	// nobody carried off in a leaving aircraft
	sleep 1;
	_t land "NONE";
	private _g = group _t;
	for "_w" from (count waypoints _g) - 1 to 0 step -1 do {deleteWaypoint [_g, _w]};
	// off the edge of the map, straight on away from the LZ
	private _out = [getPosATL _t, (_to getDir _t) + 180] call MCCMK_fnc_mapEdgeExit;
	_t flyInHeight 80;
	private _w = _g addWaypoint [_out, 0];
	_w setWaypointType "MOVE";
	_w setWaypointBehaviour "CARELESS";
	_w setWaypointSpeed "FULL";
	[_t, _pod, _g] spawn {
		params ["_t", "_pod", "_g"];
		private _t0 = time;
		private _off = {params ["_p"]; (_p select 0) < 0 || {(_p select 1) < 0} || {(_p select 0) > worldSize} || {(_p select 1) > worldSize}};
		waitUntil {sleep 5; !alive _t || {time > _t0 + 720} || {[getPosATL _t] call _off}};
		if (!alive _t) exitWith {};
		{deleteVehicle _x} forEach (crew _t);
		deleteVehicle _pod;
		deleteVehicle _t;
		deleteGroup _g;
	};
};
if (_what == "cancel") exitWith {
	[_st getOrDefault ["dd", []], -1] call MCCMK_fnc_dropDone;	// its green dot off the map
	{[_x select 0, _x select 1, _x select 2, _st get "spawn"] call _leave} forEach _tarus;
	["INFO", "MCCMK_fnc_pickupGo", "pickup %1 cancelled", [_id]] call MCC_fnc_log;
};
private _loaded = _tarus select {([_x] call _aboard) isNotEqualTo []};
{[_x select 0, _x select 1, _x select 2, _st get "spawn"] call _leave} forEach (_tarus - _loaded);
if (_loaded isEqualTo []) exitWith {[_st getOrDefault ["dd", []], -1] call MCCMK_fnc_dropDone; ["INFO", "MCCMK_fnc_pickupGo", "pickup %1: nobody aboard - the Tarus leave", [_id]] call MCC_fnc_log};
{if (!isNull (_x select 2)) then {deleteVehicle (_x select 2)}} forEach _loaded;
// the drop: round the mission areas to the line-up point (3 km before the line, then 1.5 km), then the usual run-in
(_st get "line") params ["_la", "_lb"];
private _ld = _la getDir _lb;
private _leadIn = _la getPos [3000, _ld + 180];
private _align = _la getPos [1500, _ld + 180];
private _route = ([getPosATL ((_loaded select 0) select 0), _leadIn] call MCCMK_fnc_safeRoute) + [[_align select 0, _align select 1, 0]];
private _preset = _loaded apply {[_x select 0, _x select 1, [_x] call _aboard]};
//(MK) a Boat pickup: each loaded one flies to the point and lands on the water there (MCCMK_fnc_heliWaterLandWp), ramp
// open; once its boat is out and nobody is left aboard, it leaves
if ((_st getOrDefault ["mode", "taru"]) == "boat") exitWith {
	{
		[_x, _la, _leave, _st get "spawn", _aboard] spawn {
			params ["_e", "_la", "_leave", "_sp", "_aboard"];
			private _t = _e select 0;
			private _ok = [_t, _la, true, {alive (_this select 0)}] call MCCMK_fnc_heliWaterLandWp;
			if (!alive _t) exitWith {};
			//(MK) an AI-driven boat is let out by itself (a player's boat waits for his "Unload watercraft")
			private _bt = [_t] call MCCMK_fltAttached;
			if (_ok && {!isNull _bt} && {!isPlayer (driver _bt)}) then {sleep 3; [objNull, _t, false] call MCCMK_fnc_floatLoad};
			waitUntil {sleep 2; !alive _t || {isNull ([_t] call MCCMK_fltAttached) && {([_e] call _aboard) isEqualTo []}}};
			sleep 3;
			[_t] call MCCMK_fnc_heliWaterEnd;
			[_t, _e select 1, _e select 2, _sp] call _leave;
		};
	} forEach _loaded;
	["INFO", "MCCMK_fnc_pickupGo", "pickup %1: %2 - %3 helicopter(s) taking the boat to %4", [_id, ["take off", "sent without the leader"] select (_what == "send"), count _loaded, mapGridPosition _la]] call MCC_fnc_log;
};
if ((_st getOrDefault ["mode", "taru"]) == "rope") exitWith {	// a fast-rope at the point, by the helicopters that picked them up
	[[_st get "grp"], _la, _loaded apply {[_x select 0, [_x] call _aboard]}, _la getDir _lb, _st getOrDefault ["dd", []]] spawn MCCMK_fnc_fastRopeInsert;
	["INFO", "MCCMK_fnc_pickupGo", "pickup %1: %2 - %3 helicopter(s) to the fast-rope point", [_id, ["take off", "sent without the leader"] select (_what == "send"), count _loaded]] call MCC_fnc_log;
};
if ((_st getOrDefault ["mode", "taru"]) == "para") then {
	// a paradrop by the aircraft that picked them up
	[[_la, _lb], [_st get "grp"], 1, 0, [0, 0, 0], [0, 0, 0], [_st get "cls", "", missionNamespace getVariable ["MCCMK_pdHeight", 300], _st getOrDefault ["paraH", [0, 120]], [0, 120], true, true], [], _preset, _route, _st getOrDefault ["dd", []]] spawn MCC_fnc_realParadrop;
} else {
	[[_la, _lb], [_st get "grp"], 1, 1, [0, 0, 0], [0, 0, 0], ["", "", missionNamespace getVariable ["MCCMK_pdHeight", 300], [0, 120], [0, 120], true, true], [_st get "method", _st get "podType"], _preset, _route, _st getOrDefault ["dd", []]] spawn MCC_fnc_realParadrop;
};
["INFO", "MCCMK_fnc_pickupGo", "pickup %1: %2 - %3 Taru(s) with %4 men, route of %5 points to the line-up", [_id, ["take off", "sent without the leader"] select (_what == "send"), count _loaded, call {private _c = 0; {_c = _c + count (_x select 2)} forEach _preset; _c}, count _route]] call MCC_fnc_log;
