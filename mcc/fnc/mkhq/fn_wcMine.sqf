/*
	MCCMK_fnc_wcMine - (server) a mine an AI unit has just placed (MCCMK_fnc_worldCleanup): removed after 60 minutes once
	no player is within 200 m. (Players' mines and the MCC console's IEDs and minefields never come here.) [mine]
*/
params [["_m", objNull, [objNull]]];
if (!isServer || {isNull _m}) exitWith {};
[_m] spawn {
	params ["_m"];
	sleep 3600;
	while {!isNull _m} do {
		if (((call MCCMK_wcPeople) findIf {(_x distance _m) < 200}) < 0) exitWith {deleteVehicle _m};
		sleep 120;
	};
};
