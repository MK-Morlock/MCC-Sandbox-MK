/*
	MCCMK_fnc_civMinimum  (server) - a generated mission's civilians topped up to a minimum (scaled to the AO by the
	caller): a few seconds after the garrison's civilians, the living civilians in the area are counted and the shortfall
	added - in free building positions first, then walking about in the area. [centre, radius, civilian faction, minimum]
*/
params [["_pos", [0, 0, 0], [[]]], ["_r", 150, [0]], ["_faction", "CIV_F", [""]], ["_min", 4, [0]]];
if (!isServer) exitWith {};
sleep 8;
private _have = count ((_pos nearEntities [["CAManBase"], _r]) select {alive _x && {(side group _x) isEqualTo civilian}});
private _need = _min - _have;
if (_need <= 0) exitWith {["INFO", "civilians", "%1 civilians in the AO (minimum %2) - none added", [_have, _min]] call MCC_fnc_log};
private _types = ([[_faction, "soldier", "men"] call MCC_fnc_makeUnitsArray] call MCC_fnc_combatInfantry) apply {if (_x isEqualType []) then {_x select 0} else {_x}};
if (_types isEqualTo []) then {_types = ["C_man_1", "C_man_polo_1_F", "C_man_polo_2_F", "C_man_p_beggar_F"] select {isClass (configFile >> "CfgVehicles" >> _x)}};
if (_types isEqualTo []) exitWith {["WARN", "civilians", "faction %1 has no civilians to add", [_faction]] call MCC_fnc_log};
// free building positions in the area, nearest first
private _spots = [];
{
	private _b = _x;
	for "_i" from 0 to ((_b call MCC_fnc_buildingPosCount) - 1) do {
		private _p = _b buildingPos _i;
		if (count (nearestObjects [_p, ["Man"], 1.5]) == 0) then {_spots pushBack _p};
	};
} forEach ((nearestObjects [_pos, ["House", "Building"], _r]) select {!(_x call MCC_fnc_isWaterStructure)});
_spots = _spots call BIS_fnc_arrayShuffle;
private _added = 0;
private _walkers = 0;
for "_n" from 1 to _need do {
	private _g = createGroup [civilian, true];
	private _inside = count _spots > 0;
	private _p = if (_inside) then {_spots deleteAt 0} else {
		private _s = [_pos, _r * 0.8] call MCC_fnc_landSpot;
		if (_s isEqualTo []) then {_pos getPos [random (_r * 0.6), random 360]} else {_s}
	};
	private _u = _g createUnit [selectRandom _types, _p, [], 0, "CAN_COLLIDE"];
	if (isNull _u) then {deleteGroup _g; continue};
	_u setPosATL _p;
	_g setBehaviour "SAFE";
	_g setSpeedMode "LIMITED";
	if (_inside) then {
		_u disableAI "PATH";
	} else {
		for "_w" from 1 to 4 do {
			private _wp = _g addWaypoint [_pos getPos [random (_r * 0.7), random 360], 0];
			_wp setWaypointType "MOVE";
			_wp setWaypointSpeed "LIMITED";
			_wp setWaypointTimeout [10, 30, 60];
		};
		(_g addWaypoint [_p, 0]) setWaypointType "CYCLE";
		_walkers = _walkers + 1;
	};
	{_x addCuratorEditableObjects [[_u], false]} forEach allCurators;
	_added = _added + 1;
};
["INFO", "civilians", "%1 civilians in the AO (minimum %2) - added %3 (%4 in buildings, %5 walking)", [_have, _min, _added, _added - _walkers, _walkers]] call MCC_fnc_log;
