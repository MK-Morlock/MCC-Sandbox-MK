/*==================================================================MCC_fnc_objectMapper=========================================================================================
Original Script
objectMapper.sqf Author: Joris-Jan van 't Land
Edited by armatec

	Description:
	Takes an array of data about a dynamic object template and creates the objects.

	Parameter(s):
	_this select 0: compositions name - "fuelDepot_us"
	_this select 1: Direction in degrees - Number
	_this select 2: Location to start or array of objects
	_this select 3: variable to apply to each spawned object

	Exsample:
	[ getpos player, 0,"c_campSite"] call MCC_fnc_objectMapper;

	<out>
		if obj select 6 got a a value then it is the target vehicle.
*/
private _objs = [];
private _made = [];
private _target = nil;
private _variable = "";


params ["_pos", "_azi", "_script"];
_variable = param [3,"",[""]];


if (!isserver) exitWith {};

_objs = [];

//DOC sqf or Comp Array?
if (typeName _script == "ARRAY") then {
	_objs = _script;
} else {
	_objs = call (compile (preprocessFileLineNumbers format ["%1mcc\general_scripts\docobject\%2.sqf",MCC_path,_script]));
};

private _posX = _pos select 0;
private _posY = _pos select 1;

private _multiplyMatrixFunc = {
	private _array1 = _this select 0;
	private _array2 = _this select 1;
	private _result = [
	(((_array1 select 0) select 0) * (_array2 select 0)) + (((_array1 select 0) select 1) * (_array2 select 1)),
	(((_array1 select 1) select 0) * (_array2 select 0)) + (((_array1 select 1) select 1) * (_array2 select 1))
	];
	_result
};
for "_i" from 0 to ((count _objs) - 1) do {
		private _obj = [];
		private _type = "";
		private _relPos = [];
		private _azimuth = 0;
		private _fuel = nil;
		private _damage = nil;
		private _newObj = objNull;
		private _vehicleinit = nil;
		private _vehicleTarget = nil;
		_obj = _objs select _i;
		_type = _obj select 0;
		_relPos = _obj select 1;
		_azimuth = _obj select 2;
		_fuel = _obj select 3;
		_damage = _obj select 4;
		if (typeName (_obj select 5) == "STRING") then {_vehicleinit = (_obj select 5)};
		_vehicleTarget = _obj select 6;

		private _rotMatrix = [];
		private _newRelPos = [];
		private _newPos = [];
		_rotMatrix =[[cos _azi, sin _azi],[-(sin _azi), cos _azi]];
		_newRelPos = [_rotMatrix, _relPos] call _multiplyMatrixFunc;
		private _z = 0;
		if ((count _relPos) > 2) then {_z = _relPos select 2} else {_z = 0};
		_newPos = [_posX + (_newRelPos select 0), _posY + (_newRelPos select 1), _z];
		_newObj = _type createVehicle _newPos;
		_newObj setDir (_azi + _azimuth);
		//_newObj setVehiclePosition [_newPos, [], 0, "CAN_COLLIDE"];
		_newObj setPos _newPos;
		sleep 0.01;
		_newObj setPos _newPos;

		_newObj setDir (_azi + _azimuth);

		//Follow the slope with small props (wire, sandbags, crates, barriers), as Eden does. Placed upright on a slope,
		//one end went into the ground and the other stuck up in the air. Buildings, vehicles and tall objects stay upright.
		if (!(_newObj isKindOf "AllVehicles") && {(_newObj buildingPos -1) isEqualTo []}) then {
			private _bb = boundingBoxReal _newObj;
			if ((((_bb select 1) select 2) - ((_bb select 0) select 2)) < 3) then {
				_newObj setVectorUp (surfaceNormal (getPosATL _newObj));
			};
		};

		if (!isNil "_fuel") then {_newObj setFuel _fuel};
		if (!isNil "_damage") then {_newObj setDamage _damage};
		if (!isNil "_vehicleinit") then {["MCC_fnc_setVehicleInit", [[netID _newObj,_newObj], _vehicleinit], 0, false] call MCC_fnc_secRemote;};
		if (!isNil "_vehicleTarget") then {_target = _newObj};
		_made pushBack _newObj;

		//Add global var
		if !(_variable isEqualTo "") then {_newObj setVariable [_variable,true]};

		//Curator
		{_x addCuratorEditableObjects [[_newObj],true]} forEach allCurators;
};

if (count _made > 0) then {MCC_lastSpawn pushBack [_made select 0, _made select [1, (count _made) - 1]]};
publicVariable "MCC_lastSpawn";
if (!isNil "_target") then {_target};