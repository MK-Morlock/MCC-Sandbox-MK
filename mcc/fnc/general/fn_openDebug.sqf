params [["_class", "RscDisplayDebugPublic", [""]]];
if (mcc_missionmaker != (name player)) exitWith {player globalchat "Access Denied"};
private _allowed = call (missionNamespace getVariable ["BIS_fnc_isDebugConsoleAllowed", {true}]);
private _ok = createDialog _class;
["DEBUG", "debug", "%1: allowed by the game = %2, opened = %3", [_class, _allowed, _ok]] call MCC_fnc_log;
if (!_ok) then {systemChat "The debug window could not be opened."} else {
	if (!_allowed) then {systemChat "Arma's debug console is disabled for this mission or session (enableDebugConsole)."};
};
