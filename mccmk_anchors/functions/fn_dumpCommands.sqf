/*
    ANC_fnc_dumpCommands  (client, once per game version)
    Writes every script command this exact game version accepts - with every form of each (nular, unary, binary, and
    the argument types) - to the RPT, from the game's own supportInfo.

    Runs by itself once per game version (remembered in your profile). To run it
    again by hand:   [true] call ANC_fnc_dumpCommands;
    Lines look like: [Anchors] Commands 12/80: b:OBJECT setvelocity ARRAY | u:abs SCALAR | ...
      n: = takes no arguments, u: = one argument after it, b: = one each side
*/
params [["_force", false]];
private _ver = productVersion;
private _key = format ["%1 %2 v2", _ver select 2, _ver select 3];
if (!_force && {(profileNamespace getVariable ["ANC_cmdDumpVersion", ""]) isEqualTo _key}) exitWith {};
private _all = (supportInfo "") select {(_x select [0, 2]) in ["n:", "u:", "b:"]};
// Lines are filled up to 900 characters - the RPT cuts lines off at about 1,000.
private _out = [];
private _cur = "";
{
    if ((count _cur) + (count _x) + 3 > 900) then {_out pushBack _cur; _cur = _x} else {_cur = [_x, _cur + " | " + _x] select (count _cur > 0)};
} forEach _all;
if (count _cur > 0) then {_out pushBack _cur};
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Commands: %1 forms in Arma %2.%3 (%4) - %5 lines follow.", count _all, _ver select 2, _ver select 3, _ver select 4, count _out]};
{if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Commands %1/%2: %3", _forEachIndex + 1, count _out, _x]}} forEach _out;
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log "[Anchors] Commands: end of list."};
profileNamespace setVariable ["ANC_cmdDumpVersion", _key];
saveProfileNamespace;
