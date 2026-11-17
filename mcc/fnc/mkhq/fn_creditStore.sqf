params [["_uid", "", [""]], ["_name", "", [""]], ["_val", 50, [0]]];
if (!isServer || {_uid == ""}) exitWith {};
if (isNil "MCCMK_creditMap") then {MCCMK_creditMap = createHashMap};
MCCMK_creditMap set [_uid, [_val, _name]];
//(MK) kept only where this campaign (or this mission's saving) keeps it - not kept, it lives for this session only
private _key = missionNamespace getVariable ["MCCMK_creditKey", ""];
if (_key != "") then {[format ["%1_MCCMK_credits", _key], [_uid, _name], _val, "SCALAR"] call MCC_fnc_setVariable};
