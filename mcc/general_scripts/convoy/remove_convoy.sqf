/*
	Convoy panel: Remove
	Deletes the convoy - every convoy vehicle with its crew and passengers (the HVT too) and their groups, so their
	waypoints go as well - removes the waypoint markers and cancels placing a convoy. Press Spawn to make a new one.
*/
if (missionNamespace getVariable ["mcc_isloading", false]) exitWith {};
if (mcc_missionmaker != (name player)) exitWith {player globalchat "Access Denied"};

MCC_convoyPlacing = false;
onMapSingleClick "";
click = false;
{deleteMarkerLocal _x} forEach ["marker1", "marker2", "marker3", "marker4", "marker5"];

private _vehicles = (missionNamespace getVariable ["MCC_convoyVehicles", []]) select {!isNull _x};
if (_vehicles isEqualTo []) exitWith {hint "No convoy to remove.\nPress Spawn to place one."};

//On the server (the convoy is made there)
[1, {
	private _groups = [];
	{
		private _veh = _x;
		{_groups pushBackUnique (group _x); _veh deleteVehicleCrew _x} forEach (crew _veh);
		deleteVehicle _veh;
	} forEach ((missionNamespace getVariable ["MCC_convoyVehicles", []]) select {!isNull _x});
	{if (!isNull _x) then {{deleteVehicle _x} forEach (units _x); deleteGroup _x}} forEach _groups;
	missionNamespace setVariable ["MCC_convoyVehicles", [], true];
}] remoteExec ["MCC_fnc_globalExecute", 2, false];

hint format ["Convoy removed (%1 vehicles).\nPress Spawn to place a new convoy.", count _vehicles];
