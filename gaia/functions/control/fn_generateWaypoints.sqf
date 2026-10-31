/* ----------------------------------------------------------------------------
Function: fnc_CreatePatrolWP

Description:
	Create waypoints for a group

Parameters:
	- Group
	- Zone


Returns:
	Nr of generated waypoints

Author:
	Spirit
---------------------------------------------------------------------------- */

private ["_group", "_newpos ","_zone","_max","_i","_wp"];
_group 		 = _this select 0;
_zone			 = _this select 1;
_goal			 = _this select 2;


//Combined orders store the original location (where he wanted to go before getting in the transporter) in this variable. So check if it holds a position
_newpos = _group getVariable  ["GAIA_OriginalDestination",[]];
_group setVariable ["GAIA_OriginalDestination", [], false];
if (count(_newpos)==0) then
{
		_newpos 	=  [_zone,_goal,(side _group)] call GAIA_fnc_calculateOptimalPosition;
		private _myVeh = vehicle (leader _group);
		if (_myVeh != leader _group && {_myVeh isKindOf "LandVehicle"}) then {
			private _taken = (allGroups select {_x != _group && {(vehicle (leader _x)) isKindOf "LandVehicle"} && {(vehicle (leader _x)) != (leader _x)} && {count (waypoints _x) > 0}}) apply {waypointPosition [_x, currentWaypoint _x]};
			for "_try" from 1 to 5 do {
				if (count _newpos == 0 || {(_taken findIf {(_x distance2D _newpos) < 75}) < 0}) exitWith {};
				_newpos = [_zone,_goal,(side _group)] call GAIA_fnc_calculateOptimalPosition;
			};
		};

};


if (count(_newpos)>0) then
{
	private _veh = vehicle (leader _group);
	if (_veh == leader _group) then {_veh = assignedVehicle (leader _group)};
	private _h = getTerrainHeightASL _newpos;
	if (!isNull _veh && {_veh isKindOf "Car"} && {!(isOnRoad _newpos)} && {
		(((surfaceNormal _newpos) select 2) < 0.966)
		|| {([0, 90, 180, 270] findIf {abs ((getTerrainHeightASL (_newpos getPos [25, _x])) - _h) > 6.7}) >= 0}
		|| {!((nearestTerrainObjects [_newpos, ["ROCK", "ROCKS"], 6, false, true]) isEqualTo [])}
		|| {([0, 90, 180, 270] findIf {surfaceIsWater (_newpos getPos [15, _x])}) >= 0}
	}) then {
		private _roads = _newpos nearRoads 300;
		if (count _roads > 0) then {
			private _near = _roads select 0;
			{if ((_x distance2D _newpos) < (_near distance2D _newpos)) then {_near = _x}} forEach _roads;
			_newpos = getPos _near;
		};
	};
 	//Now where ever a unit has last been, place a breadcrumb (so even static guards).
 	// This is used for making the patrols as optimized as possible. We try to avoid those positions.

	_dummy 	=  [_group,_newpos,"MOVE"] call GAIA_fnc_addWaypoint;
};




_newpos