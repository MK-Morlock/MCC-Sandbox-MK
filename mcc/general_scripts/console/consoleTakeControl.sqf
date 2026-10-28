private "_uav";
params [["_mode", 0]];
private _seat = if (_mode isEqualType "") then {toLower _mode} else {"gunner"};

if (isnil "MCC_ConolseUAV") exitWith {};
if (!alive MCC_ConolseUAV) exitWith {};
if (_seat == "gunner" && {count (allTurrets [MCC_ConolseUAV, false]) == 0}) then {_seat = "pilot"};

MCC_consoleTakingControl = true;
while {dialog} do {closeDialog 0};

_uav = MCC_ConolseUAV;
player connectTerminalToUAV _uav;
player action [["SwitchToUAVGunner", "SwitchToUAVDriver"] select (_seat == "pilot"), _uav];
["DEBUG", "console", "take control of %1 as %2", [typeOf _uav, _seat]] call MCC_fnc_log;
[_uav] spawn {
	params ["_u"];
	private _t = time + 10;
	waitUntil {sleep 0.2; ((UAVControl _u) find player) >= 0 || {time > _t} || {!alive _u}};
	["DEBUG", "console", "controlling %1: %2", [typeOf _u, UAVControl _u]] call MCC_fnc_log;
	if (((UAVControl _u) find player) >= 0) then {
		while {dialog} do {closeDialog 0};
		waitUntil {sleep 0.5; !alive _u || {((UAVControl _u) find player) < 0}};
		["DEBUG", "console", "left control of %1: back to the Commander Console", [typeOf _u]] call MCC_fnc_log;
	} else {
		["DEBUG", "console", "taking control of %1 failed: back to the Commander Console", [typeOf _u]] call MCC_fnc_log;
	};
	MCC_consoleTakingControl = false;
	sleep 0.5;
	if (!dialog && {alive player}) then {[nil, nil, nil, [0]] execVM format ["%1mcc\general_scripts\console\conoleOpenMenu.sqf", MCC_path]};
};

/*
player remoteControl gunner _uav;
gunner _uav switchCamera "Internal";
player remoteControl gunner _uav;
*/