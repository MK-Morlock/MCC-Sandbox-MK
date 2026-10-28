private _ok = false;
CP_screen = _this select 0;

closeDialog 0;
waituntil {!dialog};

switch (CP_screen) do {
    case 0:
   {_ok = createDialog ("CP_RESPAWNPANEL" call MCC_fnc_dialogName);
 	if !(_ok) exitWith { hint "create Dialog failed"; if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log  "CP: create respawn Dialog failed"};};};
   case 1:
   { _ok = createDialog ("CP_GEARPANEL" call MCC_fnc_dialogName);
	 if !(_ok) exitWith { hint "create Dialog failed"; if (missionNamespace getVariable ["MCC_debug", false]) then {diag_log  "CP: create gear Dialog failed"};};};
};