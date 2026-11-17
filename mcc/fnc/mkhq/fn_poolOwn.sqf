// MCCMK_fnc_poolOwn - as MCCMK_fnc_pool: the faction's own, then a sibling faction's, then - with the "Vanilla vehicle
// fallback" setting on (the default) - the side's vanilla vehicle; off, only the faction's (and its siblings') own kit.
// (Kept as its own name for the systems that used it.) [faction, kind, (content setting)] -> [classes]
params [["_fac", "", [""]], ["_kind", "Inf", [""]], ["_mode", -1, [0]]];
[_fac, _kind, _mode] call MCCMK_fnc_pool
