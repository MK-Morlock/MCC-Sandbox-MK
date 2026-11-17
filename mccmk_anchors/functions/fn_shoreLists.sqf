/*
    ANC_fnc_shoreLists  (server)
    Keeps two lists every player's actions use:
      ANC_lineEnds - loose line ends lying ashore: [[end, boat], ...] ANC_heldLines - lines someone is holding:
      [[boat, carrier], ...]
*/
private _ends = [];
private _held = [];
{
    private _d = _x getVariable ["ANC_shoreData", []];
    if (count _d == 5) then {
        _d params ["_pad", "", "", "", "_state"];
        if (_state isEqualTo "loose") then {_ends pushBack [_pad, _x]};
        if (_state isEqualTo "held") then {
            private _h = _x getVariable ["ANC_shoreHolders", []];
            if (count _h > 0) then {_held pushBack [_x, _h select 0]};
        };
    };
} forEach (vehicles select {(_x getVariable ["ANC_mode", ""]) isEqualTo "shore"});
if !(ANC_lineEnds isEqualTo _ends) then {ANC_lineEnds = _ends; publicVariable "ANC_lineEnds"};
if !(ANC_heldLines isEqualTo _held) then {ANC_heldLines = _held; publicVariable "ANC_heldLines"};
