params [["_uid", "", [""]], ["_name", "", [""]]];
if (isNil "MCCMK_creditMap") then {MCCMK_creditMap = createHashMap};
if (_uid in MCCMK_creditMap) exitWith {(MCCMK_creditMap get _uid) select 0};
//(MK) read from where this campaign (or this mission's saving) keeps it; not kept: nothing to read (starts at 50)
private _key = missionNamespace getVariable ["MCCMK_creditKey", ""];
if (_key == "") exitWith {-1};
private _v = [_name, _uid, format ["%1_MCCMK_credits", _key], "read", -1, true] call MCC_fnc_handleDB;
if !(_v isEqualType 0) then {_v = -1};
if (_v >= 0) then {MCCMK_creditMap set [_uid, [_v, _name]]};
_v
