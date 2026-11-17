/*
    ANC_fnc_isLandingCraft
    Landing craft (which use a stern kedge anchor): found by name (LCVP, LCM, LCU, LCT, landing craft, Higgins), by a
    bow ramp, or from the "Extra landing craft classes" setting. Hovercraft are never included.
*/
params [["_boat", objNull, [objNull]]];
if (isNull _boat) exitWith {false};
private _cfg = configOf _boat;
private _names = toLower format ["%1 %2", configName _cfg, getText (_cfg >> "displayName")];
if ((["lcac", "hover", "air cushion"] findIf {(_names find _x) != -1}) != -1) exitWith {false};
private _extra = ((missionNamespace getVariable ["ANC_kedgeExtra", ""]) splitString ", ") select {!(_x isEqualTo "")};
if ((_extra findIf {_boat isKindOf _x}) != -1) exitWith {true};
if ((["lcvp", "lcm", "lcu", "lct", "landing craft", "landingcraft", "landing_craft", "higgins"] findIf {(_names find _x) != -1}) != -1) exitWith {true};
private _ramp = (configProperties [_cfg >> "AnimationSources", "isClass _x", true]) findIf {((toLower configName _x) find "ramp") != -1};
_ramp != -1
