/*
	MCCMK_fnc_sarHome - (server) where a rescue without a ship takes people: [side, from, for a boat?] ->
	  helicopter: a clear landing spot at the side's nearest HQ or F.O.B. (its respawn positions), else at the nearest dry
	              land (searched outwards in 250 m rings, to 8 km);
	  boat (a tow): the nearest open water (2 m deep or more) within 3 km of that HQ or F.O.B. ([] if none).
*/
params [["_side", sideUnknown], ["_from", [0, 0, 0]], ["_water", false]];
private _bases = (([_side, false] call BIS_fnc_getRespawnPositions) apply {
	if (_x isEqualType "") then {getMarkerPos _x} else {if (_x isEqualType objNull) then {getPos _x} else {_x}}
}) select {(_x select 0) > 0};
private _dest = [];
if (_bases isNotEqualTo []) then {
	_bases = _bases apply {[_x distance2D _from, _x]};
	_bases sort true;
	_dest = (_bases select 0) select 1;
};
if (!_water) exitWith {
	if (_dest isEqualTo []) then {
		for "_r" from 250 to 8000 step 250 do {
			private _hit = [];
			for "_a" from 0 to 345 step 15 do {private _p = _from getPos [_r, _a]; if !(surfaceIsWater _p) exitWith {_hit = _p}};
			if (_hit isNotEqualTo []) exitWith {_dest = _hit};
		};
	};
	if (_dest isEqualTo []) then {_dest = _from};
	private _s = [[_dest select 0, _dest select 1, 0], 1, 11] call MCCMK_fnc_lzSpots;
	if (_s isEqualTo []) then {[_dest select 0, _dest select 1, 0]} else {_s select 0}
};
if (_dest isEqualTo []) exitWith {[]};
private _w = [];
for "_r" from 100 to 3000 step 100 do {
	for "_a" from 0 to 345 step 15 do {private _p = _dest getPos [_r, _a]; if (surfaceIsWater _p && {(getTerrainHeightASL _p) < -2}) exitWith {_w = [_p select 0, _p select 1, 0]}};
	if (_w isNotEqualTo []) exitWith {};
};
_w
