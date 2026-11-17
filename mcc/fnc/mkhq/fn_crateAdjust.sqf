/*
	MCCMK_fnc_crateAdjust - the Adjust crates panel (from the Logistics crate screen): moves the crates MCC placed on a
	cargo truck's bed - one, or all together - 10 cm a click (1 cm with Shift), turns them 90 degrees, or resets them.
	The adjustment is kept for that truck type (profileNamespace "MCCMK_bedAdjust"), so crates loaded onto the same kind
	of truck go to the corrected places.
	["open"] / ["fill"] / ["move", [x, y, z], shift] / ["turn"] / ["reset"]
*/
disableSerialization;
params [["_mode", "open", [""]], ["_d", [0, 0, 0]], ["_fine", false]];
private _truck = vehicle player;
private _crates = ((attachedObjects _truck) select {(_x getVariable ["MCCMK_bedSlot", -1]) >= 0});
_crates = [_crates, [], {_x getVariable ["MCCMK_bedSlot", 0]}, "ASCEND"] call BIS_fnc_sortBy;
if (_mode == "open") exitWith {
	if (_crates isEqualTo []) exitWith {systemChat "No crates to adjust: crates carried with vehicle-in-vehicle are placed by Arma."};
	createDialog "MCCMK_CRATE_ADJUST";
	["fill"] call MCCMK_fnc_crateAdjust;
};
private _disp = findDisplay 9300;
private _lb = _disp displayCtrl 9301;
if (_mode == "fill") exitWith {
	lbClear _lb;
	_lb lbAdd "All crates";
	{_lb lbAdd format ["Crate %1: %2", _forEachIndex + 1, getText (configFile >> "CfgVehicles" >> typeOf _x >> "displayName")]} forEach _crates;
	_lb lbSetCurSel 0;
};
private _sel = lbCurSel _lb;
private _which = if (_sel <= 0) then {_crates} else {[_crates param [_sel - 1, objNull]] - [objNull]};
private _all = profileNamespace getVariable ["MCCMK_bedAdjust", createHashMap];
private _key = toLower typeOf _truck;
private _list = +(_all getOrDefault [_key, []]);
{
	private _c = _x;
	private _slot = _c getVariable ["MCCMK_bedSlot", 0];
	while {count _list <= _slot} do {_list pushBack [0, 0, 0, 0]};
	private _a = +(_list select _slot);
	switch (_mode) do {
		case "move": {private _s = [0.1, 0.01] select _fine; _a set [0, (_a select 0) + (_d select 0) * _s]; _a set [1, (_a select 1) + (_d select 1) * _s]; _a set [2, (_a select 2) + (_d select 2) * _s]};
		case "turn": {_a set [3, ((_a select 3) + 90) mod 360]};
		case "reset": {_a = [0, 0, 0, 0]};
	};
	_list set [_slot, _a];
	_all set [_key, _list];
	profileNamespace setVariable ["MCCMK_bedAdjust", _all];
	private _p = [_truck, _c, _slot, [0, 0, 0]] call MCCMK_fnc_truckBedPoint;
	_c attachTo [_truck, _p select 0];
	[_c, _p select 1] remoteExec ["setDir", _c];
} forEach _which;
saveProfileNamespace;
