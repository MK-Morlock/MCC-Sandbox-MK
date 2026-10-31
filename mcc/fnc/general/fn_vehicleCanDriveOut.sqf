params [["_pos", [], [[]]], ["_cls", "", [""]], ["_center", [], [[]]]];
if (!canSuspend || {count _pos < 2}) exitWith {true};
private _from = [_pos select 0, _pos select 1, 0];
private _dest = [];
private _roads = _from nearRoads 300;
if (count _roads > 0) then {
	private _near = _roads select 0;
	{if ((_x distance2D _from) < (_near distance2D _from)) then {_near = _x}} forEach _roads;
	_dest = getPosATL _near;
} else {
	if (count _center >= 2) then {_dest = [_center select 0, _center select 1, 0]};
};
if (_dest isEqualTo [] || {(_dest distance2D _from) < 20}) exitWith {true};
private _type = switch (true) do {
	case (_cls isKindOf "Wheeled_APC_F"): {"wheeled_APC"};
	case (_cls isKindOf "Tank"): {"tank"};
	default {"car"};
};
private _key = format ["MCC_pathResult_%1_%2", floor (diag_tickTime * 1000), floor random 100000];
private _agent = calculatePath [_type, "CARELESS", _from, _dest];
_agent setVariable ["MCC_pathKey", _key];
_agent addEventHandler ["PathCalculated", {
	params ["_a", "_path"];
	missionNamespace setVariable [_a getVariable ["MCC_pathKey", ""], _path];
}];
private _until = diag_tickTime + 4;
waitUntil {sleep 0.1; !isNil {missionNamespace getVariable _key} || {diag_tickTime > _until}};
sleep 0.3;
private _path = missionNamespace getVariable [_key, -1];
missionNamespace setVariable [_key, nil];
if (!isNull _agent) then {deleteVehicle _agent};
if (_path isEqualTo -1) exitWith {
	if (missionNamespace getVariable ["MCC_debug", false]) then {["DEBUG", "MCC_fnc_vehicleCanDriveOut", "no answer from the pathfinder for %1 at %2 - spot allowed", [_cls, mapGridPosition _from]] call MCC_fnc_log};
	true
};
if (_path isEqualTo []) exitWith {false};
((_path select ((count _path) - 1)) distance2D _dest) < 30
