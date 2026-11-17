params [["_v", objNull, [objNull]]];
private _types = ["Pod_Heli_Transport_04_crewed_base_F", "Pod_Heli_Transport_04_base_F", "Cargo_base_F", "Slingload_01_Base_F"];
private _i = (ropeAttachedObjects _v) findIf {private _o = _x; (_types findIf {_o isKindOf _x}) >= 0};
if (_i < 0) exitWith {objNull};
(ropeAttachedObjects _v) select _i
