params [["_fac", "", [""]], ["_scope", 2, [0]]];
if (_fac == "") exitWith {[]};
private _cfgF = configFile >> "CfgFactionClasses";
if (missionNamespace getVariable ["MCC_debug", false] && {isNil {uiNamespace getVariable "MCCMK_scopeFacsLogged"}}) then {
	uiNamespace setVariable ["MCCMK_scopeFacsLogged", true];
	private _all = ("isNumber (_x >> 'side') && {getNumber (_x >> 'side') in [0, 1, 2, 3]}" configClasses _cfgF) apply {format ["%1 (%2, side %3)", configName _x, getText (_x >> "displayName"), getNumber (_x >> "side")]};
	for "_i" from 0 to ((count _all) - 1) step 12 do {
		["INFO", "factions", "loaded: %1", [(_all select [_i, 12]) joinString "; "]] call MCC_fnc_log;
	};
};
if !(_scope in [1, 3, 4, 5]) exitWith {[_fac]};
private _key = format ["MCCMK_scopeFacs_%1_%2", toLower _fac, _scope];
private _cached = uiNamespace getVariable _key;
if (!isNil "_cached") exitWith {+_cached};
private _lc = toLower _fac;
private _side = getNumber (_cfgF >> _fac >> "side");
private _out = [_fac];
if (_scope >= 4) then {
	{
		if ((toLower (configName _x)) != _lc) then {_out pushBack (configName _x)};
	} forEach ((if (_scope == 5) then {"isNumber (_x >> 'side') && {getNumber (_x >> 'side') in [0, 1, 2, 3]}"} else {format ["isNumber (_x >> 'side') && {getNumber (_x >> 'side') == %1}", _side]}) configClasses _cfgF);
} else {
	private _tables = [
		["blu_f", "blu_t_f", "blu_w_f", "blu_ctrg_f", "blu_nato_lxws"],
		["opf_f", "opf_t_f"]
	];
	private _t = _tables findIf {_lc in _x};
	if (_t >= 0) then {
		{
			if (_x != _lc && {isClass (_cfgF >> _x)} && {getNumber (_cfgF >> _x >> "side") == _side}) then {_out pushBack (configName (_cfgF >> _x))};
		} forEach (_tables select _t);
	};
};
uiNamespace setVariable [_key, +_out];
_out
