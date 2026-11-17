params [["_ship", objNull, [objNull]], ["_on", true, [true]]];
if (isNull _ship) exitWith {};
_ship setVariable ["MCCMK_radarOn", _on, true];
_ship setVariable ["MCCMK_radarRange", [_ship] call MCCMK_fnc_radarRange, true];
{if (!isNull _x && {alive _x}) then {[_x, _on] remoteExec ["MCCMK_fnc_shipRadarLocal", _x]}} forEach (_ship getVariable ["MCCMK_weapons", []]);
["INFO", "ships", "%1: radar and data link %2", [_ship getVariable ["MCC_LHDDisplayName", "ship"], ["off", "on"] select _on]] call MCC_fnc_log;
