params [["_g", grpNull, [grpNull]], ["_mode", "pickup", [""]], ["_pos", [], [[]]], ["_index", -1, [0]]];
if (isNull _g || {count _pos < 2}) exitWith {[]};
private _wp = _g addWaypoint [[_pos select 0, _pos select 1, 0], 0, _index];
_wp setWaypointType "MOVE";
_wp setWaypointCompletionRadius 150;
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointDescription format ["Taru: %1", _mode];
_wp setWaypointStatements [
	format ["private _v = vehicle this; if ((_v getVariable ['MCC_taruTask', 0]) == 0) then {_v setVariable ['MCC_taruTask', 1, true]; [_v, '%1', %2] spawn MCC_fnc_taruAI}; (_v getVariable ['MCC_taruTask', 0]) == 2", _mode, [_pos select 0, _pos select 1, 0]],
	"(vehicle this) setVariable ['MCC_taruTask', 0, true];"
];
_wp
