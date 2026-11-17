/*
	MCCMK_fnc_hideBodyInit - "Hide body" on any dead body (players' too): the medic animation, then Arma's own hideBody -
	the body sinks into the ground and is gone (the game decides what happens to the dropped weapons). Within 3 m, on
	foot, not on a body being carried or dragged. A scroll action; with ACE, in the ACE interaction menu.
	(postInit, every player)
*/
if (!hasInterface) exitWith {};

MCCMK_fnc_hideBodyOk = {
	params ["_b", "_u"];
	!isNull _b && {_b isKindOf "CAManBase"} && {!alive _b} && {isNull (attachedTo _b)} && {(vehicle _b) isEqualTo _b}
		&& {(vehicle _u) isEqualTo _u} && {(_u distance _b) < 3}
};
MCCMK_fnc_hideBodyDo = {
	params ["_b"];
	if (isNull _b) exitWith {};
	["Hiding the body..."] call MCCMK_fnc_hint;
	player playAction "MedicOther";
	[_b] remoteExec ["hideBody", 0];
};

if (call MCCMK_fnc_aceMenus) then {
	private _a = ["MCCMK_hideBody", "Hide body", "", {[_target] call MCCMK_fnc_hideBodyDo}, {[_target, _player] call MCCMK_fnc_hideBodyOk}] call ace_interact_menu_fnc_createAction;
	["CAManBase", 0, ["ACE_MainActions"], _a, true] call ace_interact_menu_fnc_addActionToClass;
};
if !(call MCCMK_fnc_scrollMenus) exitWith {};	//(MK) "ACE menu only": no scroll action too

private _add = {
	player addAction ["Hide body", {[cursorObject] call MCCMK_fnc_hideBodyDo}, nil, 1.3, false, true, "", "[cursorObject, _this] call MCCMK_fnc_hideBodyOk"];
};
[_add] spawn {
	params ["_add"];
	waitUntil {sleep 1; !isNull player};
	call _add;
	player addEventHandler ["Respawn", _add];
};
