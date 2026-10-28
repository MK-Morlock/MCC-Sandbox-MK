params [["_class", "", [""]]];
private _all = missionNamespace getVariable ["MCC_CASBombs", []];
private _cfg = configFile >> "CfgVehicles" >> _class;
if (!isClass _cfg) exitWith {_all};

private _cache = missionNamespace getVariable "MCC_casAllowedCache";
if (isNil "_cache") then {_cache = createHashMap; missionNamespace setVariable ["MCC_casAllowedCache", _cache]};
private _cached = _cache get toLower _class;
if (!isNil "_cached") exitWith {_cached};

private _mags = getArray (_cfg >> "magazines");
private _turretMags = [];
{
	_turretMags append getArray (_x >> "magazines");
	{_turretMags append getArray (_x >> "magazines")} forEach ("true" configClasses (_x >> "Turrets"));
} forEach ("true" configClasses (_cfg >> "Turrets"));
{
	_mags pushBack getText (_x >> "attachment");
} forEach ("true" configClasses (_cfg >> "Components" >> "TransportPylonsComponent" >> "Pylons"));

private _kind = {
	params ["_mag"];
	private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
	if (_ammo == "") exitWith {""};
	private _sim = toLower getText (configFile >> "CfgAmmo" >> _ammo >> "simulation");
	switch (true) do {
		case (_ammo isKindOf ["BombCore", configFile >> "CfgAmmo"]): {"bomb"};
		case (_ammo isKindOf ["RocketCore", configFile >> "CfgAmmo"] || {_sim == "shotrocket"}): {"rockets"};
		case (_ammo isKindOf ["MissileCore", configFile >> "CfgAmmo"] || {_sim == "shotmissile"}): {"missile"};
		case (_sim in ["shotbullet", "shotshell"]): {"gun"};
		default {""};
	};
};

private _gun = false; private _rockets = false; private _agm = false; private _aam = false; private _bombs = false;
{
	switch ([_x] call _kind) do {
		case "gun": {_gun = true};
		case "rockets": {_rockets = true};
		case "bomb": {_bombs = true};
		case "missile": {
			private _lock = getNumber (configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _x >> "ammo") >> "airLock");
			if (_lock >= 1) then {_aam = true};
			if (_lock < 2) then {_agm = true};
		};
	};
} forEach ((_mags + _turretMags) select {_x != ""});
private _turretGun = (_turretMags findIf {([_x] call _kind) == "gun"}) >= 0;

private _isPlane = _class isKindOf "Plane";
private _isUav = getNumber (_cfg >> "isUav") == 1;
private _armed = _gun || _rockets || _agm || _aam || _bombs;

private _ok = {
	params ["_t"];
	switch (_t) do {
		case "Gun-run (Direct)": {[_class, 0] call MCC_fnc_casCanRun};
		case "Rockets-run (Direct)": {[_class, 1] call MCC_fnc_casCanRun};
		case "CAS-run (Direct)": {([_class, 0] call MCC_fnc_casCanRun) && {[_class, 1] call MCC_fnc_casCanRun}};
		case "Bombs-run (Direct)": {[_class, 3] call MCC_fnc_casCanRun};
		case "S&D": {_armed};
		case "Rockets-run": {_rockets || _agm};
		case "AT run": {_agm};
		case "AA run": {_aam};
		case "JDAM";
		case "LGB";
		case "Bombing-run": {_bombs && _isPlane};
		case "AC-130": {_isPlane && _turretGun};
		case "UAV";
		case "Controllable": {_isUav};
		case "Cruise Missile": {true};
		default {true};
	};
};
private _result = _all select {[_x] call _ok};
_cache set [toLower _class, _result];
_result
