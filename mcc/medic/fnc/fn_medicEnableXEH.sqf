/*================================================= MCC_fnc_medicEnableXEH =========================================================
	Hooks the MCC medic system onto all soldiers (existing and future). Runs on every machine.

	Before, this only happened in XEH preInit, when the Eden/Zeus Medic System module had not run yet - so a mission
	that turned the system on with the module set MCC_medicSystemEnabled but never added the damage handlers.
	Does nothing when ACE medical is loaded (MCC's medic system stays off with ACE, as in the original).
====================================================================================================================================*/
if (isClass (configFile >> "CfgPatches" >> "ace_medical")) exitWith {
	if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log format ["%1 MCC Medic System: not started - ACE medical is loaded", time]};
	false
};
if (missionNamespace getVariable ["MCC_medicXEHadded", false]) exitWith {true};
MCC_medicXEHadded = true;

// init handler also applied to units that already exist (6th parameter)
["CAManBase", "init", MCC_fnc_initMedicXEH, true, [], true] call CBA_fnc_addClassEventHandler;
["CAManBase", "Respawn", MCC_fnc_initMedicXEH] call CBA_fnc_addClassEventHandler;

if (!isNil "MCC_fnc_log") then {["INFO", "fn_medicEnableXEH", "MCC medic system started"] call MCC_fnc_log};
true
