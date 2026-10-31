//========================================================MCC_fnc_airDrop ======================================================================================================
//  Parameter(s):
//     	0: _ammount - 	integer
//     	1: spawnkind: 	ARRAY of STRING  - CAS type class "Gun-run (Direct)","Rockets-run (Direct)","CAS-run (Direct)","Bombs-run (Direct)","S&D","Rockets-run","AT run","AA run","JDAM","LGB","Bombing-run","Cruise Missile","AC-130","UAV","Controllable"
//		2: _pos:		POSITION - cas target pos
//		3: _planeType:	STRING plane vehicle class for CAS or "west","east","guer","civ","logic" for airdrop
//		4: _spawn		POSITION: plane spawn pos
//		5: _away		POSITION: plane despawn pos
//		6: _isParachute	INTEGER: <optional> 0 - parachute from helicopter. 1 - if it is slingload.  2 - parachute from thin air 3 - spawn crew
//		CAS Script by Shay_gman 08.01.12
//==============================================================================================================================================================================

private _spawnkind = "";
private _pos = [];
private _spawn = [];
private _away = [];
private _pilot1 = objNull;
private _pilotGroup1 = grpNull;
private _wp = [];
private _plane1 = [];
private _planepos = [];
private _missile = "";
private _planeType = "";
private _lasertargets = objNull;
private _nukeType = "";
private _nul = [];
private _x = 0;
private _wp = [];
private _isParachute = 0;
private _planeClasss = "";
private _isHeliDLC = configNull;
private _object = objNull;
private _sling = false;
#define mcc_playerConsole_IDD 2993

params ["_ammount"];
_spawnkind				= _this select 1 select 0;
_pos					= _this select 2;
_planeType				= _this select 3 select 0;
_spawn					= _this select 4;
_away					= _this select 5;
_isParachute			= param [6,0,[0]];

//=====================================================

//start the drop
//If it's an airdrop
if (tolower _planeType in ["west","east","guer","civ","logic"]) then  {

	//If parachute from thin air exit here:
	if (_isParachute >= 2) exitWith {
		_pos = [_pos select 0,_pos select 1, (_pos select 2) + 300];
		for [{_x=0},{_x < count _spawnkind},{_x=_x+1}] do {
			_pos = [_pos, [_pos,_away] call BIS_fnc_dirTo,20] call BIS_fnc_relPos;
			[_pos, _spawnkind select _x, objNull,_isParachute == 3] spawn MCC_fnc_CreateAmmoDrop;
			sleep (3 + random 3);
		};
	};

	//Lets Spawn a plane
	_isHeliDLC = isClass (configFile >> "CfgPatches" >> "A3_Air_F_Heli_Heli_Transport_03");
	_planeClasss = [_planeType] call MCCMK_fnc_supplyAutoHeli;
	private _chosenAir = missionNamespace getVariable ["MCCMK_adAircraft", ""];
	if (_chosenAir != "" && {isClass (configFile >> "CfgVehicles" >> _chosenAir)}) then {_planeClasss = _chosenAir};
	private _isPlaneAir = _planeClasss isKindOf "Plane";
	if (_isPlaneAir && {_isParachute == 1}) then {_isParachute = 0};
	["DEBUG", "supplyDrop", "aircraft %1 (%2) | %3 | %4 item(s)", [_planeClasss, ["automatic", "chosen in the panel"] select (_planeClasss == _chosenAir), ["parachute", "slingload"] select (_isParachute == 1), count _spawnkind]] call MCC_fnc_log;

	private _flyH = missionNamespace getVariable [["MCCMK_adHeightHeli", "MCCMK_adHeightPlane"] select _isPlaneAir, 75];
	private _smokeOn = missionNamespace getVariable [["MCCMK_adSmokeHeli", "MCCMK_adSmokePlane"] select _isPlaneAir, true];
	private _smokeVeh = missionNamespace getVariable [["MCCMK_adSmokeHeliVeh", "MCCMK_adSmokePlaneVeh"] select _isPlaneAir, true];
	if (isNil "MCCMK_dropAir") then {MCCMK_dropAir = []};
	MCCMK_dropAir = MCCMK_dropAir select {alive _x && {!(_x getVariable ["MCCMK_dropDone", false])}};
	private _dropPos = +_pos;
	private _near = MCCMK_dropAir select {((_x getVariable ["MCCMK_dropTgt", [0, 0, 0]]) distance2D _dropPos) < 1000};
	private _inDir = _pos getDir _spawn;
	if (_isParachute == 1) then {
		private _nSling = {_x getVariable ["MCCMK_dropSling", false]} count _near;
		_pos = _pos getPos [25 * _nSling, _inDir + 180];
		_spawn = _pos getPos [2500, _inDir];
		["DEBUG", "supplyDrop", "%1 other sling load(s) inbound to this area: set-down moved %2 m along the line", [_nSling, 25 * _nSling]] call MCC_fnc_log;
	} else {
		private _step = [500, 1000] select _isPlaneAir;
		_spawn = _pos getPos [5000 + _step * (count _near), _inDir];
		["DEBUG", "supplyDrop", "%1 other supply aircraft inbound to this area: spawning %2 m out", [count _near, round (_pos distance2D _spawn)]] call MCC_fnc_log;
	};
	_plane1 			= [_planeClasss, _spawn, _pos, _flyH, true] call MCC_fnc_createPlane;		//Spawn plane 1
	_pilotGroup1		= group _plane1;
	MCCMK_dropAir pushBack _plane1;
	_plane1 setVariable ["MCCMK_dropTgt", _dropPos];
	_plane1 setVariable ["MCCMK_dropSling", _isParachute == 1];
	_pilot1				= driver _plane1;
	_pilotGroup1 setVariable ["MCC_dropFor", switch (toLower _planeType) do {case "east": {east}; case "guer": {resistance}; case "civ": {civilian}; default {west}}, true];
	if (_isPlaneAir) then {
		_plane1 setVelocityModelSpace [0, ((getNumber (configFile >> "CfgVehicles" >> _planeClasss >> "maxSpeed")) * 0.6 max 250) / 3.6, 0];
	};

	if (tolower _planeType == "east" && !_isHeliDLC && {_planeClasss == "I_Heli_Transport_02_F"}) then
	{
		_plane1 setObjectTextureGlobal [0,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
		_plane1 setObjectTextureGlobal [1,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
		_plane1 setObjectTextureGlobal [2,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
	};

	if (tolower _planeType == "west" && !_isHeliDLC && {_planeClasss == "I_Heli_Transport_02_F"}) then
	{
		_plane1 setObjectTextureGlobal [0,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
		_plane1 setObjectTextureGlobal [1,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
		_plane1 setObjectTextureGlobal [2,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
	};

	//Attach slingload
	if (_isParachute == 1) then {
		_object = (_spawnkind select 0) createvehicle [10,10,500];
		_object setpos (_plane1 modeltoworld [0,0,-15]);
		_sling = _plane1 setSlingload _object;

		_wp = (group _plane1) addWaypoint [[_pos select 0, _pos select 1, 0], 0];	//Add WP
		_wp setWaypointType "MOVE";
		_wp setWaypointStatements ["true", ""];
		_wp setWaypointSpeed "FULL";
		_wp setWaypointCombatMode "BLUE";
		_wp setWaypointCompletionRadius 50;
		_plane1 flyInHeight _flyH;
		sleep 2;

		waitUntil {_plane1 distance2d _pos < 150 || (!alive _plane1)};

		if (!alive _plane1) exitWith {};

		//workaround for some reason after vhicle is slingloaded it can't be driven
		_object spawn {
			private _object = objNull;
			_this allowDamage false;

			waituntil {((isNull attachedTo _this) && ((getpos _this) select 2) < 2) || isTouchingGround _this};

			_this allowDamage true;
			/*
			_pos = getpos _this;
			_dir = getdir _this;
			_class = typeof _this;
			deleteVehicle _this;
			waituntil {isNull _this};
			_object = _class createvehicle _pos;
			_object setDir _dir;
			{_x addCuratorEditableObjects [[_object],false]} forEach allCurators;
			*/
		};

		//Start precise landing
		_pos = (AGLToASL _pos) vectorAdd [0,0,15];
		[_plane1, _pos] call MCC_fnc_heliPreciseLanding;

		_plane1 setSlingLoad objNull;
		_plane1 setVariable ["MCCMK_dropDone", true];

		//Delete the plane when finished
		_plane1 setVariable ["MCC_exitFull", true];
		[_plane1, _flyH, true] spawn MCC_fnc_haloPlaneExit;

	} else {
		private _gap = missionNamespace getVariable ["MCC_supplyDropGap", 1.5];
		private _tgt = [_pos select 0, _pos select 1, 0];
		private _lineDir = _spawn getDir _tgt;
		if (_isPlaneAir) then {
			private _lead = _tgt getPos [2750, _lineDir + 180];
			private _wpLead = (group _plane1) addWaypoint [[_lead select 0, _lead select 1, 0], 0];
			_wpLead setWaypointType "MOVE";
			_wpLead setWaypointSpeed "FULL";
			_wpLead setWaypointCombatMode "BLUE";
			_wpLead setWaypointCompletionRadius 50;
		};
		_wp = (group _plane1) addWaypoint [_tgt, 0];
		_wp setWaypointType "MOVE";
		_wp setWaypointStatements ["true", ""];
		_wp setWaypointSpeed "FULL";
		_wp setWaypointCombatMode "BLUE";
		_wp setWaypointCompletionRadius 30;
		private _wpOut = (group _plane1) addWaypoint [[_away select 0, _away select 1, 0], 0];
		_wpOut setWaypointType "MOVE";
		_wpOut setWaypointSpeed "FULL";
		_wpOut setWaypointCombatMode "BLUE";
		_wpOut setWaypointCompletionRadius 300;
		_plane1 flyInHeight _flyH;
		if (_isPlaneAir) then {
			[_plane1, _tgt, _lineDir] spawn {
				params ["_pl", "_tg", "_ld"];
				private _fw = [sin _ld, cos _ld, 0];
				private _rt = [cos _ld, -(sin _ld), 0];
				while {alive _pl && {!(_pl getVariable ["MCCMK_dropDone", false])}} do {
					private _o = (getPosASL _pl) vectorDiff (AGLToASL _tg);
					private _along = _o vectorDotProduct _fw;
					if (_along > 300) exitWith {};
					if (_along > -2500) then {
						private _v = velocity _pl;
						private _want = ((-(_o vectorDotProduct _rt)) * 0.12) max -8 min 8;
						private _dv = ((_want - (_v vectorDotProduct _rt)) max -0.6) min 0.6;
						_pl setVelocity (_v vectorAdd (_rt vectorMultiply _dv));
					};
					sleep 0.1;
				};
			};
		};
		private _hasBay = isClass (configFile >> "CfgVehicles" >> _planeClasss >> "VehicleTransport" >> "Carrier");
		private _loads = [];
		private _maxKg = getNumber (configFile >> "CfgVehicles" >> _planeClasss >> "VehicleTransport" >> "Carrier" >> "maxLoadMass");
		private _usedKg = 0;
		private _left = [];
		{
			private _cl = _x;
			private _veh = objNull;
			private _skip = "";
			if (_hasBay) then {
				private _kg = [_cl] call MCCMK_fnc_classMass;
				if (_maxKg > 0 && {(_usedKg + _kg) > _maxKg}) then {_skip = "too heavy"} else {
					if (_cl isKindOf "AllVehicles") then {
						_veh = createVehicle [_cl, [10, 10, 0], [], 0, "CAN_COLLIDE"];
						if (_plane1 setVehicleCargo _veh) then {
							["DEBUG", "supplyDrop", "%1 loaded into %2 (vehicle in vehicle)", [_cl, _planeClasss]] call MCC_fnc_log;
						} else {
							deleteVehicle _veh;
							_veh = objNull;
							_skip = "bay full";
						};
					};
					if (_skip == "") then {_usedKg = _usedKg + _kg};
				};
			};
			if (_skip == "") then {_loads pushBack [_cl, _veh]} else {
				["DEBUG", "supplyDrop", "%1 left out of %2: %3 (%4 of %5 kg loaded)", [_cl, _planeClasss, _skip, round _usedKg, _maxKg]] call MCC_fnc_log;
				_left pushBack format ["%1 (%2)", getText (configFile >> "CfgVehicles" >> _cl >> "displayName"), _skip];
			};
		} forEach _spawnkind;
		if (count _left > 0) then {
			hint format ["Left out of the %1 drop:\n%2", getText (configFile >> "CfgVehicles" >> _planeClasss >> "displayName"), _left joinString "\n"];
		};
		private _bayLate = missionNamespace getVariable ["MCCMK_bayPushback", 30];
		waitUntil {sleep 0.5; ((_plane1 distance2D _tgt) < ([600, 2000] select _isPlaneAir)) || (!alive _plane1)};
		if (!alive _plane1) exitWith {};
		[_plane1, true] call MCCMK_fnc_aircraftRamp;
		private _tOpen = time;
		waitUntil {
			sleep 0.1;
			private _ph = (_plane1 getVariable ["MCCMK_rampParts", []]) apply {
				_x params ["_kind", "_nm"];
				switch (_kind) do {case "anim": {_plane1 animationPhase _nm}; case "door": {_plane1 doorPhase _nm}; default {_plane1 animationSourcePhase _nm}}
			};
			private _moving = _ph select {_x > 0.02};
			!alive _plane1 || {time > _tOpen + 10} || {count _ph == 0} || {count _moving > 0 && {(_moving findIf {_x < 0.95}) < 0}} || {count _moving == 0 && {time > _tOpen + 2}}
		};
		if (!alive _plane1) exitWith {};
		private _n = count _loads;
		private _tDrop = time + 90;
		for "_k" from 0 to (_n - 1) do {
			(_loads select _k) params ["_cl", "_veh"];
			private _isVeh = (!isNull _veh) || {_cl isKindOf "AllVehicles"};
			private _slot = -_k * _gap;
			private _sp = 0;
			private _h = 0;
			private _carry = 0;
			waitUntil {
				sleep 0.05;
				private _v = velocity _plane1;
				private _vh = [_v select 0, _v select 1, 0];
				_sp = vectorMagnitude _vh;
				private _p = getPosASL _plane1;
				_h = (_p select 2) - (getTerrainHeightASL _tgt);
				_carry = if (!isNull _veh) then {-_bayLate} else {0};
				private _ahead = if (_sp > 1) then {([_tgt select 0, _tgt select 1, 0] vectorDiff [_p select 0, _p select 1, 0]) vectorDotProduct (vectorNormalized _vh)} else {0};
				!alive _plane1 || {time > _tDrop} || {_ahead <= (_slot * _sp) + _carry}
			};
			if (!alive _plane1) exitWith {};
			_planepos = getpos _plane1;
			private _info = [_tgt, _lineDir, _carry, _sp, _h];
			if (missionNamespace getVariable ["MCC_debug", false]) then {
				private _f = [sin _lineDir, cos _lineDir, 0];
				private _o = [(_planepos select 0) - (_tgt select 0), (_planepos select 1) - (_tgt select 1), 0];
				["DEBUG", "supplyDrop", "item %1 of %2 (%3, %4) released | along %5 m, side %6 m from the target | height %7 m | speed %8 km/h | heading %9 deg off the line | carry allowed %10 m", [_k + 1, _n, _cl, ["crate", ["vehicle", "vehicle from the bay"] select (!isNull _veh)] select _isVeh, round (_o vectorDotProduct _f), round (_o vectorDotProduct [_f select 1, -(_f select 0), 0]), round _h, round (speed _plane1), round ((((getDir _plane1) - _lineDir) + 540) mod 360 - 180), round _carry]] call MCC_fnc_log;
			};
			if (!isNull _veh) then {
				objNull setVehicleCargo _veh;
				[_veh, _smokeVeh, _info] spawn {
					params ["_veh", "_smk", "_info"];
					private _t = time + 180;
					sleep 3;
					waitUntil {sleep 0.2; !alive _veh || {time > _t} || {((getPos _veh) select 2) < 4}};
					if (!alive _veh) exitWith {};
					if (_smk) then {"SmokeShellGreen" createVehicle (getPos _veh)};
					_info params ["_tgt", "_dir", "_carry", "_sp", "_h"];
					private _o = (getPos _veh) vectorDiff [_tgt select 0, _tgt select 1, (getPos _veh) select 2];
					["DEBUG", "supplyDrop", "%1 landed | along %2 m, side %3 m from the target | released at %4 km/h, %5 m above the target | carry allowed %6 m", [typeOf _veh, round (_o vectorDotProduct [sin _dir, cos _dir, 0]), round (_o vectorDotProduct [cos _dir, -(sin _dir), 0]), round (_sp * 3.6), round _h, round _carry]] call MCC_fnc_log;
				};
			} else {[_planepos, _cl, _pilot1, false, false, [_smokeOn, _smokeVeh] select _isVeh, _info] spawn MCC_fnc_CreateAmmoDrop};
		};
		_plane1 setVariable ["MCCMK_dropDone", true];
		sleep 2;
		[_plane1, false] call MCCMK_fnc_aircraftRamp;
		_plane1 setVariable ["MCC_exitFull", true];
		[_plane1, _flyH, true] spawn MCC_fnc_haloPlaneExit;
	}
} else {
	//Case CAS

	//cruise missile
	if (tolower _spawnkind == "cruise missile") exitWith {
		while {dialog} do {closeDialog 0};
		//disable mouse control at start
		MCC_ConsoleUAVMouseButtonDown = false;

		//Arma's own cruise missile (the destroyer VLS missile: heavy warhead, explodes on impact); the GBU-12 bomb used
		//before was created in mid-air and pushed at 80 m/s, and did very little damage. GBU-12 if the class is missing.
		private _cmClass = ["Bo_GBU12_LGB", "ammo_Missile_Cruise_01"] select (isClass (configFile >> "CfgAmmo" >> "ammo_Missile_Cruise_01"));
		_missile = _cmClass createVehicle [_pos select 0, _pos select 1, 600];
		waituntil {alive _missile};
		missionNamespace setVariable ["MCC_ConolseUAV",_missile];

		//The feed opens in the view mode last chosen for it (MCC_fnc_feedVision; Regular the first time)
		missionNamespace setVariable ["MCC_ConsoleUAVCameraMod", profileNamespace getVariable ["MCC_feedVision_uav", 0]];
		//Cruise mode for the console: chase camera behind the missile, mouse does not move the aim
		MCC_consoleCruise = true;
		//Fixed aim point at the target: the missile used to home on the console's aim sphere, which the mouse moves
		private _cmAim = "Land_HelipadEmpty_F" createVehicle [_pos select 0, _pos select 1, 0];
		[_missile, _cmAim] spawn {
			params ["_m", "_aim"];
			waitUntil {sleep 0.5; !alive _m};
			deleteMarkerLocal (missionNamespace getVariable ["MCCMK_cruiseMarker", ""]);
			sleep 3;
			deleteVehicle _aim;
			MCC_consoleCruise = false;
		};

		createDialog ("MCC_playerConsole2" call MCC_fnc_dialogName);
		waitUntil {!isNull (missionNamespace getVariable ["MCC_fakeUAV",objNull]) && !isNull (missionNamespace getVariable ["MCC_fakeUAVCenter",objNull])};

		playSound "missileLunch";
		[[netid _missile,_missile], "missileLunch"] remoteExec ["MCC_fnc_globalSay3D", 0, false];
		//Start 2 - 5 km away, low (about 120 m), and fly in, from the direction of the line drawn on the map (it comes
		//from where the line starts, like a ship off the coast or a VLS site); a random direction only without a line
		private _cmDir = if (_spawn isEqualType [] && {count _spawn >= 2} && {(_pos distance2D _spawn) > 50}) then {_pos getDir _spawn} else {random 360};
		private _cmStart = _pos getPos [2000 + random 3000, _cmDir];
		_cmStart set [2, 120];
		[_cmAim, _cmStart, _missile,250,true,"",true] execVM MCC_path + "mcc\general_scripts\CAS\missile_guide.sqf";
	};

	//ac-130
	if (tolower _spawnkind == "ac-130") exitWith {
		//AC-130

		//If we pressed the AC 130 when we have one retired the last one.
		if (alive(missionNamespace getVariable ["MCC_ACConsoleUp",objNull])) then {
			private _uav = (missionNamespace getVariable ["MCC_ACConsoleUp",objNull]);
			_uav setVariable ["MCC_supportDone", true, true];
			[group driver _uav, driver _uav, _uav, _away] call MCC_fnc_deletePlane;
			missionNamespace setVariable ["MCC_ACConsoleUp",objNull];
			publicVariable "MCC_ACConsoleUp";

			[_uav, "leave", "Gunship", "Left the scene", format ["%1data\AC130_icon.paa", MCC_path], playerSide] call MCC_fnc_supportNotice;
		} else {

			[objNull, "", "Gunship", "Entered the scene", format ["%1data\AC130_icon.paa", MCC_path], playerSide] call MCC_fnc_supportNotice;

			_pos set [2,(_pos select 2)+400];

			//register AC-130
			//==================================
			_planeType = "B_T_VTOL_01_armed_F";
			_side = if (missionNamespace getVariable ["MCC_cruiseFromCommander", false]) then {side group player} else {call MCC_fnc_evacSide};
			_uav = [_planeType, _spawn, _pos, 400, false,_side] call MCC_fnc_createPlane;
			if ((side group driver _uav) != _side) then {
				private _old = group driver _uav;
				(crew _uav) joinSilent (createGroup _side);
				deleteGroup _old;
			};
			[_uav, [["Olive", "Blue"] select (_side isEqualTo west), 1], true] call BIS_fnc_initVehicle;
			_uav setVariable ["MCC_acSide", _side];
			[_uav, crew _uav] spawn {
				params ["_v", "_crew"];
				waitUntil {sleep 2; isNull _v || {!alive _v} || {(_crew findIf {alive _x && {vehicle _x == _x}}) >= 0}};
				{
					[_x] spawn {
						params ["_u"];
						waitUntil {sleep 1; isNull _u || {vehicle _u == _u && {isTouchingGround _u || {((getPosATL _u) select 2) < 1}}}};
						sleep 10;
						if (!isNull _u && {!isPlayer _u}) then {
							private _g = group _u;
							deleteVehicle _u;
							if (!isNull _g && {count (units _g) == 0}) then {deleteGroup _g};
						};
					};
				} forEach _crew;
			};
			MCC_consoleACgunReady1 = true;
			MCC_consoleACgunReady2 = true;
			MCC_consoleACgunReady3 = true;
			MCC_acAmmoType40 = 0;
			_uav addEventHandler ["HandleDamage", {
				params ["_v", "_sel", "_dmg", "_src", "_proj", "", "_inst", "_hp"];
				if (_dmg > 0.1 && {!isNull _src} && {!(_src isEqualTo _v)}) then {
					private _kv = if (_src isKindOf "CAManBase") then {_src} else {vehicle _src};
					private _n = getText (configFile >> "CfgVehicles" >> (typeOf _kv) >> "displayName");
					if (_n == "") then {_n = typeOf _kv};
					_v setVariable ["MCC_lastHit", [format ["%1 (%2)", _n, side group _src], time]];
				};
				if (missionNamespace getVariable ["MCC_debug", false] && {_dmg > 0.1} && {time > (_v getVariable ["MCC_dmgLogT", 0])}) then {
					_v setVariable ["MCC_dmgLogT", time + 0.5];
					["DEBUG", "support", "gunship damage: %1 (%2) %3 | source %4 | projectile %5 | instigator %6 | altitude %7", [_sel, _hp, _dmg toFixed 2, typeOf _src, _proj, typeOf _inst, round ((getPosATL _v) select 2)]] call MCC_fnc_log;
				};
				_dmg
			}];
			if (missionNamespace getVariable ["MCC_debug", false]) then {
				{
					_x addEventHandler ["Killed", {
						params ["_u", "_k", "_i"];
						["DEBUG", "support", "gunship crew member died: %1 | killer %2 | instigator %3 | vehicle damage %4", [typeOf _u, typeOf _k, typeOf _i, damage (vehicle _u)]] call MCC_fnc_log;
					}];
				} forEach (crew _uav);
			};
			_uav addEventHandler ["Killed", {
				params ["_v", "_k"];
				private _last = _v getVariable ["MCC_lastHit", []];
				private _by = if (isNull _k || {_k == _v}) then {if (count _last > 0 && {time - (_last select 1) < 120}) then {format ["%1, crashed after the hit", _last select 0]} else {"no recorded attacker (crash or impact)"}} else {
					private _kv = if (_k isKindOf "CAManBase") then {_k} else {vehicle _k};
					private _n = getText (configFile >> "CfgVehicles" >> (typeOf _kv) >> "displayName");
					if (_n == "") then {_n = typeOf _kv};
					format ["%1 (%2)", _n, side group _k]
				};
				private _s = _v getVariable ["MCC_acSide", west];
				["AC-130 destroyed", 5, format ["by %1", _by]] remoteExec ["MCC_fnc_consoleBanner", _s];
				["DEBUG", "support", "AC-130 destroyed by %1", [_by]] call MCC_fnc_log;
				missionNamespace setVariable ["MCC_ACConsoleUp", objNull];
				publicVariable "MCC_ACConsoleUp";
				[_v] spawn {
					params ["_v"];
					sleep 2;
					{private _g = group _x; deleteVehicle _x; if (count (units _g) == 0) then {deleteGroup _g}} forEach ((crew _v) select {!isPlayer _x});
				};
			}];
			{_uav setMagazineTurretAmmo [_x select 0, _x select 1, _x select 2]} forEach [["100Rnd_105mm_HEAT_MP", 12, [1]], ["4000Rnd_20mm_Tracer_Red_shells", 800, [1]], ["240Rnd_40mm_GPR_Tracer_Red_shells", 50, [2]], ["160Rnd_40mm_APFSDS_Tracer_Red_shells", 30, [2]]];

			_grp = group driver _uav;
			_grp setCombatMode "BLUE";
			_grp setBehaviour "CARELESS";

			_wp = _grp addWaypoint [_pos, 0];
			_wp setWaypointType "LOITER";
			_wp setWaypointLoiterType "CIRCLE_L";
			_wp setWaypointSpeed "LIMITED";
			_wp setWaypointLoiterRadius 1200;


			missionNamespace setVariable ["MCC_ACConsoleUp",_uav];
			missionNamespace setVariable ["MCC_consoleACpos",_pos];
			[_uav, _pos, _side] spawn {
				params ["_uav", "_pos", "_side"];
				private _t = time + 120;
				waitUntil {sleep 1; !alive _uav || {(_uav distance2D _pos) < 1500} || {time > _t}};
				missionNameSpace setVariable ["MCC_ConsoleACTimeStart", time];
				publicVariable "MCC_ConsoleACTimeStart";
				["DEBUG", "support", "Gunship on station: its %1 s start now", [(missionNamespace getVariable ["MCC_ConsoleACTime", 360]) max 60]] call MCC_fnc_log;
			[_uav, (missionNamespace getVariable ["MCC_ConsoleACTime", 360]) max 60, "Gunship", _side, format ["%1data\AC130_icon.paa", MCC_path],
				{({((_x select 0) in ["100Rnd_105mm_HEAT_MP", "4000Rnd_20mm_Tracer_Red_shells", "240Rnd_40mm_GPR_Tracer_Red_shells", "160Rnd_40mm_APFSDS_Tracer_Red_shells"]) && {(_x select 2) > 0}} count (magazinesAllTurrets _this)) == 0},
				{missionNamespace setVariable ["MCC_ACConsoleUp", objNull]; publicVariable "MCC_ACConsoleUp"}] call MCC_fnc_supportTimer;
			};
			publicVariable "MCC_ACConsoleUp";
			publicVariable "MCC_consoleACpos";

			//Make controlabel
			_grp setvariable ["MCC_canbecontrolled",true,true];


			//Fire some flares
			_uav spawn {
				while {alive _this} do {
					_plane = _this;
					( driver _plane) forceweaponfire ["CMFlareLauncher","burst"];
					sleep (30 + (random 30));
				};
			};
		};
	};

	private _uavArmed = tolower _spawnkind == "uav armed";
	if (_uavArmed) then {_spawnkind = "controllable"};

	//UAV
	if (tolower _spawnkind in ["uav","controllable"]) exitWith {
		//UAV

		[_pos,_planeType,360,_spawnkind,_spawn,_uavArmed] spawn {
			private _uav = [];
			private _grp = grpNull;
			private _wp = [];
			private _side = configNull;
			params ["_pos","_planeType","_time","_spawnkind","_spawn",["_uavArmed", false]];

			_pos set [2,(_pos select 2)+500];
			_side =  (getNumber (configFile >> "CfgVehicles" >> _planeType >> "side")) call BIS_fnc_sideType;
			_uav = [_planeType, _spawn, _pos, 500, false,_side] call MCC_fnc_createPlane;

			_grp = group driver _uav;
			_grp setCombatMode "BLUE";
			_grp setBehaviour "CARELESS";
			_grp setSpeedMode "LIMITED";

			_wp = _grp addWaypoint [_pos, 0];
			_wp setWaypointType "LOITER";
			_wp setWaypointLoiterType "CIRCLE_L";
			_wp setWaypointSpeed "LIMITED";
			_wp setWaypointLoiterRadius 1000;

			//Make controlabel
			_grp setvariable ["MCC_canbecontrolled",true,true];
			_grp setvariable ["MCC_canbecontrolledUAV",true,true];
			_uav setVehicleLock "LOCKED";

			//Spawn detection
			if (_spawnkind == "uav") then {
				[_uav,_time + 120] spawn MCC_fnc_uavDetect;
			};
			[_uav, _pos, _time, _side, _uavArmed] spawn {
				params ["_uav", "_pos", "_time", "_side", "_uavArmed"];
				private _t = time + 120;
				waitUntil {sleep 1; !alive _uav || {(_uav distance2D _pos) < 1500} || {time > _t}};
			[_uav, _time, "UAV", _side, "\A3\ui_f\data\map\markers\nato\b_uav.paa",
				if (_uavArmed) then {{({(_x select 2) > 0 && {((toLower (_x select 0)) find "laser") < 0} && {((toLower (_x select 0)) find "flare") < 0} && {((toLower (_x select 0)) find "chaff") < 0}} count (magazinesAllTurrets _this)) == 0}} else {{false}}] call MCC_fnc_supportTimer;
			};
		};
	};

	if (_spawnkind in ["Gun-run (Direct)","Rockets-run (Direct)","CAS-run (Direct)","Bombs-run (Direct)"]) then {


		private _casType =   switch (_spawnkind) do
								{
									case "Gun-run (Direct)": {0};
									case "Rockets-run (Direct)":{1};
									case "CAS-run (Direct)":{2};
									case "Bombs-run (Direct)":{3};
		};

		_dir = [_spawn, _pos] call BIS_fnc_dirTo;
		[_planeType, _casType, _dir, _pos] remoteExec ["MCC_fnc_cas",2];

	} else {
		private _dir = [];
		private _dis = 0;
		private _alt = 0;
		private _pitch = 0;
		private _speed = 0;
		private _duration = 0;
		private _planePos = [];
		private _planeSide = sideUnknown;
		private _planeArray = [];
		private _vectorDir = [];
		private _velocity = [];
		private _vectorUp = [];
		private _planeCfg = configNull;
		private _time = 0;
		if (_spawnkind in ["JDAM", "LGB", "Bombing-run", "Rockets-run", "AT run", "AA run"] && {!(_spawnkind in ([_planeType] call MCC_fnc_casAllowedTypes))}) then {
			if (isNil "MCCMK_casSwap") then {MCCMK_casSwap = createHashMap};
			private _oc = configFile >> "CfgVehicles" >> _planeType;
			private _fac = getText (_oc >> "faction");
			private _key = format ["ai|%1|%2", _fac, _spawnkind];
			private _new = MCCMK_casSwap getOrDefault [_key, ""];
			if (_new == "") then {
				private _cands = ((("getNumber (_x >> 'scope') == 2 && {getText (_x >> 'faction') == '" + _fac + "'}") configClasses (configFile >> "CfgVehicles")) apply {configName _x}) select {(_x isKindOf "Plane" || {_x isKindOf "Helicopter"}) && {_spawnkind in ([_x] call MCC_fnc_casAllowedTypes)}};
				_new = ((_cands select {_x isKindOf "Plane"}) + _cands) param [0, ""];
				if (_new == "") then {_new = switch ((getNumber (_oc >> "side")) call BIS_fnc_sideType) do {case east: {"O_Plane_CAS_02_F"}; case resistance: {"I_Plane_Fighter_03_CAS_F"}; default {"B_Plane_CAS_01_F"}}};
				MCCMK_casSwap set [_key, _new];
			};
			["DEBUG", "cas", "%1 cannot fly %2 with its own weapons: %3 flies it instead", [_planeType, _spawnkind, _new]] call MCC_fnc_log;
			_planeType = _new;
		};
		_planeCfg = configfile >> "cfgvehicles" >> _planeType;
		_pos set [2,(_pos select 2) + getterrainheightasl _pos];
		_dir =[_spawn, _pos] call BIS_fnc_dirTo;
		_dis =  2500;
		_alt = 600;
		_pitch = atan (_alt / _dis);
		_speed = 400 / 3.6;
		_duration = ([0,0] distance [_dis,_alt]) / _speed;

		//--- Create plane
		_planePos = [_pos,_dis,_dir + 180] call bis_fnc_relpos;
		_planePos set [2,(_pos select 2) + _alt];
		_planeSide = (getnumber (_planeCfg >> "side")) call bis_fnc_sideType;
		_planeArray = [_planePos,_dir,_planeType,_planeSide] call MCC_fnc_spawnVehicle;
		_plane1 = _planeArray select 0;
		_plane1 setposasl _planePos;
		_pilotGroup1 = group _plane1;
		_pilot1		= driver _plane1;

		//--- Play radio
		[_plane1,"CuratorModuleCAS"] call bis_fnc_curatorSayMessage;

		//Set WP behaviour for flat bombing
		if (_spawnkind in ["S&D", "AA run"]) then	{

			_wp = _pilotGroup1 addWaypoint [[_pos select 0, _pos select 1, 0], 0];	//Add WP
			_wp setWaypointStatements ["true", ""];
			_wp setWaypointSpeed "FULL";
			_wp setWaypointCompletionRadius 100;

			_plane1 setcombatmode "RED";
			_wp setWaypointType "SAD";
			_wp setWaypointCombatMode "RED";

		}	else	{

			_plane1 move ([_pos,_dis,_dir] call bis_fnc_relpos);
			_plane1 disableai "move";
			_plane1 disableai "target";
			_plane1 disableai "autotarget";
			_plane1 setcombatmode "blue";


			_vectorDir = [_planePos,_pos] call bis_fnc_vectorFromXtoY;
			_velocity = [_vectorDir,_speed] call bis_fnc_vectorMultiply;
			_plane1 setvectordir _vectorDir;
			[_plane1,-90 + atan (_dis / _alt),0] call bis_fnc_setpitchbank;
			_vectorUp = vectorup _plane1;

			[_plane1,_planePos,_pos,_velocity,_vectorDir,_vectorUp,_duration] spawn {

				params ["_plane1","_planePos","_pos","_velocity","_vectorDir","_vectorUp","_duration"];
				_time = time;
				private _gain = if (_plane1 isKindOf "helicopter") then {40} else {0};
				waituntil {
					//--- Set the plane approach vector
					_plane1 setVelocityTransformation [
						_planePos, [_pos select 0,_pos select 1,(_pos select 2) + 20 + _gain],
						_velocity, _velocity,
						_vectorDir,_vectorDir,
						_vectorUp, _vectorUp,
						(time - _time) / _duration
					];
					_plane1 setvelocity velocity _plane1;

					(_plane1 getVariable ["MCC_casDone",false]) || !(canMove _plane1) || ((position _plane1) select 2) < 100;
				};
			};
		};

		switch (_spawnkind) do
		{
			case "S&D":	//Seek and Destroy
			{
				 waitUntil {((_plane1 distance2D _pos) < 1500) || (!alive _plane1)};
				_pilotGroup1 setSpeedMode "FULL";
				_pilotGroup1 setCombatMode "RED";
				_pilotGroup1 setBehaviour "COMBAT";
				_plane1 enableAI "AUTOTARGET";
				sleep 120;
			};

			case "JDAM":	//JDAM Bomb
			{
				private _gp = [_pos select 0, _pos select 1, 0];
				private _lt = createVehicle [(["LaserTargetE", "LaserTargetW"] select (((side _plane1) getFriend west) > 0.6)), _gp, [], 0, "CAN_COLLIDE"];
				[_plane1, _gp] call MCC_fnc_casReleaseWait;
				[_plane1, "bomb", [_lt], 1, 0.5] call MCC_fnc_casRealFire;
				[_lt] spawn {sleep 60; deleteVehicle (_this select 0)};
			};

			case "LGB":    //LGB
			{
				waitUntil {((_plane1 distance2D _pos) < 1500) || (!alive _plane1)};
				private _lt = (nearestObjects [_pos, ["LaserTarget"], 1000]) param [0, objNull];
				private _own = isNull _lt;
				if (_own) then {_lt = createVehicle [(["LaserTargetE", "LaserTargetW"] select (((side _plane1) getFriend west) > 0.6)), [_pos select 0, _pos select 1, 0], [], 0, "CAN_COLLIDE"]};
				[_plane1, getPosATL _lt] call MCC_fnc_casReleaseWait;
				[_plane1, "bomb", [_lt], 1, 0.5] call MCC_fnc_casRealFire;
				if (_own) then {[_lt] spawn {sleep 60; deleteVehicle (_this select 0)}};
			};

			case "Bombing-run":	//Bombing run
			{
				[_plane1, [_pos select 0, _pos select 1, 0]] call MCC_fnc_casReleaseWait;
				[_plane1, [_pos select 0, _pos select 1, 0], 15, 4 + (_ammount * 0.5)] call MCC_fnc_casGuideArm;
				[_plane1, "bomb", [], _ammount * 2, 0.25] call MCC_fnc_casRealFire;
			};

			case "Rockets-run":	//Rockets run
			{
				waitUntil {((_plane1 distance2D _pos) < 1200) || (!alive _plane1)};
				if (!alive _plane1) exitWith {};
				if !([_plane1, "rocket", [], _ammount * 2, 0.15] call MCC_fnc_casRealFire) then {
					private _lt = createVehicle [(["LaserTargetE", "LaserTargetW"] select (((side _plane1) getFriend west) > 0.6)), [_pos select 0, _pos select 1, 0], [], 0, "CAN_COLLIDE"];
					[_plane1, "agm", [_lt], _ammount * 2, 0.6] call MCC_fnc_casRealFire;
					[_lt] spawn {sleep 60; deleteVehicle (_this select 0)};
				};
				sleep 1;
			};

			case "AT run":	//SnD Armor
			{
				waitUntil {((_plane1 distance2D _pos) < 2000) || (!canMove _plane1)};
				_targets = (nearestObjects [[_pos select 0,_pos select 1,0] ,["Car","Tank"],200]) select {alive _x && {[side _x, side _plane1] call BIS_fnc_sideIsEnemy}};
				_targets resize ((count _targets) min (_ammount + 1));
				if (count _targets > 0) then {[_plane1, "agm", _targets, (count _targets) * 2, 0.8] call MCC_fnc_casRealFire} else {["DEBUG", "cas", "AT run: no enemy vehicles within 200 m of the target", []] call MCC_fnc_log};
			};

			case "AA run":	//SnD Air
			{
				waitUntil {((_plane1 distance2D _pos) < 4000) || (!canMove _plane1)};
				_pilotGroup1 setCombatMode "RED";
				_pilotGroup1 setBehaviour "COMBAT";
				_plane1 enableAI "TARGET";
				_plane1 enableAI "AUTOTARGET";
				private _end = time + 180;
				private _shots = 0;
				while {alive _plane1 && {time < _end} && {_shots < ((_ammount + 1) * 2)}} do {
					private _air = ((getSensorTargets _plane1) select {((_x select 1) == "air") && {(_x select 2) == "enemy"} && {alive (_x select 0)}}) apply {_x select 0};
					if (count _air > 0) then {
						private _tg = _air select 0;
						{if ((_x distance _plane1) < (_tg distance _plane1)) then {_tg = _x}} forEach _air;
						if ([_plane1, "aam", [_tg], 1, 0.5] call MCC_fnc_casRealFire) then {_shots = _shots + 1} else {_end = 0};
					};
					sleep 3;
				};
			};

			case "CBU-97(ACE)":	//MCC_fnc_CBU-97
			{
				_plane1 flyInHeight 150;
				_plane1 addWeapon "ACE_CBU97_Bomblauncher";
				for [{_i=1},{_i<=_ammount},{_i=_i+1}] do
					{
						_plane1 addMagazine "ACE_CBU97";
					};
				_planepos = getpos _plane1;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 150]) < 700) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do
					{
						_plane1 Fire ["ACE_CBU97_Bomblauncher"];
						sleep 1;
					};
			};

			case "CBU-87(ACE)":	//MCC_fnc_CBU-AP
			{
				_plane1 addWeapon "ACE_CBU87_Bomblauncher";
				for [{_i=1},{_i<=_ammount},{_i=_i+1}] do
					{
						_plane1 addMagazine "ACE_CBU87";
					};
				_planepos = getpos _plane1;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 100]) < 800) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do
					{
						_plane1 Fire ["ACE_CBU87_Bomblauncher"];
						sleep 1;
					};
			};

			case "BLU-107(ACE)":	//BLU-107
			{
				_plane1 flyInHeight 200;
				_plane1 addWeapon "ACE_BLU107_Bomblauncher";
				for [{_i=1},{_i<=_ammount},{_i=_i+1}] do
					{
						_plane1 addMagazine "ACE_BLU107";
					};
				_planepos = getpos _plane1;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 150]) < 800) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do
					{
						_plane1 Fire ["ACE_BLU107_Bomblauncher"];
						sleep 0.5;
					};
			};

			case "SADARM":	//MCC_fnc_SADARM
			{
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 200) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do
					{
						_planepos = getpos _plane1;
						[_planepos, _pilot1] spawn MCC_fnc_SADARM;
						sleep (0.5 + random 0.5);
					};
			};

			case "CBU-Mines":	//MCC_fnc_CBU-Mines
			{
				CBU_type = MCC_CBU_MINES;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 200) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do
					{
						_planepos = getpos _plane1;
						_bomb = "CruiseMissile2" createvehicle [_planepos select 0,_planepos select 1,3000]; 	//make the bomb
						_bomb setpos [_planepos select 0,_planepos select 1,(_planepos select 2) -10];
						_bomb setdir getdir _plane1;
						_bomb setVelocity [((velocity vehicle _pilot1) select 0)/2, ((velocity vehicle _pilot1) select 1)/2,((velocity vehicle _pilot1) select 2)];
						[_bomb, CBU_type] spawn MCC_fnc_CBU;
						sleep (0.5 + random 0.5);
					};
			};

			case "CBU-WP(ACE)":	//MCC_fnc_CBU-Mines
			{
				CBU_type = MCC_CBU_WP;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 200) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do
					{
						_planepos = getpos _plane1;
						_bomb = "CruiseMissile2" createvehicle [_planepos select 0,_planepos select 1,3000]; 	//make the bomb
						_bomb setpos [_planepos select 0,_planepos select 1,(_planepos select 2) -10];
						_bomb setdir getdir _plane1;
						_bomb setVelocity [((velocity vehicle _pilot1) select 0)/2, ((velocity vehicle _pilot1) select 1)/2,((velocity vehicle _pilot1) select 2)];
						[_bomb, CBU_type] spawn MCC_fnc_CBU;
						sleep (0.5 + random 0.5);
					};
			};

			case "CBU-CS(ACE)":	//MCC_fnc_CBU-Mines
			{
				CBU_type = MCC_CBU_CS;
				waitUntil {((_plane1 distance [_pos select 0, _pos select 1, 200]) < 200) || (!alive _plane1)};
				//Make the drop
				for [{_x=1},{_x<=_ammount},{_x=_x+1}] do
					{
						_planepos = getpos _plane1;
						_bomb = "CruiseMissile2" createvehicle [_planepos select 0,_planepos select 1,3000]; 	//make the bomb
						_bomb setpos [_planepos select 0,_planepos select 1,(_planepos select 2) -10];
						_bomb setdir getdir _plane1;
						_bomb setVelocity [((velocity vehicle _pilot1) select 0)/2, ((velocity vehicle _pilot1) select 1)/2,((velocity vehicle _pilot1) select 2)];
						[_bomb, CBU_type] spawn MCC_fnc_CBU;
						sleep (0.5 + random 0.5);
					};
			};

			case "Tactical MCC_NUKE(0.3k)":	//Tactical MCC_NUKE(0.3k)
			{
				_nukeType = "ACE_B61_03";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE;
			};

			case "Tactical MCC_NUKE(1.5k)":	//Tactical MCC_NUKE(1.5k)
			{
				_nukeType = "ACE_B61_15";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE;
			};

			case "Tactical MCC_NUKE(5.0k)":	//"Tactical MCC_NUKE(5.0k)"
			{
				_nukeType = "ACE_B61_50";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE;
			};

			case "Air Burst(0.3k)":	//Tactical MCC_NUKE(0.3k) MCC_NUKE_AIR
			{
				_nukeType = "ACE_B61_03";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE_AIR;
			};

			case "Air Burst(1.5k)":	//Tactical MCC_NUKE(1.5k) MCC_NUKE_AIR
			{
				_nukeType = "ACE_B61_15";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE_AIR;
			};

			case "Air Burst(5.0k)":	//Tactical MCC_NUKE(5.0k) MCC_NUKE_AIR
			{
				_nukeType = "ACE_B61_50";
				[_plane1, _pos, _nukeType] spawn MCC_NUKE_AIR;
			}
		};

		_plane1 enableAI "move";
		_plane1 setVariable ["MCC_casDone",true];
		//Delete the plane when finished
		sleep 1;

		//Fire some flares exiting the area
		{
			_fire = [_x,[["CMFlareLauncher","burst"]]] spawn
			{
				_plane = _this select 0;
				_planeDriver = driver _plane;
				_weapons = _this select 1;
				_duration = 5;
				_time = time + _duration;
				waituntil
				{
					{
						_planeDriver forceweaponfire _x;
					} foreach _weapons;
					sleep 0.5;
					time > _time || isnull _plane
				};
			};
		} foreach [_plane1];

		[_pilotGroup1, _pilot1, _plane1, _away] call MCC_fnc_deletePlane;
		//[_pilotGroup2, _pilot2, _plane2, _away] call MCC_fnc_deletePlane;
	};
};

