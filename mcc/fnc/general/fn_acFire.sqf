params [["_uav", objNull, [objNull]], ["_weapon", "", [""]]];
if (!alive _uav) exitWith {false};
([_uav, _weapon] call MCC_fnc_acGun) params ["_u", "_m", "_cfgMode"];
if (isNull _u) exitWith {["DEBUG", "console", "AC-130: no gunner found for %1", [_weapon]] call MCC_fnc_log; false};
private _known = _uav getVariable [format ["MCC_fireMode_%1_%2", _weapon, _m], ""];
private _tries = if (_known != "") then {[_known]} else {
	private _c = (getArray (configFile >> "CfgWeapons" >> _weapon >> "modes")) + (getArray (configFile >> "CfgWeapons" >> _weapon >> _m >> "modes"));
	_c = _c select {_x != "this"};
	_c = _c + [_cfgMode, "medium", "close", "short", "far", "manual", "player", "Burst", "Single", "FullAuto", _m, _weapon];
	_c arrayIntersect _c
};
private _ok = false;
{
	private _before = _uav getVariable ["MCC_firedCount", 0];
	_u forceWeaponFire [_m, _x];
	private _t = time + 0.3;
	waitUntil {sleep 0.02; (_uav getVariable ["MCC_firedCount", 0]) > _before || {time > _t}};
	if ((_uav getVariable ["MCC_firedCount", 0]) > _before) exitWith {
		_ok = true;
		if (_known == "") then {
			_uav setVariable [format ["MCC_fireMode_%1_%2", _weapon, _m], _x];
			["DEBUG", "console", "AC-130: %1 (muzzle %2) fires with mode '%3'", [_weapon, _m, _x]] call MCC_fnc_log;
		};
	};
} forEach _tries;
if (!_ok) then {["DEBUG", "console", "AC-130: %1 did not fire with any mode of %2", [_weapon, _tries]] call MCC_fnc_log};
_ok
