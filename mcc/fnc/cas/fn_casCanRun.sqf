params [["_class", "", [""]], ["_casType", 0, [0]]];
private _cfg = configFile >> "CfgVehicles" >> _class;
if (!isClass _cfg) exitWith {false};
private _types = switch (_casType) do {
	case 0: {["machinegun", "cannon", "horn"]};
	case 1: {["missilelauncher", "launcher", "rocketlauncher"]};
	case 2: {["machinegun", "missilelauncher", "cannon", "horn", "rocketlauncher"]};
	case 3: {["bomblauncher"]};
	default {[]};
};
private _w = +(getArray (_cfg >> "weapons"));
private _fnc_turrets = {
	params ["_c"];
	{
		if (getNumber (_x >> "isPersonTurret") == 0 && {getNumber (_x >> "minTurn") <= 0} && {getNumber (_x >> "maxTurn") >= 0}) then {_w append getArray (_x >> "weapons")};
		[_x] call _fnc_turrets;
	} forEach ("true" configClasses (_c >> "Turrets"));
};
[_cfg] call _fnc_turrets;
{
	private _pw = getText (configFile >> "CfgMagazines" >> (getText (_x >> "attachment")) >> "pylonWeapon");
	if (_pw != "") then {_w pushBackUnique _pw};
} forEach ("true" configClasses (_cfg >> "Components" >> "TransportPylonsComponent" >> "Pylons"));
(_w findIf {_x != "" && {(toLower ((_x call BIS_fnc_itemType) select 1)) in _types}}) >= 0
