/*
	MCCMK_fnc_factionFamily - a faction's family: the factions it borrows vehicles from when it has none of a kind (the
	second step of MCCMK_fnc_pools, before the side's vanilla vehicle). Same side first, then the other sides - only their
	vehicles are borrowed; the crews are always the faction's own.
	  Base game and DLC: exact families - FIA (all three sides), CSAT (with CSAT Pacific), NATO (with NATO Pacific,
	  Woodland and CTRG); AAF, LDF, Syndikat, Spetsnaz, Gendarmerie, Looters each on their own.
	  Mods: factions from the same mod with the same name core once the mod prefix and side markers are taken off
	  (CUP_O_TK, CUP_O_TK_MILITIA and CUP_I_TK_GUE are one family; CUP_O_RU another).
	Never another mod's factions. Cached for the game session. [faction] -> [factions]
*/
params [["_fac", "", [""]]];
if (_fac == "") exitWith {[]};
private _key = "MCCMK_family_" + toLower _fac;
private _cached = uiNamespace getVariable _key;
if (!isNil "_cached") exitWith {+_cached};
private _cfgF = configFile >> "CfgFactionClasses";
private _lc = toLower _fac;
private _sideOf = {params ["_f"]; [_f] call MCC_fnc_factionSide};
private _mySide = [_fac] call _sideOf;
private _tables = [
	["blu_g_f", "opf_g_f", "ind_g_f"],
	["opf_f", "opf_t_f"],
	["blu_f", "blu_t_f", "blu_w_f", "blu_ctrg_f"],
	["ind_f"], ["ind_e_f"], ["ind_c_f"], ["opf_r_f"], ["blu_gen_f"], ["ind_l_f"]
];
private _fam = [];
private _t = _tables findIf {_lc in _x};
if (_t >= 0) then {
	_fam = ((_tables select _t) - [_lc]) select {isClass (_cfgF >> _x)} apply {configName (_cfgF >> _x)};
} else {
	// a mod's faction: the same mod, the same name core (the mod prefix and the side markers taken off)
	private _core = {
		params ["_n"];
		private _tk = ((toLower _n) splitString "_") - ["b", "o", "i", "c", "blu", "opf", "ind", "civ", "west", "east", "guer", "indep", "resistance", "f", "faction"];
		if (count _tk > 1) then {_tk deleteAt 0};	// the mod prefix (cup, rhs, uk3cb, lop...)
		_tk param [0, ""]
	};
	private _myCore = [_fac] call _core;
	private _mod = toLower ([_cfgF >> _fac] call MCCMK_fnc_classSource);
	if (_myCore != "") then {
		{
			private _f = configName _x;
			if (toLower _f != _lc && {isNumber (_x >> "side")} && {getNumber (_x >> "side") in [0, 1, 2]} && {(toLower ([_x] call MCCMK_fnc_classSource)) == _mod} && {([_f] call _core) == _myCore}) then {_fam pushBack _f};
		} forEach ("true" configClasses _cfgF);
	};
};
// the same side first
private _same = _fam select {([_x] call _sideOf) isEqualTo _mySide};
_fam = _same + (_fam - _same);
uiNamespace setVariable [_key, _fam];
+_fam
