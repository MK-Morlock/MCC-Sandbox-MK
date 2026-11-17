/*
	MCCMK_fnc_genRun - (server, scheduled) runs one of the generator's own server functions with the mission's ID in scope,
	so what it creates is marked as that mission's (MCCMK_fnc_genTag): [arguments, mission ID, function name]. Used in place
	of a remoteExec to the server from inside a generated mission. Local only (not in CfgRemoteExec), and only the generator's
	own functions are run.
*/
params [["_a", []], ["_MCCMK_gen", ""], ["_f", "", [""]]];
if (!isServer) exitWith {};
private _ok = ["mcc_fnc_", "mccmk_fnc_", "gaia_fnc_"] findIf {((toLower _f) find _x) == 0} >= 0;
if (!_ok) exitWith {["WARN", "genRun", "refused %1", [_f]] call MCC_fnc_log};
private _code = missionNamespace getVariable [_f, {}];
_a call _code;
