params [["_list", [], [[]]], ["_job", "patrol", [""]], ["_n", -1, [0]]];
private _classes = (_list apply {if (_x isEqualType "") then {_x} else {_x param [0, ""]}}) select {_x != "" && {isClass (configFile >> "CfgVehicles" >> _x)}};
if (count _classes == 0) exitWith {""};
private _fits = _classes select {
	private _p = [_x] call MCCMK_fnc_vehicleProfile;
	switch (toLower _job) do {
		case "patrol": {(_p select 4) >= 1 && {(_p select 3) == ""} && {!(_p select 2)} && {!(_p select 16)}};
		case "transport": {(_p select 9) >= ([_n, 4] select (_n < 0)) && {(_p select 3) == ""} && {!(_p select 2)}};
		case "gunship": {(_p select 19) >= 3 || {(_p select 18) > 0}};
		case "lifter": {(_p select 15) >= ([_n, 2000] select (_n < 0))};
		default {true};
	}
};
if (count _fits == 0) exitWith {""};
selectRandom _fits
