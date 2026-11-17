/*
    ANC_fnc_slingGuard  (96, every computer, once)
    - no helicopter lifts a boat that is anchored, moored or has a tow or shore line out, whoever flies it (a player
    with the game's own sling loading, the AI, or a mission script). Every helicopter gets a rope handler; when it
    hooks up such a boat (ANC_fnc_slingBlock), the load is let go at once (on the computer the helicopter belongs to)
    and everyone aboard is told: "Cannot sling load a boat when it's moored." (anchored / its tow line is out / its
    shore line is out).
*/
if (!isNil "ANC_slingGuardOn") exitWith {};
ANC_slingGuardOn = true;
ANC_fnc_slingGuardAdd = {
    params ["_h"];
    if (isNull _h || {_h getVariable ["ANC_slingGuard", false]}) exitWith {};
    _h setVariable ["ANC_slingGuard", true];
    _h addEventHandler ["RopeAttach", {
        params ["_h", "", "_o"];
        if (isNull _o || {!(_o isKindOf "Ship")}) exitWith {};
        [_h, _o] spawn {
            params ["_h", "_o"];
            sleep 0.2;
            if !((getSlingLoad _h) isEqualTo _o) exitWith {}; // (another rope - a tow line - not a sling load)
            private _why = [_o] call ANC_fnc_slingBlock;
            if (_why == "") exitWith {};
            if (local _h) then {_h setSlingLoad objNull};
            if (hasInterface && {player in (crew _h)}) then {hint format ["Cannot sling load a boat when %1.", _why]};
            if (isServer) then {if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] %1 tried to sling load %2 - refused (%3)", typeOf _h, typeOf _o, _why]}};
        };
    }];
};
["Helicopter", "init", {[_this select 0] call ANC_fnc_slingGuardAdd}, true, [], true] call CBA_fnc_addClassEventHandler;
