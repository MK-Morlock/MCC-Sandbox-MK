disableSerialization;
params [["_d", displayNull, [displayNull]]];
if (isNull _d || {!(profileNamespace getVariable ["MCC_consoleButtons", false])}) exitWith {};
private _flat = "\mcc_sandbox_mod\data\";
{
	private _t = ctrlText _x;
	if ((toLower (_t select [0, (count _flat) + 10])) == (toLower (_flat + "btn_round_"))) then {_x ctrlSetText ("\mcc_sandbox_mod\data\classic\" + (_t select [count _flat]))};
} forEach (allControls _d);
