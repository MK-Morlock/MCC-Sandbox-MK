params [["_g", grpNull], ["_action", 0], ["_loc", [0, 0, 0]], ["_arr", []], ["_shown", false], ["_type", ""]];
if (!isServer || {isNull _g}) exitWith {false};
private _special = _type in ["Water landing (engine on)", "Water landing (engine off)", "Boat drop (landed)", "Boat drop (low hover)", "Boat load"];
private _q = +(_g getVariable ["MCCMK_wpQ", []]);
private _busy = _g getVariable ["MCCMK_wpBusy", false];
if (_action != 0) then {
	_g setVariable ["MCCMK_wpJobId", (_g getVariable ["MCCMK_wpJobId", 0]) + 1];
	_g setVariable ["MCCMK_wpQ", []];
	_g setVariable ["MCCMK_wpBusy", false];
	_g setVariable ["MCCMK_wpNow", nil];
	_g setVariable ["MCCMK_wpPlan", [], true];
	_q = [];
	_busy = false;
	if (_action == 1) then {
		private _v = vehicle (leader _g);
		if (_v isKindOf "Air" && {!(_type == "Boat drop (landed)" && {(_v distance2D _loc) < 50})}) then {[_v, _v getVariable ["MCCMK_flyH", 50]] call MCCMK_fnc_heliWaterEnd};
	};
};
if (_action == 2) exitWith {false};
if (!_special && {!_busy}) exitWith {false};
if (_action == 1) then {while {(count (waypoints _g)) > 0} do {deleteWaypoint ((waypoints _g) select 0)}};
private _owner = remoteExecutedOwner;
if (_owner <= 0) then {_owner = 2};
_g setVariable ["MCCMK_wpOwner", _owner];
_q pushBack [_loc, _arr, _shown, _type, _special];
_g setVariable ["MCCMK_wpQ", _q];
if (_busy) then {
	_g setVariable ["MCCMK_wpGo", true];
} else {
	_g setVariable ["MCCMK_wpBusy", true];
	[_g, _g getVariable ["MCCMK_wpJobId", 0]] spawn MCCMK_fnc_wpJobRun;
};
[_g] call MCCMK_fnc_wpPlan;
["INFO", "wpJob", "%1: %2 queued (%3 in the queue, %4)", [groupId _g, _type, count _q, ["started", "behind the one running"] select _busy]] call MCC_fnc_log;
true
