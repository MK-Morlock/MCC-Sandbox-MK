params [["_g", grpNull]];
if (isNull _g) exitWith {};
private _p = [];
private _now = _g getVariable ["MCCMK_wpNow", []];
if (_now isNotEqualTo []) then {_p pushBack _now};
{_p pushBack [_x select 0, [_x select 3] call MCCMK_fnc_wpLabel]} forEach (_g getVariable ["MCCMK_wpQ", []]);
_g setVariable ["MCCMK_wpPlan", _p, true];
