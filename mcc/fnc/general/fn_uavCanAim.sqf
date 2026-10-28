params [["_uav", objNull, [objNull]], ["_wpn", [], [[]]], ["_aim", [0, 0, 0], [[]]]];
if (!alive _uav || {count _wpn < 6}) exitWith {[false, "no weapon"]};
private _path = _wpn select 5;
private _to = (getPosASL _uav) vectorFromTo (AGLToASL _aim);
private _rel = _uav vectorWorldToModel _to;
private _turn = -((_rel select 0) atan2 (_rel select 1));
private _elev = asin ((_rel select 2) max -1 min 1);
if (_path isEqualTo [-1]) exitWith {
	private _cone = getNumber (configFile >> "CfgAmmo" >> (_wpn select 3) >> "missileLockCone");
	if (_cone <= 0) exitWith {[true, ""]};
	private _off = acos (((_rel select 1) max -1) min 1);
	[_off <= _cone, format ["%1 deg off the nose, lock cone %2", round _off, _cone]]
};
private _tc = [_uav, _path] call BIS_fnc_turretConfig;
private _minT = if (isNumber (_tc >> "minTurn")) then {getNumber (_tc >> "minTurn")} else {-360};
private _maxT = if (isNumber (_tc >> "maxTurn")) then {getNumber (_tc >> "maxTurn")} else {360};
private _minE = if (isNumber (_tc >> "minElev")) then {getNumber (_tc >> "minElev")} else {-90};
private _maxE = if (isNumber (_tc >> "maxElev")) then {getNumber (_tc >> "maxElev")} else {90};
private _turnOk = (_maxT - _minT >= 360) || {_turn >= _minT && {_turn <= _maxT}} || {(_turn - 360) >= _minT && {(_turn - 360) <= _maxT}} || {(_turn + 360) >= _minT && {(_turn + 360) <= _maxT}};
private _elevOk = _elev >= _minE && {_elev <= _maxE};
[_turnOk && _elevOk, format ["turn %1 (limits %2 to %3), elevation %4 (limits %5 to %6)", round _turn, _minT, _maxT, round _elev, _minE, _maxE]]
