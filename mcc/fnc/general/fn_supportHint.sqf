params [["_kind", "", ["", []]]];
private _k = toLower (if (_kind isEqualType []) then {_kind param [0, ""]} else {_kind});
private _extra = if (_k == "ac-130") then {"Right click to toggle gun control"} else {
	if (_k in ["uav", "uav armed", "controllable"]) then {"Right click to toggle camera control"} else {""}
};
["Air support incoming." + (if (_extra == "") then {""} else {toString [10] + _extra}), 6] call MCC_fnc_hintBrief;
