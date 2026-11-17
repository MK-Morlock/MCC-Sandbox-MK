/*
    ANC_fnc_bagNear  (client, postInit)
    The rope bag by hand, on foot within 4 m of a boat (checked twice a second, only while you're on foot):
      "Get Bag"     - not holding a line, and the boat's rope bag is in it (a Heaving line in the boat or on you, and the bag not
                      already out on its line): the bag in your hand, its line running out to where you stand
                      (ANC_fnc_bagGet).
    Again after respawning or switching unit.
*/
if (!hasInterface) exitWith {};
ANC_bagBoat = objNull;
ANC_bagHome = false;
if (isNil "ANC_pfh") then {ANC_pfh = []};
ANC_pfh pushBack ([{
    if (!isNull objectParent player || {!alive player}) exitWith {ANC_bagBoat = objNull; ANC_bagHome = false};
    private _p = getPosASL player;
    private _held = player getVariable ["ANC_holdingBoat", objNull];
    private _gap = {
        params ["_b"];
        (_b call ANC_fnc_hullOutline) params ["_cx", "_sY", "_bY", "_hw"];
        private _l = _b worldToModel (ASLToAGL _p);
        private _dx = (_l select 0) - (((_l select 0) max (_cx - _hw)) min (_cx + _hw));
        private _dy = (_l select 1) - (((_l select 1) max _sY) min _bY);
        sqrt ((_dx * _dx) + (_dy * _dy))
    };
    ANC_bagHome = !isNull _held && {([_held] call _gap) <= 4};
    private _b = objNull;
    if (isNull _held) then {
        private _best = 4;
        {
            if (alive _x && {count (_x getVariable ["ANC_shoreData", []]) == 0} && {[player, _x] call ANC_fnc_hasLine}) then {
                private _d = [_x] call _gap;
                if (_d <= _best) then {_best = _d; _b = _x};
            };
        } forEach (nearestObjects [player, ["Ship"], 15]);
    };
    ANC_bagBoat = _b;
}, 0.5] call CBA_fnc_addPerFrameHandler);
// (the timer runs only while there are boats - ANC_fnc_wake / ANC_fnc_sleep; the actions below are set up once)
if (!isNil "ANC_bagNearOnce") exitWith {};
ANC_bagNearOnce = true;

ANC_bagActions = {
    private _u = player;
    if (isNull _u || {_u getVariable ["ANC_bagActs", false]}) exitWith {};
    _u setVariable ["ANC_bagActs", true];
    [_u, "ANC_getBag", "Get Bag", {
        if (isNull ANC_bagBoat) exitWith {};
        [["bagGet", ANC_bagBoat, player, 0], "server", 2] call ANC_fnc_remote;
    }, "!isNull ANC_bagBoat && {isNull objectParent _this} && {isNull (_this getVariable ['ANC_holdingBoat', objNull])}", 1.45] call ANC_fnc_act;
    [_u, "ANC_bagInBoat", "Bag in Boat", {
        [["bagStow", objNull, player, 0], "server", 2] call ANC_fnc_remote;
    }, "ANC_bagHome && {isNull objectParent _this}", 1.45] call ANC_fnc_act;
};
call ANC_bagActions;
["unit", {call ANC_bagActions}] call CBA_fnc_addPlayerEventHandler;
