params [["_fac", "", [""]], ["_side", west, [west]]];
if (isNil "MCC_haloGearCache") then {MCC_haloGearCache = createHashMap};
private _key = format ["%1|%2", _fac, _side];
if (_key in MCC_haloGearCache) exitWith {MCC_haloGearCache get _key};
private _fnc_kit = {
	params ["_f"];
	private _best = [];
	private _bs = 0;
	{
		private _n = toLower (configName _x + " " + getText (_x >> "displayName"));
		private _s = switch (true) do {
			case ((_n find "uav") >= 0): {0};
			case ((_n find "helipilot") >= 0 || {(_n find "heli pilot") >= 0} || {(_n find "helicopter pilot") >= 0}): {2};
			case ((_n find "pilot") >= 0): {1};
			default {0};
		};
		if (_s > _bs) then {
			private _u = getText (_x >> "uniformClass");
			if (_u != "" && {isClass (configFile >> "CfgWeapons" >> _u)}) then {
				private _h = ((getArray (_x >> "linkedItems")) select {getNumber (configFile >> "CfgWeapons" >> _x >> "ItemInfo" >> "type") == 605}) param [0, ""];
				_best = [_h, _u, configName _x];
				_bs = _s;
			};
		};
		if (_bs == 2) exitWith {};
	} forEach ("getNumber (_x >> 'scope') == 2 && {getText (_x >> 'faction') == _f} && {(configName _x) isKindOf 'CAManBase'}" configClasses (configFile >> "CfgVehicles"));
	_best
};
private _kit = [_fac] call _fnc_kit;
if (_kit isEqualTo []) then {
	{
		_kit = [_x] call _fnc_kit;
		if !(_kit isEqualTo []) exitWith {};
	} forEach (([_fac] call MCC_fnc_factionSiblings) - [_fac]);
};
private _si = ([west, east, resistance] find _side) max 0;
private _dh = ["H_CrewHelmetHeli_B", "H_CrewHelmetHeli_O", "H_CrewHelmetHeli_I"] select _si;
private _du = ["U_B_HeliPilotCoveralls", "U_O_PilotCoveralls", "U_I_HeliPilotCoveralls"] select _si;
if !(isClass (configFile >> "CfgWeapons" >> _dh)) then {_dh = "H_CrewHelmetHeli_B"};
if !(isClass (configFile >> "CfgWeapons" >> _du)) then {_du = "U_B_HeliPilotCoveralls"};
private _res = if (_kit isEqualTo []) then {[_dh, _du, "side default"]} else {
	_kit params ["_h", "_u", "_src"];
	if (_h == "" || {!isClass (configFile >> "CfgWeapons" >> _h)}) then {_h = _dh};
	[_h, _u, _src]
};
["INFO", "paradrop", "HALO gear for %1: %2 (uniform %3, helmet %4)", [_fac, _res select 2, _res select 1, _res select 0]] call MCC_fnc_log;
MCC_haloGearCache set [_key, _res];
_res
