/*
    ANC_fnc_pushNear  (client, postInit)
    Checked once a second while you're on foot (nothing runs while you're in a vehicle). Each push moves the boat 2.5
    m along the ground, away from you - stand at the stern and push, push, push to get it into the water
    (ANC_fnc_pushBoat). Again after respawning or switching unit.
*/
if (!hasInterface) exitWith {};
ANC_pushTarget = objNull;
if (isNil "ANC_pfh") then {ANC_pfh = []};
ANC_pfh pushBack ([{
    if (!isNull objectParent player || {!alive player}) exitWith {ANC_pushTarget = objNull};
    private _p = getPosASL player;
    // the shoreline within 20 m: dry land and water both within 20 m of you
    private _wetHere = surfaceIsWater _p;
    private _shore = false;
    {
        private _a = _x;
        {
            private _q = _p vectorAdd [(sin _a) * _x, (cos _a) * _x, 0];
            if ((surfaceIsWater _q) != _wetHere) exitWith {_shore = true};
        } forEach [5, 10, 15, 20];
        if (_shore) exitWith {};
    } forEach [0, 45, 90, 135, 180, 225, 270, 315];
    private _b = objNull;
    if (_shore) then {
        // the nearest boat whose hull is within 4 m of you
        private _best = 4;
        {
            if (alive _x) then {
                (_x call ANC_fnc_hullOutline) params ["_cx", "_sY", "_bY", "_hw"];
                private _l = _x worldToModel (ASLToAGL _p);
                private _dx = (_l select 0) - (((_l select 0) max (_cx - _hw)) min (_cx + _hw));
                private _dy = (_l select 1) - (((_l select 1) max _sY) min _bY);
                private _d = sqrt ((_dx * _dx) + (_dy * _dy));
                if (_d <= _best) then {_best = _d; _b = _x};
            };
        } forEach (nearestObjects [player, ["Ship"], 15]);
    };
    ANC_pushTarget = _b;
}, 1] call CBA_fnc_addPerFrameHandler);
// (the timer runs only while there are boats - ANC_fnc_wake / ANC_fnc_sleep; the actions below are set up once)
if (!isNil "ANC_pushNearOnce") exitWith {};
ANC_pushNearOnce = true;

ANC_pushAction = {
    private _u = player;
    if (isNull _u || {_u getVariable ["ANC_pushAct", false]}) exitWith {};
    _u setVariable ["ANC_pushAct", true];
    // (in ACE: no need to be looking at the boat - ACE's self menu isn't aimed; the boat in reach is ANC_pushTarget)
    [_u, "ANC_push", "Push boat", {
        private _b = ANC_pushTarget;
        if (isNull _b) exitWith {};
        [[_b, getPosASL player], "pushBoat", _b] call ANC_fnc_remote;
    }, "!isNull ANC_pushTarget && {cursorObject isEqualTo ANC_pushTarget} && {isNull objectParent _this} && {isNull (_this getVariable ['ANC_holdingBoat', objNull])}",
    1.5, false, true, "!isNull ANC_pushTarget && {isNull objectParent _this} && {isNull (_this getVariable ['ANC_holdingBoat', objNull])}"] call ANC_fnc_act;
};
call ANC_pushAction;
["unit", {call ANC_pushAction}] call CBA_fnc_addPlayerEventHandler;
