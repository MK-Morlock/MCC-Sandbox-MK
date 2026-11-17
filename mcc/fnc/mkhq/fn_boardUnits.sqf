params [["_mode", "alone", [""]], ["_state", "climb", [""]], ["_incl", true, [true]]];
private _g = units group player;
private _who = switch (true) do {
	case (_mode == "squad"): {_g};
	case (_mode == "gunners"): {
		private _v = vehicle player;
		private _guns = (fullCrew [_v, "", false]) select {(_x select 1) in ["gunner", "commander", "turret"]} apply {_x select 0};
		(_g select {vehicle _x == _v}) - _guns
	};
	case ((_mode select [0, 5]) == "team:"): {
		private _team = _mode select [5];
		_g select {(assignedTeam _x) == _team}
	};
	default {[player]};
};
_who = (_who arrayIntersect _who) select {alive _x && {_x == player || {!isPlayer _x}} && {(_x distance2D player) < 150} && {([_x] call MCCMK_fnc_boardSit) == _state}};
_who = _who - [player];
if (_incl) then {_who = [player] + _who};
_who
