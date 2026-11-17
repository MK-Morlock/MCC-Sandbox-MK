/*
    ANC_fnc_xlLabel  (server)
    A line's name as seen from one boat, for menus and messages: "Tow line (stern) to Assault Boat, 6 m",
    "Towed (bow) by Combat Boat, 6 m", "Tether (port side) to Rescue Boat". [id, boat, with length]
*/
params [["_id", "", [""]], ["_boat", objNull, [objNull]], ["_withLen", true, [true]]];
if (isNil "ANC_xLines" || {!(_id in ANC_xLines)}) exitWith {""};
private _r = ANC_xLines get _id;
private _mine = (_r get "a") isEqualTo _boat;
private _other = [_r get "a", _r get "b"] select _mine;
private _pt = [_r get "bPt", _r get "aPt"] select _mine;
private _where = [_boat, _pt] call {
    params ["_v", "_p"];
    (_v call ANC_fnc_boatGeometry) params ["", "_sternY", "_bowY"];
    private _y = _p select 1;
    private _x = _p select 0;
    switch (true) do {
        case ((abs (_y - _bowY)) < ((_bowY - _sternY) * 0.2)): {"bow"};
        case ((abs (_y - _sternY)) < ((_bowY - _sternY) * 0.2)): {"stern"};
        case (_x < 0): {"port side"};
        default {"starboard side"};
    };
};
private _name = getText (configOf _other >> "displayName");
private _len = format [", %1 m", round (_r get "len")];
if ((_r get "kind") isEqualTo "tether") exitWith {format ["Tether (%1) to %2", _where, _name]};
if (_mine) then {format ["Tow line (%1) to %2%3", _where, _name, ["", _len] select _withLen]} else {format ["Towed (%1) by %2%3", _where, _name, ["", _len] select _withLen]}
