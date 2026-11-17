params [["_faction", "", [""]], ["_side", west, [west]], ["_minSpaces", 1, [0]]];
private _types = [];
{
	private _f = _x;
	_types = [_f, "helicopterrtd", "air"] call MCC_fnc_makeUnitsArray;
	if (count _types < 2) then {_types = [_f, "helicopterrtd"] call MCC_fnc_makeUnitsArray};
	_types = _types + ([_f, "helicopterX"] call MCC_fnc_makeUnitsArray);
	if ((_types findIf {([_x select 0, "allCargo"] call MCC_fnc_crewCount) >= _minSpaces}) >= 0) exitWith {};
} forEach ([_faction] + ([_faction] call MCC_fnc_factionSiblings));
private _fit = [];
{
	private _n = [_x select 0, "allCargo"] call MCC_fnc_crewCount;
	if (_n >= _minSpaces) then {_fit pushBack [_n, _x select 0]};
} forEach _types;
if (count _fit > 0) exitWith {_fit sort true; (_fit select 0) select 1};
switch (true) do {
	case (_side == east && {isClass (configFile >> "CfgVehicles" >> "O_T_VTOL_02_infantry_F")}): {"O_T_VTOL_02_infantry_F"};
	case (_side == west && {isClass (configFile >> "CfgVehicles" >> "B_T_VTOL_01_infantry_F")}): {"B_T_VTOL_01_infantry_F"};
	default {"I_Heli_Transport_02_F"};
}
