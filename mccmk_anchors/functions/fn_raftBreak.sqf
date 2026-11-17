/*
    ANC_fnc_raftBreak  (server)
    A rafted-up / tethered boat was knocked well out of place (ANC_fnc_raftHold): rather than yank the boats back
    together, the lines are cast off and both crews are told.
    [boat]
*/
params [["_boat", objNull, [objNull]]];
if (isNull _boat) exitWith {};
private _rl = _boat getVariable ["ANC_raftLink", []];
_boat setVariable ["ANC_raftBroke", nil];
if (count _rl < 5) exitWith {};
private _o = _rl select 0;
private _maker = if ((_boat getVariable ["ANC_mode", ""]) in ["raft", "tether"]) then {_boat} else {_o};
if (!isNull _maker) then {[_maker] call ANC_fnc_cleanup};
{if (!isNull _x) then {[_x, "The boats were knocked apart - the lines are cast off."] call ANC_fnc_tellBoat; _x setVariable ["ANC_raftBroke", nil, true]}} forEach [_boat, _o];
