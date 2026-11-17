// (MK) The seven Taru pods for the MCC console's spawn list (Singles > Ammo), in the livery set for the chosen side:
// entries as the console's lists use them - [type, class, side name, [display name, picture]]. Free, as everything there.
private _sn = missionNamespace getVariable ["mcc_sidename", west];
private _sd = if (_sn isEqualType west) then {_sn} else {[west, east, resistance, civilian] param [["WEST", "EAST", "GUER", "CIV"] find (toUpper (if (_sn isEqualType "") then {_sn} else {str _sn})), west]};
if !(_sd in [west, east, resistance]) then {_sd = west};
private _out = [];
{
	_x params ["_kind", "_label"];
	private _cls = ([_sd, _kind] call MCCMK_fnc_podClasses) select 1;
	if (isClass (configFile >> "CfgVehicles" >> _cls)) then {
		_out pushBack ["LAND", _cls, _sn, [format ["Taru pod: %1", _label], getText (configFile >> "CfgVehicles" >> _cls >> "picture")]];
	};
} forEach [["medevac", "Medical"], ["repair", "Repair"], ["ammo", "Ammunition"], ["fuel", "Fuel"], ["box", "Logistics"], ["bench", "Bench (8 seats)"], ["covered", "Transport (16 seats)"]];
_out
