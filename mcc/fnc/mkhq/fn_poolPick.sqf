// MCCMK_fnc_poolPick - a class from a faction's pool (MCCMK_fnc_pool - the vanilla step only with the "Vanilla vehicle
// fallback" setting on): the infantry by its weights, others at random. [faction, kind] -> class ("" = none)
params [["_fac", "", [""]], ["_kind", "Inf", [""]]];
private _l = [_fac, _kind] call MCCMK_fnc_pool;
if (_l isEqualTo []) exitWith {""};
if (_kind == "Inf") then {
	private _p = [_fac] call MCCMK_fnc_pools;
	private _all = _p getOrDefault ["Inf", []];
	private _w = _p getOrDefault ["InfWeights", []];
	if (count _w == count _all && {(_w findIf {_x > 0}) >= 0}) exitWith {_all selectRandomWeighted _w};
	selectRandom _l
} else {selectRandom _l}
