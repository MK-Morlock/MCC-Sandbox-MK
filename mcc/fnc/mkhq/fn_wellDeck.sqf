params [["_p", objNull, [objNull]], ["_open", true, [true]]];
if (isNull _p) exitWith {};
playSound3D ["A3\Sounds_F\sfx\alarm_independent.wss", _p];
{_p animate [_x, [0, 1] select _open]} forEach ["door_welldeck", "door_welldeck_2", "door_welldeck_3"];
["INFO", "boarding", "%1 %2 the LHD well deck", [name player, ["closed", "opened"] select _open]] call MCC_fnc_log;
