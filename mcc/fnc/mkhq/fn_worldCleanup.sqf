/*
	MCCMK_fnc_worldCleanup - (every computer, postInit) the cleanup OUTSIDE generated missions, all driven by events (no
	scanning loop - each thing gets its own timer only when it needs one). Missions keep their own cleanup.
	  Wrecks: removed after the "Cleanup: Wrecks" time (60 min) once nobody is within 50 m or looking - sunk ones too (a
	          diver can salvage them meanwhile). Not within 300 m of a base (HQ, F.O.B.s - the HQ's Clear wrecks).
	  Enemy vehicles (and static weapons) left EMPTY or DISABLED (can't move): removed after the same time once nobody is
	          within 300 m or looking; never once a player has been in one (seized - his), never within 300 m of a base.
	          A disabled, empty enemy vehicle can be salvaged meanwhile ("Salvage vehicle", 1.5x a wreck's value).
	  Player-side vehicles, supply pods: never removed.
	  Supply crates and containers: an EMPTY one removed 10 min after it was emptied, once nobody is within 50 m or
	          looking; never within 300 m of a base. One with anything in it is left alone.
	  Mines placed by AI: removed after 60 min once no player is within 200 m. Players' mines and the MCC console's IEDs
	          and minefields are never touched.
	  Parachutes: a unit's parachute deleted as soon as he has got out of it (players' HALO jumps included).
	  (Bodies inside intact vehicles: the body cleanup, MCCMK_fnc_dropCleanup.)
*/
// a unit's parachute, once he's out of it (where the parachute is local)
["ParachuteBase", "GetOut", {
	params ["_p"];
	if (!local _p) exitWith {};
	[_p] spawn {params ["_p"]; sleep 2; if (!isNull _p && {((crew _p) findIf {alive _x}) < 0}) then {deleteVehicle _p}};
}] call CBA_fnc_addClassEventHandler;
// a player in a vehicle: it's seized - his, never removed (also what the mission cleanup reads)
{
	[_x, "GetIn", {
		params ["_v", "", "_u"];
		if (local _u && {isPlayer _u} && {!(_v getVariable ["MCC_seized", false])}) then {_v setVariable ["MCC_seized", true, true]};
	}, true, [], true] call CBA_fnc_addClassEventHandler;
	// left empty, or disabled: told to the server (where the vehicle is local)
	[_x, "GetOut", {params ["_v"]; if (local _v && {alive _v} && {((crew _v) findIf {alive _x}) < 0}) then {[_v] remoteExec ["MCCMK_fnc_wcVehicle", 2]}}, true, [], true] call CBA_fnc_addClassEventHandler;
	[_x, "Dammaged", {params ["_v"]; if (local _v && {alive _v} && {!(_v getVariable ["MCCMK_wcVeh", false])} && {!canMove _v}) then {[_v] remoteExec ["MCCMK_fnc_wcVehicle", 2]}}, true, [], true] call CBA_fnc_addClassEventHandler;
} forEach ["LandVehicle", "Air", "Ship"];
// a crate closed after use: the server checks whether it's empty
{
	[_x, "ContainerClosed", {params ["_c"]; [_c] remoteExec ["MCCMK_fnc_wcCrate", 2]}, true, [], true] call CBA_fnc_addClassEventHandler;
} forEach ["ReammoBox_F", "Slingload_01_Base_F"];
// a mine an AI unit has just placed (players' never)
["CAManBase", "Fired", {
	params ["_u", "_w", "", "", "", "", "_p"];
	if (_w != "Put" || {isPlayer _u} || {isNull _p}) exitWith {};
	[_p] remoteExec ["MCCMK_fnc_wcMine", 2];
}, true, [], true] call CBA_fnc_addClassEventHandler;

if (!isServer) exitWith {};
// --- the shared rules (server)
MCCMK_wcPeople = {
	private _p = [];
	{_p append ((units group _x) select {alive _x})} forEach (allPlayers - (entities "HeadlessClient_F"));
	_p arrayIntersect _p
};
MCCMK_wcNearBase = {
	params ["_o"];
	private _b = [];
	{_b append ([_x] call BIS_fnc_getRespawnPositions)} forEach [west, east, resistance, civilian];
	(_b findIf {(_o distance2D _x) < 300}) >= 0
};
MCCMK_wcWatched = {	// a player within _near m, or looking at it (in view, line of sight)
	params ["_o", "_ppl", "_near"];
	private _end = (getPosASL _o) vectorAdd [0, 0, 1];
	(_ppl findIf {
		private _d = _x distance _o;
		(_d < _near) || {(_d < (viewDistance max 500)) && {private _rd = _x getRelDir _o; (_rd < 70) || {_rd > 290}} && {([_x, "VIEW", _o] checkVisibility [eyePos _x, _end]) > 0}}
	}) >= 0
};
MCCMK_wcMission = {params ["_o"]; ((_o getVariable ["MCC_MWid", ""]) != "") && {!(_o getVariable ["MCC_seized", false])}};	// the mission cleanup's
MCCMK_wcEnemy = {	// a vehicle of a side hostile to a player's side, and friendly to none
	params ["_v"];
	private _cs = getNumber (configOf _v >> "side");
	if !(_cs in [0, 1, 2]) exitWith {false};
	private _vs = [east, west, independent] select _cs;
	private _ps = [];
	{_ps pushBackUnique (side group _x)} forEach (allPlayers - (entities "HeadlessClient_F"));
	(_ps findIf {[_x, _vs] call BIS_fnc_sideIsEnemy}) >= 0 && {(_ps findIf {(_x getFriend _vs) >= 0.6}) < 0}
};
// --- wrecks: each one timed from when it was destroyed
addMissionEventHandler ["EntityKilled", {
	params ["_v"];
	if (_v isKindOf "CAManBase" || {!(_v isKindOf "AllVehicles")} || {_v isKindOf "ParachuteBase"} || {_v getVariable ["MCC_isLHD", false]}) exitWith {};
	[_v] spawn {
		params ["_v"];
		if (_v getVariable ["MCCMK_wcWreck", false]) exitWith {};
		_v setVariable ["MCCMK_wcWreck", true];
		private _t0 = time;
		sleep 20;	// (settled - sunk or not)
		while {!isNull _v} do {
			private _mins = missionNamespace getVariable ["MCC_cleanupWrecks", 60];
			private _sunk = (surfaceIsWater (getPos _v)) && {((getPosASL _v) select 2) < -1.5};
			private _wait = _mins * 60;
			if (_mins > 0 && {(time - _t0) >= _wait} && {!([_v] call MCCMK_wcMission)} && {!([_v] call MCCMK_wcNearBase)} && {!([_v, call MCCMK_wcPeople, 50] call MCCMK_wcWatched)}) exitWith {
				if (missionNamespace getVariable ["MCC_debug", false]) then {["INFO", "MCCMK_fnc_worldCleanup", "wreck %1 at %2 removed%3", [typeOf _v, mapGridPosition _v, ["", " (sunk)"] select _sunk]] call MCC_fnc_log};
				{deleteVehicle _x} forEach (crew _v);
				deleteVehicle _v;
			};
			sleep 60;
		};
	};
}];
