params [["_ship", objNull, [objNull]]];
if (isNull _ship) exitWith {[]};
private _t = _ship getVariable ["MCC_ShipType", 0];
private _pre = ["land_destroyer_01_", "land_carrier_01_", "", "cup_lhd_"] param [_t, ""];
if (_pre == "") exitWith {[]};
(nearestObjects [_ship, [], [260, 400, 0, 300] select _t]) select {((toLower typeOf _x) find _pre) == 0 && {!(_x isKindOf "AllVehicles")}}
