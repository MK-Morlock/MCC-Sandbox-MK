/*
    ANC_fnc_shoreDrop  (server)
    "Drop the line" (or the holder dies, disconnects or gets into a vehicle). Helpers just let go. If the person
    carrying the end lets go and others are still holding, the next one takes the end; otherwise it drops where they
    stand and lies there loose.
*/
params ["_player", ["_boat", objNull]];
if (isNull _boat && {!isNull _player}) then {_boat = _player getVariable ["ANC_holdingBoat", objNull]};
if (!isNull _player) then {_player setVariable ["ANC_holdingBoat", objNull, true]};
if (isNull _boat) exitWith {};
private _h = (_boat getVariable ["ANC_shoreHolders", []]) select {!isNull _x && {_x != _player}};
_boat setVariable ["ANC_shoreHolders", _h];
private _d = _boat getVariable ["ANC_shoreData", []];
if (count _d != 5) exitWith {};
_d params ["_pad", "_pt", "_len"];
if (count _h > 0) then {
    if ((_boat getVariable ["ANC_shoreCarrier", objNull]) isEqualTo _player || {isNull (_boat getVariable ["ANC_shoreCarrier", objNull])}) then {
        private _next = _h select 0;
        if (!isNull (attachedTo _pad)) then {detach _pad};
        _boat setVariable ["ANC_shoreCarrier", _next, true];
        [[_pad, _boat, _boat getVariable ["ANC_visual", objNull]], "shoreFollow", _next] call ANC_fnc_remote;
    };
    [_boat, _pad, _pt, _len, (missionNamespace getVariable ["ANC_pullStrength", 600]) * (count _h), "held"] call ANC_fnc_setShore;
} else {
    private _p = getPosASL _pad;
    _boat setVariable ["ANC_shoreCarrier", objNull, true];
    if (!isNull (attachedTo _pad)) then {detach _pad};
    private _bagBack = _boat getVariable ["ANC_visual", objNull];
    if (!isNull _bagBack) then {_bagBack attachTo [_pad, [0, 0, 0.1]]};
    _pad setPosASL [_p select 0, _p select 1, ((getTerrainHeightASL _p) max 0) + 0.05];
    _boat setVariable ["ANC_state", "loose"];
    [_boat, _pad, _pt, _len, 0, "loose"] call ANC_fnc_setShore;
};
call ANC_fnc_shoreLists;
if (!isNull _player) then {[["Line dropped."], "notify", _player] call ANC_fnc_remote};
