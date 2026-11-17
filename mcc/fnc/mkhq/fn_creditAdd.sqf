params [["_uid", "", [""]], ["_name", "", [""]], ["_amt", 0, [0]], ["_msg", "", [""]]];
if (!isServer || {_uid == ""} || {_amt == 0}) exitWith {};
private _i = allPlayers findIf {getPlayerUID _x == _uid};
if (_i >= 0) then {
	private _p = allPlayers select _i;
	private _v = (_p getVariable ["MCC_valorPoints", 50]) + _amt;
	_p setVariable ["MCC_valorPoints", _v, true];
	[_uid, name _p, _v] call MCCMK_fnc_creditStore;
	if (_msg != "") then {[_msg] remoteExec ["MCCMK_fnc_hint", _p]};
} else {
	private _v = ([_uid, _name] call MCCMK_fnc_creditGet) max 50;
	[_uid, _name, _v + _amt] call MCCMK_fnc_creditStore;
	["INFO", "credits", "%1 is offline: %2 credits held for them", [_name, _amt]] call MCC_fnc_log;
};
