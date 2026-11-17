/*
    ANC_fnc_shoreTie  (server)
    The line then holds the boat like a mooring line (it can't slip), at its current length.
*/
params ["_player"];
private _boat = _player getVariable ["ANC_holdingBoat", objNull];
private _say = {[[_this], "notify", _player] call ANC_fnc_remote};
if (isNull _boat) exitWith {};
private _d = _boat getVariable ["ANC_shoreData", []];
if (count _d != 5) exitWith {};
_d params ["_pad", "_pt"];
private _post = [_player] call ANC_fnc_shorePost;
if (isNull _post) exitWith {"Nothing within 3 m to make the line fast to." call _say};
_boat setVariable ["ANC_shoreCarrier", objNull, true];
if (!isNull (attachedTo _pad)) then {detach _pad};
private _bagBack = _boat getVariable ["ANC_visual", objNull];
if (!isNull _bagBack) then {_bagBack attachTo [_pad, [0, 0, 0.1]]};
private _at = getPosASL _post;
_pad setPosASL [_at select 0, _at select 1, ((getPosASL _player) select 2) + 0.8];
{_x setVariable ["ANC_holdingBoat", objNull, true]} forEach (_boat getVariable ["ANC_shoreHolders", []]);
_boat setVariable ["ANC_shoreHolders", []];
_boat setVariable ["ANC_state", "tied"];
private _len = ((_boat modelToWorldWorld _pt) distance (getPosASL _pad)) + 0.3;
[_boat, _pad, _pt, _len, -1, "tied"] call ANC_fnc_setShore;
call ANC_fnc_shoreLists;
"Line made fast." call _say;
