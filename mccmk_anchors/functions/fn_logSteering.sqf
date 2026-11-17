/*
    ANC_fnc_logSteering  (client, diagnostic)
    Measures how far a boat's outboard motor swivels when steering, and writes it to the RPT, compared with a standard
    outboard (about 40 degrees each side, 80 degrees in total).

    Use: sit in the driver's seat of the boat, open the debug console and run
    then, within 30 seconds, steer fully left, fully right and back to straight a few times (moving slowly is fine).
    The result is logged at the end.

    What it records:
      - the boat's model animations whose names suggest steering, the motor, the
        propeller or the rudder, with the range of each one's phase;
      - the model's memory points whose names suggest the motor / propeller /
        rudder, and for each pair of them, how far the line between them swings left and right (in degrees) - the pair
        on the motor shows its swivel.
*/
private _boat = vehicle player;
if (_boat isEqualTo player || {driver _boat != player}) exitWith {hintSilent "Sit in the driver's seat of the boat first."};
private _keys = ["steer", "rudder", "motor", "engine", "prop", "wheel", "rotor", "turn", "direction"];
private _match = {params ["_n"]; private _l = toLower _n; (_keys findIf {(_l find _x) != -1}) != -1};

private _anims = (animationNames _boat) select {[_x] call _match};
// Memory points: the form with a model-detail level isn't in every game version, so it's tried safely (compiled at
// run time) and the plain form used otherwise.
private _all = [];
isNil {_all = call compile "_boat selectionNames ""Memory"""};
if (isNil "_all" || {!(_all isEqualType [])} || {count _all == 0}) then {_all = selectionNames _boat};
private _mem = _all select {[_x] call _match};
if (count _mem > 8) then {_mem resize 8};
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Steering log: %1 | model %2", typeOf _boat, (getModelInfo _boat) select 1]};
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Steering log: animations %1", _anims]};
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Steering log: memory points %1", _mem]};
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Steering log: config turnCoef %1, maxSpeed %2 km/h, steerAheadSimul %3, predictTurnSimul %4",
    getNumber (configOf _boat >> "turnCoef"), getNumber (configOf _boat >> "maxSpeed"),
    getNumber (configOf _boat >> "steerAheadSimul"), getNumber (configOf _boat >> "predictTurnSimul")]};
hintSilent "Steering log running for 30 seconds: steer fully left, fully right and back, a few times.";

// Every pair of motor-type memory points: the horizontal angle of the line between them.
private _pairs = [];
for "_i" from 0 to ((count _mem) - 2) do {
    for "_j" from (_i + 1) to ((count _mem) - 1) do {_pairs pushBack [_mem select _i, _mem select _j]};
};
private _yaw = {
    params ["_a", "_b"];
    private _pa = _boat selectionPosition _a;
    private _pb = _boat selectionPosition _b;
    private _v = _pb vectorDiff _pa;
    if (((_v select 0) ^ 2) + ((_v select 1) ^ 2) < 0.0004) exitWith {nil}; // vertical pair: no heading
    (_v select 0) atan2 (_v select 1)
};
private _base = _pairs apply {_x call _yaw};
private _pairMin = _pairs apply {0};
private _pairMax = _pairs apply {0};
private _animMin = _anims apply {1e9};
private _animMax = _anims apply {-1e9};

private _end = time + 30;
while {time < _end && {alive _boat} && {driver _boat == player}} do {
    {
        private _p = _boat animationPhase _x;
        _animMin set [_forEachIndex, (_animMin select _forEachIndex) min _p];
        _animMax set [_forEachIndex, (_animMax select _forEachIndex) max _p];
    } forEach _anims;
    {
        private _b0 = _base select _forEachIndex;
        private _y = _x call _yaw;
        if (!isNil "_b0" && {!isNil "_y"}) then {
            private _d = ((_y - _b0 + 540) mod 360) - 180; // change from the start, -180..180
            _pairMin set [_forEachIndex, (_pairMin select _forEachIndex) min _d];
            _pairMax set [_forEachIndex, (_pairMax select _forEachIndex) max _d];
        };
    } forEach _pairs;
    sleep 0.1;
};

{
    if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Steering log: animation '%1' phase %2 to %3", _x, (_animMin select _forEachIndex) toFixed 3, (_animMax select _forEachIndex) toFixed 3]};
} forEach _anims;
private _best = -1;
private _bestRange = 0;
{
    private _r = (_pairMax select _forEachIndex) - (_pairMin select _forEachIndex);
    if (_r > 0.5) then {
        if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Steering log: memory points %1 - %2 swing %3 deg to %4 deg (%5 deg in total)",
            _x select 0, _x select 1, (_pairMin select _forEachIndex) toFixed 1, (_pairMax select _forEachIndex) toFixed 1, _r toFixed 1]};
    };
    if (_r > _bestRange) then {_bestRange = _r; _best = _forEachIndex};
} forEach _pairs;
private _msg = if (_best == -1) then {
    "No motor memory points swung - the motor may not swivel in this model, or no suitable points were found (see the lists above)."
} else {
    format ["Motor swivel measured: %1 deg left to %2 deg right, %3 deg in total (standard outboard: about 40 each side, 80 in total).",
        abs (_pairMin select _best) toFixed 1, (_pairMax select _best) toFixed 1, _bestRange toFixed 1]
};
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Steering log: %1", _msg]};
hintSilent ("Steering log done - see the RPT. " + _msg);
