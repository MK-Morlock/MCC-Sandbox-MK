//============================================================MCC_fnc_paradrop======================================================================================
// Create a HALO or regular parachute jump for the given unit
//Example:[pos,[_unit, unitID],halo,hight,jumperNumber] remoteExec ["MCC_fnc_paradrop", true, false];
// Params:
// 	pos: array, position.
//	,[unitID,_unit]: object and number, unit ID for the jump
//	halo:  boolean ,true - halo, false - parajump
//	hight:  number,jump hight
//  jumperNumber: number, jumper number if more then one is jumping inorder to spread them around
//=================================================================================================================================================================
private _unit = nil;
private _halo = false;
private _height = 0;
private _headgear = "";
private _uniform = "";
private _backpack = "";
private _backPackItems = [];
private _useUnitPos = false;
private _uniformItems = [];
private _parachute = objNull;
private _jumperNumber = 0;
private _chute = "";
private _packHolder = nil;
private _parachuteBag = false;
private _transition = false;

params ["_pos"];
_unit			= if (((_this select 1) select 0) == "") then {(_this select 1) select 1} else {objectFromNetId ((_this select 1) select 0)};
if (isNil "_unit") exitWIth {};
_halo			= _this select 2;
_height			= param [3,500,[0]];
_jumperNumber	= _this select 4;
_parachuteBag = param [5,true,[true]];
_useUnitPos 	= param [6,false,[false]]; //if true will ignor pos and height and will use the unit pos once outside a vehicle
_transition		= param [7,true,[false]]; //if true show transition

_packHolder 	= objNull;

if ( !(isPlayer _unit) && { (_unit == leader _unit) } ) then {
	_unit setDir ( random 360 );
};

//if (isnil "mcc_isparajuming") then {mcc_isparajuming = false};
if (!local _unit || _unit getVariable ["mcc_isparajuming", false]) exitWith {};

_unit setVariable ["mcc_isparajuming", true];

//----- Debug logging (only with MCC debug on; no effect on the jump): exit / chute / landing positions against the drop line
//MCC_dropLine on the unit = [line start (ASL-free 2D), line direction, kind] from MCC_fnc_realParadrop. Logged as
//"along" = metres past the line start along the flight direction (minus = before it), "side" = metres right of the line.
private _fnc_dropLog = {
	params ["_u", "_stage"];
	(_u getVariable ["MCC_dropLine", []]) params [["_a", []], ["_d", 0], ["_kind", -1]];
	if (_a isEqualTo []) exitWith {};
	private _p = getPosATL _u;
	private _rel = [(_p select 0) - (_a select 0), (_p select 1) - (_a select 1)];
	private _along = (_rel select 0) * (sin _d) + (_rel select 1) * (cos _d);
	private _side = (_rel select 0) * (cos _d) - (_rel select 1) * (sin _d);
	private _v = velocity (vehicle _u);
	private _vAlong = (_v select 0) * (sin _d) + (_v select 1) * (cos _d);
	private _vSide = (_v select 0) * (cos _d) - (_v select 1) * (sin _d);
	["DEBUG", "paradrop", "%1 %2 | %3 | along %4 m side %5 m | height %6 m | speed along %7 m/s, side %12 m/s, down %8 m/s | facing %9 (line %10) | t=%11",
		[["PARA", "PODS", "HALO"] param [_kind, "?"], _stage, name _u, round _along, round _side, round (_p select 2),
		 round _vAlong, round (-(_v select 2)), round (getDir (vehicle _u)), round _d, round (time * 10) / 10, round _vSide]] call MCC_fnc_log;
};


//If is player make some effects
if (isPlayer _unit && _transition) then {
	cutText ["Get Ready to jump","BLACK OUT",1];
	sleep 2;
	playmusic "ac130";
};

if (_halo) then {
		//HALO
		private _haloLoadout = if (isPlayer _unit) then {getUnitLoadout _unit} else {[]};
		_headgear = headgear _unit; 		//Remove uniforms and add HALO gear
		_uniform = uniform _unit;
		_uniformItems = uniformItems _unit;

		_backpack = backpack _unit;
		_backPackItems = backPackItems _unit;

		removeHeadgear _unit;
		removeUniform _unit;
		removeBackpack _unit;

		_unit addHeadgear "H_CrewHelmetHeli_B";
		_unit forceAddUniform  "U_B_HeliPilotCoveralls";

		if ( isPlayer _unit ) then
		{
			if (_backpack != "") then
			{
				_packHolder = createVehicle ["groundWeaponHolder", [0,0,0], [], 0, "can_collide"]; //create an empty holder
				_packHolder addBackpackCargo [_backpack, 1]; //place your old backpack into the empty holder
				_packHolder attachTo [_unit,[0.1,0.56,-.72],"pelvis"]; //attach empty holder to unit
				_packHolder setVectorDirAndUp [[0,1,0],[0,0,-1]]; //set the vector and direction of the empty holder
			};

			_unit addBackpack "B_Parachute";
		};

		//wait until outside
		waitUntil {vehicle _unit == _unit};
		[_unit, "exit"] call _fnc_dropLog;
		if (isNil {_unit getVariable "MCC_dropDeathEH"}) then {
			_unit setVariable ["MCC_dropDeathEH", _unit addEventHandler ["Killed", {
				params ["_u", "_k"];
				private _t0 = _u getVariable ["MCC_dropExitT", -1];
				if (_t0 < 0 || {time - _t0 > 180}) exitWith {};
				["WARN", "paradrop", "%1 died during the drop, %2 s after leaving the aircraft | height %3 m | %4 | speed %5 m/s | killer %6", [name _u, round (time - _t0), round ((getPosATL _u) select 2), if (vehicle _u != _u) then {format ["in %1", typeOf (vehicle _u)]} else {"not in a parachute"}, round (vectorMagnitude (velocity _u)), if (isNull _k || {_k == _u}) then {"none (impact or fall)"} else {name _k}]] call MCC_fnc_log;
			}]];
		};
		_unit setVariable ["MCC_dropExitT", time];

		//if use unit pos
		if (_useUnitPos) then {
			_pos =position _unit;
			_height = _pos select 2;
		};

		_unit setpos [(_pos select 0) + (_jumperNumber*20), _pos select 1,_height];
		[_unit, "after setPos"] call _fnc_dropLog;

		sleep 2;

		if ( isPlayer _unit ) then {
			cutText ["","BLACK IN",1];
			playmusic "";

			while { alive _unit && (vehicle _unit == _unit) } do {playmusic "mcc_wind"; sleep 4.6};

			//Opening Chute
			if (_backpack != "") then
			{
				_packHolder = nearestObject [getPos _unit, "GroundWeaponHolder"];
				_packHolder attachTo [vehicle _unit,[0.1,0.72,0.52]]; //attach the empty holder to the new position (the parachute has no "pelvis" point)
				_packHolder setVectorDirAndUp [[0,0.1,1],[0,1,0.1]]; //set the new vector direction
			};
		} else {
			_dir = direction (leader _unit);
			private _w = wind;
			private _windDir = if ((vectorMagnitude [_w select 0, _w select 1, 0]) > 0.3) then {(((_w select 0) atan2 (_w select 1)) + 180) mod 360} else {_dir};
			private _v0 = velocity _unit;
			if (!(_unit getVariable ["MCC_haloFollower", false]) && {(vectorMagnitude [_v0 select 0, _v0 select 1, 0]) > 5}) then {
				_unit setDir (((_v0 select 0) atan2 (_v0 select 1) + 360) mod 360);
				_unit setVelocity _v0;
			};
			_unit disableAI "ANIM";
			_unit switchMove "HaloFreeFall_non";
			waitUntil {sleep 1; !(alive _unit) || {((getPosATL _unit) select 2) < 2000}};
			if (alive _unit) then {[_unit, "at 2000 m"] call _fnc_dropLog};
			//A little before the chute: animation control back on (as ROS does), then the non-steerable chute is created in
			//the air where he is ("FLY") and he is put in it - no turning of the jumper or the canopy, nothing touched after.
			private _ros = _unit getVariable ["MCC_haloFormationChute", false];
			private _chuteAlt = [180, 120 + random 50] select _ros;
			waitUntil {sleep 0.5; !(alive _unit) || {((getPosATL _unit) select 2) < ([_chuteAlt + 50, 300] select _ros)}};
			waitUntil {sleep 0.1; !(alive _unit) || {isNull (attachedTo _unit)}};
			_unit enableAI "ANIM"; _unit enableAI "MOVE"; _unit enableAI "PATH"; _unit enableAI "FSM";
			_chuteAlt = _unit getVariable ["MCC_haloChuteAlt", _chuteAlt];
			waitUntil {sleep 0.1; !(alive _unit) || {((getPosATL _unit) select 2) < _chuteAlt}};
			if (alive _unit) then {
				private _fv = velocity _unit;
				private _cp = getPosATL _unit;
				_parachute = createVehicle ["NonSteerable_Parachute_F", _cp, [], 0, "CAN_COLLIDE"];
				_parachute setPosATL _cp;
				_unit moveInDriver _parachute;
				_parachute setVelocity (_fv vectorMultiply 0.5);
				if (!isNil {_unit getVariable "MCC_haloChuteDir"}) then {
					private _cv = velocity _parachute;
					_parachute setDir (_unit getVariable "MCC_haloChuteDir");
					_parachute setVelocity _cv;
					_unit setVariable ["MCC_haloChuteDir", nil, true];
				};
			};
			[_unit, "chute open"] call _fnc_dropLog;
		};

		while {alive _unit && (((getpos _unit) select 2)> 1) && !isTouchingGround _unit} do {sleep 1};
		[_unit, "landed"] call _fnc_dropLog;
		if (!isPlayer _unit) then {unassignVehicle _unit; [_unit, _parachute] spawn MCC_fnc_paraOffRoof}; if (!isPlayer _unit && {side group _unit != ([east, west, independent, civilian] param [getNumber (configFile >> "CfgVehicles" >> typeOf _unit >> "side"), civilian])}) then {["WARN", "paradrop", "%1 landed with his group on side %2 (his own side %3; captive %4, rating %5)", [name _unit, side group _unit, [east, west, independent, civilian] param [getNumber (configFile >> "CfgVehicles" >> typeOf _unit >> "side"), civilian], captive _unit, rating _unit]] call MCC_fnc_log};
		if (!isPlayer _unit) then {_unit enableAI "MOVE"; _unit enableAI "PATH"; _unit enableAI "FSM"};

		if !(alive _unit) exitwith {};

		if ( isPlayer _unit ) then
		{
			if (!isNil "_packHolder" && {!isNull _packHolder}) then {detach _packHolder; deleteVehicle _packHolder};
			{if (typeOf _x == "GroundWeaponHolder") then {detach _x; deleteVehicle _x}} forEach attachedObjects _unit;
			if (count _haloLoadout > 0) then {
				private _now = getUnitLoadout _unit;
				{_now set [_x, _haloLoadout select _x]} forEach [3, 5, 6];
				_unit setUnitLoadout _now;
			};
			[_unit] spawn {
				params ["_u"];
				sleep 4;
				{if (count crew _x == 0) then {deleteVehicle _x}} forEach (nearestObjects [_u, ["ParachuteBase"], 25]);
			};
		}
		else
		{
			//AI: own uniform and its items back (they went to the player before), and the backpack back on with its load
			if (_headgear != "") then { removeHeadgear _unit; _unit addHeadgear _headgear };
			if (_uniform != "") then { removeUniform _unit; _unit forceAddUniform  _uniform };

			{
				switch (true) do
				{
					case (isClass (configFile >> "CfgMagazines" >> _x)) : {_unit addMagazine _x};
					case (isClass (configFile >> "CfgWeapons" >> _x)) : {_unit addItem _x};
					case (isClass (configFile >> "CfgGlasses" >> _x)) : {_unit addItem _x};
				};
			} foreach _uniformItems;

			if (_backpack != "") then {
				removeBackpack _unit;
				_unit addBackpack _backpack;
				clearAllItemsFromBackpack _unit;
				{_unit addItemToBackpack _x} forEach _backPackItems;
			} else {
				if (backpack _unit == "B_Parachute") then {removeBackpack _unit};
			};

			_unit setBehaviour "AWARE";
		};
} else {

	//Parachute
	private _shay = !isPlayer _unit && {missionNamespace getVariable ["MCC_paraShayChute", true]};
	private _po = _unit getVariable ["MCC_paraOpen", [0, 0]];
	private _manual = (_po select 0) == 1;
	private _plBag = backpack _unit;
	private _plLoadout = [];
	if (isPlayer _unit || {missionNamespace getVariable ["MCC_paraAIEngineChute", false]}) then {
		if (_plBag != "B_Parachute") then {
			_plLoadout = getUnitLoadout _unit;
			removeBackpack _unit;
			_unit addBackpack "B_Parachute";
		};
	};
	//wait until outside
	waitUntil {vehicle _unit == _unit};
	_unit allowDamage false;
	private _lowDrop = ((getPosATL _unit) select 2) < 62;
	if ((missionNamespace getVariable ["MCC_debug", false]) && {isNil {_unit getVariable "MCC_goEH"}}) then {
		_unit setVariable ["MCC_goEH", _unit addEventHandler ["GetOutMan", {
			params ["_u", "_role", "_veh"];
			["DEBUG", "getout", "GETOUT %1 got out of %2 (%3) at %4 m | attached to the chute: %5 | attached to him: %6 | chest pack switch %7", [name _u, typeOf _veh, _role, round ((getPosATL _u) select 2), (attachedObjects _veh) apply {typeOf _x}, (attachedObjects _u) apply {typeOf _x}, missionNamespace getVariable ["MCC_paraChestPack", true]]] call MCC_fnc_log;
		}]];
	};
	[_unit, "exit"] call _fnc_dropLog;
	if (isNil {_unit getVariable "MCC_dropDeathEH"}) then {
		_unit setVariable ["MCC_dropDeathEH", _unit addEventHandler ["Killed", {
			params ["_u", "_k"];
			private _t0 = _u getVariable ["MCC_dropExitT", -1];
			if (_t0 < 0 || {time - _t0 > 180}) exitWith {};
			["WARN", "paradrop", "%1 died during the drop, %2 s after leaving the aircraft | height %3 m | %4 | speed %5 m/s | killer %6", [name _u, round (time - _t0), round ((getPosATL _u) select 2), if (vehicle _u != _u) then {format ["in %1", typeOf (vehicle _u)]} else {"not in a parachute"}, round (vectorMagnitude (velocity _u)), if (isNull _k || {_k == _u}) then {"none (impact or fall)"} else {name _k}]] call MCC_fnc_log;
		}]];
	};
	_unit setVariable ["MCC_dropExitT", time];

	//if use unit pos
	if (_useUnitPos) then {
		_pos =position _unit;
		_height = _pos select 2;
	};

	_unit setpos [(_pos select 0) + (_jumperNumber*20), _pos select 1,_height];

	if (!_lowDrop) then {sleep 2};

	_dir = direction (leader _unit);

	_unit allowDamage (!_shay);
	_backpack = if (_plBag != "B_Parachute") then {_plBag} else {""};

	if (_backpack != "" && {missionNamespace getVariable ["MCC_paraChestPack", true]}) then {
		_packHolder = createVehicle ["groundWeaponHolder", [0,0,0], [], 0, "can_collide"]; //create an empty holder
		_packHolder addBackpackCargo [_backpack, 1]; //place your old backpack into the empty holder
		_packHolder attachTo [_unit,[0.1,0.56,-.72],"pelvis"]; //attach empty holder to unit
		_packHolder setVectorDirAndUp [[0,1,0],[0,0,-1]]; //set the vector and direction of the empty holder
	};

	if !(isPlayer _unit) then {
		private _aiOpen = if (_manual) then {if ((_po select 1) < 0) then {99999} else {(_po select 1) + random 30}} else {110 + random 30};
		waitUntil { (((getPosATL _unit) select 2) < _aiOpen) || !(alive _unit) };
		_chute = "NonSteerable_Parachute_F";

		_dir = direction (leader _unit);
		_unit setDir _dir;
	} else {
		cutText ["","BLACK IN",1];
		playmusic "";
		_chute = "Steerable_Parachute_F";

		0 spawn {
			while {!isTouchingGround player} do {
				playmusic "mcc_wind";
				sleep 4.4;
			};
		};

		if (_manual) then {
			waitUntil {sleep 0.1; !alive _unit || {vehicle _unit != _unit} || {isTouchingGround _unit} || {((getPosATL _unit) select 2) < 1}};
		} else {
			waitUntil {sleep 0.1; !alive _unit || {vehicle _unit != _unit} || {((getPosATL _unit) select 2) < 100}};
		};
		if (vehicle _unit != _unit) then {_parachute = vehicle _unit};
	};


	private _v = velocity _unit;
	private _hDir = if (vectorMagnitude [_v select 0, _v select 1, 0] > 1) then {((_v select 0) atan2 (_v select 1) + 360) mod 360} else {getDir _unit};
	private _cp = getPosATL _unit;
	if (backpack _unit == "B_Parachute" && {isNull _parachute} && {!(isPlayer _unit && {_manual})} && {isPlayer _unit || {missionNamespace getVariable ["MCC_paraAIEngineChute", false]}}) then {
		_unit setDir _hDir;
		_unit action ["OpenParachute", _unit];
		private _tw = time + 1.5;
		waitUntil {sleep 0.05; vehicle _unit != _unit || {time > _tw}};
		_parachute = vehicle _unit;
		if (_parachute == _unit) then {["WARN", "paradrop", "%1: Arma's parachute did not open - scripted chute instead", [name _unit]] call MCC_fnc_log};
	};
	if ((isNull _parachute || {_parachute == _unit}) && {!(isPlayer _unit && {_manual})} && {alive _unit}) then {
		private _wv = wind;
		private _cDir = ((if ((vectorMagnitude [_wv select 0, _wv select 1, 0]) > 0.3) then {(_wv select 0) atan2 (_wv select 1)} else {_hDir}) + 345 + (random 30)) mod 360;
		private _pre = [animationState _unit, lifeState _unit, round (vectorMagnitude (velocity _unit)), vehicle _unit == _unit, assignedVehicleRole _unit];
		if (_shay) then {
			_parachute = createVehicle [_chute, [-5000, -5000, 0], [], ((_dir)-3+(random 6)), 'NONE'];
			_parachute setDir _cDir;
			_parachute setPos (getPos _unit);
			_unit moveindriver _parachute;
		} else {
			isNil {
				_parachute = createVehicle [_chute, _cp vectorAdd [0, 0, 5000], [], 0, "CAN_COLLIDE"];
				_parachute setDir _cDir;
				private _vn = velocity _unit;
				_parachute setPosATL (getPosATL _unit);
				_unit assignAsDriver _parachute;
				_unit moveInDriver _parachute;
				_parachute setVelocity [(_vn select 0) * 0.25, (_vn select 1) * 0.25, ((_vn select 2) * 0.3) max -6];
			};
		};
		if (missionNamespace getVariable ["MCC_debug", false]) then {
			[_unit, _parachute, _pre] spawn {
				params ["_u", "_c", "_pre"];
				private _t0 = time;
				["DEBUG", "paradrop", "MOVEIN %1 | before: anim %2, life %3, speed %4 m/s, on foot %5, role %6 | right after: in chute %7, anim %8 | chest pack switch %9, holder on him: %10", [name _u, _pre select 0, _pre select 1, _pre select 2, _pre select 3, _pre select 4, vehicle _u == _c, animationState _u, missionNamespace getVariable ["MCC_paraChestPack", true], (attachedObjects _u) apply {typeOf _x}]] call MCC_fnc_log;
				{
					sleep _x;
					["DEBUG", "paradrop", "MOVEIN %1 +%2 s | in chute %3 | anim %4 | life %5 | assigned %6 | chute locked %7 | chute alive %8", [name _u, round ((time - _t0) * 10) / 10, vehicle _u == _c, animationState _u, lifeState _u, (assignedVehicle _u) isEqualTo _c, locked _c, alive _c]] call MCC_fnc_log;
				} forEach [0.1, 0.1, 0.1, 0.2, 0.2, 0.3];
			};
		};
	};
	if (!isPlayer _unit && {!_shay} && {!isNull _parachute} && {_parachute != _unit}) then {
		[_unit] orderGetIn true;
		[_unit] allowGetIn true;
		(group _unit) addVehicle _parachute;
		_parachute lock true;
		[_unit, _parachute] spawn {
			params ["_u", "_c"];
			waitUntil {sleep 0.2; !alive _u || {isNull _c} || {vehicle _u != _c} || {((getPosATL _u) select 2) < 15}};
			if (!isNull _c) then {_c lock false};
		};
	};
	[_unit, "chute open"] call _fnc_dropLog;
	if (missionNamespace getVariable ["MCC_debug", false]) then {
		[_unit, _parachute] spawn {
			params ["_u", "_c"];
			private _t0 = time;
			private _last = getDir _c;
			private _fnc_tilt = {if (isNull _this) then {-1} else {round (acos ((((vectorUp _this) vectorDotProduct [0, 0, 1]) max -1) min 1))}};
			while {time - _t0 < 12} do {
				sleep 0.5;
				if (!alive _u) exitWith {};
				if (vehicle _u != _c) exitWith {
					["DEBUG", "paradrop", "CHUTE %1 left the chute %2 s after it opened | height %3 m | chute tilt %4 deg | chute %5 | still assigned to it: %6", [name _u, round ((time - _t0) * 10) / 10, round ((getPosATL _u) select 2), _c call _fnc_tilt, if (isNull _c) then {"deleted"} else {["destroyed", "intact"] select (alive _c)}, (assignedVehicle _u) isEqualTo _c]] call MCC_fnc_log;
				};
				private _turn = ((((getDir _c) - _last) + 540) mod 360) - 180;
				_last = getDir _c;
				["DEBUG", "paradrop", "CHUTE %1 +%2 s | tilt %3 deg | turning %4 deg/s | height %5 m | sinking %6 m/s", [name _u, round ((time - _t0) * 10) / 10, _c call _fnc_tilt, round (_turn * 2), round ((getPosATL _u) select 2), round (-((velocity _c) select 2))]] call MCC_fnc_log;
			};
		};
	};
	if (isPlayer _unit) then {
		[_unit, _parachute] spawn {
			params ["_u", "_c"];
			private _last = getDir _c;
			while {alive _u && {vehicle _u == _c}} do {
				private _v = velocity _c;
				private _track = ((_v select 0) atan2 (_v select 1) + 360) mod 360;
				private _turn = (((getDir _c) - _last + 540) mod 360) - 180;
				_last = getDir _c;
				["INFO", "paradrop", "%1 chute: heading %2, turned %3 deg in 2 s (+ = right), moving towards %4 at %5 m/s, sinking %6 m/s, height %7 m, attached %8", [name _u, round getDir _c, round _turn, round _track, round (vectorMagnitude [_v select 0, _v select 1, 0]), round (-(_v select 2)), round ((getPosATL _c) select 2), (attachedObjects _c) apply {typeOf _x}]] call MCC_fnc_log;
				sleep 2;
			};
		};
	};
	_unit allowDamage true;

	if (!alive _unit) exitWith {};

	//Opening Chute
	if (!isnil "_packHolder") then {
		_packHolder attachTo [vehicle _unit,[0.1,0.72,0.52]]; //attach the empty holder to the new position (the parachute has no "pelvis" point)
		_packHolder setVectorDirAndUp [[0,0.1,1],[0,1,0.1]]; //set the new vector direction
	};

	while { (alive _unit) && (((getpos _unit) select 2)> 1) && !(isTouchingGround _unit) } do {sleep 1};
	[_unit, "landed"] call _fnc_dropLog;
	if (!isPlayer _unit) then {if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "getout", "MOVEOUT by landing (unassign) | %1 from %2 at %3 m", [name _unit, typeOf (vehicle _unit), round ((getPosATL _unit) select 2)]] call MCC_fnc_log}; unassignVehicle _unit; if (!isNull _parachute && {_parachute != _unit}) then {(group _unit) leaveVehicle _parachute}; [_unit, _parachute] spawn MCC_fnc_paraOffRoof};
	if (!isNil {_unit getVariable "MCC_goEH"}) then {_unit removeEventHandler ["GetOutMan", _unit getVariable "MCC_goEH"]; _unit setVariable ["MCC_goEH", nil]}; if (!isPlayer _unit && {side group _unit != ([east, west, independent, civilian] param [getNumber (configFile >> "CfgVehicles" >> typeOf _unit >> "side"), civilian])}) then {["WARN", "paradrop", "%1 landed with his group on side %2 (his own side %3; captive %4, rating %5)", [name _unit, side group _unit, [east, west, independent, civilian] param [getNumber (configFile >> "CfgVehicles" >> typeOf _unit >> "side"), civilian], captive _unit, rating _unit]] call MCC_fnc_log};

	//The backpack shown on the parachute is only a copy (the unit keeps its real backpack): remove it for everyone on
	//landing - it was only removed for players, so AI left backpacks hanging in the air / lying on the ground - and also
	//when the jumper died on the way down
	if (!isnil "_packHolder") then {
		detach _packHolder;
		deleteVehicle _packHolder;
	};
	if (count _plLoadout > 0) then {
		private _now = getUnitLoadout _unit;
		_now set [5, _plLoadout select 5];
		_unit setUnitLoadout _now;
	};
	if (!alive _unit) exitwith {};

	if (isPlayer _unit) then {

		//Spawn bag near the drop
		if (_parachuteBag) then {
			_parachute = "B_Parachute" createVehicle (getpos _unit);
			sleep 0.3;
			_parachute setPos (getpos _unit);
		};
	} else {
		_unit setBehaviour "AWARE";
	};
};

_unit setVariable ["mcc_isparajuming", false];