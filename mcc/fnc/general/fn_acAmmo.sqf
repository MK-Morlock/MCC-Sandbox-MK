params [["_uav", objNull, [objNull]], ["_weapon", "", [""]]];
if (!alive _uav) exitWith {0};
private _cfg = configFile >> "CfgWeapons" >> _weapon;
private _mags = getArray (_cfg >> "magazines");
private _wells = getArray (_cfg >> "magazineWell");
{
	if (_x != "this") then {
		private _mc = _cfg >> _x;
		_mags append getArray (_mc >> "magazines");
		_wells append getArray (_mc >> "magazineWell");
	};
} forEach getArray (_cfg >> "muzzles");
{
	{_mags append getArray _x} forEach (configProperties [configFile >> "CfgMagazineWells" >> _x, "isArray _x", true]);
} forEach _wells;
private _n = 0;
{
	if ((_x select 0) in _mags) then {_n = _n + (_x select 2)};
} forEach (magazinesAllTurrets _uav);
if (_n == 0) then {
	private _paths = (allTurrets [_uav, false]) select {_weapon in (_uav weaponsTurret _x)};
	if (count _paths > 0 && {count (_uav weaponsTurret (_paths select 0)) == 1}) then {
		private _p = _paths select 0;
		{
			if ((_x select 1) isEqualTo _p) then {_n = _n + (_x select 2)};
		} forEach (magazinesAllTurrets _uav);
	};
};
_n
