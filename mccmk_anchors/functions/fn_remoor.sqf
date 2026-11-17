/*
    ANC_fnc_remoor  (server, spawned)
    "Moor" while already moored.
*/
params ["_boat", "_player"];
private _say = {[[_this], "notify", _player] call ANC_fnc_remote};
private _lines = _boat getVariable ["ANC_lines", []];
private _data = _boat getVariable ["ANC_moorData", []];
private _large = ((_boat call ANC_fnc_boatGeometry) select 6) >= 12;
private _slack = [0.3, 0.6] select _large;
private _haulRate = [0.5, 0.3] select _large;

private _lens = _data apply {_x select 2};
private _inPlace = true;
{
    _x params ["", "", "_pad", "_boatPoint", "", "_final"];
    if ((abs ((_lens param [_forEachIndex, 0]) - _final) > 0.2) || {((_boat modelToWorldWorld _boatPoint) distance (getPosASL _pad)) > _final + 0.2}) exitWith {_inPlace = false};
} forEach _lines;
if (_inPlace) exitWith {"Already moored." call _say};

_boat setVariable ["ANC_state", "mooring"];
[_boat, "Hauling back to the mooring position...", _player] call ANC_fnc_tellBoat;
private _timeout = time + 120;
while {alive _boat && {time < _timeout}} do {
    private _done = true;
    {
        private _target = ((_x select 5) - _slack) max 0.5;
        private _l = _lens param [_forEachIndex, _target];
        if (_l > _target + 0.05) then {_lens set [_forEachIndex, (_l - (_haulRate * 0.25)) max _target]; _done = false};
        if (_l < _target - 0.05) then {_lens set [_forEachIndex, _target]};
    } forEach _lines;
    [_boat, _lens] call ANC_fnc_setMoorLines;
    if (_done) exitWith {};
    sleep 0.25;
};
if (!alive _boat) exitWith {[_boat] call ANC_fnc_cleanup};
{_lens set [_forEachIndex, _x select 5]} forEach _lines;
[_boat, _lens] call ANC_fnc_setMoorLines;
_boat setVariable ["ANC_state", "moored"];
[_boat, "Moored."] call ANC_fnc_tellBoat;
