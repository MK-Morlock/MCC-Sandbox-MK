params [["_o", objNull, [objNull]]];
if (isNull _o) exitWith {false};
private _side = _o getVariable ["side", _o getVariable ["MCC_side", sideUnknown]];
private _s = missionNamespace getVariable [format ["MCC_START_%1", _side], []];
(_s isEqualType []) && {count _s > 1} && {(_o distance2D _s) < 60}
