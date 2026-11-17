private _list = uiNamespace getVariable ["MCCMK_lhdPurchases", []];
private _say = {params ["_m"]; if (isNil "MCCMK_fnc_lhdStatus") then {[_m] call MCCMK_fnc_hint} else {[_m] call MCCMK_fnc_lhdStatus}};
if (_list isEqualTo []) exitWith {["Nothing to undo."] call _say};
private _e = _list deleteAt ((count _list) - 1);
uiNamespace setVariable ["MCCMK_lhdPurchases", _list];
_e params ["_v", "_cur", "_amt", "_pos"];
if (isNull _v || {!alive _v}) exitWith {["That vehicle no longer exists."] call _say};
private _name = getText (configOf _v >> "displayName");
private _why = switch (true) do {
	case (((crew _v) select {alive _x}) isNotEqualTo []): {"someone is in it"};
	case ((damage _v) > 0.05): {"it has been damaged"};
	case (((getPosASL _v) distance _pos) > 5): {"it has been moved"};
	default {""};
};
if (_why != "") exitWith {
	_list pushBack _e;
	uiNamespace setVariable ["MCCMK_lhdPurchases", _list];
	[format ["Can't undo the %1: %2.", _name, _why]] call _say;
};
deleteVehicle _v;
switch (_cur) do {
	case "res": {
		private _var = format ["MCC_res%1", playerSide];
		private _r = +(missionNamespace getVariable [_var, [0, 0, 0, 0, 0]]);
		{_r set [_forEachIndex, (_r select _forEachIndex) + _x]} forEach _amt;
		missionNamespace setVariable [_var, _r];
		publicVariable _var;
	};
	case "cr": {player setVariable ["MCC_valorPoints", (player getVariable ["MCC_valorPoints", 50]) + _amt, true]};
};
[format ["Undone: %1, %2.", _name, ["removed", "fully refunded"] select (_cur in ["res", "cr"])]] call _say;
["INFO", "LHDSpawn", "%1 undid the purchase of %2 (%3 %4)", [name player, _name, _cur, _amt]] call MCC_fnc_log;
