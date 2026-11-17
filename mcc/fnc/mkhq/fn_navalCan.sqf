params [["_u", objNull, [objNull]]];
if (isNull _u || {!alive _u}) exitWith {false};
private _side = side group _u;
if !((((missionNamespace getVariable ["MCC_server", objNull]) getVariable [format ["CP_commander%1", _side], ""]) == getPlayerUID _u) || {leader group _u == _u}) exitWith {false};
((missionNamespace getVariable ["MCC_staticShips", []]) findIf {
	!isNull _x && {(_x getVariable ["MCC_side", sideUnknown]) isEqualTo _side} && {private _s = _x; ((_s getVariable ["MCCMK_weapons", []]) findIf {!isNull _x && {alive _x} && {((typeOf _x) isEqualTo "B_Ship_Gun_01_F" && {_s getVariable ["MCCMK_navalGuns", false]}) || {(typeOf _x) isEqualTo "B_Ship_MRLS_01_F" && {_s getVariable ["MCCMK_navalVLS", false]}}}}) >= 0}
}) >= 0
