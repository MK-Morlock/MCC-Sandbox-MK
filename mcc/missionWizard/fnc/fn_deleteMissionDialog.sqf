/*================================================================ MCC_fnc_deleteMissionDialog ==============================================================
	Client: pick a generated mission (or all of them) and delete it with its tasks, AI, objects, mines and markers.
	Opened from the MCC console ("Delete Missions") or the Zeus module "Delete Generated Mission".
==============================================================================================================================================================*/
private _list = missionNamespace getVariable ["MCC_generatedMissionsList", []];
if (count _list == 0) exitWith {hint "No generated missions to delete."};

private _names = (_list apply {format ["%1  (%2)", _x select 1, _x select 2]}) + ["ALL generated missions"];
private _result = ["Delete Generated Mission", [
	["Mission", _names, "Removes its tasks, AI groups and their vehicles, objects, mines and map markers"]
]] call MCC_fnc_initDynamicDialog;
if (count _result == 0) exitWith {};

private _idx = _result select 0;
private _id = if (_idx >= count _list) then {"ALL"} else {(_list select _idx) select 0};
["delete", [_id]] remoteExec ["MCC_fnc_generatedMissions", 2];
hint format ["Deleting %1", (_names select _idx)];
