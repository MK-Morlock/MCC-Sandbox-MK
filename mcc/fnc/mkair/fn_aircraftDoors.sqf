params [["_v", objNull, [objNull]], ["_open", true, [true]]];
if (isNull _v) exitWith {false};
if (!local _v) exitWith {[_v, _open] remoteExec ["MCCMK_fnc_aircraftDoors", _v]; true};
private _phase = [0, 1] select _open;
private _skip = ["ramp", "rear", "cargo", "back", "pilot", "cockpit", "copilot", "gunner", "driver", "commander", "never", "hatch"];
private _done = [];
{
	private _n = configName _x;
	private _ln = toLower _n;
	if ((toLower (getText (_x >> "source"))) == "door" && {(_ln find "door") >= 0} && {(_skip findIf {(_ln find _x) >= 0}) < 0}) then {
		_v animateDoor [_n, _phase];
		_done pushBack _n;
	};
} forEach ("isClass _x" configClasses (configFile >> "CfgVehicles" >> (typeOf _v) >> "AnimationSources"));
["DEBUG", "aircraftDoors", "%1: side doors %2 (%3)", [typeOf _v, ["closing", "opening"] select _open, if (count _done == 0) then {"none found"} else {_done joinString ", "}]] call MCC_fnc_log;
count _done > 0
