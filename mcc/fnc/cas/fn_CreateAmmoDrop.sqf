/*==========================================================MCC_fnc_CreateAmmoDrop===============================================================================================
// drop an object from a plane and attach paracute to it, thanks to BIS
// Example:[_planepos, _spawnkind, _pilot] spawn MCC_fnc_CreateAmmoDrop;
// _planepos = position,  plane position
// _spawnkind = string, vehiclecClass to drop
// _pilot = plane's pilot
*/

private _pilot = objNull;
private _para = objNull;
private _drop = objNull;
private _time = 0;
private _smoke = "";
private _class = "";
private _paras = [];
private _objectData = [];
private _velocity = [];
private _spawnCrew = false;
params ["_pos", "_spawnkind"];
_pilot = param [2,objNull,[missionNamespace,objNull]];
_spawnCrew = param [3,false,[false]];
private _keepVel = param [4, false, [false]];
private _smokeOn = param [5, true, [false]];
private _info = param [6, [], [[]]];
private _given = _spawnkind isEqualType objNull;

_class = ["I_Parachute_02_F", "B_Parachute_02_F", "O_Parachute_02_F", "I_Parachute_02_F", "I_Parachute_02_F"] select (([sideUnknown, west, east, resistance, civilian] find (if (!isNull _pilot) then {side group _pilot} else {sideUnknown})) max 0);
if !(isClass (configFile >> "CfgVehicles" >> _class)) then {_class = "B_Parachute_02_F"};
_paras = [];

if (!_given && {!isnull _pilot}) then {while {(_pos distance vehicle _pilot) < 20} do {sleep 0.2}};

_drop = if (_given) then {_spawnkind} else {createVehicle [_spawnkind, _pos, [], 0, "CAN_COLLIDE"]};
if (_given) then {_spawnkind = typeOf _drop};
{_x addCuratorEditableObjects [[_drop],false]} forEach allCurators;

_objectData = (_drop call bis_fnc_objectType) select 1;

_para = createVehicle [_class, getpos _drop,[],0,"CAN_COLLIDE"];
_para attachTo [_drop, [0,0,0]];
_velocity = if (!isnull _pilot) then {velocity (vehicle _pilot)} else {[0, 0, 0]};
detach _para;

_para setVelocity _velocity;

if (_objectData in ["Ship","Submarine","TrackedAPC","Tank","WheeledAPC","Car"]) then {
	_drop attachto [_para,[0,0,-(abs ((boundingbox _drop select 0) select 2))]];
	_paras = [_para];
} else {
	private _bbP = boundingBoxReal _para;
	private _bbD = boundingBoxReal _drop;
	private _off = [
		-(((_bbD select 0) select 0) + ((_bbD select 1) select 0)) / 2,
		-(((_bbD select 0) select 1) + ((_bbD select 1) select 1)) / 2,
		((_bbP select 0) select 2) - ((_bbD select 0) select 2)
	];
	["DEBUG", "supplyDrop", "crate %1 under %2 | crate height %3 m | harness end %4 m | offset %5", [_spawnkind, _class, ((_bbD select 1) select 2) - ((_bbD select 0) select 2), (_bbP select 0) select 2, _off]] call MCC_fnc_log;
	_drop attachto [_para, _off];
	_paras =  [_para];
};

if (!_keepVel) then {_para setvelocity [0,0,-1]};

//spaw crew
if (_spawnCrew || isAutonomous _drop) then {
	createVehicleCrew _drop;
};

0 = [_drop, _paras, _smokeOn, _info] spawn
{
	private _veh = _this select 0;
	private _smokeOn = _this select 2;
	waitUntil {getPos _veh select 2 < 4};
	(_this select 3) params [["_tgt", []], ["_dir", 0], ["_carry", 0], ["_sp", 0], ["_h", 0]];
	if (count _tgt > 1) then {
		private _o = (getPos _veh) vectorDiff [_tgt select 0, _tgt select 1, (getPos _veh) select 2];
		["DEBUG", "supplyDrop", "%1 landed | along %2 m, side %3 m from the target | released at %4 km/h, %5 m above the target | carry allowed %6 m", [typeOf _veh, round (_o vectorDotProduct [sin _dir, cos _dir, 0]), round (_o vectorDotProduct [cos _dir, -(sin _dir), 0]), round (_sp * 3.6), round _h, round _carry]] call MCC_fnc_log;
	};
	_vel = velocity _veh;
	detach _veh;
	_veh setVelocity _vel;

	if (_smokeOn) then {playSound3D ["a3\sounds_f\weapons\Flare_Gun\flaregun_1_shoot.wss",_veh]};

	{
		detach _x;
		_x disableCollisionWith _veh;
	} count (_this select 1);

	if (_smokeOn) then {_smoke = "SmokeShellGreen" createVehicle (getpos _veh)};			//Mark the drop with smoke

	_time = time + 5;
	waitUntil {time > _time};
	{
		if (!isNull _x) then {deleteVehicle _x};
	} count (_this select 1);
};


