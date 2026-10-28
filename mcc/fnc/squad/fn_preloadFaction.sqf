params [["_fac", "", [""]]];
if (_fac == "") exitWith {};
private _done = missionNamespace getVariable ["MCCMK_preloaded", []];
if ((toUpper _fac) in _done) exitWith {};
_done pushBack (toUpper _fac);
missionNamespace setVariable ["MCCMK_preloaded", _done];
private _classes = [_fac] call MCCMK_fnc_factionVehicles;
private _n = 0;
{
	[_x] call MCCMK_fnc_vehicleProfile;
	_n = _n + 1;
	if (_n % 2 == 0) then {sleep 0.01};
} forEach _classes;
