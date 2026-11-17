/*
	MCCMK_fnc_droneDowned  (server) - a drone has been hit and can't move (or is 90% damaged): once it's down and resting
	on the ground (a minute at most), it can be salvaged like a wreck. A shot-down drone often never "dies" in Arma's
	terms (no destroyed state), so it would otherwise just lie there. Destroyed outright: the wreck salvage handles it.
	[drone]
*/
params [["_v", objNull, [objNull]]];
if (!isServer || {isNull _v}) exitWith {};
[_v] spawn {
	params ["_v"];
	private _t = time + 60;
	waitUntil {sleep 1; isNull _v || {!alive _v} || {(((getPosATL _v) select 2) < 3) && {(vectorMagnitude (velocity _v)) < 1}} || {time > _t}};
	if (isNull _v || {!alive _v} || {_v getVariable ["MCCMK_salvageOffered", false]}) exitWith {};
	_v setVariable ["MCCMK_downedDrone", true, true];
	[_v] call MCCMK_salvageOffer;
	["INFO", "salvage", "downed drone %1 at grid %2 can be salvaged", [typeOf _v, mapGridPosition _v]] call MCC_fnc_log;
};
