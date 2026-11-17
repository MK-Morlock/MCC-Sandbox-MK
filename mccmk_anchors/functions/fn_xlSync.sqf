/*
    ANC_fnc_xlSync  (server)
    Shares a boat's extra lines (tow lines and tethers, from the line register ANC_xLines) with every computer, as
    ANC_xl = [[id, kind, other vehicle, own point, other's point, length, "tower" / "towed" / ""], ...], so the pull
    model (ANC_fnc_rodeTick) sees every tow line on the boat at once.
    [boat]
*/
params [["_boat", objNull, [objNull]]];
if (!isServer || {isNull _boat}) exitWith {};
if (isNil "ANC_xLines") then {ANC_xLines = createHashMap};
private _out = [];
{
    private _r = _y;
    private _a = _r get "a";
    private _b = _r get "b";
    if (_a isEqualTo _boat) then {_out pushBack [_x, _r get "kind", _b, _r get "aPt", _r get "bPt", _r get "len", "tower"]};
    if (_b isEqualTo _boat) then {_out pushBack [_x, _r get "kind", _a, _r get "bPt", _r get "aPt", _r get "len", "towed"]};
} forEach ANC_xLines;
if !(_out isEqualTo (_boat getVariable ["ANC_xl", []])) then {_boat setVariable ["ANC_xl", _out, true]};
call ANC_fnc_lineBoats;
