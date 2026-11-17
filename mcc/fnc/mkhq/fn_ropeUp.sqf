/*
	MCCMK_fnc_ropeUp - (server) a man onto a pickup rope from a hovering helicopter: [unit, helicopter] -> true if he's on.
	A free Advanced Rappelling rope point (the same book-keeping as Advanced Pickup Rope and Advanced Rappelling, so they
	share the points) and a free passenger seat for him (counting those already on their way up); a player then climbs
	with W / S (MK_APR_Client_Pickup_Rope), an AI is winched up (MCCMK_fnc_ropeAIUp). The rope point is free again once he's
	off the rope.
*/
params [["_u", objNull], ["_h", objNull], ["_pref", -1]];
if (!isServer || {isNull _u} || {isNull _h} || {!alive _u} || {!alive _h}) exitWith {false};
if (isNil "ARMK_Get_Heli_Rappel_Points" || {_u getVariable ["ARMK_Is_Rappelling", false]}) exitWith {false};
private _up = {(_x getVariable ["ARMK_Is_Rappelling", false]) && {(_x distance _h) < 60}} count (allUnits select {(_x getVariable ["MCCMK_ropeHeli", objNull]) isEqualTo _h});
if ((([_h] call MCCMK_seatsFree) - _up) < 1) exitWith {false};
private _pts = [_h] call ARMK_Get_Heli_Rappel_Points;
private _i = -1;
if (_pref >= 0 && {_pref < count _pts} && {isNull (_h getVariable ["ARMK_Rappelling_Player_" + str _pref, objNull])}) then {_i = _pref} else {
	{if (isNull (_h getVariable ["ARMK_Rappelling_Player_" + str _forEachIndex, objNull])) exitWith {_i = _forEachIndex}} forEach _pts;
};
if (_i < 0) exitWith {false};
_h setVariable ["ARMK_Rappelling_Player_" + str _i, _u, true];
_u setVariable ["ARMK_Is_Rappelling", true, true];
_u setVariable ["MCCMK_ropeHeli", _h, true];
if (!isNil "ARMK_Rope_Doors") then {[_h] call ARMK_Rope_Doors};
if (isPlayer _u) then {
	[_u, _h, _pts select _i] remoteExec ["MK_APR_Client_Pickup_Rope", owner _u];
} else {
	[_u, _h, _pts select _i] remoteExec ["MCCMK_fnc_ropeAIUp", _u];
};
[_u, _h, _i] spawn {
	params ["_u", "_h", "_i"];
	waitUntil {sleep 2; !alive _u || {!(_u getVariable ["ARMK_Is_Rappelling", false])}};
	_h setVariable ["ARMK_Rappelling_Player_" + str _i, nil, true];
	_u setVariable ["MCCMK_ropeHeli", nil, true];
};
true
