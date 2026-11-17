// MCCMK_fnc_pool - a copy of one of a faction's pools (MCCMK_fnc_pools): its own, then a sibling faction's, then - with the
// "Vanilla vehicle fallback" setting on (the default) - the side's vanilla vehicle. [faction, kind, (content setting)] -> [classes]
params [["_fac", "", [""]], ["_kind", "Inf", [""]], ["_mode", -1, [0]]];
private _p = [_fac, false, _mode] call MCCMK_fnc_pools;
if (!(missionNamespace getVariable ["MCCMK_vanillaFallback", true]) && {_kind in (_p getOrDefault ["vanilla", []])}) exitWith {[]};
+(_p getOrDefault [_kind, []])
