/*
    ANC_fnc_setRode  (server)
    Sets the anchor rope / chain length used by the modelled pull (ANC_fnc_rodeTick) and switches the pull on or off.
    Broadcast only when it changes, so hauling sends a small update a few times a second at most.
    [boat, length, on/off]  - set the length and switch the pull on / off
*/
params ["_boat", "_len", ["_on", -1]];
if (abs ((_boat getVariable ["ANC_rodeLen", -1]) - _len) > 0.05) then {_boat setVariable ["ANC_rodeLen", _len, true]};
if (_on isEqualType true) then {
    if (_on) then {
        private _end = _boat getVariable ["ANC_end", objNull];
        if !((_boat getVariable ["ANC_endObj", objNull]) isEqualTo _end) then {_boat setVariable ["ANC_endObj", _end, true]};
    };
    if !((_boat getVariable ["ANC_force", false]) isEqualTo _on) then {
        _boat setVariable ["ANC_force", _on, true];
        call ANC_fnc_lineBoats;
    };
};
