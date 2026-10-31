params [["_group", grpNull, [grpNull]], ["_pos", [], [[]]]];
if (isNull _group || {count _pos < 2}) exitWith {false};
private _side = side _group;
private _p = [_pos select 0, _pos select 1, 0];
if (((_p nearEntities [["CAManBase", "LandVehicle", "Ship"], 150]) findIf {alive _x && {((side group _x) isEqualTo _side) || {(side _x) isEqualTo _side}}}) >= 0) exitWith {false};
if (((missionNamespace getVariable ["MCC_MWObjectiveItems", []]) findIf {!isNull _x && {alive _x} && {(_x distance2D _p) < 250}}) >= 0) exitWith {false};
((_p nearEntities [["CAManBase", "LandVehicle", "Ship"], 120]) findIf {
	alive _x && {((side _x) getFriend _side) < 0.6} && {!((vehicle _x) isKindOf "Air") || {isTouchingGround (vehicle _x)}}
}) >= 0
