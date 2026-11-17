/*==================================================================MCC_fnc_paratroops==========================================================================
//Contorol the paratroop reinforcement spawn
// Example:[_pos,_paraSide,_paraType,_p_mcc_zone_markername,_p_mcc_zone_behavior,_p_mcc_awareness,_p_mcc_spawnfaction,_startPosDir] spawn MCC_fnc_paratroops;
// <IN>
//	_pos:					Array- position.
//	_paraSide:				String, side to call "West","East","Resistance"
//	_paraType:				Integer, 	0 - "paradrop: small - Spec-Ops "
//										1 - "paradrop: medium - QRF"
//										2 - "paradrop: large - Airborne"
//										3 - "drop-off: small - Spec-Ops "
//										4 - "drop-off: medium - QRF"
//										5 - "drop-off: large - Airborne"
//										6 - "fast-rope: small - Spec-Ops "
//										7 - "fast-rope: medium - QRF"
//										8 - "fast-rope: large - Airborne"
//	_p_mcc_zone_markername		String, Zone number the helicopter's cargo will patrol that zone.
//	_p_mcc_zone_behavior		String, The helicopter's cargo will have this behavior ("MOVE","FORTIFY" exc...)
// 	_p_mcc_awareness			String, The helicopter's cargo will have this awareness ("default","safe" exc...)
//	_p_mcc_spawnfaction			String, Faction name.
//	_startPosDir				Array, spawn and de-spawn location for the helicopter.
//==============================================================================================================================================================*/
private _away = [];
private "_p_mcc_zone_markername";
private _heli = [];
private "_heliCrew";
private _paraSide = "";
private "_paraType";
private _helitype = "";
private _spawn = [];
private "_heliPilot";
private "_type";
private "_timeOut";
private _unit = objNull;
private "_side";
private "_spawnParaGroup";
private _paraGroupArray = [];
private "_paraGroup";
private _paraMode = 0;
private _heliCrewCount = 0;
private "_p_mcc_spawnfaction";
private "_p_mcc_zone_behavior";
private "_mcc_awareness";
private _rampOutPos = [];
private _flyHeight = 0;
private _dropPos = [];
private "_rope";
private _ropes = [];
private "_vehicleClass";

params ["_pos"];
_paraSide				= param [1,"",["",east]];
_paraType 				=  if (TypeName  (_this select 2) == "STRING") then {call compile (_this select 2)} else {(_this select 2)};
_p_mcc_zone_markername  = _this select 3;
_p_mcc_zone_behavior	= _this select 4;
_p_mcc_awareness		= _this select 5;
_p_mcc_spawnfaction		= _this select 6;
_startPosDir			= _this select 7;
private _mwZone = param [8, "", [""]];	//(MK) a generated mission's QRF: its zone (the mission's cleanup removes it all)

// (MK) The helicopter starts 4.5 km from the drop point (out of sight at today's view distances), in the
// direction given, or the nearest other direction with no player within 1.5 km of the start (else the one furthest
// from every player). A paradrop leaves the same distance out on the other side; a drop-off goes back the way it came.
private _qrfPlayers = (allPlayers - (entities "HeadlessClient_F")) select {alive _x};
private _baseDir = if (isNil "_startPosDir") then {90} else {[_pos, _startPosDir] call BIS_fnc_dirTo};
private _spawndir = _baseDir;
private _bestFar = -1;
{
	private _d = _baseDir + _x;
	private _p = _pos getPos [4500, _d];
	private _near = 1e9;
	{_near = _near min (_x distance2D _p)} forEach _qrfPlayers;
	if (_near >= 1500) exitWith {_spawndir = _d; _bestFar = _near};
	if (_near > _bestFar) then {_bestFar = _near; _spawndir = _d};
} forEach [0, 30, -30, 60, -60, 90, -90, 120, -120, 150, -150, 180];
_spawn = _pos getPos [4500, _spawndir];
_spawn set [2, (_pos param [2, 0]) + 100];
_away = _pos getPos [4500, _spawndir - 180];
_away set [2, (_pos param [2, 0]) + 100];

//id sent a string
if (typeName _paraSide isEqualTo typeName sideLogic) then {
	_paraSide = str _paraSide;
};
_unitspawned = [];
_paraGroupArray = [];
_customParaGroup = false;
_dropPos = [];
_rampOutPos = [];
_ropes = [];
_actualRopes = [];

// get group configs
{
	if ( ((_x select 3) == "Rifle Squad") || ((_x select 3) == "Recon Team") ) then {
		_paraGroupArray pushBack (format ["%1", ( _x select 2)]);
	};
} forEach ([_paraSide,_p_mcc_spawnfaction,"Infantry","LAND"] call mcc_make_array_grps);


if ( (count _paraGroupArray) == 0 ) then {
	_customParaGroup = true;
	_unitsArray = [];

	//Let's build the faction unit's array
	//(MK) the faction's infantry pool (MCCMK_fnc_pools: own content, then official DLC, then all; none: a sibling
	// faction's - never a vanilla soldier)
	_unitsArray = [_p_mcc_spawnfaction, "InfMen"] call MCCMK_fnc_pool;	// ordinary soldiers, as the original
	if ( (count _unitsArray) == 0 ) exitWith {};

	_paraGroupArray set [0, _unitsArray];

	//diag_log format ["MCC paradrop custom array: %1", count _paraGroupArray];
};

if ( (count _paraGroupArray) == 0 ) exitWith { if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["MCC Warning: no suitable paratrooper group found for %1", _this]}; player groupChat format ["Error: no suitable paratrooper group for this Faction"]; };

//Set default helicopter and crew
switch (_paraSide) do {
	case "WEST": {
		_side = west;
		switch (_paraType % 3) do
		{
			case 0: // 0, 3, 6
			{
				_helitype = "B_Heli_Light_01_F";
				//_spawnParaGroup = _paraGroupArray select 1;
				_spawnParaGroup = _paraGroupArray select ((count _paraGroupArray) -1);
				_ropes = [[0.6,0.5,0],[-0.8,0.5,0]];
			};
			case 1: // 1, 4, 7
			{
				_helitype = "B_Heli_Transport_01_F";
				_spawnParaGroup = _paraGroupArray select ((count _paraGroupArray) -1);
				_ropes = [[-1.11,2.5,0],[1.11,2.5,0]];
			};
			case 2: // 2, 5, 8
			{
				_helitype = "B_Heli_Transport_03_F";
				_spawnParaGroup = _paraGroupArray select 0;
				_ropes = [[1,-4,-1],[-1,-4,-1]];
			};
		};
	};

	case "EAST": {
		_side = east;
		switch (_paraType % 3) do
		{
			case 0:
			{
				_helitype = "O_Heli_Attack_02_F";
				_spawnParaGroup = _paraGroupArray select ((count _paraGroupArray) - 1);
				_ropes = [[1.35,1.35,0],[-1.45,1.35,0]];
			};
			case 1:
			{
				_helitype = "O_Heli_Light_02_F";
				_spawnParaGroup = _paraGroupArray select ((count _paraGroupArray) -1);
				//_ropes = [[1.3,1.3,-25],[-1.3,1.3,-25]];
				_ropes = [[1.3,1.3,0],[-1.3,1.3,0]];
			};
			case 2:
			{
				_helitype = "O_Heli_Transport_04_covered_F";
				_spawnParaGroup = _paraGroupArray select 0;
				_ropes = [[1,-4,-1],[-1,-4,-1]];
			};
		};
	};

	default {
		_side = resistance;
		_helitype = "I_Heli_Transport_02_F";

		switch (_paraType % 3) do
		{
			case 0:
			{
				_helitype = "I_Heli_light_03_F";
				_spawnParaGroup = _paraGroupArray select ((count _paraGroupArray) -1);
				_ropes = [[1.3,1.3,0],[-1.3,1.3,0]];
			};
			case 1:
			{
				_helitype = "I_Heli_light_03_unarmed_F";
				_spawnParaGroup = _paraGroupArray select ((count _paraGroupArray) -1);
				_ropes = [[1.3,1.3,0],[-1.3,1.3,0]];
			};
			case 2:
			{
				_helitype = "I_Heli_Transport_02_F";
				_spawnParaGroup = _paraGroupArray select 0;
				_ropes = [[1,-5,0],[-1,-5,0]];
			};
		};
	};
};


if ( isNil "_spawnParaGroup" ) exitWith { if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["MCC ERROR: no group found for %1", _this]}; };

//Try to find an helicopter from the faction
private "_minSpaces";
private _vehiclesTypesArray = [];
private _availableSpaces = [];
private _newHeliClassesArray = [];
_minSpaces = switch (_paraType % 3) do {
				case 0: {6};
				case 1: {12};
				default {18};
			};

_vehiclesTypesArray = [_p_mcc_spawnfaction,"helicopterrtd","air"] call MCC_fnc_makeUnitsArray;
if (count _vehiclesTypesArray < 2) then {
	_vehiclesTypesArray = [_p_mcc_spawnfaction,"helicopterrtd"] call MCC_fnc_makeUnitsArray;
};

_vehiclesTypesArray = _vehiclesTypesArray + ([_p_mcc_spawnfaction,"helicopterX"] call MCC_fnc_makeUnitsArray);

private _defHeli = _helitype;
// (MK) Helicopters with enough seats, through the content filter like the generator's lists (the faction's own content,
// then official DLC, then all); none: a sibling faction's (same mod); the side's vanilla helicopter only as a last resort
private _seatOK = {
	params ["_list"];
	private _out = [];
	{
		private _c = _x param [0, ""];
		private _n = [_c, "allCargo"] call MCC_fnc_crewCount;
		if (_n >= _minSpaces) then {_out pushBack [_c, _n]};
	} forEach _list;
	_out
};
//(MK) from the faction's pools (MCCMK_fnc_pools: own content, then official DLC, then all; none: a sibling faction's;
// none at all: the side's vanilla helicopter) - its transport helicopters with enough seats
private _hp = ([_p_mcc_spawnfaction, "HeliTransport"] call MCCMK_fnc_pool) + ([_p_mcc_spawnfaction, "Heli"] call MCCMK_fnc_pool);
_newHeliClassesArray = [(_hp arrayIntersect _hp) apply {[_x]}] call _seatOK;
//(MK) the faction (and its siblings) has no helicopter with enough seats, and the "Vanilla vehicle fallback" setting is off:
// no helicopter QRF (it would have come in the side's vanilla helicopter)
if (count _newHeliClassesArray == 0 && {!(missionNamespace getVariable ["MCCMK_vanillaFallback", true])}) exitWith {
	["INFO", "MCC_fnc_paratroops", "%1 has no transport helicopter (vanilla fallback off) - no helicopter QRF", [_p_mcc_spawnfaction]] call MCC_fnc_log;
};
if (count _newHeliClassesArray > 0) then {
	_newHeliClassesArray = _newHeliClassesArray apply {[_x select 1, _x select 0]};
	_newHeliClassesArray sort true;
	_helitype = (_newHeliClassesArray select 0) select 1;
};
if (_helitype != _defHeli) then {
	private _ro = getArray (configFile >> "CfgVehicles" >> _helitype >> "ace_fastroping_ropeOrigins");
	_ro = _ro select {_x isEqualType [] && {count _x == 3}};
	if (count _ro >= 2) then {_ropes = [_ro select 0, _ro select 1]} else {
		private _w = (getNumber (configFile >> "CfgVehicles" >> _helitype >> "mapSize")) * 0.12;
		_w = (_w max 0.9) min 1.6;
		_ropes = [[_w, 0.5, 0], [-_w, 0.5, 0]];
	};
};

if ( _paraType < 3 ) then {
	_paraMode = 0; // paradrop
	_flyHeight = 400;
} else {
	if ( _paraType < 6 ) then
	{
		_paraMode = 1; // drop-off
	}
	else
	{
		_paraMode = 2; // fast-rope
	};
	_flyHeight = 50;
};

_heli 				= [_helitype, _spawn, _pos, _flyHeight, false, _side] call MCC_fnc_createPlane;
_heliCrew			= group _heli;
[_heli, "helicopter QRF"] call MCCMK_fnc_airTrack;	//(MK) debug
if (_mwZone != "") then {_heli setVariable ["MCC_MWReinforceZone", _mwZone]; _heliCrew setVariable ["MCC_MWReinforceZone", _mwZone]};
_heliPilot			= driver _heli;
crew _heli joinSilent _heliCrew;

if ( _heliType == "I_Heli_Transport_02_F" ) then
{
	if (_paraSide == "EAST") then
	{
		_heli setObjectTextureGlobal [0,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
		_heli setObjectTextureGlobal [1,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
		_heli setObjectTextureGlobal [2,'#(rgb,8,8,3)color(0.635,0.576,0.447,0.5)'];
	};
	if (_paraSide == "WEST") then
	{
		_heli setObjectTextureGlobal [0,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
		_heli setObjectTextureGlobal [1,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
		_heli setObjectTextureGlobal [2,'#(rgb,8,8,3)color(0.960,0.990,0.990,0.1)'];
	};
};

_heli setBehaviour "CARELESS";

_heliCrewCount = count (crew _heli);

// In case of drop-off or fast-rope return to start position
if ( _paraMode > 0 ) then {
	_away = _spawn;
	_heli flyInHeight _flyHeight;
	_heliPilot flyInHeight _flyHeight;
};

private _cargoNum = [];
private "_unitsArray";
private "_i";
private "_type";
private "_z";
private _cargoGroups = [];
//--------spawn the jumping group----------------------
_cargoNum = [_helitype, "allCargo"] call MCC_fnc_crewCount; //populate heli before kick off
_cargoGroups = [];

if (_cargoNum > 0) then {

	//Limit group size
	switch (_paraType % 3) do {
		case 0:
		{
			_cargoNum =  _cargoNum min 6
		};

		case 1:
		{
			_cargoNum =  _cargoNum min 12
		};

		default
		{
			_cargoNum =  _cargoNum min 18
		};
	};

	//lets spawn groups
	for "_i" from 0 to (ceil (_cargoNum /6)) step 1 do {

		if !( _customParaGroup ) then {
			_unitspawned=[[100,100,5000], _side, (call compile _spawnParaGroup),[],[],[0.1,(missionNamespace getVariable ["MCC_AI_Skill",0.5])],[],[(6 min _cargoNum), 0]] call MCC_fnc_spawnGroup;
			sleep 0.1;
		} else {

			_unitspawned = createGroup _side;

			{
				private _type = _x;
				_unit = _unitspawned createUnit [_type, _spawn, [], 0.5, "NONE"];

				//Curator
				{_x addCuratorEditableObjects [[_unit],false]} forEach allCurators;
			} forEach ([_spawnParaGroup, 6 min _cargoNum] call MCCMK_fnc_buildSquad);
		};

		_cargoGroups pushBack _unitspawned;
		if (_mwZone != "") then {_unitspawned setVariable ["MCC_MWReinforceZone", _mwZone]};	//(MK) the mission's cleanup
		// (MK) the helicopter's crew: the paratroopers' own faction
		if (count _cargoGroups == 1 && {!isNull leader _unitspawned}) then {[_heli, faction leader _unitspawned] call MCCMK_fnc_factionCrew};
		_cargoNum = _cargoNum - (count units _unitspawned);

		{
			_x assignAsCargo _heli;
			_x moveInCargo _heli;
			_x setSkill ["aimingspeed", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
			_x setSkill ["spotdistance", (missionNamespace getVariable ["MCC_AI_Spot",0.3])];
			_x setSkill ["aimingaccuracy", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
			_x setSkill ["aimingshake", (missionNamespace getVariable ["MCC_AI_Aim",0.1])];
			_x setSkill ["spottime", (missionNamespace getVariable ["MCC_AI_Spot",0.3])];
			_x setSkill ["commanding", (missionNamespace getVariable ["MCC_AI_Command",0.5])];
			_x setSkill ["general", (missionNamespace getVariable ["MCC_AI_Skill",0.5])];
			/*
				removeBackpack _x;
				_x addBackpack "B_Parachute";
			*/
		} forEach (units _unitspawned);
	};
};

_dropPos = _pos findEmptyPosition [10,150,_heliType];
if ( count _dropPos == 0 ) then { _dropPos = _pos; };

//Set waypoint
_heliCrew move _pos;
(driver _heli) move _pos;

_heli setSpeedMode "FULL";

waitUntil { sleep 1;(driver _heli) move _pos;(_heli distance2d _dropPos) < 100};  // include heli heigth else if flying higher then 250 m this wil be 'true'

//Open doors
[_heli,true] spawn MCC_fnc_heliOpenCloseDoor;

// toss ropes for fast-rope
if ( _paraMode == 2 ) then {

	_heli flyInHeight 35;
	sleep 4;
	doStop (driver _heli);
	_timeOut = time + 10;
	waitUntil { sleep 1; ( (abs(speed _heli) < 0.5) && ((getPos _heli select 2) < 50) )  || !alive _heli || !alive (driver _heli) || time > _timeOut};
	if ( !alive _heli || !alive (driver _heli)) exitWith {};

	{
		_rope = ropeCreate [_heli, _x,55,[10],[10], true];
		_actualRopes set [count _actualRopes, _rope];
		/*
		_rope = createVehicle ["land_rope_f", [0,0,0], [], 0, "CAN_COLLIDE"];
		sleep 0.3;
		_rope allowDamage false;
		_rope disableCollisionWith _heli;
		_actualRopes set [count _actualRopes, _rope];
		_rope setdir (getdir _heli);
		_rope attachto [_heli, _x];
		*/
		sleep 0.5;
	} forEach _ropes;
};

{
	[units _x] allowGetIn false;
	[_x, _heli, _p_mcc_zone_markername, _p_mcc_zone_behavior, _p_mcc_awareness, _paraMode, _paraType, _actualRopes, (_forEachIndex % 2), count _cargoGroups] spawn
	{
		private "_paraGroup";
		private "_dir";
		private "_p_mcc_zone_markername";
		private "_p_mcc_zone_behavior";
		private "_p_mcc_awareness";
		private "_paraMode";
		private "_paraType";
		private "_actualRopes";
		private "_rope";
		private "_index";
		private "_number";

		_paraGroup 	= _this select 0;
		_heli = (_this select 1);
		_p_mcc_zone_markername = _this select 2;
		_p_mcc_zone_behavior = _this select 3;
		_p_mcc_awareness = _this select 4;
		_paraMode = _this select 5;
		_paraType = _this select 6;
		_actualRopes = _this select 7;
		_index = _this select 8;
		_number = _this select 9;
		_dir = (direction _heli) + 180;

		 switch ( _paraMode ) do
		{
			case 0: // paradrop
			{
				_heli flyInHeight (getPosATL _heli select 2); // to maintain current altitude
				{
					if (typeOf _heli == "I_Heli_Transport_02_F") then
					{
						sleep 1.6;

						_d = if ((speed _heli) <= 40) then {6} else {5};

						_rampOutPos = [_heli, _d, ((getDir _heli) + 180)] call BIS_fnc_relPos;
						_altitude = getPosATL _heli;

						_a = if ((speed _heli) <= 40) then {3} else {0};

						_rampOutPos set [2, ((_altitude select 2) - _a)];

						_x setPosATL _rampOutPos;
						_x setDir ((getDir _heli) + 180);
					}
					else
					{
						sleep 0.8;
					};

					_x allowDamage false;
					_x action ["GETOUT",vehicle _x];
					unassignVehicle _x;
					//_x action ["GetOut",vehicle _x];
					sleep 1;
					_chute = createVehicle ["NonSteerable_Parachute_F", position _x, [], ((_dir)-5+(random 10)), 'NONE'];
					_chute setPos (getPos _x);
					_chute setDir ((_dir)-5+(random 10));
					_x setDir ( direction _chute );
					_chute setPos (getPos _x);
					_x moveindriver _chute;
					(vehicle _x) setDir ((_dir)-5+(random 10));
					_x allowDamage true;
				} foreach (units _paraGroup);
			};

			case 1: // drop-off
			{
				{
					_x allowDamage false;
					unassignVehicle _x;
					waituntil {isTouchingGround _x};
					_x allowDamage true;
				} foreach (units _paraGroup);
			};

			case 2: // fast-rope
			{
				_heli doMove (getPosATL _heli);
				//doStop _heli;
				doStop driver _heli;

				{
					if ( _number > 1 ) then
					{
						_rope = _actualRopes select _index;
					}
					else
					{
						_rope = _actualRopes select (_forEachIndex % 2);
					};

					[_x, _rope] spawn
						{
							private "_unit";
							private _zc = 0;
							private "_zdelta";
							private "_rope";
							_unit = _this select 0;
							_rope = _this select 1;
							_zdelta = 7 / 10;
							_zc = -4;

							if (isNil "_rope") exitWith {};

							_unit action ["GETOUT", vehicle _unit];
							unassignVehicle _unit;
							["call", [[], compile format ["objectFromNetID '%1' switchmove 'crew_tank01_out'", netID _unit]], 0, false] call MCC_fnc_secRemote;
							//_unit switchmove "crew_tank01_out";

							_unit setpos [(getpos _unit select 0), (getpos _unit select 1), 0 max ((getpos _unit select 2) - 3)];

							while { (alive _unit) && ( (getpos _unit select 2) > 0.3 ) && ( _zc > -55 ) } do
							{
								_unit attachTo [_rope, [0,0,_zc]];
								_zc = _zc - _zdelta;
								sleep 0.1;
							};

							["call", [[], compile format ["objectFromNetID '%1' switchmove ''", netID _unit]], 0, false] call MCC_fnc_secRemote;
							//_unit switchmove "";
							detach _unit;
						};
					sleep ( 1 + ((random 6)/10) );
				} foreach (units _paraGroup);
			};
		};
	};

	sleep 0.8; // 2nd group will disembark in parallel with offset of 0.8 seconds

} foreach _cargoGroups;

if ( _paraMode > 0 ) then  // Drop-off or fast-rope
{
	// if chopper is still around after 40/70 seconds leave to avoid getting stuck
	if ( _paraMode > 1 ) then {
		_timeOut = time + 40;
	} else {
		_timeOut = time + 70;
	};

	{
		_x setBehaviour "AWARE";
	} foreach _cargoGroups;

	//wait untill all paratroopers are out
	waitUntil { sleep 1; (count crew _heli == _heliCrewCount) || (time > _timeOut);  };

	// toss ropes for fast-rope
	if ( _paraMode == 2 ) then
	{
		//make sure all AI cargo has left the chopper - give 4 seconds for last unit to slide down the rope
		waitUntil { sleep 1; (count crew _heli == _heliCrewCount) || (time > _timeOut + 20);  };
		sleep 4;

		// drop the ropes and delete them
		{
			_attachPoint = _ropes select _forEachIndex;
			_zc = -22;
			while { _zc > -50 } do
			{
				_x attachTo [_heli, [_attachPoint select 0 , _attachPoint select 1,_zc]];
				_zc = _zc - 2;
				sleep 0.1;
			};
			deletevehicle _x;
		} foreach _actualRopes;

		//wait 3 seconds before flying away
		sleep 3;
	};

	_away = _spawn;
	_heli flyInHeight _flyHeight;
	_heliPilot flyInHeight _flyHeight;

	//Set waypoint
	_heli doMove _away;
	_heliPilot doMove _away;
}
else // Paradrop
{
	sleep 10;
	_heli flyInHeight _flyHeight;
	_heliPilot flyInHeight _flyHeight;
};


_heliPilot doMove _away;
_heli setSpeedMode "FULL";
_heli setBehaviour "CARELESS";

//_heli setDestination [_away, "VehiclePlanned", true];

//Close doors
[_heli,false] spawn MCC_fnc_heliOpenCloseDoor;

// Allow chopper to leave else AI will board again :-/
sleep 5;

// activate GAIA for each paragroup
if (_p_mcc_zone_behavior in ["bis", "bisd","bisp"]) then {

	[1,_pos,[3,"NO CHANGE","NO CHANGE","FULL","AWARE","true", "",0],_cargoGroups] spawn MCC_fnc_manageWp;

} else {

	{
		private _paraGroup = _x;

		if ( _p_mcc_awareness == "Default" ) then // MM most likely forgot to set awareness - paratroopers are not default :-)
		{
			_p_mcc_awareness = "AWARE";
		};

		//_null = [leader _paraGroup, _p_mcc_zone_markername,_p_mcc_zone_behavior,_p_mcc_awareness,"SHOWMARKER","spawned" ] spawn mcc_ups;
		_paraGroup setVariable ["GAIA_ZONE_INTEND",[_p_mcc_zone_markername,_p_mcc_zone_behavior], true];

	} foreach _cargoGroups;
};

// (MK) Removed once it is 4.5 km from every player - out of sight - or after 4 minutes at most. Reaching its exit point
// with a player still within 4.5 km, it carries on further out. Shot down: the wreck is left (the wreck cleanup).
//(MK) out past the EDGE of the map, straight on away from the drop; removed once beyond it (12 minutes at most)
if (alive _heli) then {
	_away = [getPosATL _heli, _pos getDir _heli] call MCCMK_fnc_mapEdgeExit;
	_away set [2, 100];
	_heliPilot doMove _away;
};
_timeOut = time + 720;
waitUntil {sleep 2; !alive _heli || {((((getPosATL _heli) select 0) < 0) || {((getPosATL _heli) select 1) < 0} || {((getPosATL _heli) select 0) > worldSize} || {((getPosATL _heli) select 1) > worldSize})} || {time > _timeOut}};
if (!alive _heli) exitWith {};

{deleteVehicle _x} forEach (crew _heli);
deletegroup (group _heli);	//case we want to delete the whole shabang
deletevehicle _heli;