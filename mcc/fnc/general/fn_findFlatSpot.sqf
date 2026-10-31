params [["_pos", [], [[]]], ["_maxRange", 250, [0]], ["_footprint", 20, [0]]];
private _fp = (_footprint max 12) min 60;
private _reserved = missionNamespace getVariable ["MCC_MWPlacedSpots", []];
if (count _pos < 2) exitWith {[]};
private _c = [_pos select 0, _pos select 1, 0];
private _zone = "";
{
	private _m = str _x;
	if ((markerShape _m) != "" && {_c inArea _m}) exitWith {_zone = _m};
} forEach (missionNamespace getVariable ["MCC_zones_numbers", []]);
private _range = _maxRange;
if (_zone != "") then {
	private _sz = markerSize _zone;
	_range = (_c distance2D (getMarkerPos _zone)) + sqrt (((_sz select 0) ^ 2) + ((_sz select 1) ^ 2));
};
_range = _range max 60;
private _f = 1 max (_range / 500);
private _ringStep = 20 * _f;
private _arcStep = 25 * _f;
private _best = [];
{
	_x params ["_grad", "_rad", "_needFlat", "_needOpen"];
	private _bestScore = 1e9;
	for "_d" from 0 to _range step _ringStep do {
		private _n = if (_d == 0) then {1} else {(ceil ((2 * pi * _d) / _arcStep)) max 8};
		private _step = 360 / _n;
		for "_i" from 0 to (_n - 1) do {
			private _p = if (_d == 0) then {_c} else {_c getPos [_d, _i * _step]};
			if ((_zone == "" || {_p inArea _zone}) && {!(surfaceIsWater _p)} && {!isOnRoad _p} && {(count (_p nearRoads (_fp max 15))) == 0} && {!_needFlat || {!((_p isFlatEmpty [-1, -1, _grad, _rad, 0, false]) isEqualTo [])}}) then {
				private _h = getTerrainHeightASL _p;
				private _dev = 0;
				private _wet = false;
				{
					private _q = _p getPos [_x select 0, _x select 1];
					if (surfaceIsWater _q) exitWith {_wet = true};
					_dev = _dev max (abs ((getTerrainHeightASL _q) - _h));
				} forEach ([0, 45, 90, 135, 180, 225, 270, 315] apply {[_fp, _x]}) + ([0, 45, 90, 135, 180, 225, 270, 315] apply {[_fp * 0.5, _x]});
				if (_wet) then {continue};
				if ((_reserved findIf {(_p distance2D (_x select 0)) < ((_x select 1) + _fp + 10)}) >= 0) then {continue};
				if !((_p nearEntities [["LandVehicle", "Air", "Ship", "StaticWeapon"], _fp]) isEqualTo []) then {continue};
				if (_needOpen && {[_p, _fp] call MCC_fnc_structuresNear}) then {continue};
				private _score = _dev + (_d * 0.002);
				if (_score < _bestScore) then {_bestScore = _score; _best = [_p select 0, _p select 1, 0]};
			};
		};
	};
	if (count _best > 0) exitWith {};
} forEach [[0.12, _fp, true, true], [0.2, _fp, true, true], [1, _fp, false, true], [0.12, _fp, true, false], [0.2, _fp, true, false], [1, _fp, false, false]];
_best
