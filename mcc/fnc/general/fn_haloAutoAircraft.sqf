params [["_faction", "", [""]], ["_side", west, [west]], ["_need", 1, [0]]];
private _key = format ["%1|%2|%3", _faction, _side, _need];
private _cache = missionNamespace getVariable ["MCC_haloAutoCache", createHashMap];
if (_key in _cache) exitWith {_cache get _key};
private _sideN = [east, west, independent, civilian] find _side;
private _natl = [["_TKA"], ["USMC", "USAF", "_US"], ["_AAF", "_RACS"], []] param [_sideN max 0, []];
private _fam = toUpper ((_faction splitString "_") param [0, "#"]);
private _best = "";
private _bs = -1;
{
	private _c = configName _x;
	private _seats = [_c, "allCargo"] call MCC_fnc_crewCount;
	if (_seats >= _need) then {
		private _uc = toUpper _c;
		private _fc = getText (_x >> "faction");
		private _sc = ([0, 100] select ((_uc find "C130") >= 0)) + ([0, 15] select ((_uc find "C130") >= 0 && {(_uc find "CUP_") == 0}))
			+ ([0, 40] select (_fc == _faction)) + ([0, 20] select (_fc != _faction && {(toUpper ((_fc splitString "_") param [0, ""])) == _fam}))
			+ ([0, 10] select (getNumber (_x >> "side") == _sideN))
			+ ([0, 5] select ((_natl findIf {(_uc find _x) >= 0}) >= 0)) + ([0, 2] select ((_uc find (_natl param [0, "#"])) >= 0))
			+ ((_seats min 40) / 100);
		if (_sc > _bs) then {_bs = _sc; _best = _c};
	};
} forEach ("getNumber (_x >> 'scope') == 2 && {(configName _x) isKindOf 'Plane'}" configClasses (configFile >> "CfgVehicles"));
_cache set [_key, _best];
missionNamespace setVariable ["MCC_haloAutoCache", _cache];
_best
