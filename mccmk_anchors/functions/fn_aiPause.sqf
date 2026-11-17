/*
    ANC_fnc_aiPause  (server)
    Holds an AI driver still while the anchor is weighed or the lines cast off, so it doesn't strain against them;
    lets it go again afterwards.
    [boat, true] = hold, [boat, false] = release. Uses vanilla disableAI /
    enableAI "MOVE", run where the driver is simulated.
*/
params ["_boat", "_hold"];
if (isNil "ANC_aiPaused") then {ANC_aiPaused = []};
private _drv = driver _boat;
if (_hold) then {
    if (!isNull _drv && {alive _drv} && {!isPlayer _drv}) then {
        [[_drv, "MOVE"], "disableAI", _drv] call ANC_fnc_remote;
        _boat setVariable ["ANC_aiPausedDriver", _drv];
        ANC_aiPaused pushBackUnique _boat;
    };
} else {
    private _d = _boat getVariable ["ANC_aiPausedDriver", objNull];
    if (!isNull _d) then {[[_d, "MOVE"], "enableAI", _d] call ANC_fnc_remote};
    _boat setVariable ["ANC_aiPausedDriver", nil];
    _boat setVariable ["ANC_aiWeighing", nil];
    ANC_aiPaused = ANC_aiPaused - [_boat];
};
