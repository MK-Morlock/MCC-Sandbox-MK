/*
	MCCMK_fnc_aceMode - where MCC MK's own actions go ("MCC actions with ACE"): 2 = the ACE menu only, 0 = the ACE menu
	and the scroll menu, 1 = the scroll menu only. Without ACE: always 1. (An older save's checkbox: on = 2, off = 1.)
	Read at mission start.
*/
if !(isClass (configFile >> "CfgPatches" >> "ace_interact_menu")) exitWith {1};
private _v = missionNamespace getVariable ["MCCMK_aceActions", 2];
if (_v isEqualType true) then {_v = [1, 2] select _v};
if !(_v in [0, 1, 2]) then {_v = 2};
_v
