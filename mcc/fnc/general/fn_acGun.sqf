params [["_uav", objNull, [objNull]], ["_weapon", "", [""]]];
if (!alive _uav) exitWith {[objNull, _weapon, _weapon]};
private _path = (allTurrets [_uav, false]) select {_weapon in (_uav weaponsTurret _x)};
if (count _path == 0) exitWith {[objNull, _weapon, _weapon]};
private _muzzles = getArray (configFile >> "CfgWeapons" >> _weapon >> "muzzles");
private _gu = _uav turretUnit (_path select 0);
private _m = _muzzles param [0, "this"];
{
	private _nm = if (_x == "this") then {_weapon} else {_x};
	if (!isNull _gu && {(_gu ammo _nm) > 0}) exitWith {_m = _x};
} forEach _muzzles;
if (_weapon == "autocannon_40mm_VTOL_01") then {_m = ([_uav] call MCC_fnc_acAmmoType) select 0};
private _modeCfg = if (_m == "this") then {configFile >> "CfgWeapons" >> _weapon} else {configFile >> "CfgWeapons" >> _weapon >> _m};
if (_m == "this") then {_m = _weapon};
private _mode = (getArray (_modeCfg >> "modes")) param [0, "this"];
if (_mode == "this") then {_mode = _m};
[_uav turretUnit (_path select 0), _m, _mode]
