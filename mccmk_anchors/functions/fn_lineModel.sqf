/*
    ANC_fnc_lineModel
    The .p3d shown at the loose end of a heaving line: the "Line end model" setting (a class name or a .p3d path;
    default the folded bag Land_Sleeping_bag_brown_folded_F, as Paddle Mod uses). If that can't be
    found: a tyre. The model used is written to the RPT once.
*/
if (!isNil "ANC_lineModelPath") exitWith {ANC_lineModelPath};
private _fix = {
    params ["_p"];
    if (_p isEqualTo "") exitWith {""};
    if !((toLower _p) select [(count _p) - 4] isEqualTo ".p3d") then {_p = _p + ".p3d"};
    if !((_p select [0, 1]) isEqualTo "\") then {_p = "\" + _p};
    _p
};
private _resolve = {
    params ["_entry"];
    if (_entry isEqualTo "") exitWith {""};
    private _cfg = configFile >> "CfgVehicles" >> _entry;
    private _p = if (isClass _cfg) then {[getText (_cfg >> "model")] call _fix} else {[_entry] call _fix};
    if (!(_p isEqualTo "") && {fileExists _p}) then {_p} else {""}
};
ANC_lineModelPath = "";
ANC_lineModelClass = "";
{
    ANC_lineModelPath = [_x] call _resolve;
    if !(ANC_lineModelPath isEqualTo "") exitWith {
        if (isClass (configFile >> "CfgVehicles" >> _x)) then {ANC_lineModelClass = _x};
    };
} forEach [missionNamespace getVariable ["ANC_lineModel", "Land_Sleeping_bag_brown_folded_F"], "Land_Sleeping_bag_brown_folded_F", "Land_Tyre_F"];
// Also log Land_Rope_01_F's model file, for the dropped Heaving line item.
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Line end model: %1 | Land_Rope_01_F model in config: '%2'", ANC_lineModelPath, getText (configFile >> "CfgVehicles" >> "Land_Rope_01_F" >> "model")]};
ANC_lineModelPath
