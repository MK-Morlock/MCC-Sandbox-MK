params [["_uav", objNull, [objNull]]];
private _w = "autocannon_40mm_VTOL_01";
private _type = (missionNamespace getVariable ["MCC_acAmmoType40", 0]) max 0 min 1;
private _label = ["HE", "AP"] select _type;
private _muzzles = (getArray (configFile >> "CfgWeapons" >> _w >> "muzzles")) select {_x != "this"};
private _ap = _muzzles select {((toLower _x) find "ap") >= 0};
private _he = _muzzles - _ap;
if (count _muzzles >= 2 && {count _ap == 0 || {count _he == 0}}) then {_he = [_muzzles select 0]; _ap = [_muzzles select 1]};
private _muz = if (_type == 0) then {_he param [0, _w]} else {_ap param [0, _w]};
private _rounds = 0;
if (alive _uav) then {
	private _path = (allTurrets [_uav, false]) select {_w in (_uav weaponsTurret _x)};
	if (count _path > 0) then {
		{
			_x params ["_mag", "_p", "_n"];
			if (_p isEqualTo (_path select 0)) then {
				private _isAP = ((toLower (getText (configFile >> "CfgMagazines" >> _mag >> "ammo"))) find "apfsds") >= 0 || {((toLower _mag) find "apfsds") >= 0};
				if ((_type == 1) isEqualTo _isAP) then {_rounds = _rounds + _n};
			};
		} forEach (magazinesAllTurrets _uav);
	};
	if !(_uav getVariable ["MCC_muzzlesLogged", false]) then {
		_uav setVariable ["MCC_muzzlesLogged", true];
		["DEBUG", "console", "AC-130 40mm muzzles %1: HE = %2, AP = %3", [_muzzles, _he, _ap]] call MCC_fnc_log;
	};
};
[_muz, _label, _rounds]
