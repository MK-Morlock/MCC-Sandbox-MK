params [["_kind", "gun", [""]]];
private _parse = {params ["_s", "_d"]; private _a = (_s splitString ", ") apply {parseNumber _x}; if (count _a < count _d) then {_d} else {_a}};
if (_kind == "gun") exitWith {[[missionNamespace getVariable ["MCCMK_navalGunCost", "75,0"], [75, 0]] call _parse, 60]};
[[missionNamespace getVariable ["MCCMK_navalVLSCost", "150,50"], [150, 50]] call _parse, 180]
