params [["_route", "", [""]], ["_params", []], ["_targets", 0], ["_jip", false], ["_isCall", false, [false]]];
if (_route == "") exitWith {};
if (isServer) exitWith {
	if (_isCall) then {_params remoteExecCall [_route, _targets, _jip]} else {_params remoteExec [_route, _targets, _jip]};
};
[_route, _params, _targets, _jip, _isCall] remoteExecCall ["MCC_fnc_secRelay", 2];
