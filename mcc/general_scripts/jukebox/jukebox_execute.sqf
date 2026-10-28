private "_trigger";

params ["_zone", "_zonePos", "_zoneX", "_zoneY", "_activate", "_cond", "_track"];
MCC_jukeboxMusic = _this select 7;
		
_trigger = createTrigger ["EmptyDetector", _zonePos];
_trigger setpos _zonePos;
_trigger setTriggerArea [_zoneX, _zoneY, 0, true];

if (MCC_jukeboxMusic) then 
{
	_trigger setTriggerStatements ["this",format ["playMusic  '%1'",_track], ""];
} 
else 
{
	_trigger setSoundEffect["ClickSoft", "", "",format ['%1',_track]];
};

_trigger setTriggerActivation [_activate, _cond, false];

