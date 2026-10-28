/*================================================================== MCC_fnc_toggleRespawn ==================================================================
	Console button Disable Respawn / Enable Respawn (idc 9140 of the MCC console). Switches player respawn off or on for everyone.
	Off: as before (players who die go to spectator mode). On again: players respawn at their start location, and players
	who are in spectator mode because respawn was off are brought back to their start location (MCC_fnc_respawnRestore).
	Respawn on = MCC_TRAINING true (the variable the Respawn event handler in init.sqf reads).
==============================================================================================================================================================*/
disableSerialization;
private _on = !(missionNamespace getVariable ["MCC_TRAINING", true]);	//the new state
MCC_TRAINING = _on;
publicVariable "MCC_TRAINING";
MCC_enable_respawn = true;

if (_on) then {
	["Respawn is on again"] remoteExec ["MCC_fnc_globalHint", 0, "MCC_respawnHint"];
	[] remoteExec ["MCC_fnc_respawnRestore", 0];
} else {
	["Mission started, respawn is off"] remoteExec ["MCC_fnc_globalHint", 0, "MCC_respawnHint"];
};

//The console button shows what a click will do next
[] call MCC_fnc_respawnButton;
