params [["_plane", objNull, [objNull]], ["_kind", "bomb", [""]], ["_targets", [], [[]]], ["_count", 1, [0]], ["_gap", 0.5, [0]], ["_share", 0, [0]]];
//(MK) _share (0-1): fire that share of ALL the kind the aircraft carries (the strike line's strength: 1/4 .. all) instead
// of _count; every weapon of the kind is used, one after another (pylons with different loads are different weapons)
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
private _guns = [];	// [unit, weapon, mode, rounds, turret]
{
	_x params ["_mag", "_path", "_cnt"];
	if (_cnt > 0) then {
		private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
		if (([_ammo] call _fnc_kind) == _kind) then {
			private _w = getText (configFile >> "CfgMagazines" >> _mag >> "pylonWeapon");
			if (_w == "") then {_w = ((_plane weaponsTurret _path) select {_mag in (getArray (configFile >> "CfgWeapons" >> _x >> "magazines"))}) param [0, ""]};
			if (_w != "") then {
				private _gi = _guns findIf {((_x select 1) == _w) && {(_x select 4) isEqualTo _path}};
				if (_gi >= 0) then {(_guns select _gi) set [3, ((_guns select _gi) select 3) + _cnt]} else {
					private _u = if (_path isEqualTo [-1]) then {driver _plane} else {_plane turretUnit _path};
					private _m = (getArray (configFile >> "CfgWeapons" >> _w >> "modes")) param [0, "this"];
					if (_m == "this") then {_m = _w};
					_guns pushBack [_u, _w, _m, _cnt, _path];
				};
			};
		};
	};
} forEach (magazinesAllTurrets _plane);
if (count _guns == 0) exitWith {["DEBUG", "cas", "%1 has no loaded %2 weapon: no shots", [typeOf _plane, _kind]] call MCC_fnc_log; false};
private _total = 0;
{_total = _total + (_x select 3)} forEach _guns;
if (_share > 0) then {
	_count = (ceil (_total * _share)) max 1;
	_gap = (_gap min (3 / _count)) max 0.06;	// a big salvo released within about 3 s, so it lands on the cross
};
["DEBUG", "cas", "%1 fires its own %2 (%3) x%4 of %5 carried", [typeOf _plane, (_guns apply {_x select 1}) joinString ", ", _kind, _count, _total]] call MCC_fnc_log;
private _gi = 0;
private _left = (_guns select 0) select 3;
for "_i" from 0 to (_count - 1) do {
	if (!alive _plane) exitWith {};
	if (_left <= 0) then {_gi = _gi + 1; _left = if (_gi < count _guns) then {(_guns select _gi) select 3} else {0}};
	if (_gi >= count _guns) exitWith {};
	(_guns select _gi) params ["_u", "_w", "_m"];
	_left = _left - 1;
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
