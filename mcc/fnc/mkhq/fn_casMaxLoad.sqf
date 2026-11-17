/*
	MCCMK_fnc_casMaxLoad - a strike aircraft (bombing run / rocket run) armed for the most air-to-ground it can carry:
	every pylon that takes the kind ("bomb" / "rocket") gets the load of it with the MOST in it (a multi-bomb rack, a
	19-rocket pod); a rocket run on an aircraft that can't take rockets gets guided missiles instead. Pylons that take none
	keep what they had; an aircraft without pylons keeps its own weapons. The total loaded is kept on the aircraft
	(MCCMK_casLoad) - the line's strength fires a share of it (MCC_fnc_casRealFire). [aircraft, kind] -> the kind loaded
*/
params [["_v", objNull, [objNull]], ["_kind", "bomb", [""]]];
if (isNull _v) exitWith {""};
private _pyl = "true" configClasses (configOf _v >> "Components" >> "TransportPylonsComponent" >> "pylons");
if (_pyl isEqualTo []) exitWith {""};
private _kindOf = {	// as MCC_fnc_casRealFire tells them apart
	params ["_mag"];
	private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
	private _cfg = configFile >> "CfgAmmo" >> _ammo;
	private _sim = toLower (getText (_cfg >> "simulation"));
	switch (true) do {
		case (_ammo isKindOf ["BombCore", configFile >> "CfgAmmo"]): {"bomb"};
		case (_ammo isKindOf ["RocketCore", configFile >> "CfgAmmo"] || {_sim == "shotrocket"}): {"rocket"};
		case (_ammo isKindOf ["MissileCore", configFile >> "CfgAmmo"] || {_sim == "shotmissile"}): {["agm", "aam"] select ((getNumber (_cfg >> "airLock")) >= 2)};
		default {""};
	};
};
private _picks = {	// [pylon, magazine] for every pylon that takes the kind - the one holding the most
	params ["_k"];
	private _out = [];
	{
		private _i = _forEachIndex + 1;
		private _best = "";
		private _bc = -1;
		{
			if (([_x] call _kindOf) == _k) then {
				private _c = getNumber (configFile >> "CfgMagazines" >> _x >> "count");
				if (_c > _bc) then {_bc = _c; _best = _x};
			};
		} forEach (_v getCompatiblePylonMagazines _i);
		if (_best != "") then {_out pushBack [_i, _best, _bc, getArray (_x >> "turret")]};
	} forEach _pyl;
	_out
};
private _k = _kind;
private _list = [_k] call _picks;
if (_list isEqualTo [] && {_kind == "rocket"}) then {_k = "agm"; _list = [_k] call _picks};
if (_list isEqualTo []) exitWith {""};
private _total = 0;
{
	_x params ["_i", "_mag", "_c", "_tur"];
	_v setPylonLoadout [_i, _mag, true, [[-1], _tur] select (_tur isNotEqualTo [])];
	_total = _total + _c;
} forEach _list;
_v setVariable ["MCCMK_casLoad", _total];
["INFO", "cas", "%1 armed for a %2: %3 on %4 pylon(s) - %5 in all", [typeOf _v, ["bombing run", "rocket run"] select (_kind == "rocket"), _k, count _list, _total]] call MCC_fnc_log;
_k
