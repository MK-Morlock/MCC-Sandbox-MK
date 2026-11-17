/*
	MCCMK_fnc_clearBodies  (server) - the RTS HQ's "Clear bodies": every body within 300 m of the HQ removed, with the
	weapons lying beside it. Not players' own bodies (the body cleanup takes those later, so their kit can be recovered),
	and not one being carried or dragged. [HQ, caller]
*/
params [["_hq", objNull, [objNull]], ["_u", objNull, [objNull]]];
if (!isServer || {isNull _hq}) exitWith {};
private _b = allDeadMen select {
	((_x distance2D _hq) < 300) && {isNull (attachedTo _x)} && {(vehicle _x) isEqualTo _x} && {!(_x getVariable ["MCCMK_wasPlayer", false])}
};
{
	{deleteVehicle _x} forEach (nearestObjects [_x, ["GroundWeaponHolder", "WeaponHolderSimulated"], 3]);
	deleteVehicle _x;
} forEach _b;
if (!isNull _u) then {[[format ["%1 bod%2 cleared from the base.", count _b, ["ies", "y"] select (count _b == 1)], "No bodies in the base."] select (count _b == 0)] remoteExec ["MCCMK_fnc_hint", _u]};
["INFO", "cleanup", "Clear bodies at %1: %2 removed", [mapGridPosition _hq, count _b]] call MCC_fnc_log;
