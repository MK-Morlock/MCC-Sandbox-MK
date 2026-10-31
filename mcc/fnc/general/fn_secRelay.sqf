params [["_route", "", [""]], ["_params", []], ["_targets", 0], ["_jip", false], ["_isCall", false, [false]]];
if (!isServer) exitWith {};
if !((toLower _route) in ["call", "spawn", "bis_fnc_call", "bis_fnc_spawn", "mcc_fnc_globalexecute", "mcc_fnc_setvehicleinit"]) exitWith {};
private _id = remoteExecutedOwner;
private _allowed = call MCC_fnc_secSenderOK;
if (!_allowed) exitWith {
	if (missionNamespace getVariable ["MCC_debug", false]) then {["WARN", "MCC_fnc_secRelay", "ignored a %1 request from machine %2 - not the mission maker, an admin, a Zeus or a headless client", [_route, _id]] call MCC_fnc_log};
};
if (_isCall) then {_params remoteExecCall [_route, _targets, _jip]} else {_params remoteExec [_route, _targets, _jip]};
