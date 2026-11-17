/*
	MCCMK_fnc_floatFill - (where the boat is local) a scuttled boat flooded a little at a time: [boat, scuttled?]. The
	game's own leak only works on a boat under water, wrecked or capsized, so the water inside is raised step by step
	(setWaterFillPercentage, 1% at a time) over "Scuttle time" minutes; full and still afloat after 20 s: destroyed
	quietly (no explosion, no fire), so it goes down as a wreck. Plugged: the flooding stops and the water is pumped out
	(1% every 1.2 s). With MCC debug on, the RPT logs how full it is every 10 s.
*/
params [["_v", objNull], ["_on", true]];
if (isNull _v || {!local _v}) exitWith {};
if (!_on) exitWith {[_v, -1, true] call MCCMK_fnc_floatLeak};
[_v] spawn {
	params ["_v"];
	private _mins = (missionNamespace getVariable ["MCCMK_scuttleTime", 5]) max 0.5;
	private _gap = (_mins * 60) / 100;	// seconds per 1%
	private _t0 = time;
	private _next = time + 10;
	while {alive _v && {local _v} && {_v getVariable ["MCCMK_scuttled", false]} && {(getWaterFillPercentage _v) < 1}} do {
		_v setWaterFillPercentage (((getWaterFillPercentage _v) + 0.01) min 1);
		if ((missionNamespace getVariable ["MCC_debug", false]) && {time >= _next}) then {
			_next = time + 10;
			["INFO", "floatary", "%1 flooding: %2%% full after %3 s, %4 m (ASL)", [typeOf _v, round ((getWaterFillPercentage _v) * 100), round (time - _t0), ((getPosASL _v) select 2) toFixed 1]] call MCC_fnc_log;
		};
		sleep _gap;
	};
	if (alive _v && {_v getVariable ["MCCMK_scuttled", false]}) then {
		sleep 20;
		if (alive _v && {_v getVariable ["MCCMK_scuttled", false]}) then {
			["INFO", "floatary", "%1 full after %2 s - %3", [typeOf _v, round (time - _t0), ["still afloat: destroyed quietly so it sinks", "gone down"] select (((getPosASL _v) select 2) < -1)]] call MCC_fnc_log;
			if (((getPosASL _v) select 2) >= -1) then {_v setDamage [1, false]};
		};
	};
};
