params [["_kind", "", ["", []]]];
// (airdrops pass a list of lists: dig down to the first name)
private _k = _kind;
while {_k isEqualType []} do {_k = _k param [0, ""]};
_k = toLower (if (_k isEqualType "") then {_k} else {""});
private _extra = if (_k == "ac-130") then {"Right click to toggle gun control"} else {
	if (_k in ["uav", "uav armed", "controllable"]) then {"Right click to toggle camera control"} else {""}
};
["Air support incoming." + (if (_extra == "") then {""} else {toString [10] + _extra}), 6] call MCC_fnc_hintBrief;
