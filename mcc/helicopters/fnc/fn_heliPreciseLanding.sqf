/*==================================================================MCC_fnc_heliPreciseLanding=========================================================================================
	Uses velocity to land an helicopter to a precise location

	<IN>
		0:	OBJECT, the helicopter
		1:	ARRAY, position in ASL

	<OUT>
		NOTHING
==============================================================================================================================================================================*/
private _distance = 0;
private _magnitude = 0;
private _vel = [];
private _vehicle = objNull;
private _positionASL = [];
_vehicle= param [0,objNull,[objNull]];
_positionASL = param [1,[0,0,0],[[]]];

if (isNull _vehicle || str _positionASL == "[0,0,0]") exitWith {};

_distance = ((getPosASL _vehicle) distance _positionASL);

// Give up after 90 s, or when the heli stops getting closer for 15 s (e.g. a slingloaded cargo already touching the
// ground stops it from descending). Without this the loop never ended and the heli hovered over the spot forever.
private _timeout = time + 90;
private _bestDist = _distance;
private _lastProgress = time;

while {alive _vehicle && alive driver _vehicle && canMove _vehicle && _distance > 5 && time < _timeout && (time - _lastProgress) < 15} do {
	if (_distance < _bestDist - 1) then {_bestDist = _distance; _lastProgress = time};

	_magnitude = 8;
	_distance = ((getPosASL _vehicle) distance _positionASL);
	if( _distance <= 10 ) then {
		_magnitude = (_distance / 10) * _magnitude;
	};

	_vel = velocity _vehicle;
	_vel = _vel vectorAdd (( (getPosASL _vehicle) vectorFromTo _positionASL ) vectorMultiply _magnitude);
	_vel = (vectorNormalized _vel) vectorMultiply ( (vectorMagnitude _vel) min _magnitude );
	_vehicle setVelocity _vel;

	sleep 0.05;
};
