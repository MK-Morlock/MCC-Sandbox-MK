//===================================================================MCC_fnc_setEvac======================================================================================
//	Sets an empty ot AI vehicle into an ecav for a specific side
// Example:[_object, _side, _addGunners,_campaignEvac] remoteExec ["MCC_fnc_setEvac", false, false];
// Params:
//	_object:		OBJECT the evac vehicle can be empty
// 	_side: 			SIDE, Evac Side
// 	_addGunners: 	BOOLEAN, if true will spawn gunners to available vehicle's turrets
//	_campaignEvac: 	BOOLEAN if set to true the evac will respawn every day while the MCC campaign is running
//==============================================================================================================================================================================
private _gunnersGroup = grpNull;
private _side = west;
private _type = "";
private _entry = configNull;
private _turrets = [];
private _path = [];
private _pilotClass = "";
private _evacVehicles = [];
private _addGunners = false;
private _object = objNull;
private _pos = [];
_object =  _this param [0, objNull, [objNull]];
_side =  _this param [1, west];
_addGunners =  _this param [2, true, [true]];
_campaignEvac = _this param [3, false, [false]];

_pos = getpos _object;
_gunnersGroup = creategroup _side;											 //Create gunners group
_gunnersGroup setbehaviour "AWARE";										//Make the gunners aggresive
_gunnersGroup setcombatmode "red";
_type = typeOf _object;														//Find turrets
_entry = configFile >> "CfgVehicles" >> _type;
_pilotClass = getText (configFile >> "CfgVehicles" >> _type >> "crew");
_turrets = [_entry >> "turrets"] call BIS_fnc_returnVehicleTurrets;			//All turrets were found, now spawn crew for them
_path = [];

private _i = 0;
private _index = 0;
private _turretIndex = 0;
private _thisTurret = [];
private _isCargo = [];
private _turretPath = "";
private _unit = objNull;
_i = 0;
_index = 0;

//spawn driver if needed
if (isnull (driver _object)) then {
	_unit = (creategroup _side) createUnit [_pilotClass, _pos, [], 0, "NONE"];
	_unit assignAsDriver _object;
	_unit moveInDriver _object;
	(group _unit) setbehaviour "CARELESS";
	(group _unit) setcombatmode "yellow";
	_unit setSkill 1;
};

if (_addGunners) then {
	while {_i < (count _turrets)} do {
		_turretIndex = _turrets select _i;
		_thisTurret = _path + [_turretIndex];
		_turretPath = configName ((configFile >> "CfgVehicles" >> _type >> "turrets") Select _index);

		_isCargo = ["cargo",tolower _turretPath] call BIS_fnc_inString;
		if (isNull (_object turretUnit _thisTurret) && !_isCargo) then
		{
			_unit = _gunnersGroup createUnit [_pilotClass, _pos, [], 0, "NONE"]; //Spawn unit into this turret, if empty.
			_unit assignAsGunner _object;
			_unit moveInTurret [_object, _thisTurret];
			_unit setSkill 1;
		};
		_i = _i + 2;
		_index = _index + 1;
	};
};

_object setVariable ["MCC_evacStartPos", getposATL _object, true];
_object setVariable ["MCC_evacSide", _side, true];

_evacVehicles = missionNamespace getvariable [format ["MCC_evacVehicles_%1",_side],[]];
_evacVehicles pushBack _object;

missionNamespace setvariable ([format ["MCC_evacVehicles_%1",_side],_evacVehicles]);
publicvariable (format ["MCC_evacVehicles_%1",_side]);

{_x addCuratorEditableObjects [[_object],true]} forEach allCurators;

//If campaignEvac
if (_campaignEvac) then {
	private _varName = format ["MCC_campaignEvac_%1", _side];
	missionNamespace setVariable [_varName,[_object,_type,(if (surfaceIsWater _pos) then {getPosASL _object} else { getposATL _object}), direction _object]];
	publicvariable _varName;
};

//Wait until the evac is dead
[_object, _side, _gunnersGroup] spawn {
	params [["_object", objNull, [objNull]], ["_side", sideLogic, [sideLogic]], ["_gg", grpNull, [grpNull]]];
	private _displayName = getText (configFile >> "CfgVehicles" >> typeOf _object >> "displayname");
	private _grps = [_gg];
	while {alive _object} do {
		{_grps pushBackUnique (group _x)} forEach ((crew _object) select {!isPlayer _x});
		sleep 2;
	};
	private _evacVehicles = (missionNamespace getVariable [format ["MCC_evacVehicles_%1", _side], []]) select {alive _x};
	missionNamespace setVariable [format ["MCC_evacVehicles_%1", _side], _evacVehicles];
	publicVariable (format ["MCC_evacVehicles_%1", _side]);
	if (!isNull _object) then {["MCCNotificationBad", ["Evac", format ["%1 Evac is down", _displayName], ""]] remoteExec ["bis_fnc_showNotification", _side]};
	{
		private _g = _x;
		{if (!isPlayer _x) then {if (vehicle _x != _x) then {moveOut _x}; deleteVehicle _x}} forEach (units _g);
		deleteGroup _g;
	} forEach (_grps select {!isNull _x});
};
