/*============================================MCC_fnc_MWFindMissionCenter=========================================================================================================
	Find the mission Wizard's center
	Example: [_pos,_minRadius,_maxRadius,_isCQB] call MCC_fnc_MWFindMissionCenter;

	<IN>
		_pos				= position, from where to start looking.
		_minRadius 			= integer, minimum distance from _pos
		_maxRadius			= integer, Maximum distance from _pos
		_isCQB 			= Boolean, true - for CQB areay false if it doesn't matters.
		_isBasedLocations 	= Boolean, true if the map support locations

	<OUT>
 		Return - pos
//===========================================================================================================================================================================*/
private _centerFound = false;
private _buildingsArray = objNull;
private _newPos = nil;
private _locations = [];
private _location = nil;
private _time = 0;
private _radius = 0;

params [
	["_pos", [0,0,0], [[]]],
	["_minRadius", 0, [0]],
	["_isCQB", false, [false]],
	["_isBasedLocations", false, [false]],
	["_strict", false, [false]]
];

_centerFound = false;
_newPos = nil;

if (_isBasedLocations) then {
	if (_isCQB) then
	{
		_locations = MCC_MWcityLocations + MCC_MWmilitaryLocations;
	}
	else
	{
		_locations = MCC_MWhillsLocations + MCC_MWnatureLocations + MCC_MWmarineLocations;
	};

	if (_strict) then {
		private _inside = _locations select {((getpos (_x select 0)) distance2D _pos) <= _minRadius};
		if (count _inside > 0) then {_locations = _inside};
	};
	_location = _locations call BIS_fnc_selectRandom;
	_newPos = getpos (_location select 0);
} else {
	if (_strict) then {
		if (_isCQB) then {
			private _blds = (nearestObjects [_pos, ["House","Ruins","Church","FuelStation","Strategic"], _minRadius]) select {((_x distance2D _pos) <= (_minRadius * 0.9)) && {!(surfaceIsWater (getPos _x))}};
			if (count _blds > 0) then {_newPos = getPos (selectRandom _blds); _centerFound = true};
		};
		for "_t" from 1 to 200 do {
			if (_centerFound) exitWith {};
			private _p = _pos getPos [(_minRadius * 0.9) * sqrt (random 1), random 360];
			if !(surfaceIsWater _p) then {_newPos = [_p select 0, _p select 1, 0]; _centerFound = true};
		};
	} else {
		//Lets find a pice of land
		_time = time + 30;
		_newPos = [0,0];

		while {!_centerFound && time < _time} do {

			//first is whitelist second is blacklist, third is condition
			_radius = _minRadius;
			while {count _newPos <3 && time < _time} do
			{
				_newPos = [[[_pos,_radius]],["water"]] call BIS_fnc_randomPos;
				_radius = _radius + 50;
			};



			if (_isCQB) then
				{
					_buildingsArray	= nearestObjects  [_newPos,["House","Ruins","Church","FuelStation","Strategic"],_minRadius];	//Let's find the buildings in the area
					if ((count _buildingsArray > 0) && (!surfaceIsWater _newPos)) then
						{
							_newPos = getpos (selectRandom _buildingsArray);
							_centerFound = true;
						};
				}
					else
				{
					if (!surfaceIsWater _newPos) then {_centerFound = true};
				};
		};
	};
};

if (isnil "_location") then {_location = [0,""]};
[_newPos,(_location select 1)];