params [
	["_center", [0,0,0], [[]]],
	["_radius", 200, [0]],
	["_arrayUnits", [], [[]]],
	["_side", sideUnknown, [sideUnknown]],
	["_zone", 0, [0, ""]]
];
private _pool = (_arrayUnits + (missionNamespace getVariable ["MCC_MWunitsArrayAutonomous", []])) select {_x isEqualType [] && {count _x > 1}} apply {_x select 1};
_pool = _pool arrayIntersect _pool;
private _sams = _pool select {private _c = _x; ((["SAM_System_01_base_F", "SAM_System_02_base_F", "SAM_System_03_base_F", "SAM_System_04_base_F"] findIf {_c isKindOf _x}) >= 0) || {((toLower getText (configFile >> "CfgVehicles" >> _c >> "model")) find "sam_system") >= 0}};
private _radars = _pool select {private _c = _x; ((["Radar_System_01_base_F", "Radar_System_02_base_F"] findIf {_c isKindOf _x}) >= 0) || {((toLower getText (configFile >> "CfgVehicles" >> _c >> "displayName")) find "radar") >= 0} || {((toLower getText (configFile >> "CfgVehicles" >> _c >> "model")) find "radar_system") >= 0}};
private _std = false;
if ((missionNamespace getVariable ["MCC_MWAirDefenceFallback", true]) && {count _sams == 0 || {count _radars == 0}}) then {
	private _set = switch (_side) do {
		case west: {[["B_SAM_System_03_F"], ["B_Radar_System_01_F"]]};
		case east: {[["O_SAM_System_04_F"], ["O_Radar_System_02_F"]]};
		default {[["I_E_SAM_System_03_F", "B_SAM_System_03_F"], ["I_E_Radar_System_01_F", "B_Radar_System_01_F"]]};
	};
	if (count _sams == 0) then {_sams = ((_set select 0) select {isClass (configFile >> "CfgVehicles" >> _x)}) select [0, 1]; _std = count _sams > 0};
	if (count _radars == 0) then {_radars = ((_set select 1) select {isClass (configFile >> "CfgVehicles" >> _x)}) select [0, 1]};
};
if (count _sams == 0) exitWith {["INFO", "MCC_fnc_MWSpawnAirDefence", "no SAM launcher in the faction (%1 static/autonomous classes checked, %2 radars) - no air-defence site", [count _pool, count _radars]] call MCC_fnc_log};
if (isNil "MCC_MWStaticUsed") then {MCC_MWStaticUsed = []};
private _sam = selectRandom _sams;
private _cands = (selectBestPlaces [_center, _radius, "meadow", 10, 40]) call BIS_fnc_arrayShuffle;
private _samPos = [];
{
	private _p = _x select 0;
	if ((_p distance2D _center) > 40 && {(MCC_MWStaticUsed findIf {((_x select 0) distance2D _p) < 35}) < 0}) then {
		_samPos = [_p, _sam, 30] call MCC_fnc_clearVehicleSpot;
	};
	if (count _samPos > 0) exitWith {};
} forEach _cands;
if (count _samPos == 0) then {_samPos = [_center, _sam, _radius max 100] call MCC_fnc_clearVehicleSpot};
if (count _samPos == 0) then {_samPos = _center findEmptyPosition [40, (_radius max 100) * 2, _sam]};
if (count _samPos == 0) exitWith {["INFO", "MCC_fnc_MWSpawnAirDefence", "no clear spot for the air-defence site near %1", [mapGridPosition _center]] call MCC_fnc_log};
private _fnc_place = {
	params ["_pos", "_class"];
	private _v = [_pos, random 360, _class, _side] call MCC_fnc_spawnVehicle;
	(_v select 2) setVariable ["GAIA_ZONE_INTEND", [str _zone, "NOFOLLOW"], true];
	{_x addCuratorEditableObjects [[_v select 0], true]} forEach allCurators;
	MCC_MWStaticUsed pushBack [_pos, _v select 0];
	_v select 0
};
private _samObj = [_samPos, _sam] call _fnc_place;
private _radarObj = objNull;
if (count _radars > 0) then {
	private _radar = selectRandom _radars;
	private _rPos = [];
	{
		_rPos = [_samPos getPos [25 + random 15, _x + random 30], _radar, 20] call MCC_fnc_clearVehicleSpot;
		if (count _rPos > 0) exitWith {};
	} forEach [0, 60, 120, 180, 240, 300];
	if (count _rPos == 0) then {_rPos = _samPos findEmptyPosition [20, 120, _radar]};
	if (count _rPos > 0) then {_radarObj = [_rPos, _radar] call _fnc_place};
};
["INFO", "MCC_fnc_MWSpawnAirDefence", "air-defence site at %1: %2%3%4", [mapGridPosition _samPos, typeOf _samObj, if (isNull _radarObj) then {" (no radar)"} else {" + " + typeOf _radarObj}, if (_std) then {" (standard - the faction has none)"} else {""}]] call MCC_fnc_log;
