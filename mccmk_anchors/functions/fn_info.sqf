/*
    ANC_fnc_info
    Returns [mode, attachPoint, maxLength, rodeType, kind] for a boat.
      mode: "anchor", "kedge" or "" (no anchor for this boat)
      kind: "anchor" or "kedge" (dinghies anchor like any other boat; the
            grapnel is only used for towing - ANC_fnc_towDeploy)
    Standard boats use known attach points; any other boat or ship gets one at the outside of the stem (or the
    transom, per setting), a little above the waterline, like a bow roller. Landing craft use the transom.
*/
params [["_boat", objNull, [objNull]]];
private _none = ["", [0, 0, 0], 0, "", ""];
if (isNull _boat || {!(_boat isKindOf "Ship")}) exitWith {_none};
if ((toLower getText (configOf _boat >> "simulation")) isEqualTo "submarinex") exitWith {_none};

// Standard boats always get an anchor (point from ANC_fnc_pointFor).
private _standard = (["Rubber_duck_base_F", "Boat_Armed_01_Base_F", "Boat_Civil_01_Base_F", "ASH_MKVSOC", "rhsusf_mkvsoc", "Boat_Transport_02_base_F", "sab_Boat_01_base_F"] findIf {_boat isKindOf _x}) != -1
    && {!((typeOf _boat) in ["D41_Trawler", "TxT_LCS1"])};
if (_standard) exitWith {
    (_boat call ANC_fnc_rodeInfo) params ["_rode", "_max"];
    ["anchor", [_boat, "anchorBow"] call ANC_fnc_pointFor, _max, _rode, "anchor"]
};

if ((missionNamespace getVariable ["ANC_boats", 1]) != 1) exitWith {_none};

(_boat call ANC_fnc_boatGeometry) params ["_cx", "_sternY", "_bowY", "_halfW", "_bottomZ", "_topZ", "_length", "_zWater"];
// Where the rope leaves the hull: top of the stem / transom, or an adjusted point (ANC_fnc_pointFor).
private _bowPoint = [_boat, "anchorBow"] call ANC_fnc_pointFor;
private _sternPoint = [_boat, "anchorStern"] call ANC_fnc_pointFor;

if ((missionNamespace getVariable ["ANC_kedge", true]) && {_boat call ANC_fnc_isLandingCraft}) exitWith {
    ([_boat, true] call ANC_fnc_rodeInfo) params ["_rode", "_max"];
    ["kedge", _sternPoint, _max, _rode, "kedge"]
};

(_boat call ANC_fnc_rodeInfo) params ["_rode", "_max"];
private _useStern = (missionNamespace getVariable ["ANC_anchorEnd", 0]) == 1;
["anchor", [_bowPoint, _sternPoint] select _useStern, _max, _rode, "anchor"]
