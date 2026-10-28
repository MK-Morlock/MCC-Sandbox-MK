params [["_key", 2, [0]]];
private _side = playerSide;
private _cas = missionNamespace getVariable [format ["MCC_CASConsoleArray%1", _side], []];
private _fnc_cost = {
	params ["_e"];
	private _c = missionNamespace getVariable [str _e, []];
	if (count _c == 0) then {"free"} else {(_c apply {format ["%1%2 %3", toUpper ((_x select 0) select [0, 1]), (_x select 0) select [1], _x select 1]}) joinString ", "}
};
if (_key == 3) exitWith {
	if (alive (missionNamespace getVariable ["MCC_ACConsoleUp", objNull])) exitWith {["connect", objNull, "Connect to AC-130"]};
	private _i = _cas findIf {(toLower ((_x select 0) select 0)) == "ac-130"};
	if (_i < 0) exitWith {["none", objNull, "AC-130 not available"]};
	["deploy", _i, "Deploy AC-130" + toString [10] + ([_cas select _i] call _fnc_cost)]
};
private _list = allUnitsUAV select {alive _x && {(side _x) isEqualTo _side}};
private _picked = ((missionNamespace getVariable ["MCC_ConsoleGroupSelected", []]) apply {vehicle (leader _x)}) select {_x in _list};
if (count _picked > 0) exitWith {["connect", _picked select 0, "Connect to UAV"]};
private _sel = missionNamespace getVariable ["MCC_ConolseUAV", objNull];
if (!isNull _sel && {_sel in _list}) exitWith {["connect", _sel, "Connect to UAV"]};
if (count _list == 1) exitWith {["connect", _list select 0, "Connect to UAV"]};
if (count _list > 1) exitWith {["select", objNull, "Select a UAV on the map"]};
private _i = _cas findIf {(toLower ((_x select 0) select 0)) == "uav armed"};
if (_i < 0) exitWith {["none", objNull, "No UAV available"]};
["deploy", _i, "Deploy UAV" + toString [10] + ([_cas select _i] call _fnc_cost)]
