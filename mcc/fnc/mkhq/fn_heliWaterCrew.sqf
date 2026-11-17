/*
	MCCMK_fnc_heliWaterCrew - (server) an aircraft on the water: its AI crew are told to stay in it though it can't move
	(allowCrewInImmobile). [aircraft]
*/
params [["_h", objNull]];
if (!isServer || {isNull _h}) exitWith {};
[_h, true] remoteExec ["allowCrewInImmobile", _h];
