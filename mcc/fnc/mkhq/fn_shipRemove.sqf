// (server) Removes a ship for good - its parts, weapons and their AI crews, its respawn point and its place in the ship
// list; if it was the HQ, the HQ falls back to the nearest F.O.B. (as when a ship sinks). [ship, message]
params [["_ship", objNull, [objNull]], ["_msg", "", [""]]];
if (!isServer || {isNull _ship}) exitWith {};
private _side = _ship getVariable ["MCC_side", sideUnknown];
private _name = _ship getVariable ["MCC_LHDDisplayName", "Ship"];
private _wasHQ = [_ship] call MCCMK_fnc_isHQ;
private _objs = ((_ship getVariable ["MCCMK_shipObjects", []]) + ([_ship] call MCCMK_fnc_hullParts) + (_ship getVariable ["MCCMK_weapons", []]) + (attachedObjects _ship) + [_ship]) select {!isNull _x};
{if (!isNull _x) then {{if (!isPlayer _x) then {deleteVehicle _x}} forEach crew _x; deleteVehicle _x}} forEach _objs;
MCC_staticShips = (missionNamespace getVariable ["MCC_staticShips", []]) select {!isNull _x && {_x != _ship}};
publicVariable "MCC_staticShips";
MCCMK_spawnPointList = (missionNamespace getVariable ["MCCMK_spawnPointList", []]) select {!isNull _x && {_x != _ship}};
publicVariable "MCCMK_spawnPointList";
private _rid = _ship getVariable ["MCCMK_respawnId", []];
if (count _rid > 1) then {[_side, _rid select 1] call BIS_fnc_removeRespawnPosition};
if (_msg != "") then {[_msg] remoteExec ["systemChat", _side]};
if (_wasHQ) then {
	private _fobs = (([_side] call MCCMK_fnc_spawnPoints) select {!(_x getVariable ["MCC_isLHD", false])}) apply {[_x distance2D _ship, _x]};
	_fobs sort true;
	if (count _fobs > 0) then {[(_fobs select 0) select 1, objNull, true] call MCCMK_fnc_makeHQ} else {[format ["%1 was your HQ - you have no HQ now.", _name]] remoteExec ["systemChat", _side]};
};
