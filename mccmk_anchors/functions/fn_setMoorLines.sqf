/*
    ANC_fnc_setMoorLines  (server)
    Shares a moored boat's line lengths with every computer, so the modelled pull (ANC_fnc_rodeTick) runs wherever the
    boat is simulated.
    [boat, [length, ...]] - [boat, []] switches the lines' pull off.
    Broadcast only when something actually changes.
*/
params ["_boat", "_lens"];
private _lines = _boat getVariable ["ANC_lines", []];
private _data = [];
{
    _x params ["", "", "_pad", "_boatPoint"];
    if (_forEachIndex < count _lens) then {_data pushBack [_pad, _boatPoint, _lens select _forEachIndex]};
} forEach _lines;
private _old = _boat getVariable ["ANC_moorData", []];
// (findIf has no index of its own, so the index is counted here.)
private _changed = count _old != count _data;
if (!_changed) then {
    for "_i" from 0 to (count _data) - 1 do {
        if (abs (((_data select _i) select 2) - ((_old select _i) select 2)) > 0.05) exitWith {_changed = true};
    };
};
if (_changed) then {_boat setVariable ["ANC_moorData", _data, true]};
// With "Arma rope physics" the ropes themselves hold the boat (ANC_fnc_moorWatchdog sets them to the line length), so
// the mod's own pull is off.
private _on = count _data > 0 && {(missionNamespace getVariable ["ANC_moorPhysics", 0]) == 0};
if !((_boat getVariable ["ANC_moorOn", false]) isEqualTo _on) then {
    _boat setVariable ["ANC_moorOn", _on, true];
    call ANC_fnc_lineBoats;
};
