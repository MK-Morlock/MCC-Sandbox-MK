/*
	MCCMK_fnc_airLandedHold - (where the aircraft is local: the server) an aircraft spawned "Landed" (the Spawn panel's or
	the 3D Editor's Start: Landed): crew aboard, engine off, on the ground, and held there until its group is given its
	first order - a waypoint from the MCC console or the Commander Console, or a High Command order (each adds a waypoint).
	Then the pilot is let go: he starts up and takes off by himself (a plane taxis to take off: face it down a runway).
	The same hold as the 3D Editor's "Hold position" (MCC_fnc_applyPlaceBehaviour): the pilot may not move, the engine
	is kept off. [aircraft]
*/
params [["_v", objNull, [objNull]]];
if (isNull _v || {!local _v}) exitWith {};
_v engineOn false;
_v setVelocity [0, 0, 0];
_v setVariable ["MCCMK_landedHold", true, true];
["INFO", "landed", "%1 placed landed at %2, engine off - held until its first order", [typeOf _v, mapGridPosition _v]] call MCC_fnc_log;
[_v] spawn {
	params ["_v"];
	sleep 3;	// (the spawn's own behaviour and waypoints are set first)
	private _g = group (effectiveCommander _v);
	if (isNull _g) exitWith {_v setVariable ["MCCMK_landedHold", nil, true]};
	// (MK) what its orders look like now: the waypoints THEMSELVES (where they are) and the current one, and where the pilot
	// plans to go. A console order deletes the old waypoints and adds a new one - the count can end up the same, so
	// counting them isn't enough.
	private _sigFn = {params ["_g", "_d"]; [(waypoints _g) apply {waypointPosition _x}, currentWaypoint _g]};
	private _sig = [_g, driver _v] call _sigFn;
	// (the planned destination: only a change of more than 20 m counts - with no plan it is his own position, which can drift)
	private _dest0 = (expectedDestination (driver _v)) select 0;
	private _why = "";
	while {true} do {
		if (!alive _v) exitWith {_why = "destroyed"};
		private _d = driver _v;
		if (isNull _d || {!alive _d}) exitWith {_why = "no pilot"};
		if (isPlayer _d) exitWith {_why = "a player took the controls"};
		_g = group _d;
		if !(([_g, _d] call _sigFn) isEqualTo _sig) exitWith {_why = "its group was given an order"};
		if ((((expectedDestination _d) select 0) distance2D _dest0) > 20) exitWith {_why = "the pilot was given somewhere to go"};
		if !((currentCommand _d) in ["", "STOP", "WAIT"]) exitWith {_why = format ["the pilot was given an order (%1)", currentCommand _d]};
		if (_d checkAIFeature "MOVE") then {_d disableAI "MOVE"};
		if (isEngineOn _v) then {_v engineOn false};
		sleep 1;
	};
	private _d = driver _v;
	if (!isNull _d) then {_d enableAI "MOVE"};
	_v setVariable ["MCCMK_landedHold", nil, true];
	["INFO", "landed", "%1 let go: %2", [typeOf _v, _why]] call MCC_fnc_log;
};
