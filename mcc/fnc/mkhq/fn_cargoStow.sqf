/*
	MCCMK_fnc_cargoStow - server: keeps an object loaded into a vehicle's cargo list, rather than deleting it and making a
	copy when it's unloaded, so whatever it holds (contents, damage, a crate's remaining value) survives the trip. It's
	hidden inside the vehicle and goes with it if the vehicle is destroyed or deleted.
	[object, vehicle, true = load / false = unload]
*/
params [["_o", objNull, [objNull]], ["_v", objNull, [objNull]], ["_stow", true, [true]]];
if (!isServer) exitWith {[_o, _v, _stow] remoteExec ["MCCMK_fnc_cargoStow", 2]};
if (isNull _o) exitWith {};
if (_stow) exitWith {
	_o attachTo [_v, [0, 0, -50]];
	_o hideObjectGlobal true;
	_o enableSimulationGlobal false;
	_o allowDamage false;
	if !(_v getVariable ["MCCMK_cargoEH", false]) then {
		_v setVariable ["MCCMK_cargoEH", true];
		private _code = {
			params ["_veh"];
			{private _k = _x param [4, objNull]; if (!isNull _k) then {deleteVehicle _k}} forEach (_veh getVariable ["MCC_logisticsCargo", []]);
			_veh setVariable ["MCC_logisticsCargo", [], true];
		};
		_v addEventHandler ["Killed", _code];
		_v addEventHandler ["Deleted", _code];
	};
};
// unload: beside the vehicle, or by parachute when it's flying
detach _o;
_o enableSimulationGlobal true;
_o hideObjectGlobal false;
_o allowDamage true;
if (isNull _v) exitWith {};
if (((getPos _v) select 2) > 20) then {
	private _pos = _v modelToWorld [0, -10, -10];
	_o setPos _pos;
	[_o, _v] spawn {
		params ["_o", "_v"];
		private _para = createVehicle ["I_parachute_02_F", getPos _o, [], 0, "CAN_COLLIDE"];
		private _vel = velocity _v;
		_vel set [2, -22];
		_para setVelocity _vel;
		_o attachTo [_para, [0, 0, 1]];
		waitUntil {sleep 0.2; ((getPos _o) select 2) < 4 || {!alive _o}};
		detach _o;
		sleep 1;
		deleteVehicle _para;
	};
} else {
	private _pos = (getPos _v) findEmptyPosition [1, 8, typeOf _o];
	if (_pos isEqualTo []) then {_pos = _v modelToWorld [0, -((((boundingBoxReal _v) select 1) select 1) + 2), 0]};
	_o setPos _pos;
};
