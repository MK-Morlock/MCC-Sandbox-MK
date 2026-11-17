/*
	MCCMK_fnc_heliGlide - (server; spawn it) a helicopter comes down from its travelling height to its hover height ON THE
	WAY IN, not after it has stopped: [helicopter, the spot, fly height, hover height]. The pilot only ever holds the one
	flying height he's given, so it's lowered as the distance closes - over a run-in that scales with the height to lose
	(150 m + 6 m for each metre down, 300 m to 2 km) and ends 150 m out, where he's at hover height and slowing. Not below
	20 m until the last 250 m (trees and buildings on the way in). Ends at 150 m, on a new glide, or after 10 minutes.
*/
params [["_h", objNull], ["_spot", [0, 0, 0]], ["_fly", 50], ["_hover", 20]];
if (isNull _h) exitWith {};
private _id = diag_tickTime + random 1;
_h setVariable ["MCCMK_glideId", _id];
private _lose = (_fly - _hover) max 0;
if (_lose < 1) exitWith {};
private _run = ((150 + (_lose * 6)) max 300) min 2000;
private _t = time + 600;
while {alive _h && {time < _t} && {(_h getVariable ["MCCMK_glideId", 0]) isEqualTo _id}} do {
	private _d = _h distance2D _spot;
	if (_d < 150) exitWith {_h flyInHeight (_hover max 5)};
	if (_d < _run) then {
		private _f = _hover + (_lose * ((_d - 150) / ((_run - 150) max 1)));
		if (_d > 250) then {_f = _f max 20};
		_h flyInHeight (_f max 5);
	};
	sleep 1;
};
