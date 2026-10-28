params [["_plane", objNull, [objNull]], ["_kind", "bomb", [""]], ["_targets", [], [[]]], ["_count", 1, [0]], ["_gap", 0.5, [0]]];
if (!alive _plane) exitWith {false};
private _fnc_kind = {
	params ["_ammo"];
	private _cfg = configFile >> "CfgAmmo" >> _ammo;
	private _sim = toLower (getText (_cfg >> "simulation"));
	switch (true) do {
		case (_ammo isKindOf ["BombCore", configFile >> "CfgAmmo"]): {"bomb"};
		case (_ammo isKindOf ["RocketCore", configFile >> "CfgAmmo"] || {_sim == "shotrocket"}): {"rocket"};
		case (_ammo isKindOf ["MissileCore", configFile >> "CfgAmmo"] || {_sim == "shotmissile"}): {
			private _lock = getNumber (_cfg >> "airLock");
			if (_lock >= 2) then {"aam"} else {if (_lock == 1 && {_kind in ["agm", "aam"]}) then {_kind} else {"agm"}}
		};
		default {""};
	};
};
private _gun = [];
{
	_x params ["_mag", "_path", "_cnt"];
	if (_cnt > 0 && {count _gun == 0}) then {
		private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
		if (([_ammo] call _fnc_kind) == _kind) then {
			private _w = getText (configFile >> "CfgMagazines" >> _mag >> "pylonWeapon");
			if (_w == "") then {_w = ((_plane weaponsTurret _path) select {_mag in (getArray (configFile >> "CfgWeapons" >> _x >> "magazines"))}) param [0, ""]};
			if (_w != "") then {
				private _u = if (_path isEqualTo [-1]) then {driver _plane} else {_plane turretUnit _path};
				private _m = (getArray (configFile >> "CfgWeapons" >> _w >> "modes")) param [0, "this"];
				if (_m == "this") then {_m = _w};
				_gun = [_u, _w, _m];
			};
		};
	};
} forEach (magazinesAllTurrets _plane);
if (count _gun == 0) exitWith {["DEBUG", "cas", "%1 has no loaded %2 weapon: no shots", [typeOf _plane, _kind]] call MCC_fnc_log; false};
_gun params ["_u", "_w", "_m"];
["DEBUG", "cas", "%1 fires its own %2 (%3) x%4", [typeOf _plane, _w, _kind, _count]] call MCC_fnc_log;
for "_i" from 0 to (_count - 1) do {
	if (!alive _plane) exitWith {};
	private _t = if (count _targets > 0) then {_targets select (_i mod (count _targets))} else {objNull};
	if (_t isEqualType objNull && {!isNull _t}) then {
		_u reveal [_t, 4];
		_u doTarget _t;
		if !(_u fireAtTarget [_t, _w]) then {_u forceWeaponFire [_w, _m]};
	} else {
		_u forceWeaponFire [_w, _m];
	};
	sleep _gap;
};
true
