/*====================================================== MCC_fnc_MusicTrigger ==========================================================
	Execute music or sound on all clients triggers
========================================================================================================================================*/
private "_trigger";

params ["_zone", "_zonePos", "_zoneX", "_zoneY", "_activate", "_cond", "_track", "_jukeBoxMusic"];

_trigger = createTrigger ["EmptyDetector", _zonePos];
_trigger setpos _zonePos;
_trigger setTriggerArea [_zoneX, _zoneY, 0, true];

if (_jukeBoxMusic) then {
	_trigger setTriggerStatements ["this",format ["playMusic  '%1'",_track], ""];
} else {
	if (isClass(configFile >> "CfgSounds" >> _track) || isClass(missionconfigFile >> "CfgSounds" >> _track)) then {
		_trigger setTriggerStatements ["this",format ["playSound '%1'",_track], ""];
	} else {
		_trigger setSoundEffect["ClickSoft", "", "",format ['%1',_track]];
	};
};

_trigger setTriggerActivation [_activate, _cond, false];

