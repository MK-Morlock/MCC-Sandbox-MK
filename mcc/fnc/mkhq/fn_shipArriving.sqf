params [["_pos", [0, 0], [[], objNull]], ["_nm", "", [""]], ["_side", sideUnknown, [sideUnknown]], ["_end", 0, [0]]];
private _id = format ["MCCMK_shipArr_%1_%2", round diag_tickTime, floor random 100000];
while {serverTime < _end} do {
	private _p = if (_pos isEqualType objNull) then {getPos _pos} else {_pos};
	private _left = (_end - serverTime) max 0;
	[_id, _p, format ["%1 (arriving %2)", _nm, [_left, "MM:SS"] call BIS_fnc_secondsToString]] remoteExec ["MCCMK_fnc_shipMarkerLocal", _side];
	sleep (10 min (_left max 0.5));
};
[_id, [0, 0], ""] remoteExec ["MCCMK_fnc_shipMarkerLocal", _side];
