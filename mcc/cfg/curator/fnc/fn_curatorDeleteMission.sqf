//============================================================MCC_fnc_curatorDeleteMission=======================================================================
// Zeus: delete a generated mission (tasks, AI, objects, mines, markers)
//===============================================================================================================================================================
params [["_module", objNull, [objNull]]];
if (isNull _module || {!local _module}) exitWith {};
deleteVehicle _module;
[] spawn MCC_fnc_deleteMissionDialog;
