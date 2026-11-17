/*
    ANC_fnc_notice  (client)
    A short message in Arma's own notification box, top right. [text]
*/
params [["_msg", "", [""]]];
if (!hasInterface || {_msg isEqualTo ""}) exitWith {};
["ANC_Notice", [[_msg] call ANC_fnc_keys]] call BIS_fnc_showNotification;
