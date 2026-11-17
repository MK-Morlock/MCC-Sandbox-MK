params [["_cls", "", [""]]];
if (isNil "MCCMK_traverseCache") then {MCCMK_traverseCache = createHashMap};
if (_cls in MCCMK_traverseCache) exitWith {MCCMK_traverseCache get _cls};
private _tur = configFile >> "CfgVehicles" >> _cls >> "Turrets";
private _r = [-360, 360];
if (isClass _tur && {count _tur > 0}) then {
	private _mt = _tur select 0;
	private _mn = getNumber (_mt >> "minTurn");
	private _mx = getNumber (_mt >> "maxTurn");
	if (_mn != 0 || {_mx != 0}) then {_r = [_mn, _mx]};
};
MCCMK_traverseCache set [_cls, _r];
_r
