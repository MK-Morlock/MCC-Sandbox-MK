/*
    ANC_fnc_xlWatch  (server, spawned)
    One extra line's watchdog. Lets go if either vehicle is destroyed or deleted, a submarine dives, the line is torn
    far beyond its length, or (tow lines) enemies board the other vehicle. Tow lines: the visible rope follows the
    line's tension (see below). [id]
*/
params [["_id", "", [""]]];
// Tow lines: the visible rope follows the line's TENSION, 20 times a second. The tension is worked out exactly as the
// pull model does (ANC_fnc_rodeTick: the line's stretch and the speed the two ends are separating at, with the same
// stiffness and damping), and gives the sag of a real tow line from the sagging-cable formula: sag = w L^2 / (8 T)
// (w = a wet tow line's weight, about 4 N per metre). Pulling hard: straight (a few millimetres of sag). Easing off:
// a gentle curve. Slack (the boats closer than the line's length): the rope hangs at its full length.
if (((ANC_xLines getOrDefault [_id, createHashMap]) getOrDefault ["kind", ""]) isEqualTo "tow") then {
    [{
        params ["_args", "_h"];
        _args params ["_id"];
        if (isNil "ANC_xLines" || {!(_id in ANC_xLines)}) exitWith {[_h] call CBA_fnc_removePerFrameHandler};
        private _r = ANC_xLines get _id;
        private _rope = _r get "rope";
        private _a = _r get "a";
        private _b = _r get "b";
        if (isNull _rope || {isNull _a} || {isNull _b}) exitWith {};
        private _pa = _a modelToWorldVisualWorld (_r get "aPt");
        private _pb = _b modelToWorldVisualWorld (_r get "bPt");
        private _gap = _pa distance _pb;
        private _len = _r get "len";
        private _visual = _len;
        if (_gap >= _len) then {
            private _ma = (getMass _a) max 50;
            private _mb = (getMass _b) max 50;
            private _mu = (_ma * _mb) / (_ma + _mb);
            private _k = _mu * 0.617 * 8;
            private _u = (_pb vectorDiff _pa) vectorMultiply (1 / (_gap max 0.01));
            private _vr = ((velocity _b) vectorDiff (velocity _a)) vectorDotProduct _u;
            private _vTow = (vectorMagnitude (velocity _a)) max (vectorMagnitude (velocity _b));
            private _t = (((_k * ((_gap - _len) min 3)) + (2 * 1.2 * sqrt (_k * _mu) * _vr)) max 0) min (((_ma min _mb) * (((_vr max 0) / 0.5) + 3 + (0.05 * _vTow * _vTow))) + 600);
            private _sag = if (_t > 1) then {(4 * _gap * _gap) / (8 * _t)} else {1e9};
            _sag = _sag min (_gap * 0.05);
            _visual = _gap + (((8 * _sag * _sag) / (3 * (_gap max 0.5))) max 0.004);
        };
        if ((abs ((ropeLength _rope) - _visual)) > 0.003) then {ropeUnwind [_rope, 50, _visual]};
    }, 0.05, [_id]] call CBA_fnc_addPerFrameHandler;
};
while {true} do {
    sleep 0.25;
    if (isNil "ANC_xLines" || {!(_id in ANC_xLines)}) exitWith {};
    private _r = ANC_xLines get _id;
    private _a = _r get "a";
    private _b = _r get "b";
    if (isNull _a || {isNull _b} || {!alive _a} || {!alive _b}) exitWith {[_id, "A line was lost."] call ANC_fnc_xlRelease};
    if (((_a call ANC_fnc_isSubmersible) && {!(_a call ANC_fnc_isSurfaced)}) || {(_b call ANC_fnc_isSubmersible) && {!(_b call ANC_fnc_isSurfaced)}}) exitWith {[_id, "The line was let go - the submarine dived."] call ANC_fnc_xlRelease};
    private _gap = (_a modelToWorldWorld (_r get "aPt")) distance (_b modelToWorldWorld (_r get "bPt"));
    private _len = _r get "len";
    if (_gap > (_len + 30)) exitWith {
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Line %1 parted: %2 m apart on a %3 m line (%4 at %5 km/h, %6 at %7 km/h).", _id, round _gap, round _len, typeOf _a, round (speed _a), typeOf _b, round (speed _b)]};
        [_id, "The line parted."] call ANC_fnc_xlRelease;
    };
    if (((_r get "kind") isEqualTo "tow") && {(diag_tickTime - (_r getOrDefault ["logT", -100])) > 3} && {(abs (speed _a)) > 3 || {(abs (speed _b)) > 3}}) then {
        _r set ["logT", diag_tickTime];
        private _toLine = (_a modelToWorldWorld (_r get "aPt")) vectorDiff (_b modelToWorldWorld (_r get "bPt"));
        private _off = abs ((((vectorDir _b) select 0) atan2 ((vectorDir _b) select 1)) - ((_toLine select 0) atan2 (_toLine select 1)));
        if (_off > 180) then {_off = 360 - _off};
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Tow %1: line %2 m, gap %3 m (%4), %5 %6 km/h, %7 %8 km/h, towed boat %9 deg off the line.", _id, (round (_len * 10)) / 10, (round (_gap * 10)) / 10, ["slack", "taut"] select (_gap >= _len), typeOf _a, round (speed _a), typeOf _b, round (speed _b), round _off]};
    };
    if ((_r get "kind") isEqualTo "tow") then {
        private _pl = _r get "player";
        private _mySide = side group ([_pl, effectiveCommander _a] select (isNull _pl));
        if (((crew _b) findIf {alive _x && {(_mySide getFriend (side group _x)) < 0.6}}) != -1) exitWith {[_id, "Enemies aboard the other vehicle - tow line let go."] call ANC_fnc_xlRelease};
    };
};
