/*================================================================== MCC_fnc_paraGuide ==================================================================
	Steers an AI paratrooper (in free fall and under canopy) to his landing spot on the drop line.
	Jumpers used to keep the aircraft speed and land wherever their momentum and the pilot line took them, often well off to
	the side of the line drawn in the MCC console. The horizontal speed is now eased each moment towards what is needed to
	reach the spot by the time he lands (at most 6 m/s under canopy, 30 m/s in free fall), so a little drift remains.
	Runs where the unit is local. Players steer their own parachute and are not guided.

	<IN>	0: OBJECT unit
			1: ARRAY  landing spot [x, y] or [x, y, z]
=========================================================================================================================================================*/
params [["_unit", objNull, [objNull]], ["_target", [], [[]]]];
if (isNull _unit || {isPlayer _unit} || {count _target < 2}) exitWith {};

[_unit, _target] spawn {
	params ["_unit", "_target"];
	private _end = time + 600;
	sleep 1;	//clear of the aircraft first
	while {alive _unit && {time < _end} && {((getPosATL (vehicle _unit)) select 2) > 4}} do {
		private _v = vehicle _unit;
		if (local _v) then {
			private _p = getPosASL _v;
			private _vel = velocity _v;
			private _h = (getPosATL _v) select 2;
			private _sink = ((_vel select 2) * -1) max 2;
			private _timeLeft = (_h / _sink) max 2;
			private _dx = (_target select 0) - (_p select 0);
			private _dy = (_target select 1) - (_p select 1);
			private _max = [30, 6] select (_v != _unit);
			private _want = [_dx / _timeLeft, _dy / _timeLeft];
			private _m = sqrt ((_want select 0)^2 + (_want select 1)^2);
			if (_m > _max) then {_want = [(_want select 0) * _max / _m, (_want select 1) * _max / _m]};
			_v setVelocity [
				(_vel select 0) + ((_want select 0) - (_vel select 0)) * 0.25,
				(_vel select 1) + ((_want select 1) - (_vel select 1)) * 0.25,
				_vel select 2
			];
		};
		sleep 0.2;
	};
};
