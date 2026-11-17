/*
	MCCMK_fnc_sarSource - (server) the ship a rescue comes from: [position, side] -> [ship (objNull: none within 6 km),
	distance]. Not one that is sinking.
*/
params [["_pos", [0, 0, 0]], ["_side", sideUnknown]];
private _ships = ((missionNamespace getVariable ["MCC_staticShips", []]) select {
	!isNull _x && {(_x getVariable ["MCC_side", sideUnknown]) isEqualTo _side} && {!(_x getVariable ["MCCMK_sinking", false])}
}) apply {[_x distance2D _pos, _x]};
_ships sort true;
if (_ships isEqualTo [] || {((_ships select 0) select 0) > 6000}) exitWith {[objNull, 0]};
[(_ships select 0) select 1, (_ships select 0) select 0]
