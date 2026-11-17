params [["_fac", "", [""]], ["_scope", 2, [0]]];
if (_fac == "") exitWith {[]};
private _facs = ([_fac, _scope] call MCCMK_fnc_scopeFactions) apply {toLower _x};
if ((count _facs) <= 1) exitWith {+([_fac] call MCC_fnc_factionClasses)};
private _key = format ["MCCMK_scopeClasses_%1_%2", toLower _fac, _scope];
private _cached = uiNamespace getVariable _key;
if (!isNil "_cached") exitWith {+_cached};
private _lc = toLower _fac;
private _all = (format ["getNumber (_x >> 'scope') == 2 && {(toLower getText (_x >> 'faction')) in %1}", _facs]) configClasses (configFile >> "CfgVehicles");
private _own = _all select {(toLower getText (_x >> "faction")) == _lc};
private _rest = _all select {(toLower getText (_x >> "faction")) != _lc};
private _out = _own + _rest;
uiNamespace setVariable [_key, _out];
+_out
