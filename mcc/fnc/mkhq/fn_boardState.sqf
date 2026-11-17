params [["_u", objNull, [objNull]]];
private _ships = (missionNamespace getVariable ["MCC_staticShips", []]) select {!isNull _x && {(_x getVariable ["MCC_ShipType", 0]) != 2}};
if (isNull _u || {_ships isEqualTo []} || {!alive _u}) exitWith {["", objNull]};
private _res = ["", objNull];
{
	private _s = _x;
	private _half = (([_s getVariable ["MCC_ShipType", 0]] call MCCMK_fnc_shipCfg) select 3);
	private _m = _s worldToModel (ASLToAGL (getPosASL _u));
	private _ax = abs (_m select 0);
	private _ay = abs (_m select 1);
	private _v = vehicle _u;
	if (_ax <= (_half select 0) && {_ay <= (_half select 1)} && {_v == _u} && {((getPosASL _u) select 2) > 3}) exitWith {_res = ["deck", _s]};
	if (_ax <= (_half select 0) + 25 && {_ay <= (_half select 1) + 25}) then {
		private _inBoat = _v != _u && {!(_v isKindOf "Air")} && {!(_v getVariable ["MCC_isLHD", false])} && {surfaceIsWater (getPos _v)} && {((getPosASL _v) select 2) < 3} && {(abs (speed _v)) < 6};
		private _swim = _v == _u && {surfaceIsWater (getPos _u)} && {((getPosASL _u) select 2) < 3};
		if (_inBoat || _swim) exitWith {_res = ["climb", _s]};
	};
	if ((_res select 0) != "") exitWith {};
} forEach _ships;
_res
