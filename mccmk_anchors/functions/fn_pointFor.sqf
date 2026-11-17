/*
    ANC_fnc_pointFor
    Every attachment point the mod uses, in the boat's own coordinates. A point adjusted by a player
    (ANC_fnc_adjustPoints) and saved for this boat alone is used first, then one saved for its type; otherwise the
    automatic one.
      "anchorBow"   anchor at the bow (bow roller)
      "anchorStern" anchor at the stern / landing craft kedge
      "towBow"      tow line when this boat is being towed
      "towStern"    tow line when this boat is towing
      "moorBow"     mooring bow line (deck cleat; dinghies: bow eye)
      "moorStern"   mooring stern line (deck cleat)
      "moorFwd"     port / starboard layout: forward side cleat
      "moorAft"     port / starboard layout: aft side cleat
      Mooring points are set on the starboard side; port is the mirror image.
    [boat, name, side] - side (1 / -1) only matters for the mooring points.
*/
params [["_boat", objNull, [objNull]], ["_name", "", [""]], ["_side", 1, [0]]];
// points saved for THIS boat only (attachment point editor, "This boat only") come first - kept on the boat itself,
// shared with everyone, nothing to ask the server; then the points saved for all boats of its type; then the
// automatic ones.
private _own = (_boat getVariable ["ANC_boatPoints", []]) select {(_x select 0) isEqualTo _name};
private _saved = (missionNamespace getVariable ["ANC_pointOverrides", createHashMap]) getOrDefault [typeOf _boat, createHashMap];
private _p = if (_own isNotEqualTo []) then {(_own select 0) select 1} else {_saved getOrDefault [_name, []]};
// Saved "for all boats" on another class built on the SAME MODEL (another variant, or the other side's version):
// those points apply too - one model, one set of fittings.
if (count _p != 3 && {_own isEqualTo []}) then {
    if (isNil "ANC_modelOf") then {ANC_modelOf = createHashMap};
    private _mk = {
        params ["_c"];
        private _m = ANC_modelOf getOrDefault [_c, "?"];
        if (_m isEqualTo "?") then {
            _m = toLower (getText (configFile >> "CfgVehicles" >> _c >> "model"));
            if ((_m select [0, 1]) isEqualTo "\") then {_m = _m select [1]};
            if ((count _m) > 4 && {(_m select [(count _m) - 4]) isEqualTo ".p3d"}) then {_m = _m select [0, (count _m) - 4]};
            ANC_modelOf set [_c, _m];
        };
        _m
    };
    private _mine = [typeOf _boat] call _mk;
    if (_mine != "") then {
        {
            if (count _p != 3 && {_name in _y} && {([_x] call _mk) isEqualTo _mine}) then {_p = _y get _name};
        } forEach (missionNamespace getVariable ["ANC_pointOverrides", createHashMap]);
    };
};
if (count _p == 3) exitWith {
    if ((_name in ["moorBow", "moorStern", "moorFwd", "moorAft"]) && {_side < 0}) then {[-(_p select 0), _p select 1, _p select 2]} else {_p}
};

private _isBoat = _boat isKindOf "Ship" || {_boat call ANC_fnc_isSubmersible};
switch (_name) do {
    case "anchorBow": {
        private _known = switch (true) do {
            case (_boat isKindOf "Boat_Armed_01_Base_F"):     {_boat selectionPosition "slingLoadCargo1"};
            case (_boat isKindOf "ASH_MKVSOC"):               {[-0.15, 10.6, -1.2]};
            case (_boat isKindOf "Boat_Transport_02_base_F"): {[0, 2.74, 0.2]};
            case (_boat isKindOf "sab_Boat_01_base_F"):       {[0, 3.35, -4.5]};
            default {[]};
        };
        if ((count _known == 3) && {!((typeOf _boat) in ["D41_Trawler", "TxT_LCS1"])}) then {_known} else {[_boat, false] call ANC_fnc_hullPoint}
    };
    case "anchorStern": {[_boat, true] call ANC_fnc_hullPoint};
    // Mooring cleats: on deck just inside the rail, about 10 % in from the bow / stern (at least 0.6 m). Dinghies:
    // the bow eye at the stem.
    case "moorBow": {
        if (_boat call ANC_fnc_isDinghy) then {[_boat, false] call ANC_fnc_hullPoint} else {
            (_boat call ANC_fnc_boatGeometry) params ["", "", "_bowY", "", "", "", "_length"];
            [_boat, _bowY - ((_length * 0.1) max 0.6), _side] call ANC_fnc_deckPoint
        }
    };
    // Port / starboard layout: side cleats on deck, about 30 % in from the bow and from the stern (on the side facing
    // the dock).
    case "moorFwd": {
        (_boat call ANC_fnc_boatGeometry) params ["", "", "_bowY", "", "", "", "_length"];
        [_boat, _bowY - ((_length * 0.3) max 0.8), _side] call ANC_fnc_deckPoint
    };
    case "moorAft": {
        (_boat call ANC_fnc_boatGeometry) params ["", "_sternY", "", "", "", "", "_length"];
        [_boat, _sternY + ((_length * 0.3) max 0.8), _side] call ANC_fnc_deckPoint
    };
    case "moorStern": {
        (_boat call ANC_fnc_boatGeometry) params ["", "_sternY", "", "", "", "", "_length"];
        [_boat, _sternY + ((_length * 0.1) max 0.6), _side] call ANC_fnc_deckPoint
    };
    case "towBow";
    case "towStern": {
        private _stern = _name isEqualTo "towStern";
        // Inflatables: the towing eye on the end of the (starboard) side tube - not the middle of the transom, where
        // the outboard is mounted.
        if (_stern && {_isBoat} && {_boat call ANC_fnc_isDinghy}) exitWith {
            (_boat call ANC_fnc_boatGeometry) params ["_cx", "_sternY", "", "_halfW"];
            private _y = _sternY + 0.25;
            private _rail = [_boat, _y, 1] call ANC_fnc_hullSidePoint;
            [_cx + (((_rail select 0) - _cx) * 0.75), _y, (_rail select 2) - 0.05]
        };
        if (_isBoat) then {[_boat, _stern] call ANC_fnc_hullPoint} else {
            (boundingBoxReal _boat) params ["_bbMin", "_bbMax"];
            [((_bbMin select 0) + (_bbMax select 0)) / 2, [_bbMax select 1, _bbMin select 1] select _stern, (_bbMin select 2) + (((_bbMax select 2) - (_bbMin select 2)) / 3)]
        }
    };
    default {[0, 0, 0]};
};
