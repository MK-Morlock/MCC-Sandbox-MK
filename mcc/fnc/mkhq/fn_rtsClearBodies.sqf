// (MK) RTS HQ "Clear bodies": every body within 300 m of the HQ removed, with the weapons beside it (MCCMK_fnc_clearBodies).
params [["_ctrl", controlNull, [controlNull]]];
[missionNamespace getVariable ["MCC_selectedRtsObject", objNull], player] remoteExec ["MCCMK_fnc_clearBodies", 2];
