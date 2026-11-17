/*============================================== MCC_fnc_spawnVehicle =============================================================================

	Replace BIS_fnc_spawnVehicle allow spawning of random animations originally by  Joris-Jan van 't Land

	Parameter(s):
	_this select 0: desired position (Array).
	_this select 1: desired azimuth (Number).
	_this select 2: type of the vehicle (String).
	_this select 3: side or existing group (Side or Group).
	_this select 4: (optional) force precise position (Bool, default: true).

	Returns:
	Array:
	0: new vehicle (Object).
	1: all crew (Array of Objects).
	2: vehicle's group (Group).

====================================================================================================================================================
*/

//Validate parameter count
if ((count _this) < 4) exitWith {debugLog "Log: [spawnVehicle] Function requires at least 4 parameters!"; []};

private _grp = grpNull;
private _side = sideUnknown;
private _newGrp = false;

_this params [
	["_pos",[0,0,0],[[]]],
	["_azi",0,[0]],
	["_type","",[""]],
	["_param4",sideEnemy,[sideEnemy,grpNull]],
	["_precisePosition",true,[true]],
	["_randomAnimations",true,[true]],
	["_crewFaction","",[""]],	// (MK) the chosen faction: its own soldiers crew the vehicle, whatever vehicle it is
	["_landed",false,[false,0]]	// (MK) Start: false / 0 flying; true / 1 landed; 2 on the water (afloat) - engine off, held until its first order
];
private _start = if (_landed isEqualType 0) then {_landed} else {[0, 1] select _landed};
_landed = _start > 0;

//Determine if an actual group was passed or a new one should be created.
if ((typeName _param4) == (typeName sideEnemy)) then
{
	_side = _param4;
	_grp = createGroup _side; [_grp] call MCCMK_fnc_genTag;
	_newGrp = true;
}
else
{
	_grp = _param4;
	_side = side _grp;
	_newGrp = false;
};

//Validate parameters
if ((typeName _pos) != (typeName [])) exitWith {debugLog "Log: [spawnVehicle] Position (0) must be an Array!"; []};
if ((typeName _azi) != (typeName 0)) exitWith {debugLog "Log: [spawnVehicle] Azimuth (1) must be a Number!"; []};
if ((typeName _type) != (typeName "")) exitWith {debugLog "Log: [spawnVehicle] Type (2) must be a String!"; []};
if ((typeName _grp) != (typeName grpNull)) exitWith {debugLog "Log: [spawnVehicle] Group (3) must be a Group!"; []};

private _sim = "";
private _veh = objNull;
private _crew = [];
_sim = getText(configFile >> "CfgVehicles" >> _type >> "simulation");

switch (tolower _sim) do {
	case "soldier": {
		_veh = _grp createunit [_type,_pos,[],0,"none"]; [_veh] call MCCMK_fnc_genTag;
	};
	case "airplanex";
	case "helicopterrtd";
	case "helicopterx": {
		if (count _pos == 2) then {_pos set [2,0];};
		if (_landed) then {
			//(MK) Start: Landed - on the ground where it was put; On water - afloat on the sea there (Floatary floats it)
			_pos set [2, 0];
			_veh = createVehicle [_type,_pos,[],0,"CAN_COLLIDE"]; [_veh] call MCCMK_fnc_genTag;
			if (_start == 2 && {surfaceIsWater _pos}) then {
				_veh setVariable ["MCCMK_waterLanding", true, true];
				_veh setPosASL [_pos select 0, _pos select 1, 0.3];
				_precisePosition = false;
			};
		} else {
			//Make sure aircraft start at a reasonable height.
			_pos set [2,(_pos select 2) max 50];
			_veh = createVehicle [_type,_pos,[],0,"FLY"]; [_veh] call MCCMK_fnc_genTag;
		};
	};
	default {
		_veh = createvehicle [_type,_pos,[],0,"none"]; [_veh] call MCCMK_fnc_genTag;
	};
};


//Set the correct direction.
_veh setDir _azi;

//Make sure the vehicle is where it should be.
if (_precisePosition) then
{
	_veh setPos _pos;
};

//Set a good velocity in the correct direction.
if (_sim == "airplanex" && {!_landed}) then {
	_veh setVelocity [100 * (sin _azi), 100 * (cos _azi), 0];
};

//Spawn the crew and add the vehicle to the group.
createvehiclecrew _veh;
_crew = crew _veh;
_crew joinsilent _grp;
_grp addVehicle _veh;
//(MK) crewed by the chosen faction; with none given, by the vehicle's own faction (its configured crew can be another
// faction's, or the side's vanilla soldiers)
if (_crewFaction == "") then {_crewFaction = getText (configFile >> "CfgVehicles" >> _type >> "faction")};
[_veh, _crewFaction] call MCCMK_fnc_factionCrew;
_crew = crew _veh;
if !(toLower _sim in ["soldier", "airplanex", "helicopterrtd", "helicopterx"]) then {
	_veh allowDamage false;
	{_x allowDamage false} forEach _crew;
	[_veh, _crew] spawn {
		params ["_v", "_c"];
		sleep 8;
		if (!isNull _v) then {_v allowDamage true};
		{if (!isNull _x) then {_x allowDamage true}} forEach _c;
	};
};

//If this is a new group, select a leader.
if (_newGrp) then
{
	_grp selectLeader (effectiveCommander _veh);
};

//If we pick random animation
if (_randomAnimations) then {

	[_veh] spawn MCC_fnc_vehicleRandomAnimation;
};

if (_landed && {toLower _sim in ["airplanex", "helicopterrtd", "helicopterx"]}) then {
	[_veh] call MCCMK_fnc_airLandedHold;
	//(MK) afloat: its water-landing mark (watertight) kept until it is 5 m up
	if (_veh getVariable ["MCCMK_waterLanding", false]) then {
		["INFO", "waterLand", "%1 spawned afloat at %2, engine off", [_type, mapGridPosition _veh]] call MCC_fnc_log;
		[_veh] call MCCMK_fnc_heliWaterCrew;
		[_veh] spawn {params ["_v"]; waitUntil {sleep 2; !alive _v || {((getPosATL _v) select 2) > 5}}; if (alive _v) then {_v setVariable ["MCCMK_waterLanding", nil, true]}};
	};
};
[_veh, "spawnVehicle"] call MCCMK_fnc_airTrack;	//(MK) debug: AI aircraft logged when destroyed or removed (callers name themselves)
[_veh, _crew, _grp]