/*================================================================== MCC_fnc_respawnRestore ==================================================================
	Runs on every player when respawn is switched on again (MCC_fnc_toggleRespawn). A player who is in spectator mode
	because respawn was off (in MCC_deadGroup, attached out of the way, made harmless) is brought back: spectator closed,
	detached, no longer captive, back in a group of his own side, and sent to his start location as after a normal respawn.
==============================================================================================================================================================*/
if (!hasInterface) exitWith {};
if (isNil "MCC_deadGroup" || {group player != MCC_deadGroup}) exitWith {};
[] spawn {
	while {dialog} do {closeDialog 0};	//closes the spectator (it runs while its dialog is open)
	sleep 1;
	detach player;
	player setCaptive false;
	private _side = [getNumber (configFile >> "CfgVehicles" >> typeOf player >> "side")] call BIS_fnc_sideType;
	private _grp = createGroup [_side, true];
	[player] joinSilent _grp;
	cutText ["", "BLACK IN", 2];
	[] spawn MCC_fnc_startLocations;
};
