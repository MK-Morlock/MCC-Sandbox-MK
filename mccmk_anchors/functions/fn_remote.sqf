/*
    ANC_fnc_remote  (any computer)
    So it works on servers and missions that only allow whitelisted remote calls (CfgRemoteExec) or filter them with
    BattlEye: nothing needs whitelisting.

        target: 2 = the server, 0 = every computer, or an object / group / array of
                them = wherever that is local (a player = that player's computer).
        jipObject (optional, with target 0): players joining later get it too,
                until that object is deleted.

    Only the names handled in ANC_fnc_rxInit can be run this way.
*/
params ["_args", ["_name", "", [""]], ["_target", 2], ["_jipObj", objNull, [objNull]]];
private _payload = [_name, _args];
if (!isNull _jipObj) exitWith {
    private _id = ["ANC_rx", _payload] call CBA_fnc_globalEventJIP;
    [_id, _jipObj] call CBA_fnc_removeGlobalEventJIP; // dropped when the object is deleted
};
if (_target isEqualType 0) exitWith {
    if (_target == 2) then {["ANC_rx", _payload] call CBA_fnc_serverEvent} else {["ANC_rx", _payload] call CBA_fnc_globalEvent};
};
if (_target isEqualType [] && {_target isEqualTo []}) exitWith {};
["ANC_rx", _payload, _target] call CBA_fnc_targetEvent;
