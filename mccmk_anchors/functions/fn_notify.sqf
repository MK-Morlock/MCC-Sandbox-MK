/*
 ANC_fnc_notify
 - shows a short message to this player.
*/
params [["_msg", "", [""]]];
if (!hasInterface || {_msg isEqualTo ""}) exitWith {};
hintSilent ([_msg] call ANC_fnc_keys); // the player's own keys in place of {anchor}, {tow} etc.
