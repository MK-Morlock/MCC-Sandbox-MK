// (MK) (server) Places a Taru pod in the RTS base: within 150 m of the Aerial Workshop, on dry, clear ground; the side
// pays (unless costs are Free). [kind, position, direction, caller, workshop]
params [["_kind", "box", [""]], ["_pos", [0, 0, 0], [[]]], ["_dir", 0, [0]], ["_u", objNull, [objNull]], ["_ws", objNull, [objNull]]];
if (!isServer || {isNull _u}) exitWith {};
private _say = {params ["_m"]; [_m] remoteExec ["MCCMK_fnc_hint", _u]};
private _side = side group _u;
_pos = [_pos select 0, _pos select 1, 0];
if (isNull _ws || {(_ws distance2D _pos) > 150}) exitWith {["The pod has to go inside the base - within 150 m of the Aerial Workshop."] call _say};
if (surfaceIsWater _pos) exitWith {["Not in the water."] call _say};
if (count ((nearestObjects [_pos, ["AllVehicles", "Building", "Static", "Thing"], 4]) select {!(_x isKindOf "Man")}) > 0) exitWith {["Something is in the way there - pick a clear spot."] call _say};
([_kind] call MCCMK_fnc_rtsPodCost) params ["_label", "_cost"];
private _paid = true;
if !(call MCCMK_fnc_resFree) then {
	private _var = format ["MCC_res%1", _side];
	private _r = +(missionNamespace getVariable [_var, [0, 0, 0, 0, 0]]);
	if ((_cost findIf {(_r select (["ammo", "repair", "fuel", "food", "med"] find (_x select 0))) < (_x select 1)}) >= 0) then {
		_paid = false;
	} else {
		{private _i = ["ammo", "repair", "fuel", "food", "med"] find (_x select 0); _r set [_i, (_r select _i) - (_x select 1)]} forEach _cost;
		missionNamespace setVariable [_var, _r];
		publicVariable _var;
	};
};
if (!_paid) exitWith {["Not enough resources for that pod."] call _say};
private _cls = ([_side, _kind] call MCCMK_fnc_podClasses) select 1;
private _pod = createVehicle [_cls, _pos, [], 0, "CAN_COLLIDE"];
_pod setDir _dir;
_pod setVectorUp (surfaceNormal _pos);
_pod setVariable ["MCCMK_podSide", _side, true];
{_x addCuratorEditableObjects [[_pod], false]} forEach allCurators;
[format ["%1 pod placed.", _label]] call _say;
["INFO", "pods", "%1 placed a %2 pod (%3) in the base at grid %4", [name _u, _label, _cls, mapGridPosition _pos]] call MCC_fnc_log;
