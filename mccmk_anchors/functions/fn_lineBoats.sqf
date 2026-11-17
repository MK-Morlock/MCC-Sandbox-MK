/*
    ANC_fnc_lineBoats  (server)
    Rebuilds the list of vehicles with a line out - anchor, mooring, tow (both ends) or shore line - and shares it
    with every computer, only if it has changed. Called whenever a line goes out or comes in, so the pull model
    (ANC_fnc_rodeTick) never has to search for them.
*/
if (!isServer) exitWith {[[], "lineBoats", 2] call ANC_fnc_remote};
private _list = vehicles select {
    (_x getVariable ["ANC_force", false])
    || {_x getVariable ["ANC_moorOn", false]}
    || {count (_x getVariable ["ANC_xl", []]) > 0} // tow lines and tethers (the line register)
    || {count (_x getVariable ["ANC_shoreData", []]) == 5}
    || {count (_x getVariable ["ANC_raftLink", []]) >= 5} // rafted up / tethered (both boats)
};
if !(_list isEqualTo (missionNamespace getVariable ["ANC_lineBoats", []])) then {
    ANC_lineBoats = _list;
    publicVariable "ANC_lineBoats";
};
