/*
    ANC_fnc_hullDist  (any computer)
    (MK) The distance from someone (or a point) to the nearest edge of a boat's hull, seen from above (its rectangle -
    ANC_fnc_hullOutline); 0 inside it. Used for Board Boat on foot and the distances shown in its menus.
    [unit or position ASL, boat] -> metres
*/
params ["_u", "_b"];
private _p = if (_u isEqualType objNull) then {getPosASL _u} else {_u};
(_b call ANC_fnc_hullOutline) params ["_cx", "_sY", "_bY", "_hw"];
private _m = _b worldToModel (ASLToAGL _p);
private _dx = (_m select 0) - (((_m select 0) max (_cx - _hw)) min (_cx + _hw));
private _dy = (_m select 1) - (((_m select 1) max _sY) min _bY);
sqrt ((_dx * _dx) + (_dy * _dy))
