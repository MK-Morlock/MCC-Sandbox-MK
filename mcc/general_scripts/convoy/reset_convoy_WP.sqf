/*
	Convoy panel: Reset
	Removes the convoy waypoint markers and cancels placing them (the map clicks stop). Nothing more until Spawn is
	pressed again. (It used to start asking for new waypoints straight away, so the next map click put markers back.)
	A placed convoy is not touched: Remove deletes it.
*/
if (missionNamespace getVariable ["mcc_isloading", false]) exitWith {};
if (mcc_missionmaker != (name player)) exitWith {player globalchat "Access Denied"};

MCC_convoyPlacing = false;
onMapSingleClick "";
click = false;
{deleteMarkerLocal _x} forEach ["marker1", "marker2", "marker3", "marker4", "marker5"];
hint "Convoy reset: waypoint markers removed.\nPress Spawn to place the convoy again.";
