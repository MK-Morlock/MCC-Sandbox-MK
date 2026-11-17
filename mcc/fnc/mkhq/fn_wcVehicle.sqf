/*
	MCCMK_fnc_wcVehicle - (server) a vehicle just left empty or disabled (MCCMK_fnc_worldCleanup). An ENEMY one (or static
	weapon) is timed: removed after the "Cleanup: Wrecks" time once nobody is within 300 m or looking - never once seized
	by a player, never within 300 m of a base, the mission cleanup's own left to it. Its crew back in and able to move:
	the timer stops. Disabled and empty: it can be salvaged meanwhile ("Salvage vehicle"). [vehicle]
*/
params [["_v", objNull, [objNull]]];
if (!isServer || {isNull _v} || {!alive _v} || {_v getVariable ["MCCMK_wcVeh", false]} || {_v isKindOf "ParachuteBase"} || {_v getVariable ["MCC_seized", false]}) exitWith {};
if !([_v] call MCCMK_wcEnemy) exitWith {};
private _static = _v isKindOf "StaticWeapon";
private _empty = ((crew _v) findIf {alive _x}) < 0;
private _dis = !_static && {!canMove _v};
if (!_empty && {!_dis}) exitWith {};
_v setVariable ["MCCMK_wcVeh", true];
[_v, _static] spawn {
	params ["_v", "_static"];
	private _t0 = time;
	while {!isNull _v && {alive _v}} do {
		private _empty = ((crew _v) findIf {alive _x}) < 0;
		private _dis = !_static && {!canMove _v};
		if ((!_empty && {!_dis}) || {_v getVariable ["MCC_seized", false]}) exitWith {_v setVariable ["MCCMK_wcVeh", _v getVariable ["MCC_seized", false]]};	// crewed and mobile again, or his
		// disabled and empty: it can be salvaged (a disabled vehicle is worth more than its wreck)
		if (_dis && {_empty} && {!(_v getVariable ["MCCMK_disabledSalvage", false])} && {!isNil "MCCMK_salvageOffer"}) then {
			_v setVariable ["MCCMK_disabledSalvage", true, true];
			[_v] call MCCMK_salvageOffer;
		};
		private _mins = missionNamespace getVariable ["MCC_cleanupWrecks", 60];
		if (_mins > 0 && {(time - _t0) >= _mins * 60} && {!([_v] call MCCMK_wcMission)} && {!([_v] call MCCMK_wcNearBase)} && {!([_v, call MCCMK_wcPeople, 300] call MCCMK_wcWatched)}) exitWith {
			if (missionNamespace getVariable ["MCC_debug", false]) then {["INFO", "MCCMK_fnc_wcVehicle", "%1 enemy %2 at %3 removed", [["empty", "disabled"] select _dis, typeOf _v, mapGridPosition _v]] call MCC_fnc_log};
			{deleteVehicle _x} forEach (crew _v);
			deleteVehicle _v;
		};
		sleep 60;
	};
};
