/*
	MCCMK_fnc_floatLoad - (server) Load / Unload Watercraft (the original's): [boat, carrier, load?]. Loaded: the boat in
	the carrier's cargo bay; unloaded: set on the water behind it, facing out (10 m behind a helicopter, 15 m a plane).
	An AI-driven boat's engine is off while aboard.
*/
params [["_boat", objNull], ["_ac", objNull], ["_load", true], ["_slide", false]];
// (MK) _slide: driven in up the ramp (drive-in loading) - fixed where it reached, then slid on into its place over 0.6 s
if (!isServer || {isNull _ac}) exitWith {};
if (_load) then {
	if (isNull _boat || {!isNull ([_ac] call MCCMK_fltAttached)}) exitWith {};
	private _off = [_ac] call MCCMK_fltCarrierOffset;
	if (_off isEqualTo []) exitWith {};
	_boat setVariable ["MCCMK_floatZ", (getPosASL _boat) select 2];	// (MK) the height it floated at - it comes out at it
	if (_slide) then {
		private _from = _ac worldToModel (ASLToAGL (getPosASL _boat));
		_boat attachTo [_ac, _from];
		_boat setDir 0;
		[_boat, _ac, _from, _off] spawn {
			params ["_b", "_a", "_f", "_o"];
			for "_k" from 1 to 6 do {
				sleep 0.05;
				if (isNull _b || {!((attachedTo _b) isEqualTo _a)}) exitWith {};
				private _q = _k / 6;
				_b attachTo [_a, (_f vectorMultiply (1 - _q)) vectorAdd (_o vectorMultiply _q)];
			};
		};
	} else {
	_boat attachTo [_ac, _off];
	};
	private _mkD = driver _boat;
	if (!isNull _mkD && {!isPlayer _mkD}) then {
		[_mkD] remoteExecCall ["doStop", _mkD];
		[_boat, false] remoteExecCall ["engineOn", _boat];
	};
	playSound3D ["A3\sounds_f\structures\doors\servodoors\ServoDoorsSqueak_1.wss", _ac, false, getPosASL _ac, 5, 1, 100];
} else {
	_boat = [_ac] call MCCMK_fltAttached;
	if (isNull _boat) exitWith {};
	private _d = if (_ac isKindOf "Plane") then {15} else {10};
	private _p = _ac getPos [_d, (getDir _ac) + 180];
	_p set [2, (getPosASL _ac) select 2];
	detach _boat;
	_boat setPosASL _p;
	private _mkD = driver _boat;
	private _mkAi = !isNull _mkD && {!isPlayer _mkD};
	_boat setDir ((getDir _ac) + ([0, 180] select _mkAi));	//(MK) nose to the helicopter; an AI-driven boat faces away
	if (_mkAi) then {
		[_boat, true] remoteExecCall ["engineOn", _boat];
		[_mkD, leader (group _mkD)] remoteExecCall ["doFollow", _mkD];
	};
	playSound3D ["A3\sounds_f\structures\doors\servodoors\ServoDoorsSqueak_3.wss", _ac, false, getPosASL _ac, 5, 1, 100];
	//(MK) drive-in switched collisions between them off: back on a second after it's set down (no slide - it's placed as
	// before; the slide-out sank it and the collisions coming back on with it under the tail damaged the helicopter)
	[_boat, _ac] spawn {
		params ["_b", "_a"];
		sleep 1;
		if (isNull _b || {isNull _a}) exitWith {};
		[_b, _a] remoteExecCall ["enableCollisionWith", _b];
		[_a, _b] remoteExecCall ["enableCollisionWith", _a];
	};
};
