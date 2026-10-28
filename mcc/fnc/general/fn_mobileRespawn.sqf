//==================================================================MCC_fnc_mobileRespawn===============================================================================================
// will move the respawn marker to the current position of the unit while the unit is alive, if the unit dead will move the marker to the prvious location
// Example:[_dummy, _respawnMarker, _respawnStart"] call MCC_fnc_mobileRespawn; 
// _dummy = unit, the unit players will spawn in it. 
// _respawnMarker = string "RESPAWN_WEST", "RESPAWN_EAST", "RESPAWN_GUERRILA"
// _respawnStart = position, the default respawn point if the mobile one is destroyed.
//==================================================================================================================================================================================
private _safePos = [];
params ["_dummy", "_respawnMarker", "_respawnStart"];
while {(Alive _dummy)} do
	{
		_safePos = [(getPos _dummy),1,10,1,0,900,0] call BIS_fnc_findSafePos;
		sleep 1;
		_respawnMarker setMarkerPos _safePos;
	};
_respawnMarker setMarkerPos _respawnStart;

