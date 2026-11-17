/*
	MCCMK_fnc_floatScuttle - (server) [vehicle, scuttle?, who]: scuttled - it takes on water at the "Scuttle leak" setting
	until it sinks; plugged - watertight again (an aircraft back to its own state; a boat the game's own), and the water
	pumped out slowly (MCCMK_fnc_floatLeak).
*/
params [["_v", objNull], ["_on", true], ["_who", objNull]];
if (!isServer || {isNull _v} || {!alive _v}) exitWith {};
_v setVariable ["MCCMK_scuttled", _on, true];
// a boat ignores the game's leak while it floats upright and whole (it's for under water, wrecked or capsized ), so a
// scuttled boat is flooded a little at a time instead (MCCMK_fnc_floatFill)
if (_v isKindOf "Ship") exitWith {
	[_v, _on] remoteExec ["MCCMK_fnc_floatFill", _v];
	["INFO", "floatary", "%1 %2 by %3 (flooding over %4 min)", [typeOf _v, ["plugged - pumping out", "scuttled"] select _on, if (isNull _who) then {"-"} else {name _who}, missionNamespace getVariable ["MCCMK_scuttleTime", 5]]] call MCC_fnc_log;
};
private _leak = if (_on) then {missionNamespace getVariable ["MCCMK_scuttleLeak", 10]} else {
	if ([_v] call MCCMK_fltAir) then {[0, 10] select ([_v] call MCCMK_fltCrippled)} else {-1}
};
[_v, _leak, !_on] remoteExec ["MCCMK_fnc_floatLeak", _v];
_v setVariable ["MCCMK_fltLeak", _leak, true];
["INFO", "floatary", "%1 %2 by %3 (leak %4)", [typeOf _v, ["plugged - pumping out", "scuttled"] select _on, if (isNull _who) then {"-"} else {name _who}, _leak]] call MCC_fnc_log;
