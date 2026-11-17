/*
    ANC_fnc_boardMenu  (client)
    The other boat's free seats - driver, gunners and turrets (by their own names), passengers - leaving out any that
    are taken or locked. Picking one moves the player straight across into it.
    [boat]
*/
params [["_b", objNull, [objNull]]];
if (isNull _b || {!alive _b}) exitWith {};
if ((locked _b) >= 2) exitWith {["That boat is locked."] call ANC_fnc_notice};
private _seats = [];
{
    _x params ["_unit", "_role", "_ci", "_tp"];
    if (isNull _unit) then {
        private _free = switch (toLower _role) do {
            case "driver": {!(lockedDriver _b)};
            case "cargo": {!(_b lockedCargo _ci)};
            default {!(_b lockedTurret _tp)};
        };
        if (_free) then {
            private _label = switch (toLower _role) do {
                case "driver": {"Driver"};
                case "cargo": {format ["Passenger %1", _ci + 1]};
                default {
                    private _n = getText (([_b, _tp] call BIS_fnc_turretConfig) >> "gunnerName");
                    [_n, "Gunner"] select (_n isEqualTo "")
                };
            };
            _seats pushBack [_label, toLower _role, _ci, _tp];
        };
    };
} forEach (fullCrew [_b, "", true]);
if (count _seats == 0) exitWith {["No free seat on that boat."] call ANC_fnc_notice};
ANC_boardBoat = _b;
ANC_boardSeats = _seats;
// (MK) the boat's name as the title, the distance a greyed first line under it
private _title = getText (configOf _b >> "displayName");
// (MK) the gap to its hull: from your boat's hull, or from you on foot
private _note = format ["%1 m away", round ((if (isNull objectParent player) then {[player, _b] call ANC_fnc_hullDist} else {([vehicle player, _b] call ANC_fnc_hullGap) select 0}) max 0)];
[_title, _seats apply {_x select 0}, {
    params ["_i"];
    private _b = ANC_boardBoat;
    (ANC_boardSeats param [_i, []]) params ["", "_role", "_ci", "_tp"];
    if (isNull _b || {!alive _b} || {isNil "_role"}) exitWith {};
    private _v = vehicle player;
    // (MK) 10 m between the hulls from a boat, 10 m to its hull on foot
    if (!(_v isEqualTo player) && {(([_v, _b] call ANC_fnc_hullGap) select 0) > 10}) exitWith {["The boats are too far apart to step across."] call ANC_fnc_notice};
    if (_v isEqualTo player && {([player, _b] call ANC_fnc_hullDist) > 10}) exitWith {["That boat is too far away now."] call ANC_fnc_notice};
    // still free?
    private _taken = (fullCrew [_b, "", true]) findIf {(toLower (_x select 1)) isEqualTo _role && {(_x select 2) == _ci} && {(_x select 3) isEqualTo _tp} && {!isNull (_x select 0)}};
    if (_taken >= 0) exitWith {["Someone has just taken that seat."] call ANC_fnc_notice};
    moveOut player;
    [{(vehicle player) isEqualTo player}, {
        params ["_b", "_role", "_ci", "_tp"];
        switch (_role) do {
            case "driver": {player moveInDriver _b};
            case "cargo": {player moveInCargo [_b, _ci]};
            default {player moveInTurret [_b, _tp]};
        };
    }, [_b, _role, _ci, _tp], 2] call CBA_fnc_waitUntilAndExecute;
}, _note] call ANC_fnc_listMenu;
