/*
	MCCMK_fnc_crateAmmoSet - what a broken-down ammo crate holds: a resupply for the soldiers of the breaker's side within
	50 m (the nearest 8), for the weapons they carry. Each: 4 magazines for the main weapon, 1 for the pistol, 2 rounds for
	the launcher, 2 grenades for an under-barrel launcher, 1 hand grenade and 1 smoke grenade - and anyone carrying
	explosives (charges, mines) gets 1 more of each type they carry, up to 2 types. [crate] -> magazine classes
*/
params [["_crate", objNull, [objNull]]];
private _side = side group player;
private _men = (_crate nearEntities ["CAManBase", 50]) select {alive _x && {(side group _x) isEqualTo _side}};
_men = [_men, [], {_x distance _crate}, "ASCEND"] call BIS_fnc_sortBy;
if (count _men > 8) then {_men resize 8};
if (_men isEqualTo []) then {_men = [player]};
private _ok = {params ["_m"]; _m != "" && {isClass (configFile >> "CfgMagazines" >> _m)}};
// a magazine for a weapon's muzzle: the one loaded, else one the soldier carries, else the weapon's first
private _magFor = {
	params ["_u", "_wep", "_muzzle", "_loaded"];
	if (_wep == "") exitWith {""};
	if ([_loaded] call _ok) exitWith {_loaded};
	private _cfg = configFile >> "CfgWeapons" >> _wep;
	if (_muzzle != "this") then {_cfg = _cfg >> _muzzle};
	private _mags = (getArray (_cfg >> "magazines")) apply {toLower _x};
	private _carried = (magazines _u) select {(toLower _x) in _mags};
	if (_carried isNotEqualTo []) exitWith {_carried select 0};
	if (_mags isEqualTo []) exitWith {""};
	_mags select 0
};
private _out = [];
{
	private _u = _x;
	private _pw = primaryWeapon _u;
	private _pm = primaryWeaponMagazine _u;
	private _m = [_u, _pw, "this", _pm param [0, ""]] call _magFor;
	if ([_m] call _ok) then {_out append [_m, _m, _m, _m]};
	// under-barrel grenade launcher
	if (_pw != "") then {
		private _gl = (getArray (configFile >> "CfgWeapons" >> _pw >> "muzzles")) select {_x != "this" && {_x != "SAFE"}};
		if (_gl isNotEqualTo []) then {
			private _g = [_u, _pw, _gl select 0, _pm param [1, ""]] call _magFor;
			if ([_g] call _ok) then {_out append [_g, _g]};
		};
	};
	_m = [_u, handgunWeapon _u, "this", (handgunMagazine _u) param [0, ""]] call _magFor;
	if ([_m] call _ok) then {_out pushBack _m};
	_m = [_u, secondaryWeapon _u, "this", (secondaryWeaponMagazine _u) param [0, ""]] call _magFor;
	if ([_m] call _ok) then {_out append [_m, _m]};
	_out append ["HandGrenade", "SmokeShell"];
	// explosives: placed charges, mines and directional mines the soldier carries
	private _exp = [];
	{
		private _sim = toLower getText (configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _x >> "ammo") >> "simulation");
		if (_sim in ["shotmine", "shotboundingmine", "shotdirectionalbomb"]) then {_exp pushBackUnique _x};
	} forEach (magazines _u);
	if (count _exp > 2) then {_exp resize 2};
	_out append _exp;
} forEach _men;
_out
