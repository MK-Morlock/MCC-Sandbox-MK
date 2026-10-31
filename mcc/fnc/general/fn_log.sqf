params [
	["_level", "INFO", [""]],
	["_source", "?", [""]],
	["_message", "", [""]],
	["_args", [], [[]]]
];

_level = toUpper _level;
if (!(missionNamespace getVariable ["MCC_debug", false]) && {!(_level in ["BUILD", "CAMPAIGN"])}) exitWith {};

private _text = if (count _args > 0) then {format ([_message] + _args)} else {_message};

private _machine = switch (true) do {
	case (isDedicated): {"SERVER"};
	case (isServer && hasInterface): {"SP"};
	case (isServer): {"SERVER"};
	case (!hasInterface): {"HC"};
	default {"CLIENT"};
};

if (isNil "MCC_logCounts") then {MCC_logCounts = createHashMap};
MCC_logCounts set [_level, (MCC_logCounts getOrDefault [_level, 0]) + 1];

private _suffix = "";
if (_level in ["WARN", "ERROR"]) then {
	if (isNil "MCC_logThrottleMap") then {MCC_logThrottleMap = createHashMap};
	private _key = _level + _source + _text;
	private _entry = MCC_logThrottleMap getOrDefault [_key, [-1e9, 0]];
	_entry params ["_lastTime", "_suppressed"];
	private _window = missionNamespace getVariable ["MCC_logThrottle", 10];
	if ((diag_tickTime - _lastTime) < _window) then {
		MCC_logThrottleMap set [_key, [_lastTime, _suppressed + 1]];
		_text = "";
	} else {
		if (_suppressed > 0) then {_suffix = format [" (+%1 repeats suppressed)", _suppressed]};
		MCC_logThrottleMap set [_key, [diag_tickTime, 0]];
	};
};
if (_text == "") exitWith {};

private _who = if (hasInterface && {!isNull player}) then {name player} else {"-"};

diag_log text format ["MCC [%1] %2 | %3%4 | t=%5 %6 %7", _level, _source, _text, _suffix, (round (time * 10)) / 10, _machine, _who];
