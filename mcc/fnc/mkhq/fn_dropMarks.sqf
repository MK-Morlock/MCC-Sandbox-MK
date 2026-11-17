/*
	MCCMK_fnc_dropMarks - (the player who ordered a drop) its line on the map: the red line and arrow go after their usual
	time; the GREEN DOT(S) - where it drops - stay until that drop is complete (the server says so: MCCMK_fnc_dropDone ->
	MCCMK_fnc_dropDots), 15 minutes at most. [line mode ("drop", "para", "supply"), start, end, seconds for the line, drop id]
*/
params [["_mode", "drop"], ["_a", [0, 0, 0]], ["_b", [0, 0, 0]], ["_secs", 40], ["_id", ""]];
private _lm = [_mode, [_a select 0, _a select 1, 0], [_b select 0, _b select 1, 0], [], [1, 8] select (_mode == "supply")] call MCCMK_fnc_supportLine;
private _dots = _lm select {(markerType _x) == "mil_dot"};
["add", _id, _dots] call MCCMK_fnc_dropDots;
[_lm - _dots, _secs] spawn {params ["_l", "_s"]; sleep _s; {deleteMarkerLocal _x} forEach _l};
