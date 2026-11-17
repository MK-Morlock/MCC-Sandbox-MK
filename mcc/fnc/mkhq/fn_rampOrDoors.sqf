/*
	MCCMK_fnc_rampOrDoors - an aircraft's RAMP opened or closed for a drop - or, if it has no ramp (a Ghost Hawk), its side
	doors: [aircraft, open?]. Used for Helocasting, paradrops from a helicopter and the Evac's Paradrop.
*/
params [["_v", objNull], ["_open", true]];
if (isNull _v || {!alive _v}) exitWith {};
if (!local _v) exitWith {[_v, _open] remoteExec ["MCCMK_fnc_rampOrDoors", _v]};
if !([_v, _open] call MCCMK_fnc_aircraftRamp) then {[_v, _open] call MCCMK_fnc_aircraftDoors};
