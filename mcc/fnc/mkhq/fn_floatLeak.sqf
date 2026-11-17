/*
	MCCMK_fnc_floatLeak - (where the vehicle is local) its water leakiness: [vehicle, leak (-1: the game's own again),
	pump it out?]. The game's own value is kept the first time. With MCC debug on, the RPT logs (INFO lines - MCC's logger
	drops DEBUG ones unless MCC_logVerbose is set) how full it is every 10 s
	while it's filling or being pumped out (to time the sinking).
	Pumping (after "Plug the leak"): the water taken in goes down 1% every 1.2 s (about 2 minutes from full).
*/
params [["_v", objNull], ["_leak", 0], ["_pump", false]];
if (isNull _v || {!local _v}) exitWith {};
if (isNil {_v getVariable "MCCMK_fltOrig"}) then {_v setVariable ["MCCMK_fltOrig", getWaterLeakiness _v]};
private _set = if (_leak < 0) then {_v getVariable ["MCCMK_fltOrig", getWaterLeakiness _v]} else {_leak};
_v setWaterLeakiness _set;
if (_pump) then {
	[_v] spawn {
		params ["_v"];
		private _t0 = time;
		private _next = time + 10;
		while {alive _v && {local _v} && {(getWaterFillPercentage _v) > 0} && {!(_v getVariable ["MCCMK_scuttled", false])}} do {
			_v setWaterFillPercentage (((getWaterFillPercentage _v) - 0.01) max 0);
			if ((missionNamespace getVariable ["MCC_debug", false]) && {time >= _next}) then {
				_next = time + 10;
				["INFO", "floatary", "%1 pumping out: %2%% full after %3 s", [typeOf _v, round ((getWaterFillPercentage _v) * 100), round (time - _t0)]] call MCC_fnc_log;
			};
			sleep 1.2;
		};
	};
};
// the sinking timed in the RPT (debug only)
if (_set > 0 && {missionNamespace getVariable ["MCC_debug", false]}) then {
	[_v, _set] spawn {
		params ["_v", "_set"];
		private _t0 = time;
		while {alive _v && {local _v} && {(getWaterLeakiness _v) isEqualTo _set} && {(getWaterFillPercentage _v) < 1}} do {
			["INFO", "floatary", "%1 leak %2: %3%% full after %4 s%5", [typeOf _v, _set, round ((getWaterFillPercentage _v) * 100), round (time - _t0), ["", " (not in water)"] select !(surfaceIsWater (getPos _v))]] call MCC_fnc_log;
			sleep 10;
		};
		["INFO", "floatary", "%1 leak %2: %3 after %4 s", [typeOf _v, _set, ["stopped", "full (sinking)"] select ((getWaterFillPercentage _v) >= 1), round (time - _t0)]] call MCC_fnc_log;
	};
};
