/*
    ANC_fnc_isDock
    True if an object is part of a pier, dock, jetty, wharf, quay, pontoon, mooring or bollard (by its model or class
    name) - or of a large static ship (the destroyer, carrier, submarine, CUP's LHD), which boats moor alongside.
    [object, boat to ignore]
*/
params ["_o", ["_boat", objNull]];
if (isNull _o || {_o isEqualTo _boat}) exitWith {false};
private _name = toLower format ["%1 %2", (getModelInfo _o) select 0, typeOf _o];
(["pier", "dock", "jetty", "wharf", "quay", "pontoon", "mooring", "bollard", "destroyer_01", "carrier_01", "submarine_01", "cup_lhd"] findIf {(_name find _x) != -1}) != -1
