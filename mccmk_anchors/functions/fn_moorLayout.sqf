/*
    ANC_fnc_moorLayout
    Which mooring points a boat type uses, chosen in the attachment point editor (L key) and saved per boat type with
    the other points:
      "ends" - bow and stern lines (default): moorBow and moorStern "sides" - port / starboard side cleats, one
      towards the bow and one towards
                the stern: moorFwd and moorAft (on the side facing the dock)
    [boat or class name]
*/
params ["_b"];
// a layout saved for this boat only comes first
if (_b isEqualType objNull && {((_b getVariable ["ANC_boatPoints", []]) findIf {(_x select 0) isEqualTo "moorLayout"}) >= 0}) exitWith {
    private _v = (((_b getVariable ["ANC_boatPoints", []]) select {(_x select 0) isEqualTo "moorLayout"}) select 0) select 1;
    if (count _v == 3 && {(_v select 0) == 1}) then {"sides"} else {"ends"}
};
private _class = if (_b isEqualType objNull) then {typeOf _b} else {_b};
private _forClass = (missionNamespace getVariable ["ANC_pointOverrides", createHashMap]) getOrDefault [_class, createHashMap];
private _v = _forClass getOrDefault ["moorLayout", []];
if (count _v == 3 && {(_v select 0) == 1}) then {"sides"} else {"ends"}
