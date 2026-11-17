params [["_u", objNull, [objNull]]];
if (isNull _u) exitWith {""};
if (isNil "MCCMK_bsCache") then {MCCMK_bsCache = createHashMap};
private _k = hashValue _u;
private _e = MCCMK_bsCache getOrDefault [_k, []];
if (count _e == 2 && {(diag_tickTime - (_e select 1)) < 0.5}) exitWith {_e select 0};
private _s = ([_u] call MCCMK_fnc_boardState) select 0;
MCCMK_bsCache set [_k, [_s, diag_tickTime]];
_s
