private _positions = [];
private _dir = 0;
private _isHalo = 0;
private _jumpReady = false;
private _unitPosition = [];
private _isCargo = false;
private _y = 0;
private _x = 0;
private _pos = [];
private _vehicle = nil;
private _time = 0;
private _light = nil;
private _pod = objNull;
params ["_plane", "_unit", "_unitNumber"];												//what is his jumper number
_isCargo	= false;

_positions 	= [[-0.5,-2.5,-2.23],[0.5,-2.5,-2.23],[-0.5,-1,-2.23],[0.5,-1,-2.23],[-0.5,0.5,-2.23],[0.5,0.5,-2.23],
				[-0.5,2,-2.23],[0.5,2,-2.23],[-0.5,3.5,-2.23],[0.5,3.5,-2.23],[-0.5,4.5,-2.23],[0.5,4.5,-2.23]];

//set the units looking the ramp
_dir			= 180;
_unitPosition 	= _positions select _unitNumber;

//correct hight for the new airplane
if (typeOf _plane == "B_T_VTOL_01_infantry_F") then {
	_unitPosition set [2,-5.7];
};

_isHalo			= _plane getvariable ["MCCisHALO",0];
_jumpReady		= _plane getvariable ["MCCjumpReady", false];

sleep .1;

if (isNull _unit) exitwith {};

if (!local _unit || !alive _plane) exitwith {};

if (isplayer _unit) then {
	titleText ["","BLACK FADED",5];
};

//Pod or plane
_pod = if (_isHalo ==1) then {_plane getVariable ["MCC_attachedPod",objnull]} else {_plane};

//put the unit in the vehicle
while {vehicle _unit != _pod &&
	   alive _pod &&
	   alive _unit &&
	   _pod emptyPositions "cargo" > 0
	  } do {
	if (vehicle _unit != _unit) then {unassignVehicle _unit};
	_unit assignAsCargo _pod ;
	_unit moveInCargo _pod ;
	sleep ([1, 0.25] select (isPlayer _unit));
};
_unit setVariable ["MCC_jumpTurn", false];
if (_isHalo != 1 && {!isPlayer _unit} && {vehicle _unit == _pod}) then {[_unit] orderGetIn true; [_unit] allowGetIn true};
if (_isHalo != 1 && {missionNamespace getVariable ["MCC_debug", false]} && {vehicle _unit == _pod}) then {
	_unit addEventHandler ["GetOutMan", {
		params ["_u", "", "_veh"];
		_u removeEventHandler ["GetOutMan", _thisEventHandler];
		if (_u getVariable ["MCC_jumpTurn", false]) exitWith {};
		private _ld = leader group _u;
		["WARN", "paradrop", "%1 left %2 before his jump | height %3 m | aircraft speed %4 km/h | his leader %5 is %6", [name _u, typeOf _veh, round ((getPosATL _veh) select 2), round (speed _veh), name _ld, if (vehicle _ld == _veh) then {"aboard"} else {"NOT aboard"}]] call MCC_fnc_log;
	}];
};


sleep ([5, 1] select (isPlayer _unit));
_unit setVariable ["MCC_dropLine", _plane getVariable ["MCC_dropLine", []]];	//(debug logging)
if (_isHalo != 1) then {[position _unit,["", _unit],_isHalo==2,(position _unit) select 2,0,false,true,false] spawn MCC_fnc_paradrop};

if (isplayer _unit) then {


	//Cinametic
	if !(missionNamespace getVariable ["MCC_dropCutscene", true]) exitWith {titleText ["","BLACK IN",1]};
	if (!alive _unit || !alive _plane) exitWith {};
	private _viewBefore = ["INTERNAL", "EXTERNAL"] select (cameraView == "EXTERNAL");
	["INFO", "paradrop", "cut-scene: %1 is in %2, view %3 (camera view %4)", [name _unit, typeOf (vehicle _unit), _viewBefore, cameraView]] call MCC_fnc_log;
	private _camera = "";
	private _relPos = [];
	private _relDir = 0;
	_camera = "Camera" camcreate getpos _unit;
	_camera cameraeffect ["internal","back"];
	_camera camPrepareFOV 0.900;
	_camera camsetTarget vehicle _unit;
	cameraEffectEnableHUD false;
	showCinemaBorder true;
	MCC_dropCutSkip = false;
	MCC_dropCutSkipEH = (findDisplay 46) displayAddEventHandler ["MouseButtonDown", {if ((_this select 1) == 0 && {!visibleMap}) then {MCC_dropCutSkip = true}}];

	private _d0 = getDirVisual _plane;
	private _sz = ((sizeOf typeOf _plane) max 10) min 60;
	private _hi = !(_plane isKindOf "Helicopter");
	MCC_paraCam = [_camera, _plane, _unit, time, (getPosASLVisual _plane) vectorAdd [(sin _d0) * 150, (cos _d0) * 150, [2, (_sz * 0.5) max 15] select _hi],
		[(_sz * 0.4) max 6, -((_sz * 2) max 30), [4, (_sz * 0.8) max 15] select _hi],
		_viewBefore];
	private _camEH = addMissionEventHandler ["EachFrame", {
		(missionNamespace getVariable ["MCC_paraCam", []]) params [["_c", objNull], ["_p", objNull], ["_u", objNull], ["_t0", 0], ["_start", [0,0,0]], ["_oB", [6,-30,8]], ["_view", "INTERNAL"]];
		if (isNull _c || {isNull _p} || {isNull _u}) exitWith {};
		private _t = time - _t0;
		private _ease = {params ["_x0", "_x1", "_f"]; private _k = (_f max 0) min 1; _k = _k * _k * (3 - 2 * _k); _x0 vectorAdd ((_x1 vectorDiff _x0) vectorMultiply _k)};
		private _ap = getPosASLVisual _p;
		if !(_p isKindOf "Helicopter") then {(boundingBoxReal _p) params ["_b1", "_b2"]; _ap = _p modelToWorldVisualWorld ((_b1 vectorAdd _b2) vectorMultiply 0.5)};
		private _d = getDirVisual _p;
		private _fw = [sin _d, cos _d, 0];
		private _rt = [cos _d, -(sin _d), 0];
		private _behind = _ap vectorAdd (_rt vectorMultiply (_oB select 0)) vectorAdd (_fw vectorMultiply (_oB select 1)) vectorAdd [0, 0, _oB select 2];
		private _endPos = [0,0,0];
		private _endLook = [0,0,0];
		if (_view == "EXTERNAL") then {
			private _veh = vehicle _u;
			private _ext = getArray (configFile >> "CfgVehicles" >> typeOf _veh >> "extCameraPosition");
			if (count _ext < 3) then {_ext = [0, 2, -20]};
			_endPos = _veh modelToWorldVisualWorld [_ext select 0, _ext select 2, _ext select 1];
			_endLook = _veh modelToWorldVisualWorld [0, 0, (_ext select 1) * 0.5];
		} else {
			private _hp = _u selectionPosition "head";
			_endPos = _u modelToWorldVisualWorld _hp;
			_endLook = _endPos vectorAdd ((getCameraViewDirection _u) vectorMultiply 10);
		};
		private _f = (((_t - 12) / 2.5) max 0) min 1;
		private _pos = switch (true) do {
			case (_t < 2): {_start};
			case (_t < 3): {[_start, _behind, _t - 2] call _ease};
			case (_t < 12): {_behind};
			default {[_behind, _endPos, _f] call _ease};
		};
		private _look = [_ap, _endLook, _f] call _ease;
		_c camSetPos (ASLToAGL _pos);
		_c camSetTarget (ASLToAGL _look);
		_c camSetFov (0.9 - 0.15 * (_f * _f * (3 - 2 * _f)));
		_c camCommit 0;
	}];
	titleText ["","BLACK IN",1];
	private _tEnd = time + 14.5;
	private _osd = false;
	private _pvW = (inputAction "personView") > 0;
	private _filmFP = false;
	waitUntil {
		sleep 0.05;
		if (!_osd && {time > _tEnd - 7.5}) then {_osd = true; [] call MCC_fnc_camp_showOSD};
		private _pvN = (inputAction "personView") > 0;
		if (_pvN && {!_pvW}) then {
			_filmFP = !_filmFP;
			if (_filmFP) then {_camera cameraEffect ["TERMINATE", "BACK"]; _unit switchCamera "INTERNAL"} else {_camera cameraEffect ["INTERNAL", "BACK"]};
		};
		_pvW = _pvN;
		time > _tEnd || {!alive _unit} || {!alive _plane} || {MCC_dropCutSkip}
	};
	if (_filmFP) then {_viewBefore = "INTERNAL"};
	removeMissionEventHandler ["EachFrame", _camEH];
	MCC_paraCam = [];
	if (vehicle _unit != _unit && {!MCC_dropCutSkip}) then {
		private _veh = vehicle _unit;
		private _ext = getArray (configFile >> "CfgVehicles" >> typeOf _veh >> "extCameraPosition");
		if (count _ext < 3) then {_ext = [0, 2, -20]};
		MCC_dropChaseFP = (_viewBefore == "INTERNAL");
		if (MCC_dropChaseFP) then {_camera cameraEffect ["TERMINATE", "BACK"]; _unit switchCamera "INTERNAL"};
		MCC_dropChase = [_camera, _veh, 0, 0, _ext, 0, 0, 1, 1];
				["INFO", "paradrop", "chase view on %1 (%2)", [typeOf _veh, name _unit]] call MCC_fnc_log;
		[_unit, _veh, _camera] spawn {
			params ["_u", "_veh", "_cam"];
			private _ehF = addMissionEventHandler ["EachFrame", {
				(missionNamespace getVariable ["MCC_dropChase", []]) params [["_c", objNull], ["_v", objNull], ["_yT", 0], ["_pT", 0], ["_ext", [0, 2, -20]], ["_y", 0], ["_p", 0], ["_zT", 1], ["_z", 1]];
				if (isNull _c || {isNull _v}) exitWith {};
				_y = _y + ((((_yT - _y) + 540) mod 360) - 180) * 0.12;
				_p = _p + (_pT - _p) * 0.12;
				_z = _z + (_zT - _z) * 0.12;
				MCC_dropChase set [5, _y]; MCC_dropChase set [6, _p]; MCC_dropChase set [8, _z];
				private _piv = [0, 0, (_ext select 1) * 0.5];
				private _rel = [_ext select 0, _ext select 2, (_ext select 1) * 0.5];
				private _dist = (vectorMagnitude _rel) * _z;
				private _az = ((_rel select 0) atan2 (_rel select 1)) + _y;
				private _el = ((asin (((_rel select 2) / (_dist max 0.1)) max -1 min 1)) + _p) max -85 min 89;
				private _pos = _piv vectorAdd [_dist * (cos _el) * (sin _az), _dist * (cos _el) * (cos _az), _dist * (sin _el)];
				private _ahead = 0;
				private _look = _piv vectorAdd [_ahead * (sin _y), _ahead * (cos _y), 0];
				_c camSetPos (ASLToAGL (_v modelToWorldVisualWorld _pos));
				_c camSetTarget (ASLToAGL (_v modelToWorldVisualWorld _look));
				_c camCommit 0;
			}];
			private _d = findDisplay 46;
			private _ehM = _d displayAddEventHandler ["MouseMoving", {
				params ["", "_dx", "_dy"];
				if (visibleMap || {MCC_dropChaseFP} || {count MCC_dropChase < 7}) exitWith {};
				private _k = missionNamespace getVariable ["MCC_chaseSens", 0.6];
				MCC_dropChase set [2, ((MCC_dropChase select 2) + _dx * 1.2 * _k) mod 360];
				MCC_dropChase set [3, (((MCC_dropChase select 3) - _dy * 1.0 * _k) max -90) min 85];
			}];
			inGameUISetEventHandler ["PrevAction", "count (missionNamespace getVariable ['MCC_dropChase', []]) > 0 && {!(missionNamespace getVariable ['MCC_dropChaseFP', false])}"];
			inGameUISetEventHandler ["NextAction", "count (missionNamespace getVariable ['MCC_dropChase', []]) > 0 && {!(missionNamespace getVariable ['MCC_dropChaseFP', false])}"];
			private _ehZ = _d displayAddEventHandler ["MouseZChanged", {
				params ["", "_zd"];
				if (visibleMap || {MCC_dropChaseFP} || {count MCC_dropChase < 9}) exitWith {};
				MCC_dropChase set [7, (((MCC_dropChase select 7) * (1 - _zd * 0.1)) max 0.3) min 3];
			}];
			MCC_dropChaseMap = false;
			private _fp = MCC_dropChaseFP;
			private _map = false;
			private _pv0 = (inputAction "personView") > 0;
			private _mp0 = (inputAction "ShowMap") > 0;
			while {alive _u && {vehicle _u == _veh} && {!(missionNamespace getVariable ["MCC_dropCutSkip", false])}} do {
				private _pv = (inputAction "personView") > 0;
				if (_pv && {!_pv0} && {!visibleMap}) then {MCC_dropChaseFP = !MCC_dropChaseFP};
				_pv0 = _pv;
				private _mp = (inputAction "ShowMap") > 0;
				if ((_mp && {!_mp0}) || {visibleMap && {!_map}}) then {if (!MCC_dropChaseFP) then {MCC_dropChaseMap = true}};
				_mp0 = _mp;
				if !(MCC_dropChaseFP isEqualTo _fp) then {
					_fp = MCC_dropChaseFP;
					if (_fp) then {
						_cam cameraEffect ["TERMINATE", "BACK"];
						_u switchCamera "INTERNAL";
					} else {
						_cam cameraEffect ["INTERNAL", "BACK"];
					};
				};
				if (!_fp) then {
					if (MCC_dropChaseMap && {!_map}) then {
						_map = true;
						_cam cameraEffect ["TERMINATE", "BACK"];
						if (!visibleMap) then {openMap [true, false]};
					};
					if (_map && {!visibleMap}) then {
						_map = false;
						_cam cameraEffect ["INTERNAL", "BACK"];
					};
				};
				MCC_dropChaseMap = false;
				sleep 0.02;
			};
			["INFO", "paradrop", "chase view ends: %1", [if (!alive _u) then {"died"} else {format ["left %1 (now in %2)", typeOf _veh, typeOf (vehicle _u)]}]] call MCC_fnc_log;
			removeMissionEventHandler ["EachFrame", _ehF];
			_d displayRemoveEventHandler ["MouseMoving", _ehM];
			_d displayRemoveEventHandler ["MouseZChanged", _ehZ];
			inGameUISetEventHandler ["PrevAction", ""];
			inGameUISetEventHandler ["NextAction", ""];
			MCC_dropChase = [];
			_cam cameraEffect ["TERMINATE", "BACK"];
			camDestroy _cam;
			_u switchCamera (["EXTERNAL", "INTERNAL"] select _fp);
			(findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", missionNamespace getVariable ["MCC_dropCutSkipEH", -1]];
		};
	} else {
		_camera cameraEffect ["TERMINATE", "BACK"];
		camdestroy _camera;
		_camera = nil;
		_unit switchCamera _viewBefore;
		(findDisplay 46) displayRemoveEventHandler ["MouseButtonDown", missionNamespace getVariable ["MCC_dropCutSkipEH", -1]];
	};
};

//Drop pods? exit
if (_isHalo ==1) exitWith {};

//let them sit for a while
while {!_jumpReady && {alive _plane} && {vehicle _unit != _unit}} do {
	sleep 1;
	_jumpReady = _plane getvariable ["MCCjumpReady", false];
};

/*
//Make them stand on the ramp
if (isplayer _unit) then {
	titleText ["Get Ready To Jump","BLACK FADED",2];
};

while {vehicle _unit != _unit} do {
	unassignVehicle _unit;
	 moveout _unit;
	_unit action ["EJECT",vehicle _unit];
	sleep 0.2;
};


//Broken for some reason will fix it someday
_unit allowdamage false;
_unit enablesimulation false;

_unit setPos [(getPos _unit)select 0,(getPos _unit)select 1,1000];

_unit switchMove "";
sleep 1;
_unit disableCollisionWith _plane;
_plane disableCollisionWith _unit;

_unit attachto [_plane,_unitPosition];
_unit setDir _dir;

if ((primaryWeapon _unit) != "") then
{
	if ((currentWeapon _unit) == (primaryWeapon _unit)) then
	{
		_unit playmoveNow "amovpercmstpslowwrfldnon";
	};
};

if (!isPlayer _unit) then
{
	_unit disableAI "MOVE";
	_unit disableAI "FSM";
};

sleep 1;
_unit enablesimulation true;
sleep 2;

if (isplayer _unit) then
{
	titleText ["","BLACK IN",2];
};

sleep 4;

////start the jump, Turn the light green
if (isplayer _unit) then
{
};
*/
//at the door or bumping into each other while forming up; normal damage afterwards (break-off, chutes, landing).
//If he is not in a formation (formation off, or more than 9), damage comes back 1.5 s after he leaves the aircraft.
if (_isHalo == 2 && {!isPlayer _unit}) then {
	_unit allowDamage false;
	_unit setVariable ["ace_medical_allowDamage", false, true];
	[_unit] spawn {
		params ["_u"];
		waitUntil {sleep 0.1; !alive _u || {vehicle _u == _u}};
		private _tExit = time;
		waitUntil {sleep 0.1; !alive _u || {_u getVariable ["MCC_haloRingDone", false]} || {(time - _tExit) > 1.5 && {!(_u getVariable ["MCC_haloInFormation", false])}} || {(time - _tExit) > 40}};
		_u allowDamage true;
		_u setVariable ["ace_medical_allowDamage", true, true];
		["DEBUG", "haloFormation", "%1: %2 at %3 m", [name _u, if (alive _u) then {"damage back on"} else {"DIED before his damage came back on"}, round ((getPosATL _u) select 2)]] call MCC_fnc_log;
	};
};
if (_isHalo == 0) then {
	_time = time + 300;
	waitUntil {sleep 0.05; isNull _plane || {!alive _plane} || {time > _time} || {(_plane getVariable ["MCCJumperNumber", -1]) >= 0}};
	private _slot = (_plane getVariable ["MCC_releaseTime", time]) + _unitNumber * (_plane getVariable ["MCC_jumpGap", missionNamespace getVariable ["MCC_paraJumpGap", 0.3]]);
	waitUntil {sleep 0.05; time >= _slot || {isNull _plane}};
	_unit setVariable ["MCC_jumpTurn", true];
	["INFO", "paradrop", "%1: jumper %2's turn", [name _unit, _unitNumber + 1]] call MCC_fnc_log;
} else {
	_time = time + 120;
	waituntil {((_plane getVariable ["MCCJumperNumber", -1]) == _unitNumber) || {time > _time} || {isNull _plane} || {!alive _plane}};
	_unit setVariable ["MCC_jumpTurn", true]; //wait for your turn (the aircraft's variable is nil once it is deleted: "waitUntil returned nil" errors every 10 s)
};

/*

if (isplayer _unit) then {
	titleText ["Jump Jump Jump !!!","BLACK FADED",1];
	sleep 1;
	titleText ["","BLACK IN",1];
};

//Start the run
_unit setdir _dir;


_y = _unitPosition select 1;
_x = _unitPosition select 0;
_unit attachto [_plane,[_x,_y, (_unitPosition select 2)]];
while {(animationState _unit) != "AmovPercMrunSlowWrflDf"} do {_unit playmoveNow "AmovPercMrunSlowWrflDf"};
while {(_y > -5)} do {
	_y = _y - 0.18;

	//Lets not bang our head with the helicopter doorway
	if (_y > -3) then {
		_unit attachto [_plane,[_x, _y, (_unitPosition select 2)]];
	} else {
		_unit attachto [_plane,[_x, _y, (_unitPosition select 2)]];
	};
	sleep 0.01;
};
*/

if (_isHalo == 0) then {
	private _tOut = time + 3;
	while {vehicle _unit != _unit && {time < _tOut} && {alive _unit}} do {
		if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "getout", "MOVEOUT by aircraft exit (moveOut) | %1 from %2 at %3 m", [name _unit, typeOf (vehicle _unit), round ((getPosATL _unit) select 2)]] call MCC_fnc_log}; 
		unassignVehicle _unit;
		moveOut _unit;
		sleep 0.1;
		if (vehicle _unit != _unit) then {if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "getout", "MOVEOUT by aircraft exit (Eject) | %1 from %2 at %3 m", [name _unit, typeOf (vehicle _unit), round ((getPosATL _unit) select 2)]] call MCC_fnc_log}; _unit action ["Eject", vehicle _unit]; sleep 0.2};
	};
	if (!isPlayer _unit && {vehicle _unit == _unit} && {!(missionNamespace getVariable ["MCC_paraShayChute", true])}) then {[_unit] orderGetIn false};
	if (vehicle _unit != _unit) then {
		["WARN", "paradrop", "%1 (jumper %2) could not be moved out of %3 - the stick carries on", [name _unit, _unitNumber + 1, typeOf (vehicle _unit)]] call MCC_fnc_log;
	} else {
		["INFO", "paradrop", "%1 (jumper %2) out", [name _unit, _unitNumber + 1]] call MCC_fnc_log;
	};
	if (!isPlayer _unit) then {
		_unit enableAI "MOVE";
		_unit enableAI "FSM";
		[_unit] spawn {
			params ["_u"];
			private _t = time + 180;
			waitUntil {sleep 1; !alive _u || {time > _t} || {vehicle _u == _u && {((getPosATL _u) select 2) < 2}}};
			[_u] allowGetIn true;
		};
	};
} else {
	while {vehicle _unit != _unit} do {
		if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "getout", "MOVEOUT by HALO exit | %1 from %2 at %3 m", [name _unit, typeOf (vehicle _unit), round ((getPosATL _unit) select 2)]] call MCC_fnc_log}; 
		unassignVehicle _unit;
		 moveout _unit;
		_unit action ["EJECT",vehicle _unit];
	
		waituntil {vehicle _unit == _unit};
	
		if (!isPlayer _unit && {_isHalo != 2}) then {	//(HALO: the AI stays still in free fall; MCC_fnc_paradrop lets it move again on landing)
			_unit enableAI "MOVE";
			_unit enableAI "FSM";
		};
	};
};

//along the drawn drop line is what puts them on the line. MCC_fnc_paraGuide is no longer called.)

if (_isHalo == 2 && {_unitNumber == 0} && {missionNamespace getVariable ["MCC_haloFormation", true]}) then {
	private _stick = _plane getVariable ["MCC_haloStick", []];
	if ((_stick findIf {isPlayer _x}) >= 0) then {[_stick] spawn MCC_fnc_haloFormationPlayer} else {[_stick] spawn MCC_fnc_haloFormation};
};

sleep (if (_isHalo == 2) then {[0.1, 0.25] select (((_plane getVariable ["MCC_haloStick", []]) findIf {isPlayer _x}) >= 0)} else {1});
_plane setVariable ["MCCJumperNumber",_unitNumber + 1,true];

/*
//_unit playmoveNow "";
_pos = getpos _unit;
sleep 0.05;
detach _unit;
sleep 0.05;

_dir = getdir _unit;
//Open Chute
if (!isPlayer _unit) then {
	_unit enableAI "MOVE";
	_unit enableAI "FSM";
	_unit playmoveNow "HaloFreeFall_non";
};

sleep 4;


if (_isHalo == 2) then {
	waituntil  {isPlayer _unit || ((position _unit) select 2) < 200};
	_unit addBackpack "B_Parachute";
} else {
	_vehicle = createVehicle ["Steerable_Parachute_F", [-5000, -5000, 0], [], ((_dir)-3+(random 6)), 'NONE'];

	waituntil {!isNil "_vehicle"};
	_pos = getpos _unit;
	_vehicle setPos _pos;
	_vehicle setDir getdir _unit;
	_unit MoveInDriver _vehicle;
};

*/

if (!isnil "_light" && isPlayer _unit) then {deleteVehicle _light};
_unit allowdamage true;