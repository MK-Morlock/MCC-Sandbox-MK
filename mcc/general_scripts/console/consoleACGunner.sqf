params [["_path", [1], [[]]]];
private _uav = missionNamespace getVariable ["MCC_ACConsoleUp", objNull];
if (!alive _uav) exitWith {hint "No AC-130 up"};
private _g = _uav turretUnit _path;
if (isNull _g || {!alive _g}) exitWith {hint "That gunner seat is empty"};
MCC_acRemoteToken = (missionNamespace getVariable ["MCC_acRemoteToken", 0]) + 1;
private _tok = MCC_acRemoteToken;
MCC_consoleTakingControl = true;
private _old = missionNamespace getVariable ["MCC_acRemote", []];
if (count _old > 1) then {
	_old params ["_ou", "_og", "_oa"];
	{if (!isNull _og) then {_og removeAction _x}} forEach _oa;
	player remoteControl objNull;
	objNull remoteControl _og;
};
while {dialog} do {closeDialog 0};
_g enableAI "TARGET";
_g enableAI "AUTOTARGET";
player remoteControl _g;
_g switchCamera "GUNNER";
private _other = [[2], [1]] select (_path isEqualTo [2]);
private _acts = [
	_g addAction [format ["Switch to %1", ["Gunner 1 (105 / 20 mm)", "Gunner 2 (40 mm)"] select (_other isEqualTo [2])], {[_this select 3] execVM format ["%1mcc\general_scripts\console\consoleACGunner.sqf", MCC_path]}, _other, 1.5, false, true],
	_g addAction ["Return to Commander Console", {MCC_acRemoteRelease = true}, nil, 1.4, false, true]
];
MCC_acRemote = [_uav, _g, _acts];
MCC_acRemoteRelease = false;
["DEBUG", "console", "AC-130: remote control of gunner %1 (%2)", [_path, typeOf _uav]] call MCC_fnc_log;
[_uav, _g, _acts, _tok] spawn {
	params ["_uav", "_g", "_acts", "_tok"];
	sleep 1;
	waitUntil {
		sleep 0.25;
		(missionNamespace getVariable ["MCC_acRemoteToken", 0]) != _tok
		|| {missionNamespace getVariable ["MCC_acRemoteRelease", false]}
		|| {!alive _uav}
		|| {!alive _g}
		|| {!alive player}
		|| {isNull (missionNamespace getVariable ["MCC_ACConsoleUp", objNull])}
		|| {cameraOn != (vehicle _g)}
	};
	if ((missionNamespace getVariable ["MCC_acRemoteToken", 0]) != _tok) exitWith {};
	{if (!isNull _g) then {_g removeAction _x}} forEach _acts;
	player remoteControl objNull;
	if (!isNull _g) then {objNull remoteControl _g};
	player switchCamera "INTERNAL";
	MCC_acRemote = [];
	MCC_acRemoteRelease = false;
	MCC_consoleTakingControl = false;
	["DEBUG", "console", "AC-130: left the gunner seat, back to the Commander Console", []] call MCC_fnc_log;
	sleep 0.5;
	if (!dialog && {alive player}) then {[nil, nil, nil, [0]] execVM format ["%1mcc\general_scripts\console\conoleOpenMenu.sqf", MCC_path]};
};
