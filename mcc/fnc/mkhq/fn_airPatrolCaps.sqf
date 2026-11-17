/*
	MCCMK_fnc_airPatrolCaps - what an aircraft can do on an Air Patrol, from the game's own data (kept for the session):
	[can carry air-to-air weapons, can attack the ground, class ("fighter", "ground" jet, "attack" or "light" helicopter,
	"drone"), pylons]. Air-to-air / ground: what its pylons can take (pylon and magazine hardpoints) and its own weapons;
	guns count as ground weapons. Fast: pylons are checked against a table built once. [class]
*/
params [["_class", "", [""]]];
private _cache = missionNamespace getVariable "MCCMK_apCaps";
if (isNil "_cache") then {_cache = createHashMap; missionNamespace setVariable ["MCCMK_apCaps", _cache]};
private _key = toLower _class;
if (_key in _cache) exitWith {_cache get _key};
private _cfg = configFile >> "CfgVehicles" >> _class;
private _kindOf = {
	params ["_mag"];
	private _a = configFile >> "CfgAmmo" >> getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
	private _aa = (getNumber (_a >> "airLock")) >= 2 || {((getNumber (_a >> "aiAmmoUsageFlags")) mod 512) >= 256};
	private _ag = !_aa && {(toLower getText (_a >> "simulation")) in ["shotmissile", "shotrocket", "shotsubmunitions", "shotbullet", "shotshell"]};
	[_aa, _ag]
};
// (MK) every pylon mounting (hardpoint) once, for the session: whether any weapon that fits it is air-to-air, or ground
// - so a pylon is a few lookups
private _hpMap = missionNamespace getVariable "MCCMK_pylonHP";
if (isNil "_hpMap") then {
	_hpMap = createHashMap;
	isNil {	// in one go (a background script would stretch it over many frames)
	{
		private _k = [configName _x] call _kindOf;
		{
			private _h = toLower _x;
			private _e = _hpMap getOrDefault [_h, [false, false]];
			_hpMap set [_h, [(_e select 0) || {_k select 0}, (_e select 1) || {_k select 1}]];
		} forEach getArray (_x >> "hardpoints");
	} forEach ("isArray (_x >> 'hardpoints')" configClasses (configFile >> "CfgMagazines"));
	};
	missionNamespace setVariable ["MCCMK_pylonHP", _hpMap];
};
private _aa = false;
private _ag = false;
private _pylons = "true" configClasses (_cfg >> "Components" >> "TransportPylonsComponent" >> "pylons");
{
	{
		private _e = _hpMap getOrDefault [toLower _x, [false, false]];
		if (_e select 0) then {_aa = true};
		if (_e select 1) then {_ag = true};
	} forEach getArray (_x >> "hardpoints");
} forEach _pylons;
// its own weapons (guns, fixed launchers), the crew's turrets included
private _weps = getArray (_cfg >> "weapons");
{_weps append getArray (_x >> "weapons")} forEach ("true" configClasses (_cfg >> "Turrets"));
{
	private _w = toLower _x;
	if !((_w find "flare") >= 0 || {(_w find "laserdesignator") >= 0} || {(_w find "smoke") >= 0} || {(_w find "cmlauncher") >= 0}) then {
		{
			([_x] call _kindOf) params ["_ma", "_mg"];
			if (_ma) then {_aa = true};
			if (_mg) then {_ag = true};
		} forEach getArray (configFile >> "CfgWeapons" >> _x >> "magazines");
	};
} forEach _weps;
private _type = switch (true) do {
	case (getNumber (_cfg >> "isUav") == 1): {"drone"};
	case (_class isKindOf "Helicopter"): {["light", "attack"] select (count _pylons >= 4 || {getNumber (_cfg >> "armor") >= 50})};
	case (getNumber (_cfg >> "maxSpeed") >= 1100): {"fighter"};
	default {"ground"};
};
private _r = [_aa, _ag, _type, count _pylons];
_cache set [_key, _r];
_r
