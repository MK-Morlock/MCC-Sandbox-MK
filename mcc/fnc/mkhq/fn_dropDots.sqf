/*
	MCCMK_fnc_dropDots - (the ordering player's machine) a drop's green dots, kept by drop id until the drop is complete.
	["add", id, markers] - kept (removed after 15 minutes at most); ["set", id, positions] - replaced by dots at these
	positions (fast-rope: one per helicopter); ["done", id, index] - that dot removed (-1: all of them).
*/
params [["_mode", "add"], ["_id", ""], ["_a", []]];
if (!hasInterface || {_id == ""}) exitWith {};
if (isNil "MCCMK_ddMarks") then {MCCMK_ddMarks = createHashMap};
private _mk = {
	params ["_p"];
	MCCMK_lineN = (missionNamespace getVariable ["MCCMK_lineN", 0]) + 1;
	private _m = format ["mccmk_line_%1", MCCMK_lineN];
	createMarkerLocal [_m, _p];
	_m setMarkerShapeLocal "ICON";
	_m setMarkerTypeLocal "mil_dot";
	_m setMarkerColorLocal "ColorGreen";
	_m setMarkerSizeLocal [0.9, 0.9];
	_m
};
switch (_mode) do {
	case "add": {
		// (the server's "set" can arrive first - a fast-rope's dots per helicopter: those are kept, the line's own dot goes)
		if (_id in MCCMK_ddMarks) then {{deleteMarkerLocal _x} forEach _a} else {MCCMK_ddMarks set [_id, _a]};
		[_id] spawn {params ["_id"]; sleep 900; ["done", _id, -1] call MCCMK_fnc_dropDots};
	};
	case "set": {
		{deleteMarkerLocal _x} forEach (MCCMK_ddMarks getOrDefault [_id, []]);
		MCCMK_ddMarks set [_id, _a apply {[_x] call _mk}];
	};
	case "done": {
		private _l = MCCMK_ddMarks getOrDefault [_id, []];
		if (_a isEqualType 0 && {_a >= 0}) then {
			if (_a < count _l) then {deleteMarkerLocal (_l select _a); _l set [_a, ""]};
			if ((_l findIf {_x != ""}) < 0) then {MCCMK_ddMarks deleteAt _id};
		} else {
			{deleteMarkerLocal _x} forEach _l;
			MCCMK_ddMarks deleteAt _id;
		};
	};
};
