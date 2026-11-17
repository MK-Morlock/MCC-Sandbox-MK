/*
	MCCMK_fnc_wcCrate - (server) a crate or container just closed after use (MCCMK_fnc_worldCleanup): if it's EMPTY, it's
	removed 10 minutes later once nobody is within 50 m or looking - not if anything has been put back, not within 300 m
	of a base, not while carried or slung, not a mission's. One with anything in it is left alone. [crate]
*/
params [["_c", objNull, [objNull]]];
if (!isServer || {isNull _c} || {_c getVariable ["MCCMK_wcCrate", false]}) exitWith {};
private _isEmpty = {params ["_c"]; ((count (weaponCargo _c)) + (count (magazineCargo _c)) + (count (itemCargo _c)) + (count (backpackCargo _c))) == 0};
if !([_c] call _isEmpty) exitWith {};
_c setVariable ["MCCMK_wcCrate", true];
[_c, _isEmpty] spawn {
	params ["_c", "_isEmpty"];
	private _t0 = time;
	while {!isNull _c} do {
		if !([_c] call _isEmpty) exitWith {_c setVariable ["MCCMK_wcCrate", false]};	// filled again: left alone
		if ((time - _t0) >= 600 && {isNull attachedTo _c} && {isNull (ropeAttachedTo _c)} && {!([_c] call MCCMK_wcMission)} && {!([_c] call MCCMK_wcNearBase)} && {!([_c, call MCCMK_wcPeople, 50] call MCCMK_wcWatched)}) exitWith {
			if (missionNamespace getVariable ["MCC_debug", false]) then {["INFO", "MCCMK_fnc_wcCrate", "empty %1 at %2 removed", [typeOf _c, mapGridPosition _c]] call MCC_fnc_log};
			deleteVehicle _c;
		};
		sleep 60;
	};
};
