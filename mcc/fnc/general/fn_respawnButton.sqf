/*================================================================== MCC_fnc_respawnButton ==================================================================
	Text and tooltip of the console respawn button (idc 9140): what a click does next.
==============================================================================================================================================================*/
disableSerialization;
private _d = uiNamespace getVariable ["MCC_groupGen_Dialog", displayNull];
if (isNull _d) exitWith {};
private _b = _d displayCtrl 9140;
_b ctrlEnable true;
if (missionNamespace getVariable ["MCC_TRAINING", true]) then {
	_b ctrlSetText "Disable Respawn";
	_b ctrlSetTooltip "Switch respawn off for all players: players who die go to spectator mode";
} else {
	_b ctrlSetText "Enable Respawn";
	_b ctrlSetTooltip "Switch respawn on again for all players: players in spectator mode return to their start location";
};
