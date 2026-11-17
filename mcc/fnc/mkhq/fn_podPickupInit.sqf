// "Pick up pod" on every Taru pod (supply pods, and empty troop pods) - commander and squad leaders, within 8 m.
if (!hasInterface) exitWith {};
// (MK) both kinds of Taru pod: the cargo pods and the crewed ones (medical, bench, transport). A troop pod's own Taru
// marks it while it's coming back for it (MCCMK_collectBy) - the action shows only once that Taru is gone.
MCCMK_podPickupAdd = {
	params ["_pod"];
	if (_pod getVariable ["MCCMK_pickupAct", false]) exitWith {};	// once per pod, whichever class hook gets there first
	_pod setVariable ["MCCMK_pickupAct", true];
	_pod addAction ["<t color='#7fd4ff'>Pick up pod</t>", {
		params ["_pod", "_u"];
		[_pod, _u] remoteExec ["MCCMK_fnc_podPickup", 2];
	}, [], 1.5, false, true, "",
	"alive _target && {(_this distance _target) < 8} && {isNull attachedTo _target} && {!alive (_target getVariable ['MCCMK_collectBy', objNull])} && {(count crew _target) == 0} && {!(_target getVariable ['MCCMK_pickupPending', false])} && {((((missionNamespace getVariable ['MCC_server', objNull]) getVariable [format ['CP_commander%1', side group _this], '']) == getPlayerUID _this) || {leader group _this == _this})}"];
};
//(MK) "MCC actions with ACE": in the ACE menu (on the pod), or the scroll menu
if (call MCCMK_fnc_aceMenus) then {
	MCCMK_podPickupCond = compile "alive _target && {(_this distance _target) < 8} && {isNull attachedTo _target} && {!alive (_target getVariable ['MCCMK_collectBy', objNull])} && {(count crew _target) == 0} && {!(_target getVariable ['MCCMK_pickupPending', false])} && {((((missionNamespace getVariable ['MCC_server', objNull]) getVariable [format ['CP_commander%1', side group _this], '']) == getPlayerUID _this) || {leader group _this == _this})}";
	private _a = ["MCCMK_podPickup", "Pick up pod", "", {[_target, _player] remoteExec ["MCCMK_fnc_podPickup", 2]},
		{private _this = _player; call MCCMK_podPickupCond}] call ace_interact_menu_fnc_createAction;
	{[_x, 0, ["ACE_MainActions"], _a, true] call ace_interact_menu_fnc_addActionToClass} forEach ["Pod_Heli_Transport_04_base_F", "Pod_Heli_Transport_04_crewed_base_F"];
};
if !(call MCCMK_fnc_scrollMenus) exitWith {};	//(MK) "ACE menu only": no scroll action too
{[_x, "init", MCCMK_podPickupAdd, true, [], true] call CBA_fnc_addClassEventHandler} forEach ["Pod_Heli_Transport_04_base_F", "Pod_Heli_Transport_04_crewed_base_F"];
