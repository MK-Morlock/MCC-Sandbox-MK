params [["_u", objNull, [objNull]]];
([_u] call MCCMK_fnc_boardState) params ["_st", "_on"];
if (_st != "deck") exitWith {objNull};
private _side = side group _u;
private _best = objNull;
private _bd = 1e9;
{
	private _s = _x;
	if (!isNull _s && {_s != _on} && {(_s getVariable ["MCC_ShipType", 0]) != 2} && {(_s getVariable ["MCC_side", sideUnknown]) isEqualTo _side}) then {
		private _half = (([_s getVariable ["MCC_ShipType", 0]] call MCCMK_fnc_shipCfg) select 3);
		private _m = _s worldToModel (ASLToAGL (getPosASL _u));
		if ((abs (_m select 0)) <= (_half select 0) + 30 && {(abs (_m select 1)) <= (_half select 1) + 30}) then {
			private _d = _u distance2D _s;
			if (_d < _bd) then {_bd = _d; _best = _s};
		};
	};
} forEach (missionNamespace getVariable ["MCC_staticShips", []]);
_best
