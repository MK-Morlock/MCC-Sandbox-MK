params ["_mode", ["_az", 0], ["_el", 0]];
private _uav = missionNamespace getVariable ["MCC_ACConsoleUp", objNull];
private _sel = (missionNamespace getVariable ["MCC_ConsoleACweaponSelected", 0]) max 0 min 2;
private _path = [[1], [2], [1]] select _sel;
private _tc = if (isNull _uav) then {configNull} else {[_uav, _path] call BIS_fnc_turretConfig};
private _minT = if (isNumber (_tc >> "minTurn")) then {getNumber (_tc >> "minTurn")} else {-360};
private _maxT = if (isNumber (_tc >> "maxTurn")) then {getNumber (_tc >> "maxTurn")} else {360};
private _minE = if (isNumber (_tc >> "minElev")) then {getNumber (_tc >> "minElev")} else {-90};
private _maxE = if (isNumber (_tc >> "maxElev")) then {getNumber (_tc >> "maxElev")} else {90};
if (_mode == "limits") exitWith {[_minT, _maxT, _minE, _maxE]};
if (_mode == "center") exitWith {[(_minT + _maxT) / 2, (_minE + _maxE) / 2]};
if (_mode == "eye") exitWith {if (isNull _uav) then {[0, 0, 0]} else {_uav modelToWorldVisual [-6, 2, -5]}};
if (_mode == "dir") exitWith {
	private _l = [-(sin _az) * (cos _el), (cos _az) * (cos _el), sin _el];
	if (isNull _uav) then {_l} else {_uav vectorModelToWorldVisual _l}
};
if (_mode == "angles") exitWith {
	if (isNull _uav || {!(_az isEqualType []) || {count _az < 3}}) exitWith {[(_minT + _maxT) / 2, (_minE + _maxE) / 2]};
	private _rel = _uav vectorWorldToModelVisual ((AGLToASL _az) vectorDiff (AGLToASL (["eye"] call MCC_fnc_acAim)));
	private _m = (vectorMagnitude _rel) max 0.001;
	[(-(_rel select 0)) atan2 (_rel select 1), asin ((_rel select 2) / _m)]
};
if (_mode == "ground") exitWith {
	private _eye = ["eye"] call MCC_fnc_acAim;
	private _dir = ["dir", _az, _el] call MCC_fnc_acAim;
	private _from = AGLToASL _eye;
	private _hit = lineIntersectsSurfaces [_from, _from vectorAdd (_dir vectorMultiply 8000), _uav, objNull, true, 1];
	if (count _hit > 0) then {ASLToAGL ((_hit select 0) select 0)} else {ASLToAGL (_from vectorAdd (_dir vectorMultiply 3000))}
};
[(_az max _minT) min _maxT, (_el max _minE) min _maxE]
