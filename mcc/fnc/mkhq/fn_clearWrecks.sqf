/*
	MCCMK_fnc_clearWrecks  (server) - the RTS HQ's "Clear wrecks": every wreck within 300 m of the HQ removed,
	free (no salvage reward). [workshop, caller]
*/
params [["_ws", objNull, [objNull]], ["_u", objNull, [objNull]]];
if (!isServer || {isNull _ws}) exitWith {};
private _w = allDead select {!(_x isKindOf "Man") && {(_x distance2D _ws) < 300}};
{{deleteVehicle _x} forEach (crew _x); deleteVehicle _x} forEach _w;
if (!isNull _u) then {[[format ["%1 wreck(s) cleared from the base.", count _w], "No wrecks in the base."] select (count _w == 0)] remoteExec ["MCCMK_fnc_hint", _u]};
["INFO", "salvage", "Clear wrecks at %1: %2 removed", [mapGridPosition _ws, count _w]] call MCC_fnc_log;
