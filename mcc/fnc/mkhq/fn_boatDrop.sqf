/*
	MCCMK_fnc_boatDrop - (server; waits) the BOAT DROP waypoint: a carrier with a boat aboard takes it to a point and lets it
	out: [aircraft, point, low hover?]. Landed: a water landing there (MCCMK_fnc_heliWaterLandWp, engine on), the boat let
	out (MCCMK_fnc_floatLoad - let out behind it; an AI-driven boat faces away), then it waits on the water for its next order. Low
	hover: brought over the point at 4 m (the Evac's hover), the boat let out under its tail onto the water, then it climbs
	to 30 m and holds there for its next order. The boat's crew carry on with their own orders.
*/
params [["_h", objNull], ["_pt", [0, 0, 0]], ["_low", false], ["_cond", {alive (_this select 0)}]];
if (!isServer || {isNull _h} || {!alive _h}) exitWith {};
private _b = [_h] call MCCMK_fltAttached;
private _say = {params ["_m"]; private _l = leader (group (driver _h)); if (isPlayer _l) then {[_m] remoteExec ["MCCMK_fnc_hint", _l]} else {private _mkO = (group _l) getVariable ["MCCMK_wpOwner", -1]; if (_mkO >= 0) then {[_m] remoteExec ["MCCMK_fnc_hint", _mkO]}}; ["INFO", "boatDrop", "%1: %2", [typeOf _h, _m]] call MCC_fnc_log};
if (isNull _b) exitWith {["No boat aboard to drop"] call _say};
_pt = [_pt select 0, _pt select 1, 0];
if (!surfaceIsWater _pt) exitWith {["That point is not water - no boat drop"] call _say};
if (_low) then {
	[_h] call MCCMK_fnc_heliWaterEnd;
	_h flyInHeight 50;
	private _held = [_h, _pt, 6, _cond] call MCCMK_fnc_heliHoverAtMove;
	if (!alive _h || {!(call _cond)}) exitWith {};
	[_h, true] call MCCMK_fnc_aircraftRamp;
	sleep 2;
	// slid out over the ramp, as an unload (MCCMK_fnc_floatLoad) - from the ramp's end it drops onto the water
	[objNull, _h, false] call MCCMK_fnc_floatLoad;
	sleep 4;
	[_h] remoteExec ["MCCMK_fnc_heliHold", _h];
	[_h, false] call MCCMK_fnc_aircraftRamp;
	_h flyInHeight 30;
	_h doMove (getPos _h);
	["Boat dropped"] call _say;
} else {
	private _ok = if ((_h getVariable ["MCCMK_waterState", ""]) == "afloat" && {(_h distance2D _pt) < 50}) then {true} else {[_h, _pt, true, _cond] call MCCMK_fnc_heliWaterLandWp};
	if (!_ok) exitWith {};
	sleep 2;
	[objNull, _h, false] call MCCMK_fnc_floatLoad;
	["Boat dropped"] call _say;
};
