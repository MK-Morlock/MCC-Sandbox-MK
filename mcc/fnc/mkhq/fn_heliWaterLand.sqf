/*
	MCCMK_fnc_heliWaterLand - (server; waits) an AI helicopter SET DOWN ON THE WATER and kept there, floating (Floatary - the
	"Floating aircraft" setting, MCCMK Commander Console > Water): [helicopter, spot, {still wanted?}] -> true once afloat.
	Arma's AI pilots can't land on water themselves, so:
	  1. the precise waypoint (Fast Rope Pos - MCCMK_fnc_heliRopePos) brings it over the spot at a 10 m hover;
	  2. it is lowered onto the surface at 1.5 m/s, engine and rotors kept running, marked as on a water landing
	     (MCCMK_waterLanding - Floatary keeps it watertight);
	  3. afloat: kept there (MCCMK_fnc_heliWaterHold) - not allowed to lift, drift eased back towards the spot;
	  4. the RAMP opens as it starts down onto the water (not the side doors - MCCMK_fnc_aircraftRamp): a boat can drive up
	     behind a carrier and "Load watercraft".
	It waits there until its next order, which ends it (MCCMK_fnc_heliWaterEnd: ramp shut, straight up).
	Only for an aircraft Floatary floats (a large one); others are refused (false), as on dry land.
	Shared by every water landing: Spawn "On water" (afloat from the start), and - to come - the Evac, the consoles'
	waypoints and the rescue.
*/
params [["_h", objNull], ["_spot", [0, 0, 0]], ["_cond", {true}], ["_low", 12], ["_engine", true]];
// (MK) _low: the height it is brought over the spot at before settling; _engine false: the pilot shuts down once afloat
// and it just floats
if (!isServer || {isNull _h} || {!alive _h} || {isNull (driver _h)}) exitWith {false};
_spot = [_spot select 0, _spot select 1, 0];
private _dbg = missionNamespace getVariable ["MCC_debug", false];
if (!surfaceIsWater _spot) exitWith {
	if (_dbg) then {["INFO", "waterLand", "%1: %2 is not water - no water landing", [typeOf _h, mapGridPosition _spot]] call MCC_fnc_log};
	false
};
if (isNil "MCCMK_fltAir" || {!([_h] call MCCMK_fltAir)} || {!(missionNamespace getVariable ["MCCMK_floatAircraft", true])}) exitWith {
	if (_dbg) then {["INFO", "waterLand", "%1: does not float (too small, or 'Floating aircraft' is off) - no water landing", [typeOf _h]] call MCC_fnc_log};
	false
};
// (MK) boat carriers only, whose engine stands 3 m of water (maxFordingDepth): any other is left out, and said why
private _depth = getNumber (configOf _h >> "maxFordingDepth");
if (!([_h] call MCCMK_fnc_boatCarrier) || {_depth < 3}) exitWith {
	if (_dbg) then {["INFO", "waterLand", "%1: no water landing - %2", [typeOf _h, if ([_h] call MCCMK_fnc_boatCarrier) then {format ["its engine drowns at %1 m of water (3 m needed - a mod's own value?)", _depth]} else {"not a boat carrier"}]] call MCC_fnc_log};
	false
};
_h setVariable ["MCCMK_waterLanding", true, true];
[_h] call MCCMK_fnc_heliWaterCrew;	// (its AI crew stay in it on the water)
// 1. over the spot, low (MK) over the spot by the Evac's hover (MCCMK_fnc_heliHoverAtMove - the pilot ordered AT the
// spot, nothing beyond it to lean towards), at a height the rotors are clear of the water.
_h setVariable ["MCCMK_glideId", -1];
private _over = [_h, _spot, _low max 8, _cond] call MCCMK_fnc_heliHoverAtMove;
if (!alive _h || {!(call _cond)}) exitWith {false};
[_h] remoteExec ["MCCMK_fnc_heliHold", _h];
// 2. and 3. down onto the water, and kept there
private _id = (_h getVariable ["MCCMK_waterId", 0]) + 1;
_h setVariable ["MCCMK_waterId", _id, true];
_h flyInHeight 0;
[_h, true] call MCCMK_fnc_aircraftRamp;	// (the ramp only, as it starts down)
[_h, _spot, _id] remoteExec ["MCCMK_fnc_heliWaterHold", _h];
private _t0 = time;
waitUntil {sleep 0.25; !alive _h || {!(call _cond)} || {(_h getVariable ["MCCMK_waterState", ""]) == "afloat"} || {(time - _t0) > 60}};
private _afloat = alive _h && {(_h getVariable ["MCCMK_waterState", ""]) == "afloat"};
// (MK) afloat: the engine off for "engine off" (kept off until its next order), and any NEW ORDER ends the water landing
// (MCCMK_fnc_heliWaterEnd): a waypoint from either console, the Evac, a Pickup's Take off, High Command - whatever changes its
// waypoints or the pilot's order. Nothing else lifts it off.
if (_afloat) then {
	_h setVariable ["MCCMK_waterEngineOff", !_engine, true];
	[_h, _id] spawn {
		params ["_h", "_id"];
		sleep 3;
		private _sigFn = {private _d = driver _h; private _g = group _d; [(waypoints _g) apply {waypointPosition _x}, currentWaypoint _g, if (isNull _d) then {""} else {currentCommand _d}]};
		private _sig = call _sigFn;
		while {alive _h && {(_h getVariable ["MCCMK_waterId", 0]) == _id}} do {
			if (isNull (driver _h) || {!alive (driver _h)} || {isPlayer (driver _h)}) exitWith {};
			if (_h getVariable ["MCCMK_waterEngineOff", false]) then {if (isEngineOn _h) then {_h engineOn false}};
			private _now = call _sigFn;
			if !(_now isEqualTo _sig) exitWith {[_h] call MCCMK_fnc_heliWaterEnd};
			sleep 1;
		};
	};
};
if (_dbg) then {["INFO", "waterLand", "%1 at %2: %3 after %4 s (precise hover first: %5) | %6 m from the spot, %7 m above the sea, engine %8", [typeOf _h, mapGridPosition _spot, ["NOT afloat", "afloat - ramp open"] select _afloat, round (time - _t0), ["not held", "in place"] select _over, (_h distance2D _spot) toFixed 1, ((getPosASL _h) select 2) toFixed 1, isEngineOn _h]] call MCC_fnc_log};
_afloat
