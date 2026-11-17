/*
    ANC_fnc_anchorModel  (server)
    The .p3d used for the visible anchor. In order:
      1. the "Anchor model" setting, if filled in: either a class name (its
         model is used) or a .p3d path;
      2. the class Land_Jens_Sharpeye_Hook_01_F (its model);
      3. \a3\data_f\anchor.p3d;
      4. the tyre, so anchors always work.
    The choice is written to the RPT log once.
*/
if (!isNil "ANC_hookModel") exitWith {ANC_hookModel};

private _fix = {
    params ["_p"];
    if (_p isEqualTo "") exitWith {""};
    if !((toLower _p) select [(count _p) - 4] isEqualTo ".p3d") then {_p = _p + ".p3d"};
    if !((_p select [0, 1]) isEqualTo "\") then {_p = "\" + _p};
    _p
};
// A class name or a path -> a .p3d path that exists, or "".
private _resolve = {
    params ["_entry"];
    if (_entry isEqualTo "") exitWith {""};
    private _cfg = configFile >> "CfgVehicles" >> _entry;
    private _p = if (isClass _cfg) then {[getText (_cfg >> "model")] call _fix} else {[_entry] call _fix};
    if (!(_p isEqualTo "") && {fileExists _p}) then {_p} else {""}
};

private _choice = "";
private _from = "";
{
    _choice = [_x] call _resolve;
    if !(_choice isEqualTo "") exitWith {_from = _x};
} forEach [missionNamespace getVariable ["ANC_anchorModel", ""], "Land_Jens_Sharpeye_Hook_01_F", "\a3\data_f\anchor.p3d", "Land_Tyre_F"];

ANC_hookModel = _choice;
if (missionNamespace getVariable ["ANC_debug", false]) then {diag_log format ["[Anchors] Anchor model: %1 (from %2)", ANC_hookModel, _from]};
ANC_hookModel
