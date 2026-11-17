/*
    ANC_fnc_shoreFollow  (the holder's own computer)
    Holding a shore line:
      - The rope's end, with the bag on it, is attached to your left-hand bone
        (as Paddle Mod does), so it moves smoothly with your hand. The visible rope always keeps a little slack, so it
        never pulls on you.
      - You can't walk further from the boat than the line's length: while you're
        moving AWAY from the boat at the end of the rope, you're held there. As soon as you move towards the boat
        you're free - the rope just slackens.
    [end object, boat, bag] - stops by itself when you let go, and puts the bag
    back on the end of the line.
*/
params ["_pad", "_boat", ["_bag", objNull]];
if (!hasInterface) exitWith {};
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Holding the line to %1: the bag is in your hand.", typeOf _boat]};
// The rope's end - with the bag on it - is attached to your left-hand bone, as Paddle Mod attaches its bag, so it
// moves smoothly with your hand. The visible rope always keeps a little slack (ANC_fnc_shoreWatch), so Arma's rope
// never carries load and can't pull on you; the pull on the boat is the mod's own.
if (!isNull _bag) then {_bag attachTo [_pad, [0, 0, 0]]};
_pad attachTo [player, [0, 0, 0], "LeftHand"];

// only ever one of these running: an older one (from the last time you held a line) is stopped first, so two never
// compete over your walk
private _oldH = player getVariable ["ANC_followPFH", -1];
if (_oldH >= 0) then {[_oldH] call CBA_fnc_removePerFrameHandler};
player setVariable ["ANC_pullAnim", ""];
private _h = [{
    params ["_args", "_handle"];
    _args params ["_pad", "_boat", "_bag", "_lastPos", "_lastPub"];
    if (isNull _pad || {isNull _boat} || {!((player getVariable ["ANC_holdingBoat", objNull]) isEqualTo _boat)}
        || {!((_boat getVariable ["ANC_shoreCarrier", objNull]) isEqualTo player)}) exitWith {
        // Let go: the bag goes back on the end of the line.
        if (!isNull _pad && {(attachedTo _pad) isEqualTo player}) then {detach _pad};
        if (!isNull _pad) then {[_pad, _bag] call ANC_fnc_bagRest}; // down on the ground, flat
        player setAnimSpeedCoef 1; player forceWalk false; player setVariable ["ANC_walkCoef", 1]; player setVariable ["ANC_walkCoefSet", 1];
        player setVariable ["ANC_pullAnim", ""];
        player setVariable ["ANC_followPFH", -1];
        [_handle] call CBA_fnc_removePerFrameHandler;
    };

    // At the end of the line you can't step further away. Same pull, no jumping.
    private _me = getPosASL player;
    private _d = _boat getVariable ["ANC_shoreData", []];
    if (count _d == 5) then {
        _d params ["", "_pt", "_len"];
        private _bp = _boat modelToWorldVisualWorld _pt;
        private _now = _me distance2D _bp;
        private _was = _lastPos distance2D _bp;
        private _dz = ((_me select 2) + 1.2) - (_bp select 2);
        private _reach = sqrt ((((_len + 0.05) ^ 2) - (_dz ^ 2)) max 0.25);
        // which way your keys are taking you: towards the boat is always free - never held, and any kept walk stops
        private _fw = ((inputAction "MoveForward") + (inputAction "MoveFastForward") + (inputAction "MoveSlowForward") + (inputAction "TurboForward")) - ((inputAction "MoveBack") + (inputAction "MoveFastBack") + (inputAction "MoveSlowBack"));
        private _rt = (inputAction "MoveRight") - (inputAction "MoveLeft");
        private _wish = ((vectorDir player) vectorMultiply _fw) vectorAdd (((vectorDir player) vectorCrossProduct [0, 0, 1]) vectorMultiply _rt)   /*
 
*/;
        private _awayV = [(_me select 0) - (_bp select 0), (_me select 1) - (_bp select 1), 0];
        private _inward = (vectorMagnitude _wish) > 0.01 && {(_wish vectorDotProduct _awayV) < 0};
        if (_inward && {(player getVariable ["ANC_pullAnim", ""]) != ""}) then {_args set [5, -10]};
        // No forces, no ground grip: you walk, it comes.
        private _onLand = !((surfaceIsWater (getPosASL _boat)) && {!(_boat call ANC_fnc_isAground)});
        private _allow = 1; // the line stretches up to 1 m as you lean into it - your full pull at 1 m (ANC_fnc_pullSpeed)
        private _stretch = if (_inward) then {0} else {(_now - _reach) max 0};
        // Walking towards the boat is never slowed.
        private _coef = 1 - (0.85 * ((_stretch / _allow) min 1));
        private _coefS = player getVariable ["ANC_walkCoef", 1];
        _coefS = _coefS + ((_coef - _coefS) * 0.15);
        if (abs (_coefS - (player getVariable ["ANC_walkCoefSet", 1])) > 0.02) then {
            player setAnimSpeedCoef _coefS;
            player setVariable ["ANC_walkCoefSet", _coefS];
        };
        player setVariable ["ANC_walkCoef", _coefS];
        if (time > (player getVariable ["ANC_stretchPubT", -10]) + 0.1) then {
            player setVariable ["ANC_stretchPubT", time];
            _boat setVariable ["ANC_pullStretch", [_stretch, serverTime], true];
        };
        if (!_inward && {_now > _reach + _allow} && {_now > _was}) then {
            private _away = vectorNormalized [(_me select 0) - (_bp select 0), (_me select 1) - (_bp select 1), 0];
            // how fast he's trying to go: how far past the line's length this frame's step took him, per second
            // (smoothed) - sent with the "pulling" flag below, so the boat comes at his pace
            private _try = ((_now - (_reach + _allow)) / ((diag_deltaTime max 0.005) min 0.1)) min 8;
            private _paceS = player getVariable ["ANC_paceS", 0];
            _paceS = _paceS + ((_try - _paceS) * 0.2);
            player setVariable ["ANC_paceS", _paceS];
            private _on = _bp vectorAdd (_away vectorMultiply (_reach + _allow));
            _me = [_on select 0, _on select 1, _me select 2];
            player setPosASL _me;
            player setVelocity [0, 0, (velocity player) select 2];
            // The walk you were doing when you came up against the line is kept; if the game switches away from it,
            // you're put straight back into it. ...but ONLY while you're actually pulling - a move-back key held.
            // Let go and you stop; step forward and you're free.
            private _back = ((inputAction "MoveBack") + (inputAction "MoveFastBack") + (inputAction "MoveSlowBack") + (inputAction "MoveForward") + (inputAction "MoveFastForward") + (inputAction "MoveSlowForward") + (inputAction "TurboForward") + (inputAction "MoveLeft") + (inputAction "MoveRight")) > 0; // (a move key held - walking back, or turned away and walking off)
            private _anim = player getVariable ["ANC_pullAnim", ""];
            // the move the player is making NOW - walking or running, forwards, backwards or sideways, whichever way
            // he faces - is the one kept (updated as he changes it); never a walking-backwards animation forced on
            // him (turned away and walking off, he walked backwards). It's only put back if the game drops him into
            // standing while he's held at the end of the line; if he isn't moving at all, nothing is forced.
            if (_back) then {
                private _cur = toLower (animationState player);
                if ((_cur select [0, 4]) == "amov" && {((["mwlk", "mrun", "mtac", "meva", "mspr"] findIf {(_cur find _x) >= 0}) >= 0)}) then {
                    _anim = _cur;
                    player setVariable ["ANC_pullAnim", _anim];
                };
            };
            if (_back) then {
                if (_anim != "" && {!((toLower (animationState player)) isEqualTo _anim)}) then {player playMoveNow _anim}; // (playMoveNow - shared with every player)
                _args set [5, time];
            };
            // Still leaning on the line: tell the server, so the line stays taut and pulls while you do. (only
            // while you hold a move key - standing at the end of the line isn't pulling)
            if (_back && {serverTime > _lastPub + 0.25}) then {
                _boat setVariable ["ANC_pullT", serverTime, true];
                _boat setVariable ["ANC_pullPace", player getVariable ["ANC_paceS", 0], true]; // his pace
                _args set [4, serverTime];
            };
        };
    };
    private _kept = player getVariable ["ANC_pullAnim", ""];
    if (_kept != "" && {time > (_args param [5, -10]) + 0.15}) then {
        player setVariable ["ANC_pullAnim", ""];
        if ((toLower (animationState player)) isEqualTo _kept && {((inputAction "MoveBack") + (inputAction "MoveFastBack") + (inputAction "MoveSlowBack") + (inputAction "MoveForward") + (inputAction "MoveFastForward") + (inputAction "MoveSlowForward") + (inputAction "TurboForward") + (inputAction "MoveLeft") + (inputAction "MoveRight")) == 0}) then {
            player playMoveNow (["amovpercmstpsnonwnondnon", "amovpercmstpsraswrfldnon"] select ((currentWeapon player) isEqualTo (primaryWeapon player) && {(primaryWeapon player) != ""}));
        };
    };
    _args set [3, _me];

}, 0, [_pad, _boat, _bag, getPosASL player, 0, -10]] call CBA_fnc_addPerFrameHandler;
player setVariable ["ANC_followPFH", _h];
