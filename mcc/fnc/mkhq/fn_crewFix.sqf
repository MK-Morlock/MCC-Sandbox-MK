/*
	MCCMK_fnc_crewFix - a vehicle's crew from the right faction (MCCMK_fnc_factionCrew), wherever the vehicle came from:
	the faction given; for a side, the faction of a player on that side (player-side supports); otherwise the enemy
	faction while a mission is being generated (MCCMK_genFaction - compositions use the side's vanilla guns), and else
	the vehicle's own faction. Never the side's vanilla soldiers. [vehicle, faction or side (optional)]
*/
params [["_v", objNull, [objNull]], ["_fac", "", ["", west]]];
if (isNull _v) exitWith {};
if (_fac isEqualType west) then {
	private _side = _fac;
	private _p = (allPlayers - (entities "HeadlessClient_F")) select {(side group _x) isEqualTo _side};
	_fac = if (_p isNotEqualTo []) then {faction (_p select 0)} else {""};
};
if (_fac == "") then {_fac = missionNamespace getVariable ["MCCMK_genFaction", ""]};
if (_fac == "") then {_fac = getText (configOf _v >> "faction")};
[_v, _fac] call MCCMK_fnc_factionCrew;
