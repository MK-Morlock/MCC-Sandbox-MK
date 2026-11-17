/*
    ANC_fnc_boatNear  (client, postInit)
    While the player is aboard a boat: every half second, the other boats he can board or move cargo to - empty,
    civilian or friendly-crewed (none with enemies aboard), nearest first: within 20 m hull to hull for Boat Cargo
    (ANC_nearBoats), within 10 m for Board Boat (ANC_nearBoardBoats) - (MK) both measured between the nearest edges of
    the two hulls. Nothing runs while he isn't in a boat. Gives him "Board Boat" and "Boat Cargo" in the scroll menu
    while there are any (again after respawning or switching unit).
*/
if (!hasInterface) exitWith {};
ANC_nearBoats = [];
ANC_nearBoardBoats = [];
ANC_footBoats = [];
if (isNil "ANC_pfh") then {ANC_pfh = []};
ANC_pfh pushBack ([{
    private _v = vehicle player;
    // on foot: boats whose hull is within 10 m of you, for Board Boat
    if (_v isEqualTo player && {alive player}) exitWith {
        if (count ANC_nearBoats > 0) then {ANC_nearBoats = []};
        private _mySide = side group player;
        private _p = getPosASL player;
        private _l = [];
        {
            if (alive _x && {((crew _x) findIf {alive _x && {((_mySide getFriend (side group _x)) < 0.6)}}) == -1}) then {
                (_x call ANC_fnc_hullOutline) params ["_cx", "_sY", "_bY", "_hw"];
                private _m = _x worldToModel (ASLToAGL _p);
                private _dx = (_m select 0) - (((_m select 0) max (_cx - _hw)) min (_cx + _hw));
                private _dy = (_m select 1) - (((_m select 1) max _sY) min _bY);
                private _d = sqrt ((_dx * _dx) + (_dy * _dy));
                if (_d <= 10) then {_l pushBack [_x, _d]};
            };
        } forEach (nearestObjects [player, ["Ship"], 40]);
        ANC_footBoats = ([_l, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy) apply {_x select 0};
    };
    if (count ANC_footBoats > 0) then {ANC_footBoats = []};
    if (!(_v isKindOf "Ship") || {!alive player}) exitWith {if (count ANC_nearBoats > 0) then {ANC_nearBoats = []; ANC_nearBoardBoats = []}};
    private _mySide = side group player;
    private _l = [];
    {
        if (!(_x isEqualTo _v) && {alive _x} && {((crew _x) findIf {alive _x && {((_mySide getFriend (side group _x)) < 0.6)}}) == -1}) then {
            private _g = ([_v, _x] call ANC_fnc_hullGap) select 0;
            if (_g <= 20) then {_l pushBack [_x, _g]};
        };
    } forEach (nearestObjects [_v, ["Ship"], 60]);
    _l = [_l, [], {_x select 1}, "ASCEND"] call BIS_fnc_sortBy;
    ANC_nearBoats = _l apply {_x select 0};
    ANC_nearBoardBoats = (_l select {(_x select 1) <= 10}) apply {_x select 0};
}, 0.5] call CBA_fnc_addPerFrameHandler);
// (the timer runs only while there are boats - ANC_fnc_wake / ANC_fnc_sleep; the actions below are set up once)
if (!isNil "ANC_boatNearOnce") exitWith {};
ANC_boatNearOnce = true;

ANC_boatActions = {
    private _u = player;
    if (isNull _u || {_u getVariable ["ANC_boatActs", false]}) exitWith {};
    _u setVariable ["ANC_boatActs", true];
    private _cond = "(count ANC_nearBoats > 0) && {vehicle _this != _this}";
    // Board Boat on foot too, with a boat within 10 m
    [_u, "ANC_boardBoat", "Board Boat", {["board"] call ANC_fnc_boatPick}, "((count ANC_nearBoardBoats > 0) && {vehicle _this != _this}) || {(count ANC_footBoats > 0) && {vehicle _this == _this}}", 1.6] call ANC_fnc_act;	// (MK) above Load / Unload, Request rescue and Scuttle
    [_u, "ANC_boatCargo", "Boat Cargo", {["cargo"] call ANC_fnc_boatPick}, _cond, 1.55] call ANC_fnc_act;
};
call ANC_boatActions;
["unit", {call ANC_boatActions}] call CBA_fnc_addPlayerEventHandler;
