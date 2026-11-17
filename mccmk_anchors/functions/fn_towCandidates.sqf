/*
    ANC_fnc_towCandidates  (server)
    Vehicles a tow line could be thrown to: within 20 m, boats first, then by distance. (MK) Boat to boat it's the gap
    between the nearest edges of the two hulls; to anything else, between the boat's ends and the vehicle.

    Who's aboard decides, not whose vehicle it is:
      empty (nobody alive aboard)        - can be towed / tow you
      only friendly crew or passengers   - can be towed / tow you, even if it's
                                           an enemy faction's boat
      anyone hostile aboard              - left out
    "Friendly" is from the point of view of the player throwing the line.

    [boat, player] -> [[vehicle, gap in m, "port bow" etc.], ...]
    [boat, player, true] -> [list, number of vehicles left out for enemies aboard]
*/
params [["_boat", objNull, [objNull]], ["_player", objNull, [objNull]], ["_withCount", false, [false]]];
private _mySide = side group ([_player, effectiveCommander _boat] select (isNull _player));
private _hostileAboard = {
    params ["_v"];
    ((crew _v) findIf {alive _x && {((_mySide getFriend (side group _x)) < 0.6)}}) != -1
};
private _blocked = 0;
private _ends = {
    params ["_v"];
    if (_v isKindOf "Ship" || {_v call ANC_fnc_isSubmersible}) then {
        [_v modelToWorldWorld ([_v, false] call ANC_fnc_hullPoint), _v modelToWorldWorld ([_v, true] call ANC_fnc_hullPoint)]
    } else {
        [getPosASL _v]
    };
};
private _mine = [_boat] call _ends;
private _found = []; // [boat? 0 : 1, gap, index into _data] - numbers only, so it sorts safely
private _data = [];
{
    private _v = _x;
    if (_v != _boat && {alive _v} && {!(_v isKindOf "CAManBase")} && {!(_v getVariable ["ANC_isHelper", false])}) then {
        private _gap = 1e9;
        if (_v isKindOf "Ship" && {_boat isKindOf "Ship"}) then {
            _gap = (([_boat, _v] call ANC_fnc_hullGap) select 0) max 0;
        } else {
            {
                private _a = _x;
                {_gap = _gap min (_a distance _x)} forEach ([_v] call _ends);
            } forEach _mine;
        };
        if (_gap <= 20 && {[_v] call _hostileAboard}) then {_blocked = _blocked + 1; _gap = 1e9};
        if (_gap <= 20) then {
            private _rel = _boat getRelDir _v;
            private _where = ["ahead", "starboard bow", "starboard", "starboard quarter", "astern", "port quarter", "port", "port bow"] select (floor (((_rel + 22.5) mod 360) / 45));
            _found pushBack [[1, 0] select (_v isKindOf "Ship"), _gap, count _data];
            _data pushBack [_v, _gap, _where];
        };
    };
} forEach (nearestObjects [_boat, ["Ship", "LandVehicle", "Air"], 20 + ((sizeOf typeOf _boat) max 10) + 30]);
_found sort true; // boats (0) before other vehicles (1), then nearest first
private _list = _found apply {_data select (_x select 2)};
if (_withCount) exitWith {[_list, _blocked]};
_list
