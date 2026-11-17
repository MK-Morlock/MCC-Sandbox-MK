params [["_ship", objNull, [objNull]], ["_pos", [0, 0], [[]]], ["_dir", 0, [0]], ["_u", objNull, [objNull]], ["_free", false, [true]]];
if (!isServer || {isNull _ship} || {isNull _u}) exitWith {};
private _side = _ship getVariable ["MCC_side", sideUnknown];
if (_free && {!([_u] call MCCMK_fnc_isMissionMaker)}) then {_free = false};
if (!_free && {!([_u, _side] call MCCMK_fnc_shipCanCommand)}) exitWith {["Only the commander can move this ship."] remoteExec ["MCCMK_fnc_hint", _u]};
if (((_ship getVariable ["MCCMK_repositionUntil", 0]) - serverTime) > 0) exitWith {["This ship is still repositioning."] remoteExec ["MCCMK_fnc_hint", _u]};
private _t = _ship getVariable ["MCC_ShipType", 0];
([_pos, _dir, _t, _side, _ship] call MCCMK_fnc_shipPosCheck) params ["_ok", "_why"];
if (!_ok) exitWith {[format ["The ship can't move there: %1.", _why]] remoteExec ["MCCMK_fnc_hint", _u]};
([_t] call MCCMK_fnc_shipCfg) params ["_nm", "", "", "_half"];
private _name = _ship getVariable ["MCC_LHDDisplayName", _nm];
private _km = (_ship distance2D _pos) / 1000;
private _fuel = 0;
if (!_free) then {
	private _perKm = missionNamespace getVariable ["MCCMK_shipMoveFuel", 50];
	if (_perKm > 0) then {_fuel = ceil ((_perKm * _km) max 100)};
};
private _var = format ["MCC_res%1", _side];
private _r = +(missionNamespace getVariable [_var, [0, 0, 0, 0, 0]]);
if ((_r select 2) < _fuel) exitWith {["Not enough Fuel to move this ship."] remoteExec ["MCCMK_fnc_hint", _u]};
if (_fuel > 0) then {
	_r set [2, (_r select 2) - _fuel];
	missionNamespace setVariable [_var, _r];
	publicVariable _var;
};
private _secs = ((missionNamespace getVariable ["MCCMK_shipMoveTime", 60]) * _km) min (missionNamespace getVariable ["MCCMK_shipMoveTimeMax", 600]);
private _wasHQ = [_ship] call MCCMK_fnc_isHQ;
private _toLocal = {
	params ["_o"];
	private _d = getDir _ship;
	private _w = (getPosWorld _o) vectorDiff (getPosWorld _ship);
	[(_w select 0) * (cos _d) - (_w select 1) * (sin _d), (_w select 0) * (sin _d) + (_w select 1) * (cos _d), _w select 2]
};
private _inBox = {
	params ["_o"];
	private _l = [_o] call _toLocal;
	(abs (_l select 0)) < ((_half select 0) + 15) && {(abs (_l select 1)) < ((_half select 1) + 15)}
};
private _objs = (_ship getVariable ["MCCMK_shipObjects", []]) select {!isNull _x};
private _cands = (_ship nearEntities [["Man", "LandVehicle", "Air", "Ship"], (_half select 1) + 40]) select {
	!(_x getVariable ["MCC_isLHD", false]) && {!(_x in _objs)} && {[_x] call _inBox} && {isNull attachedTo _x}
};
// Boats moored alongside (Anchors): their lines' dock ends are hidden markers on the hull side, carried with the ship so
// the boats arrive still moored.
private _pads = [];
{
	{
		private _p = _x param [2, objNull];
		if (!isNull _p && {[_p] call _inBox}) then {_pads pushBackUnique _p};
	} forEach (_x getVariable ["ANC_lines", []]);
} forEach (_cands select {_x isKindOf "Ship"});
private _rec = (_cands + _objs + _pads) apply {[_x, [_x] call _toLocal, (getDir _x) - (getDir _ship)]};
private _players = [];
{
	if (_x isKindOf "Man") then {if (isPlayer _x) then {_players pushBackUnique _x}} else {{if (isPlayer _x) then {_players pushBackUnique _x}} forEach crew _x};
} forEach _cands;
{[] remoteExec ["MCCMK_fnc_shipFade", _x]} forEach _players;
["INFO", "ships", "%1 moving %2 %3 km to grid %4 (%5 objects, %6 players aboard, %7 Fuel, %8 s)", [name _u, _name, (round (_km * 10)) / 10, mapGridPosition _pos, count _rec, count _players, _fuel, round _secs]] call MCC_fnc_log;
[format ["%1 repositioning to grid %2, about %3 min.", _name, mapGridPosition _pos, ceil (_secs / 60) max 1]] remoteExec ["systemChat", _side];
sleep 1.2;
switch (_t) do {
	case 0;
	case 1: {
		private _pw = getPosWorld _ship;
		_ship setPosWorld [_pos select 0, _pos select 1, _pw select 2];
		_ship setDir _dir;
		if (_t == 0) then {[_ship] call BIS_fnc_Destroyer01PosUpdate} else {[_ship] call BIS_fnc_Carrier01PosUpdate};
	};
	case 2: {
		_ship setPosASLW [_pos select 0, _pos select 1, 0];
		_ship setDir _dir;
	};
	default {
		_ship setPosASLW [_pos select 0, _pos select 1, 0];
		_ship setDir (_dir - 180);
		_ship setVariable ["CUP_WaterVehicles_Dir", getDir _ship];
		private _sp = getPosASL _ship;
		{_x setDir (getDir _ship); _x setPos _sp} forEach (_ship getVariable ["CUP_WaterVehicles_shipParts", []]);
		{deleteVehicle _x} forEach (_ship getVariable ["CUP_WaterVehicles_shipLights", []]);
		if (!isNil "CUP_fnc_spawnShipLights") then {[_ship] call CUP_fnc_spawnShipLights};
	};
};
private _nd = getDir _ship;
private _np = getPosWorld _ship;
{
	_x params ["_o", "_l", "_rd"];
	if (!isNull _o) then {
		_o setPosWorld [(_np select 0) + (_l select 0) * (cos _nd) + (_l select 1) * (sin _nd), (_np select 1) - (_l select 0) * (sin _nd) + (_l select 1) * (cos _nd), (_np select 2) + (_l select 2)];
		_o setDir (_nd + _rd);
	};
} forEach _rec;
if (_wasHQ) then {
	private _sv = format ["MCC_START_%1", _side];
	missionNamespace setVariable [_sv, (getPosASL _ship) vectorAdd [0, 0, 17]];
	publicVariable _sv;
	[] remoteExec ["MCC_fnc_startLocations", 0];
};
[_ship] call MCCMK_fnc_campaignProtect;
_ship setVariable ["MCCMK_repositionUntil", serverTime + _secs, true];
[_ship, _name, _side, serverTime + _secs] spawn MCCMK_fnc_shipArriving;
sleep _secs;
_ship setVariable ["MCCMK_repositionUntil", 0, true];
[format ["%1 is in position at grid %2.", _name, mapGridPosition _ship]] remoteExec ["systemChat", _side];
