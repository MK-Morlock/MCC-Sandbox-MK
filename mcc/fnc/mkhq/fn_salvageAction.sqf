/*
	MCCMK_fnc_salvageAction  (every player)
	"Salvage wreck" on a wreck: a hold action (and an ACE action with ACE's progress bar). 5 s for a car or small boat,
	10 s for a helicopter or truck, 20 s for a tank or plane. Needs a toolkit, or a repair source within 15 m
	(MCCMK_fnc_salvageCan). Done: the server pays (enemy wrecks only) and removes it (MCCMK_fnc_salvageDone). [wreck]
*/
params [["_v", objNull, [objNull]]];
if (!hasInterface || {isNull _v}) exitWith {};
//(MK) a drone: an action on it only shows to a player connected to it by a UAV terminal - the player's own "Salvage
// wreck" (MCCMK_fnc_salvageInit) covers drones instead
if (getNumber (configOf _v >> "isUav") == 1) exitWith {};
private _dur = switch (true) do {
	case (_v isKindOf "Tank" || {_v isKindOf "Plane"}): {20};
	case (_v isKindOf "Helicopter" || {_v isKindOf "Truck_F"} || {_v isKindOf "Wheeled_APC_F"}): {10};
	default {5};
};
private _icon = "\a3\ui_f\data\IGUI\Cfg\Actions\repair_ca.paa";
//(MK) a disabled, empty enemy vehicle (MCCMK_fnc_wcVehicle): "Salvage vehicle", while it's still disabled and empty - not
// one the player's side has crewed (that one is to be repaired, or destroyed and its wreck salvaged)
private _live = alive _v;
private _title = ["Salvage wreck", "Salvage vehicle"] select _live;
MCCMK_salvageLiveOk = {
	params ["_t", "_u"];
	!alive _t || {(_t getVariable ["MCCMK_disabledSalvage", false]) && {!canMove _t} && {((crew _t) findIf {alive _x}) < 0}
		&& {!((side group _u) in (_t getVariable ["MCCMK_usedBy", []]))}}
};
if (call MCCMK_fnc_scrollMenus) then {[
	_v, _title, _icon, _icon,
	"(_this distance _target) < 8 && {(vehicle _this) isEqualTo _this} && {[_target, _this] call MCCMK_salvageLiveOk} && {call MCCMK_fnc_salvageCan}",
	"(_this distance _target) < 9",
	{}, {},
	{params ["_target", "_caller"]; [_target, _caller] remoteExec ["MCCMK_fnc_salvageDone", 2]},
	{},
	[], _dur, 10, true, false
] call BIS_fnc_holdActionAdd};
if (call MCCMK_fnc_aceMenus) then {	//(MK) the ACE menu or the scroll menu, by "MCC actions with ACE"
	private _act = ["MCCMK_salvage", _title, _icon, {
		params ["_target", "_player"];
		[_target getVariable ["MCCMK_salvageTime", 5], [_target, _player], {(_this select 0) params ["_t", "_p"]; [_t, _p] remoteExec ["MCCMK_fnc_salvageDone", 2]}, {}, "Salvaging the wreck..."] call ace_common_fnc_progressBar;
	}, {(vehicle _player) isEqualTo _player && {[_target, _player] call MCCMK_salvageLiveOk} && {call MCCMK_fnc_salvageCan}}] call ace_interact_menu_fnc_createAction;
	_v setVariable ["MCCMK_salvageTime", _dur];
	[_v, 0, ["ACE_MainActions"], _act] call ace_interact_menu_fnc_addActionToObject;
};
