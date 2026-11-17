/*
	MCCMK_fnc_pickupClient - (players of the side) a Pickup LZ (MCCMK_fnc_taruPickup): its map marker (Arma's Pickup marker,
	"Pickup LZ - <drop>"), and for the squad's leader the actions "Take off" (in a pod at the LZ), "Send helicopters"
	(on foot within 50 m of the LZ) and "Cancel pickup" - the scroll menu and/or ACE, by "MCC actions with ACE".
	["start", id, LZ, drop name, leader's owner, the pickup's pods] / ["lead", same - the actions only, a new leader] /
	["unlead", id] / ["move", id, LZ where it landed] / ["end", id]
*/
params [["_mode", "start"], ["_id", ""], ["_lz", []], ["_what", ""], ["_owner", -1], ["_pods", []]];
if (!hasInterface) exitWith {};
private _mk = format ["MCCMK_pickupMk_%1", _id];
if (_mode == "move") exitWith {	// where the first one actually landed (and so: landed)
	_mk setMarkerPosLocal _lz;
	missionNamespace setVariable [format ["MCCMK_pkLz_%1", _id], _lz];
	missionNamespace setVariable [format ["MCCMK_pkLanded_%1", _id], true];
};
private _fnc_unlead = {
	{player removeAction _x} forEach (missionNamespace getVariable [format ["MCCMK_pickupAct_%1", _id], []]);
	missionNamespace setVariable [format ["MCCMK_pickupAct_%1", _id], []];
	if (!isNil "ace_interact_menu_fnc_removeActionFromObject") then {
		{[player, 1, ["ACE_SelfActions", _x]] call ace_interact_menu_fnc_removeActionFromObject} forEach [format ["MCCMK_pkGo_%1", _id], format ["MCCMK_pkSend_%1", _id], format ["MCCMK_pkCancel_%1", _id]];
	};
};
if (_mode == "unlead") exitWith {call _fnc_unlead};	// no longer the squad's leader: the actions go (the marker stays)
if (_mode == "end") exitWith {
	deleteMarkerLocal _mk;
	call _fnc_unlead;
	if (!isNil "ace_interact_menu_fnc_removeActionFromObject") then {
		{[player, 1, ["ACE_SelfActions", _x]] call ace_interact_menu_fnc_removeActionFromObject} forEach [format ["MCCMK_pkGo_%1", _id], format ["MCCMK_pkSend_%1", _id], format ["MCCMK_pkCancel_%1", _id]];
	};
};
if (_mode == "start") then {
	createMarkerLocal [_mk, _lz];
	_mk setMarkerTypeLocal "mil_pickup";
	_mk setMarkerColorLocal "ColorBlue";
	_mk setMarkerTextLocal format ["Pickup LZ - %1", _what];
};
if (clientOwner != _owner) exitWith {};
call _fnc_unlead;	// (never twice)
// the leader's actions
missionNamespace setVariable [format ["MCCMK_pkPods_%1", _id], _pods];
private _conds = [
	format ["(vehicle _this) in (missionNamespace getVariable ['MCCMK_pkPods_%1', []])", _id],
	// (only once they've landed and someone is aboard )
	format ["((vehicle _this) isEqualTo _this) && {missionNamespace getVariable ['MCCMK_pkLanded_%1', false]} && {(_this distance2D (missionNamespace getVariable ['MCCMK_pkLz_%1', %2])) < 50} && {((missionNamespace getVariable ['MCCMK_pkPods_%1', []]) findIf {private _v = _x; ((crew _v) findIf {alive _x && {group _x != group (driver _v)}}) >= 0}) >= 0}", _id, _lz],
	format ["((missionNamespace getVariable ['MCCMK_pkPods_%1', []]) findIf {private _v = _x; ((crew _v) findIf {alive _x && {group _x != group (driver _v)}}) >= 0}) < 0", _id]	// no passengers aboard (an aircraft's own crew aside)
];
private _titles = ["<t color='#99FF00'>Take off</t>", "<t color='#99FF00'>Send helicopters</t>", "<t color='#FF9900'>Cancel pickup</t>"];
private _whats = ["go", "send", "cancel"];
private _acts = [];
if (call MCCMK_fnc_scrollMenus) then {
	{
		_acts pushBack (player addAction [_x, {params ["", "", "", "_a"]; _a remoteExec ["MCCMK_fnc_pickupGo", 2]}, [_whats select _forEachIndex, _id], 6, false, true, "", _conds select _forEachIndex]);	// (not shown on screen - the scroll menu only)
	} forEach _titles;
};
missionNamespace setVariable [format ["MCCMK_pickupAct_%1", _id], _acts];
if (call MCCMK_fnc_aceMenus) then {
	{
		private _c = compile ("private _this = _player; " + (_conds select _forEachIndex));
		private _a = [format [["MCCMK_pkGo_%1", "MCCMK_pkSend_%1", "MCCMK_pkCancel_%1"] select _forEachIndex, _id], (_x splitString "<>") select 1, "",
			{params ["", "", "_ap"]; (_ap select 0) remoteExec ["MCCMK_fnc_pickupGo", 2]},
			{params ["", "_player", "_ap"]; call (_ap select 1)}, {}, [[_whats select _forEachIndex, _id], _c]] call ace_interact_menu_fnc_createAction;
		[player, 1, ["ACE_SelfActions"], _a] call ace_interact_menu_fnc_addActionToObject;
	} forEach _titles;
};
if (_mode == "start") then {
	[format ["Pickup LZ marked on the map (%1). Order your men aboard; then Take off from aboard, or Send helicopters from the LZ.", _what]] call MCCMK_fnc_hint;
} else {
	[format ["You lead the squad now: the pickup (%1) waits for your Take off, Send helicopters or Cancel pickup.", _what]] call MCCMK_fnc_hint;
};
