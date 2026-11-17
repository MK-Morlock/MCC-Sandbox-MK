/*
	MCCMK_fnc_lzSpots - (server) where pickup aircraft land, chosen the way Arma's own landing chooses: the aimed spot if
	it's flat and clear enough for the aircraft, else the NEAREST spot that is (searched outwards, nearest first); each
	further aircraft at the nearest such spot at least _gap m from the others. An invisible helipad then goes on each
	(MCCMK_fnc_taruPickup), so the pilot can't go to a base or shop helipad instead.
	[aimed position, how many, the aircraft's clearance radius (m), gap between them (m)] -> positions
*/
params [["_aim", [0, 0, 0]], ["_n", 1], ["_rad", 11], ["_gap", 35]];
private _ok = {
	params ["_p"];
	!(surfaceIsWater _p) && {count (_p isFlatEmpty [_rad, -1, 0.25, _rad, 0, false, objNull]) > 0}
};
private _spots = [];
for "_k" from 1 to _n do {
	private _found = [];
	for "_r" from 0 to 250 step 8 do {
		if (_found isEqualTo []) then {
			private _steps = if (_r == 0) then {1} else {(ceil (2 * pi * _r / 8)) max 6};
			for "_a" from 0 to (_steps - 1) do {
				if (_found isEqualTo []) then {
					private _p = if (_r == 0) then {_aim} else {_aim getPos [_r, 360 * _a / _steps]};
					_p = [_p select 0, _p select 1, 0];
					if (((_spots findIf {(_x distance2D _p) < _gap}) < 0) && {[_p] call _ok}) then {_found = _p};
				};
			};
		};
	};
	if (_found isEqualTo []) then {	// nothing suitable within 250 m: beside the aim (the pilot does what he can)
		_found = _aim getPos [_gap * (count _spots), 90];
		_found = [_found select 0, _found select 1, 0];
	};
	_spots pushBack _found;
};
_spots
