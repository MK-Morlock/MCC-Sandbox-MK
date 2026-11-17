// (MK) RTS HQ "Clear wrecks": every wreck within 300 m of the HQ removed, free (MCCMK_fnc_clearWrecks).
params [["_ctrl", controlNull, [controlNull]]];
[missionNamespace getVariable ["MCC_selectedRtsObject", objNull], player] remoteExec ["MCCMK_fnc_clearWrecks", 2];
