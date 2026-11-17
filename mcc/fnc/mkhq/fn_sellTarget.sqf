params [["_u", objNull, [objNull]]];
if (vehicle _u != _u) exitWith {objNull};
private _v = cursorObject;
if (isNull _v || {(_v distance _u) > 12}) exitWith {objNull};
if (((([_v, _u] call MCCMK_fnc_sellCheck) select 0)) == "") exitWith {objNull};
_v
