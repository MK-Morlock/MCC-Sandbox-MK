params [["_ship", objNull, [objNull]]];
if (!isServer || {isNull _ship} || {_ship getVariable ["MCCMK_sinking", false]}) exitWith {};
_ship setVariable ["MCCMK_sinking", true, true];
private _side = _ship getVariable ["MCC_side", sideUnknown];
private _name = _ship getVariable ["MCC_LHDDisplayName", "Ship"];
private _wasHQ = [_ship] call MCCMK_fnc_isHQ;
[format ["%1 is sinking - abandon ship!", _name]] remoteExec ["systemChat", _side];
{
	if (isPlayer _x && {(([_x] call MCCMK_fnc_boardState) select 1) == _ship}) then {["Abandon ship! Get to a lifeboat or into the water."] remoteExec ["MCCMK_fnc_hint", _x]};
} forEach allPlayers;
private _half = (([_ship getVariable ["MCC_ShipType", 0]] call MCCMK_fnc_shipCfg) select 3);
private _boatCls = ["C_Rubberboat", "B_Lifeboat"] select (isClass (configFile >> "CfgVehicles" >> "B_Lifeboat"));
{
	private _p = _ship modelToWorld [_x * ((_half select 0) + 8), 0, 0];
	_p set [2, 0];
	private _b = _boatCls createVehicle _p;
	_b setPosASLW [_p select 0, _p select 1, 0];
} forEach [-1, 1, -1, 1];
private _parts = [_ship] call MCCMK_fnc_hullParts;
private _objs = ((_ship getVariable ["MCCMK_shipObjects", []]) + _parts + (attachedObjects _ship) + [_ship]) select {!isNull _x};
private _steps = 150;
for "_i" from 1 to _steps do {
	{
		private _p = getPosWorld _x;
		_x setPosWorld [_p select 0, _p select 1, (_p select 2) - 0.2];
	} forEach _objs;
	sleep 2;
};
{if (!isNull _x) then {{if (!isPlayer _x) then {deleteVehicle _x}} forEach crew _x; deleteVehicle _x}} forEach _objs;
MCC_staticShips = (missionNamespace getVariable ["MCC_staticShips", []]) select {!isNull _x && {_x != _ship}};
publicVariable "MCC_staticShips";
MCCMK_spawnPointList = (missionNamespace getVariable ["MCCMK_spawnPointList", []]) select {!isNull _x && {_x != _ship}};
publicVariable "MCCMK_spawnPointList";
private _rid = _ship getVariable ["MCCMK_respawnId", []];
if (count _rid > 1) then {[_side, _rid select 1] call BIS_fnc_removeRespawnPosition};
[format ["%1 has been lost.", _name]] remoteExec ["systemChat", _side];
["INFO", "ships", "%1 sank and was removed%2", [_name, ["", " (it was the HQ)"] select _wasHQ]] call MCC_fnc_log;
if (_wasHQ) then {
	private _fobs = (([_side] call MCCMK_fnc_spawnPoints) select {!(_x getVariable ["MCC_isLHD", false])}) apply {[_x distance2D _ship, _x]};
	_fobs sort true;
	if (count _fobs > 0) then {[(_fobs select 0) select 1, objNull, true] call MCCMK_fnc_makeHQ} else {[format ["%1 was your HQ - you have no HQ now.", _name]] remoteExec ["systemChat", _side]};
};
