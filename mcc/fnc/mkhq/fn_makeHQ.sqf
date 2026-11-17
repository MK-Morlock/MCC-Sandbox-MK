if (!isServer) exitWith {_this remoteExec ["MCCMK_fnc_makeHQ", 2]};
params [["_t", objNull, [objNull]], ["_caller", objNull, [objNull]], ["_free", false, [true]]];
private _reply = {
	params ["_msg"];
	if (!isNull _caller && {isPlayer _caller}) then {[_msg] remoteExec ["MCCMK_fnc_hint", _caller]};
	["INFO", "makeHQ", "%1", [_msg]] call MCC_fnc_log;
};
if (isNull _t || {!alive _t} || {_t getVariable ["dead", false]}) exitWith {["Make HQ: that spawn point is destroyed or gone."] call _reply};
private _side = _t getVariable ["side", _t getVariable ["MCC_side", sideUnknown]];
if !(_side in [west, east, resistance]) exitWith {["Make HQ: that spawn point has no side."] call _reply};
private _sv = format ["MCC_START_%1", _side];
private _old = missionNamespace getVariable [_sv, []];
if ([_t] call MCCMK_fnc_isHQ) exitWith {["Make HQ: that is already the HQ."] call _reply};
private _isShip = _t getVariable ["MCC_isLHD", false];
private _name = if (_isShip) then {_t getVariable ["MCC_LHDDisplayName", "Ship"]} else {_t getVariable ["mcc_fob_name", "F.O.B."]};
if (!_free) then {
	private _cdVar = format ["MCCMK_hqMoved_%1", _side];
	private _cd = (missionNamespace getVariable ["MCC_makeHQCooldown", 10]) * 60;
	private _since = time - (missionNamespace getVariable [_cdVar, -1e9]);
	if (_since < _cd) exitWith {[format ["Make HQ: the HQ was moved recently - available again in %1 min.", ceil ((_cd - _since) / 60)]] call _reply; _t = objNull};
	private _dist = missionNamespace getVariable ["MCC_makeHQEnemyDist", 300];
	private _enemyNear = {
		params ["_p"];
		_dist > 0 && {((_p nearEntities [["CAManBase", "LandVehicle", "Air", "Ship"], _dist]) findIf {alive _x && {[_side, side group _x] call BIS_fnc_sideIsEnemy}}) >= 0}
	};
	if ([getPos _t] call _enemyNear || {(_old isEqualType []) && {count _old > 1} && {[_old] call _enemyNear}}) exitWith {[format ["Make HQ: enemy within %1 m of the F.O.B. or the current HQ.", _dist]] call _reply; _t = objNull};
	private _rv = format ["MCC_res%1", _side];
	private _res = +(missionNamespace getVariable [_rv, [0, 0, 0, 0, 0]]);
	private _cS = missionNamespace getVariable ["MCC_makeHQCostSupply", 600];
	private _cF = missionNamespace getVariable ["MCC_makeHQCostFuel", 200];
	if ((_res param [1, 0]) < _cS || {(_res param [2, 0]) < _cF}) exitWith {[format ["Make HQ: not enough resources (needs %1 Supply and %2 Fuel).", _cS, _cF]] call _reply; _t = objNull};
	_res set [1, (_res select 1) - _cS];
	_res set [2, (_res select 2) - _cF];
	missionNamespace setVariable [_rv, _res, true];
	missionNamespace setVariable [_cdVar, time, true];
};
if (isNull _t) exitWith {};
private _pos = if (_isShip) then {(getPosASL _t) vectorAdd [0, 0, 17]} else {getPos _t};
{
	if ((_old isEqualType []) && {count _old > 1} && {(_x distance2D _old) < 60} && {_x != _t}) then {
		if ((_x getVariable ["type", ""]) == "HQ") then {_x setVariable ["type", "FOB", true]};
		if !(_x getVariable ["MCC_isLHD", false]) then {
			private _fn = _x getVariable ["mcc_fob_name", ""];
			if (_fn == "") then {_fn = format ["FOB_%1", ["MCC_fob_counter", 1] call BIS_fnc_counter]; _x setVariable ["mcc_fob_name", _fn, true]};
			[[_fn], getPos _x, "colorGreen", "loc_Bunker", _fn, false] remoteExec ["BIS_fnc_markerCreate", _side, false];
		};
	};
} forEach ([_side] call MCCMK_fnc_spawnPoints);
if (!_isShip) then {
	_t setVariable ["type", "HQ", true];
	private _tn = _t getVariable ["mcc_fob_name", ""];
	if (_tn != "") then {["deleteMarker", [_tn]] remoteExec ["MCC_fnc_secAction", _side, false]};
};
missionNamespace setVariable [_sv, _pos];
publicVariable _sv;
[] remoteExec ["MCC_fnc_startLocations", 0];
[_t] call MCCMK_fnc_campaignProtect;
[format ["HQ moved to %1 (grid %2)%3", _name, mapGridPosition _t, ["", " - the previous HQ is now an F.O.B."] select ((_old isEqualType []) && {count _old > 1})]] remoteExec ["systemChat", _side];
["INFO", "makeHQ", "%1 HQ moved to %2 at %3 (from %4) by %5%6", [_side, _name, _pos apply {round _x}, if (_old isEqualType [] && {count _old > 1}) then {_old apply {round _x}} else {"none"}, if (isNull _caller) then {"script"} else {name _caller}, ["", " (free)"] select _free]] call MCC_fnc_log;
