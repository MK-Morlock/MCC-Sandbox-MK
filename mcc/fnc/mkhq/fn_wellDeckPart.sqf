params [["_u", objNull, [objNull]]];
private _v = vehicle _u;
if (_v == _u || {!(_v isKindOf "Ship")} || {_v getVariable ["MCC_isLHD", false]}) exitWith {objNull};
if (((missionNamespace getVariable ["MCC_staticShips", []]) findIf {!isNull _x && {(_x getVariable ["MCC_ShipType", 0]) == 3}}) < 0) exitWith {objNull};
private _parts = nearestObjects [_v, ["CUP_LHD_7"], 350];
if (_parts isEqualTo []) exitWith {objNull};
private _p = _parts select 0;
private _pt = _p modelToWorld (_p selectionPosition "door_welldeck_action_rear");
if ((_v distance2D _pt) > 60) exitWith {objNull};
_p
