params [["_uav", objNull, [objNull]]];
private _out = ["", 0];
if (!alive _uav) exitWith {_out};
{
	_x params ["_mag", "_path", "_cnt"];
	if (_cnt > 0 && {(_out select 1) == 0}) then {
		private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
		private _bomb = _ammo isKindOf ["BombCore", configFile >> "CfgAmmo"];
		private _missile = _ammo isKindOf ["MissileCore", configFile >> "CfgAmmo"] || {(toLower (getText (configFile >> "CfgAmmo" >> _ammo >> "simulation"))) == "shotmissile"};
		if (_bomb || _missile) then {
			private _w = getText (configFile >> "CfgMagazines" >> _mag >> "pylonWeapon");
			if (_w == "") then {_w = ((_uav weaponsTurret _path) select {_mag in (getArray (configFile >> "CfgWeapons" >> _x >> "magazines"))}) param [0, ""]};
			if (_w != "") then {
				private _unit = if (_path isEqualTo [-1]) then {driver _uav} else {_uav turretUnit _path};
				_out = [["AGM", "BOMB"] select _bomb, _cnt, _w, _ammo, _unit, _path];
			};
		};
	};
} forEach (magazinesAllTurrets _uav);
_out
