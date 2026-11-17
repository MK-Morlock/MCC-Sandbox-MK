/*
	MCCMK_fnc_heliWaterLandWp - (server; waits) a WATER LANDING WAYPOINT: [helicopter, the point, engine on?, {still wanted?},
	fly height] -> true once afloat. Its route flown round the mission areas at its flying height; it comes down with
	the distance, is brought over the point by the Evac's hover (the pilot ordered at the point), and settles onto the
	water, held level (MCCMK_fnc_heliWaterLand): no high hover and straight drop. The ramp opens as it comes down.
	Only for a
	boat carrier whose engine stands 3 m of water; refused (false, said why) otherwise, or if the point is not water.
	Used by the Evac's "Water landing", the consoles' "Water landing" waypoints and the Boat pickup.
*/
params [["_h", objNull], ["_pt", [0, 0, 0]], ["_engine", true], ["_cond", {true}], ["_fly", -1]];
if (!isServer || {isNull _h} || {!alive _h} || {isNull (driver _h)}) exitWith {false};
_pt = [_pt select 0, _pt select 1, 0];
private _say = {params ["_m"]; private _l = leader (group (driver _h)); if (isPlayer _l) then {[_m] remoteExec ["MCCMK_fnc_hint", _l]} else {private _mkO = (group _l) getVariable ["MCCMK_wpOwner", -1]; if (_mkO >= 0) then {[_m] remoteExec ["MCCMK_fnc_hint", _mkO]}}; ["INFO", "waterLand", "%1: %2", [typeOf _h, _m]] call MCC_fnc_log};
if (!surfaceIsWater _pt) exitWith {["That point is not water - no water landing"] call _say; false};
if (!([_h] call MCCMK_fnc_boatCarrier) || {(getNumber (configOf _h >> "maxFordingDepth")) < 3} || {isNil "MCCMK_fltAir"} || {!([_h] call MCCMK_fltAir)}) exitWith {[format ["%1 can't make a water landing", getText (configOf _h >> "displayName")]] call _say; false};
[_h] call MCCMK_fnc_heliWaterEnd;	// (on the water already: lifted off first)
_h land "NONE";
if (_fly > 0) then {_h flyInHeight _fly};
private _g = group (driver _h);
for "_w" from ((count (waypoints _g)) - 1) to 0 step -1 do {deleteWaypoint [_g, _w]};
// the route, then the run-in coming down with the distance
private _route = [getPos _h, _pt] call MCCMK_fnc_safeRoute;
if (_route isEqualTo []) then {_route = [_pt]};
private _last = _route select ((count _route) - 1);
private _dbg = missionNamespace getVariable ["MCC_debug", false];
if (_dbg) then {["INFO", "waterLandWp", "%1 to %2 (engine %3): route of %4 point(s), %5 m", [typeOf _h, mapGridPosition _pt, ["off", "on"] select _engine, count _route, round (_h distance2D _pt)]] call MCC_fnc_log};
{
	if (!alive _h || {!(call _cond)}) exitWith {};
	if (_forEachIndex < ((count _route) - 1)) then {
		_h doMove _x;
		waitUntil {sleep 1; !alive _h || {!(call _cond)} || {(_h distance2D _x) < 300}};
	};
} forEach _route;
if (!alive _h || {!(call _cond)}) exitWith {false};
if (_dbg) then {["INFO", "waterLandWp", "%1: descent from %2 m, %3 m up", [typeOf _h, round (_h distance2D _pt), round ((getPos _h) select 2)]] call MCC_fnc_log};
_h doMove _pt;
[_h, _pt, _cond] call MCCMK_fnc_heliWaterDescent;
if (!alive _h || {!(call _cond)}) exitWith {false};
if (_dbg) then {["INFO", "waterLandWp", "%1: handed to the hover %2 m out, %3 km/h, %4 m up", [typeOf _h, round (_h distance2D _pt), round (speed _h), round ((getPos _h) select 2)]] call MCC_fnc_log};
[_h, _pt, _cond, 10, _engine] call MCCMK_fnc_heliWaterLand
