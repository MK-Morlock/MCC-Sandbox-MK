params [["_fac", "", [""]]];
if (_fac == "") exitWith {[]};
private _key = "MCCMK_facVeh_" + toUpper _fac;
if (!isNil _key) exitWith {missionNamespace getVariable _key};
private _F = toUpper _fac;
private _out = ("getNumber (_x >> 'scope') == 2 && {toUpper (getText (_x >> 'faction')) == _F}" configClasses (configFile >> "CfgVehicles")) apply {configName _x};
_out = _out select {(_x isKindOf "AllVehicles") && {!(_x isKindOf "CAManBase")} && {!(_x isKindOf "ParachuteBase")}};
missionNamespace setVariable [_key, _out];
_out
