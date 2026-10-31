params [["_c", [], [[]]], ["_r", 100, [0]], ["_label", "", [""]], ["_roadFirst", false, [false]]];
if (count _c < 2) exitWith {[]};
_c = [_c select 0, _c select 1, 0];
private _step = 1;
private _pos = [];
if (!_roadFirst) then {
	_pos = [_c, _r * 0.4] call MCC_fnc_landSpot;
	if (_pos isEqualTo []) then {_step = 2; _pos = [_c, _r, 30] call MCC_fnc_landSpot};
	if (_pos isEqualTo []) then {
		_step = 3;
		for "_t" from 1 to 30 do {
			private _p = _c getPos [_r * sqrt (random 1), random 360];
			_p = [_p select 0, _p select 1, 0];
			if (!(surfaceIsWater _p) && {!([_p] call MCC_fnc_posOnBuilding)} && {((nearestTerrainObjects [_p, ["ROCK", "ROCKS"], 30, false, true]) findIf {((_x distance2D _p) - (((boundingBoxReal _x) select 2) * 0.5)) < 1}) < 0}) exitWith {_pos = _p};
		};
	};
};
if (_pos isEqualTo []) then {
	private _road = [_c, 1000 max _r] call BIS_fnc_nearestRoad;
	if (!isNull _road) then {
		_step = 4;
		private _rp = getPosATL _road;
		_rp set [2, 0];
		private _info = getRoadInfo _road;
		private _rd = if ((count _info > 7) && {((_info select 6) distance2D (_info select 7)) > 0.5}) then {(_info select 6) getDir (_info select 7)} else {getDir _road};
		{
			private _p = _rp getPos [6, _rd + _x];
			_p = [_p select 0, _p select 1, 0];
			if (!(surfaceIsWater _p) && {!([_p] call MCC_fnc_posOnBuilding)}) exitWith {_pos = _p};
		} forEach [90, -90];
		if (_pos isEqualTo []) then {_pos = _rp};
	};
};
if (_pos isEqualTo []) then {
	_step = 5;
	_pos = _c;
	if (surfaceIsWater _c) then {
		private _s = [_c, 0, (_r * 2) max 200, 1, 0, 0.6, 0, [], [[-500,-500,0],[-500,-500,0]]] call BIS_fnc_findSafePos;
		if !(_s isEqualTo [-500,-500,0]) then {_pos = [_s select 0, _s select 1, 0]};
	};
};
if ((_step > 1 || {_roadFirst}) && {missionNamespace getVariable ["MCC_debug", false]}) then {
	["DEBUG", "MCC_fnc_fallbackSpot", "%1: fallback step %2 used near %3 - placed at %4", [_label, _step, mapGridPosition _c, mapGridPosition _pos]] call MCC_fnc_log;
};
_pos
